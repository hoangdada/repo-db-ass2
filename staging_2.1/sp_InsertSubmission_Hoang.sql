USE bk_db_ass2;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_InsertSubmission]
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT,
    @Title          NVARCHAR(250),
    @Submit_Time    DATETIME2 = NULL,
    @File_Url       VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Assignment_ID IS NULL OR @Assignment_ID <= 0
    BEGIN
        RAISERROR(N'Mã bài tập (Assignment_ID) không hợp lệ hoặc bị bỏ trống.', 16, 1);
        RETURN;
    END;

    IF @Student_ID IS NULL OR @Student_ID <= 0
    BEGIN
        RAISERROR(N'Mã sinh viên (Student_ID) không hợp lệ hoặc bị bỏ trống.', 16, 2);
        RETURN;
    END;

    IF @Title IS NULL OR LEN(LTRIM(RTRIM(@Title))) = 0
    BEGIN
        RAISERROR(N'Tiêu đề bài nộp (Title) không được để trống.', 16, 3);
        RETURN;
    END;
    SET @Title = LTRIM(RTRIM(@Title));

    IF @File_Url IS NOT NULL AND LEN(LTRIM(RTRIM(@File_Url))) = 0
    BEGIN
        RAISERROR(N'Đường dẫn tệp đính kèm (File_Url) không được là chuỗi rỗng.', 16, 4);
        RETURN;
    END;
    IF @File_Url IS NOT NULL
    BEGIN
        SET @File_Url = LTRIM(RTRIM(@File_Url));
    END;

    IF @File_Url IS NOT NULL
        AND @File_Url NOT LIKE 'http://%'
        AND @File_Url NOT LIKE 'https://%'
    BEGIN
        RAISERROR(N'Đường dẫn tệp đính kèm (File_Url) phải bắt đầu bằng http:// hoặc https://.', 16, 5);
        RETURN;
    END;

    SET @Submit_Time = ISNULL(@Submit_Time, SYSDATETIME());

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE ID = @Student_ID)
    BEGIN
        RAISERROR(N'Sinh viên với mã ID = %d không tồn tại trong hệ thống.', 16, 6, @Student_ID);
        RETURN;
    END;

    DECLARE @Open_Date DATE;
    DECLARE @Deadline DATETIME2;

    SELECT
        @Open_Date = r.Open_Date,
        @Deadline = a.Deadline
    FROM [dbo].[Assignment] AS a
    INNER JOIN [dbo].[Resource] AS r
        ON r.ID = a.ID
    WHERE a.ID = @Assignment_ID;

    IF @Deadline IS NULL
    BEGIN
        RAISERROR(N'Bài tập (Assignment) với mã ID = %d không tồn tại trong hệ thống.', 16, 7, @Assignment_ID);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM [dbo].[Enrolls] AS e
        INNER JOIN [dbo].[Includes] AS i
            ON e.Course_Code = i.Course_Code
            AND e.Semester = i.Semester
            AND e.Education_Program = i.Education_Program
            AND e.Number_Order = i.Number_Order
        WHERE e.Student_ID = @Student_ID
            AND i.Resource_ID = @Assignment_ID
    )
    BEGIN
        RAISERROR(N'Sinh viên (ID = %d) chưa đăng ký lớp học phần chứa bài tập (ID = %d).', 16, 8, @Student_ID, @Assignment_ID);
        RETURN;
    END;

    IF CAST(@Submit_Time AS DATE) < @Open_Date
    BEGIN
        DECLARE @Open_Date_Str VARCHAR(10) = CONVERT(VARCHAR(10), @Open_Date, 23);
        RAISERROR(N'Chưa đến ngày mở nộp bài tập (ngày mở: %s).', 16, 9, @Open_Date_Str);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Old_Submission_ID SMALLINT = NULL;

        SELECT @Old_Submission_ID = ID
        FROM [dbo].[Submission] WITH (UPDLOCK, HOLDLOCK)
        WHERE Assignment_ID = @Assignment_ID
            AND Student_ID = @Student_ID;

        IF @Old_Submission_ID IS NOT NULL
        BEGIN
            EXEC [dbo].[sp_DeleteSubmission]
                @ID = @Old_Submission_ID,
                @Assignment_ID = @Assignment_ID,
                @Student_ID = @Student_ID;
        END;

        INSERT INTO [dbo].[Submission] (Assignment_ID, Student_ID, Title, Submit_Time, Final_Score)
        VALUES (@Assignment_ID, @Student_ID, @Title, @Submit_Time, NULL);

        DECLARE @New_Submission_ID SMALLINT = CAST(SCOPE_IDENTITY() AS SMALLINT);

        IF @File_Url IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[Submission_file_url] (Submission_ID, Assignment_ID, Student_ID, File_Url)
            VALUES (@New_Submission_ID, @Assignment_ID, @Student_ID, @File_Url);
        END;

        COMMIT TRANSACTION;

        DECLARE @Submission_Status NVARCHAR(20) = CASE
            WHEN @Submit_Time <= @Deadline THEN N'Đúng hạn'
            ELSE N'Trễ hạn'
        END;

        SELECT
            @New_Submission_ID AS Submission_ID,
            @Assignment_ID AS Assignment_ID,
            @Student_ID AS Student_ID,
            @Title AS Title,
            @Submit_Time AS Submit_Time,
            @Submission_Status AS Submission_Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;
END;
GO
