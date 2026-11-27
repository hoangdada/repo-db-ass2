USE bk_db_ass2;
GO

CREATE OR ALTER PROCEDURE sp_GradeSubmission
    @Submission_ID  SMALLINT,
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT,
    @Final_Score    DECIMAL(4, 2)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Kiểm tra tham số khóa chính đầu vào không được NULL
    IF @Submission_ID IS NULL OR @Assignment_ID IS NULL OR @Student_ID IS NULL
    BEGIN
        RAISERROR(N'Submission_ID, Assignment_ID, and Student_ID cannot be NULL', 16, 1);
        RETURN;
    END

    -- 2. Kiểm tra Final_Score không được NULL (tránh lọt qua kiểm tra miền do Logic 3 giá trị)
    IF @Final_Score IS NULL
    BEGIN
        RAISERROR(N'Final_Score cannot be NULL when grading a submission', 16, 1);
        RETURN;
    END

    -- 3. Kiểm tra miền giá trị của Final_Score thuộc [0.00, 10.00]
    IF @Final_Score < 0.00 OR @Final_Score > 10.00
    BEGIN
        RAISERROR(N'Final_Score must be between 0.00 and 10.00', 16, 1);
        RETURN;
    END

    -- 4. Kiểm tra bản ghi Submission có tồn tại không (theo PK 3 cột)
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

    -- 5. Lấy Deadline và Number_Of_Review_Require của Assignment tương ứng
    DECLARE @Deadline DATETIME2;
    DECLARE @RequiredReviews INT;
    DECLARE @CurrentTime DATETIME2 = SYSDATETIME();

    SELECT
        @Deadline = A.Deadline,
        @RequiredReviews = A.Number_Of_Review_Require
    FROM Assignment AS A
    WHERE A.ID = @Assignment_ID;

    -- Kiểm tra thời điểm chấm điểm phải SAU Assignment.Deadline
    IF @CurrentTime <= @Deadline
    BEGIN
        RAISERROR(N'The assignment cannot be graded until its deadline has passed', 16, 1);
        RETURN;
    END

    -- 6. Kiểm tra sinh viên nộp bài đã hoàn thành đủ số lượt ĐI CHẤM CHÉO trong Peer_review chưa
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

    -- 7. Xử lý chính: Cập nhật Final_Score cho Submission
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