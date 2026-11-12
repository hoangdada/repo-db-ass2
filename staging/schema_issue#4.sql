/*

[Schema] Phần 4: Execution & Evaluation Domain

https://github.com/hoangdada/repo-db-ass2/issues/4

*/

USE bk_db_ass2;
GO


CREATE TABLE Submission (
    ID SMALLINT NOT NULL,
    Assignment_ID SMALLINT NOT NULL,
    Student_ID SMALLINT NOT NULL,
    Title NVARCHAR(250) NOT NULL,
	Submit_time DATETIME2 NOT NULL,
	Final_score DECIMAL(4,2) NULL,

	CONSTRAINT PK_Submission
		PRIMARY KEY (ID, Assignment_ID, Student_ID),
	CONSTRAINT FK_Submission_Assignment
		FOREIGN KEY (Assignment_ID) REFERENCES Assignment(ID)
			ON DELETE NO ACTION,
	CONSTRAINT FK_Submission_Student
		FOREIGN KEY (Student_ID) REFERENCES Student(ID)
			ON DELETE NO ACTION,

	CONSTRAINT CK_Submission_Final_score
		CHECK (Final_score >= 0 AND Final_score <= 10)
		
);
GO


CREATE TABLE Attempt (
	Student_ID SMALLINT NOT NULL,
	Quiz_ID SMALLINT NOT NULL,
	Start_time DATETIME2 NOT NULL,
	Score DECIMAL(4,2) NULL, 
	Duration INT NOT NULL,

	CONSTRAINT PK_Attempt
		PRIMARY KEY (Student_ID, Quiz_ID, Start_time),
	CONSTRAINT FK_Attempt_Student
		FOREIGN KEY (Student_ID) REFERENCES Student(ID)
			ON DELETE NO ACTION,
	CONSTRAINT FK_Attempt_Quiz
		FOREIGN KEY (Quiz_ID) REFERENCES Quiz(ID)
			ON DELETE NO ACTION,

	CONSTRAINT CK_Attempt_Duration
		CHECK (Duration >= 0 AND Duration <= 86400),
	CONSTRAINT CK_Attempt_Score
		CHECK (Score >= 0 AND Score <= 10)
);
GO

