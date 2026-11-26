USE bk_db_ass2;
GO

CREATE OR ALTER PROCEDURE sp_DeleteSubmission
    @ID             SMALLINT,
    @Assignment_ID  SMALLINT,
    @Student_ID     SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Check Submission exists
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

    -- 2. Check Final_Score IS NOT NULL
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

    -- 3. Check if Peer_review already exists
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

    -- 4. Delete Submission (CASCADE DELETE Submission_file_url)
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