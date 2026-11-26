CREATE OR ALTER PROCEDURE sp_UpdateSubmission
    @Submission_ID  SMALLINT,
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT,
    @New_title      NVARCHAR(250)
AS
BEGIN

    IF @Submission_ID IS NULL OR @Assignment_ID IS NULL OR @Student_ID IS NULL
    BEGIN
        RAISERROR(N'Submission_ID, Assignment_ID, Student_ID can not be NULL', 16, 1);
        RETURN;
    END

    DECLARE @CurrentTime DATETIME2 = SYSDATETIME();

    -- CHECK tồn tại và CHECK chấm điểm
    DECLARE @Final_Score DECIMAL(4, 2);
    DECLARE @Submit_Time DATETIME2;

    SELECT @Final_Score = S.Final_Score, @Submit_Time = S.Submit_Time
    FROM Submission AS S
    WHERE ID = @Submission_ID AND Assignment_ID = @Assignment_ID AND Student_ID = @Student_ID;

    IF @Submit_Time IS NULL
    BEGIN
        RAISERROR(N'Submission does not exist', 16, 1);
        RETURN;
    END

    IF @Final_Score IS NOT NULL
    BEGIN
        RAISERROR(N'Can not update graded Submission', 16, 1);
        RETURN;
    END

    -- CHECK new title
    SET @New_title = LTRIM(RTRIM(@New_title));
    IF @New_title IS NULL OR LEN(@New_title) <= 0
    BEGIN
        RAISERROR(N'Invalid new title', 16, 1);
        RETURN;
    END

    -- UPDATE new title
    UPDATE Submission
    SET Title = @New_title, Submit_Time = @CurrentTime
    WHERE ID = @Submission_ID AND Assignment_ID = @Assignment_ID AND Student_ID = @Student_ID;

    -- NOTIFY
    DECLARE @Deadline DATETIME2;

    SELECT @Deadline = A.Deadline
    FROM Assignment AS A
    WHERE ID = @Assignment_ID;

    DECLARE @DiffMinztes INT = ABS(DATEDIFF(MINUTE, @Deadline, @CurrentTime));

    IF @CurrentTime <= @Deadline
    BEGIN
        PRINT N'Submit early by ' + CAST(@DiffMinutes AS NVARCHAR(20)) + N' minute(s).';
    END
    ELSE
    BEGIN
        PRINT N'Submit late by '  + CAST(@DiffMinutes AS NVARCHAR(20)) + N' minute(s).';
    END
END;
GO