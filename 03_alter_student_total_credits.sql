USE bk_db_ass2;
GO

IF COL_LENGTH(N'dbo.Student', N'Total_Credits') IS NULL
BEGIN
    ALTER TABLE [dbo].[Student]
        ADD Total_Credits SMALLINT NOT NULL
            CONSTRAINT DF_Student_TotalCredits DEFAULT 0;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_Student_TotalCredits'
        AND parent_object_id = OBJECT_ID(N'dbo.Student')
)
BEGIN
    ALTER TABLE [dbo].[Student]
        ADD CONSTRAINT CK_Student_TotalCredits CHECK (Total_Credits >= 0);
END;
GO

SET NOCOUNT ON;

UPDATE s
SET s.Total_Credits = ISNULL(calc.Passed_Credits, 0)
FROM [dbo].[Student] AS s
LEFT JOIN (
    SELECT
        passed.Student_ID,
        CAST(SUM(c.Number_Of_Credits) AS SMALLINT) AS Passed_Credits
    FROM (
        SELECT DISTINCT
            Student_ID,
            Course_Code
        FROM [dbo].[Enrolls]
        WHERE Final_Score > 4.00
    ) AS passed
    INNER JOIN [dbo].[Course] AS c
        ON c.Code = passed.Course_Code
    GROUP BY passed.Student_ID
) AS calc
    ON calc.Student_ID = s.ID;
GO
