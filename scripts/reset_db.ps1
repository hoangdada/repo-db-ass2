param(
    [string]$Server = "",
    [string]$Database = "bk_db_ass2"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function New-SqlConnectionString {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        [Parameter(Mandatory = $true)]
        [string]$DatabaseName,
        [int]$TimeoutSeconds = 15
    )

    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder["Data Source"] = $ServerName
    $builder["Initial Catalog"] = $DatabaseName
    $builder["Integrated Security"] = $true
    $builder["TrustServerCertificate"] = $true
    $builder["Pooling"] = $false
    $builder["Connect Timeout"] = $TimeoutSeconds
    return $builder.ConnectionString
}

function Test-SqlServerInstance {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerName
    )

    $connection = New-Object System.Data.SqlClient.SqlConnection((New-SqlConnectionString -ServerName $ServerName -DatabaseName "master" -TimeoutSeconds 3))
    try {
        $connection.Open()
        return [pscustomobject]@{
            Success = $true
            Error   = ""
        }
    }
    catch {
        $inner = $_.Exception
        while ($inner.InnerException) {
            $inner = $inner.InnerException
        }
        return [pscustomobject]@{
            Success = $false
            Error   = $inner.Message
        }
    }
    finally {
        $connection.Dispose()
    }
}

function Resolve-SqlServerInstance {
    param(
        [string]$RequestedServer
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedServer)) {
        $trimmed = $RequestedServer.Trim()
        $probe = Test-SqlServerInstance -ServerName $trimmed
        if ($probe.Success) {
            return $trimmed
        }

        [Console]::Error.WriteLine("ERROR: Could not connect to SQL Server instance '$trimmed'.")
        [Console]::Error.WriteLine("Detail: $($probe.Error)")
        [Console]::Error.WriteLine("Verify the SQL Server service is running and your Windows account has login permission.")
        exit 1
    }

    $candidates = @("localhost", ".\SQLEXPRESS")
    $failures = @()
    foreach ($candidate in $candidates) {
        $probe = Test-SqlServerInstance -ServerName $candidate
        if ($probe.Success) {
            return $candidate
        }
        $failures += "  - $candidate : $($probe.Error)"
    }

    [Console]::Error.WriteLine("ERROR: No reachable local SQL Server instance found.")
    [Console]::Error.WriteLine("Tried instances:")
    foreach ($failure in $failures) {
        [Console]::Error.WriteLine($failure)
    }
    [Console]::Error.WriteLine("Start your SQL Server service or run: .\reset_db.bat -Server `"<your_instance>`"")
    exit 1
}

function Split-SqlBatches {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SqlContent
    )

    $parts = [System.Text.RegularExpressions.Regex]::Split($SqlContent, '(?im)^\s*GO\s*(?:--.*)?$')
    return @($parts | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-SqlErrorMessage {
    param(
        [Parameter(Mandatory = $true)]
        [System.Exception]$Exception
    )

    $current = $Exception
    while ($current) {
        if ($current -is [System.Data.SqlClient.SqlException]) {
            return $current.Message
        }
        $current = $current.InnerException
    }
    return $Exception.Message
}

if ($Database -notmatch '^[A-Za-z0-9_]+$') {
    [Console]::Error.WriteLine("ERROR: Invalid database name '$Database'. Only ASCII letters, digits, and underscores are allowed.")
    exit 1
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$scripts = @(
    Get-ChildItem -Path $repoRoot -Filter "*.sql" -File |
    Where-Object { $_.Name -match '^[0-9]{2}_.+\.sql$' } |
    Sort-Object Name
)

if ($scripts.Count -eq 0) {
    [Console]::Error.WriteLine("ERROR: No numbered SQL scripts matching '^[0-9]{2}_.+\.sql$' were found in '$repoRoot'.")
    exit 1
}

$totalWatch = [System.Diagnostics.Stopwatch]::StartNew()
$resolvedServer = Resolve-SqlServerInstance -RequestedServer $Server

Write-Host "Server   : $resolvedServer"
Write-Host "Database : $Database"
Write-Host "Scripts  : $($scripts.Count) file(s) in $repoRoot"
Write-Host ""

$execConnection = New-Object System.Data.SqlClient.SqlConnection((New-SqlConnectionString -ServerName $resolvedServer -DatabaseName "master" -TimeoutSeconds 15))
try {
    $execConnection.Open()

    $dropWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $dropCommand = $execConnection.CreateCommand()
    $dropCommand.CommandTimeout = 60
    $dropCommand.CommandText = @"
IF DB_ID(N'$Database') IS NOT NULL
BEGIN
    ALTER DATABASE [$Database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$Database];
    SELECT 1;
END
ELSE
BEGIN
    SELECT 0;
END
"@
    $wasDropped = [int]$dropCommand.ExecuteScalar()
    $dropWatch.Stop()
    if ($wasDropped -eq 1) {
        Write-Host ("[DROP] {0} ({1} ms)" -f $Database, $dropWatch.ElapsedMilliseconds)
    }
    else {
        Write-Host ("[INIT] {0} did not exist ({1} ms)" -f $Database, $dropWatch.ElapsedMilliseconds)
    }

    foreach ($script in $scripts) {
        $sqlContent = [System.IO.File]::ReadAllText($script.FullName, [System.Text.Encoding]::UTF8)
        $batches = if ([string]::IsNullOrWhiteSpace($sqlContent)) { @() } else { Split-SqlBatches -SqlContent $sqlContent }
        if ($batches.Count -eq 0) {
            Write-Host ("[SKIP] {0} (empty)" -f $script.Name)
            continue
        }
        $fileWatch = [System.Diagnostics.Stopwatch]::StartNew()

        for ($i = 0; $i -lt $batches.Count; $i++) {
            $batchNumber = $i + 1
            $batchCommand = $execConnection.CreateCommand()
            $batchCommand.CommandTimeout = 120
            $batchCommand.CommandText = $batches[$i]

            try {
                $null = $batchCommand.ExecuteNonQuery()
            }
            catch [System.Data.SqlClient.SqlException] {
                $errorMessage = Get-SqlErrorMessage -Exception $_.Exception
                [Console]::Error.WriteLine("")
                [Console]::Error.WriteLine("ERROR: SQL execution failed.")
                [Console]::Error.WriteLine("Script : $($script.Name)")
                [Console]::Error.WriteLine("Batch  : $batchNumber")
                [Console]::Error.WriteLine("Message: $errorMessage")
                exit 1
            }
        }

        $fileWatch.Stop()
        Write-Host ("[OK]   {0} ({1} batches, {2} ms)" -f $script.Name, $batches.Count, $fileWatch.ElapsedMilliseconds)
    }
}
catch [System.Data.SqlClient.SqlException] {
    $errorMessage = Get-SqlErrorMessage -Exception $_.Exception
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("ERROR: SQL operation failed.")
    [Console]::Error.WriteLine("Message: $errorMessage")
    exit 1
}
finally {
    $execConnection.Dispose()
}

$tableStats = New-Object System.Collections.Generic.List[object]
$procedureNames = New-Object System.Collections.Generic.List[string]
$triggerNames = New-Object System.Collections.Generic.List[string]
$functionNames = New-Object System.Collections.Generic.List[string]
$verifyConnection = New-Object System.Data.SqlClient.SqlConnection((New-SqlConnectionString -ServerName $resolvedServer -DatabaseName $Database -TimeoutSeconds 15))
try {
    $verifyConnection.Open()
    $verifyCommand = $verifyConnection.CreateCommand()
    $verifyCommand.CommandTimeout = 30
    $verifyCommand.CommandText = @"
SELECT
    t.name AS TableName,
    CAST(SUM(p.rows) AS BIGINT) AS [RowCount]
FROM sys.tables AS t
INNER JOIN sys.partitions AS p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
"@

    $reader = $verifyCommand.ExecuteReader()
    try {
        while ($reader.Read()) {
            $tableStats.Add([pscustomobject]@{
                TableName = $reader.GetString(0)
                RowCount  = $reader.GetInt64(1)
            })
        }
    }
    finally {
        $reader.Dispose()
    }

    $procCommand = $verifyConnection.CreateCommand()
    $procCommand.CommandTimeout = 30
    $procCommand.CommandText = "SELECT name FROM sys.procedures WHERE is_ms_shipped = 0 ORDER BY name;"
    $procReader = $procCommand.ExecuteReader()
    try {
        while ($procReader.Read()) {
            $procedureNames.Add($procReader.GetString(0))
        }
    }
    finally {
        $procReader.Dispose()
    }

    $trigCommand = $verifyConnection.CreateCommand()
    $trigCommand.CommandTimeout = 30
    $trigCommand.CommandText = "SELECT name FROM sys.triggers WHERE parent_class = 1 AND is_ms_shipped = 0 ORDER BY name;"
    $trigReader = $trigCommand.ExecuteReader()
    try {
        while ($trigReader.Read()) {
            $triggerNames.Add($trigReader.GetString(0))
        }
    }
    finally {
        $trigReader.Dispose()
    }

    $funcCommand = $verifyConnection.CreateCommand()
    $funcCommand.CommandTimeout = 30
    $funcCommand.CommandText = "SELECT name FROM sys.objects WHERE type IN ('FN', 'IF', 'TF') AND is_ms_shipped = 0 ORDER BY name;"
    $funcReader = $funcCommand.ExecuteReader()
    try {
        while ($funcReader.Read()) {
            $functionNames.Add($funcReader.GetString(0))
        }
    }
    finally {
        $funcReader.Dispose()
    }
}
catch [System.Data.SqlClient.SqlException] {
    $errorMessage = Get-SqlErrorMessage -Exception $_.Exception
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("ERROR: Could not verify database '$Database'.")
    [Console]::Error.WriteLine("Message: $errorMessage")
    exit 1
}
finally {
    $verifyConnection.Dispose()
}

$totalWatch.Stop()

$totalTables = $tableStats.Count
[long]$totalRows = 0
$nameWidth = 20
foreach ($entry in $tableStats) {
    $totalRows += $entry.RowCount
    if ($entry.TableName.Length -gt $nameWidth) {
        $nameWidth = $entry.TableName.Length
    }
}

$rowWidth = [Math]::Max(8, $totalRows.ToString().Length + 2)
$divider = "-" * ($nameWidth + $rowWidth + 3)

Write-Host ""
Write-Host ("{0,-$nameWidth}   {1,$rowWidth}" -f "Table", "Rows")
Write-Host $divider
foreach ($entry in $tableStats) {
    Write-Host ("{0,-$nameWidth}   {1,$rowWidth}" -f $entry.TableName, $entry.RowCount)
}
Write-Host $divider

$procDisplay = if ($procedureNames.Count -gt 0) { $procedureNames -join ", " } else { "(none)" }
$trigDisplay = if ($triggerNames.Count -gt 0) { $triggerNames -join ", " } else { "(none)" }
$funcDisplay = if ($functionNames.Count -gt 0) { $functionNames -join ", " } else { "(none)" }

Write-Host ""
Write-Host ("Procedures ({0}): {1}" -f $procedureNames.Count, $procDisplay)
Write-Host ("Triggers   ({0}): {1}" -f $triggerNames.Count, $trigDisplay)
Write-Host ("Functions  ({0}): {1}" -f $functionNames.Count, $funcDisplay)
Write-Host ("Tables: {0} | Total rows: {1} | Procedures: {2} | Triggers: {3} | Functions: {4} | Total elapsed: {5} ms" -f $totalTables, $totalRows, $procedureNames.Count, $triggerNames.Count, $functionNames.Count, $totalWatch.ElapsedMilliseconds)
