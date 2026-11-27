USE bk_db_ass2;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_DeleteSubmission]
    @ID             SMALLINT,
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    IF @ID IS NULL OR @Assignment_ID IS NULL OR @Student_ID IS NULL
    BEGIN
        RAISERROR(N'Error: ID, Assignment_ID, and Student_ID cannot be NULL.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Submission
        WHERE ID = @ID
          AND Assignment_ID = @Assignment_ID
          AND Student_ID = @Student_ID
    )
    BEGIN
        RAISERROR(N'Error: Submission does not exist.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Submission
        WHERE ID = @ID
          AND Assignment_ID = @Assignment_ID
          AND Student_ID = @Student_ID
          AND Final_Score IS NOT NULL
    )
    BEGIN
        RAISERROR(N'Error: Final_Score already exists.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Peer_review
        WHERE Submission_ID = @ID
          AND Assignment_ID = @Assignment_ID
          AND Student_ID_Submit = @Student_ID
    )
    BEGIN
        RAISERROR(N'Lỗi: Không thể xóa bài nộp vì bài nộp này đã có dữ liệu đánh giá chéo (Peer_review).', 16, 1);
        RETURN;
    END

    BEGIN TRY
        DELETE FROM Submission
        WHERE ID = @ID
          AND Assignment_ID = @Assignment_ID
          AND Student_ID = @Student_ID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Lỗi hệ thống khi xóa bài nộp: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
END;
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

CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateSubmission]
    @Submission_ID  SMALLINT,
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT,
    @New_title      NVARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Submission_ID IS NULL OR @Assignment_ID IS NULL OR @Student_ID IS NULL
    BEGIN
        RAISERROR(N'Submission_ID, Assignment_ID, Student_ID can not be NULL', 16, 1);
        RETURN;
    END

    DECLARE @CurrentTime DATETIME2 = SYSDATETIME();

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

    SET @New_title = LTRIM(RTRIM(@New_title));
    IF @New_title IS NULL OR LEN(@New_title) <= 0
    BEGIN
        RAISERROR(N'Invalid new title', 16, 1);
        RETURN;
    END

    BEGIN TRY
        UPDATE Submission
        SET Title = @New_title, Submit_Time = @CurrentTime
        WHERE ID = @Submission_ID AND Assignment_ID = @Assignment_ID AND Student_ID = @Student_ID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;

    DECLARE @Deadline DATETIME2;

    SELECT @Deadline = A.Deadline
    FROM Assignment AS A
    WHERE ID = @Assignment_ID;

    DECLARE @DiffMinutes INT = ABS(DATEDIFF(MINUTE, @Deadline, @CurrentTime));

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

CREATE OR ALTER PROCEDURE [dbo].[sp_GradeSubmission]
    @Submission_ID  SMALLINT,
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT,
    @Final_Score    DECIMAL(4, 2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Submission_ID IS NULL OR @Assignment_ID IS NULL OR @Student_ID IS NULL
    BEGIN
        RAISERROR(N'Submission_ID, Assignment_ID, and Student_ID cannot be NULL', 16, 1);
        RETURN;
    END

    IF @Final_Score IS NULL
    BEGIN
        RAISERROR(N'Final_Score cannot be NULL when grading a submission', 16, 1);
        RETURN;
    END

    IF @Final_Score < 0.00 OR @Final_Score > 10.00
    BEGIN
        RAISERROR(N'Final_Score must be between 0.00 and 10.00', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Submission
        WHERE ID = @Submission_ID
          AND Assignment_ID = @Assignment_ID
          AND Student_ID = @Student_ID
    )
    BEGIN
        RAISERROR(N'No submission was found matching the provided ID, Assignment_ID, and Student_ID', 16, 1);
        RETURN;
    END

    DECLARE @Deadline DATETIME2;
    DECLARE @RequiredReviews INT;
    DECLARE @CurrentTime DATETIME2 = SYSDATETIME();

    SELECT
        @Deadline = A.Deadline,
        @RequiredReviews = A.Number_Of_Review_Require
    FROM Assignment AS A
    WHERE A.ID = @Assignment_ID;

    IF @CurrentTime <= @Deadline
    BEGIN
        RAISERROR(N'The assignment cannot be graded until its deadline has passed', 16, 1);
        RETURN;
    END

    DECLARE @CompletedReviews INT;

    SELECT @CompletedReviews = COUNT(*)
    FROM Peer_review AS PR
    WHERE PR.Student_ID_Review = @Student_ID
      AND PR.Assignment_ID = @Assignment_ID;

    IF @CompletedReviews < @RequiredReviews
    BEGIN
        DECLARE @StudentIDInt INT = CAST(@Student_ID AS INT);
        RAISERROR(
            N'Student (ID = %d) has completed only %d/%d required peer reviews for this assignment and is not yet eligible to receive a grade',
            16, 1, @StudentIDInt, @CompletedReviews, @RequiredReviews
        );
        RETURN;
    END

    BEGIN TRY
        UPDATE Submission
        SET Final_Score = @Final_Score
        WHERE ID = @Submission_ID
          AND Assignment_ID = @Assignment_ID
          AND Student_ID = @Student_ID;

        PRINT N'Grading successful: Updated Final_Score for the submission';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'A system error occurred while updating the submission grade: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
END;
GO
