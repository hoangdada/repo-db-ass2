/*

[Schema] Phần 4: Execution & Evaluation Domain

https://github.com/hoangdada/repo-db-ass2/issues/4

*/

USE bk_db_ass2;
GO

CREATE TABLE Attempt (
	Student_Email VARCHAR(254) NOT NULL,
	Quiz_ID SMALLINT NOT NULL,
	Start_time DATETIME2 NOT NULL,
	Score DECIMAL(4,2) NULL, 
	Duration INT NOT NULL,

	CONSTRAINT PK_Attempt
		PRIMARY KEY (Student_Email, Quiz_ID, Start_time),
	CONSTRAINT FK_Attempt_Student
		FOREIGN KEY (Student_Email) REFERENCES Student(Email),
	CONSTRAINT FK_Attempt_Quiz
		FOREIGN KEY (Quiz_ID) REFERENCES Quiz(ID),

	CONSTRAINT CK_Attempt_Duration
		CHECK (Duration >= 0 AND Duration <= 86400),
	CONSTRAINT CK_Attempt_Score
		CHECK (Score >= 0 AND Score <= 10)
);
GO

