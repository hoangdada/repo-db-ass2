/*

[Schema] Phần 4: Execution & Evaluation Domain

https://github.com/hoangdada/repo-db-ass2/issues/4

*/

USE bk_db_ass2;
GO


CREATE TABLE Submission (
    ID SMALLINT IDENTITY(1,1) NOT NULL,
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


CREATE TABLE Submission_file_url(
	Submission_ID SMALLINT NOT NULL,
	Assignment_ID SMALLINT NOT NULL,
	Student_ID SMALLINT NOT NULL,
	File_url VARCHAR(300) NOT NULL,

	CONSTRAINT PK_Submission_file_url
		PRIMARY KEY (Submission_ID, Assignment_ID, Student_ID, File_url),
	CONSTRAINT FK_Submission_file_url_Submission
        FOREIGN KEY (Submission_ID, Assignment_ID, Student_ID) REFERENCES Submission(ID, Assignment_ID, Student_ID)
        	ON DELETE CASCADE
);
GO


CREATE TABLE Peer_review (
	Student_ID_review SMALLINT NOT NULL,
	Submission_ID SMALLINT NOT NULL,
	Assignment_ID SMALLINT NOT NULL,
	Student_ID_submit SMALLINT NOT NULL,
	Review_date DATETIME2 NOT NULL,
	Comment NVARCHAR(1500) NOT NULL,

	CONSTRAINT PK_Peer_review
		PRIMARY KEY (Student_ID_review, Submission_ID, Assignment_ID, Student_ID_submit),
	CONSTRAINT FK_Peer_review_Student
		FOREIGN KEY (Student_ID_review) REFERENCES Student (ID)
			ON DELETE NO ACTION,
	CONSTRAINT FK_Peer_review_Submission
		FOREIGN KEY (Submission_ID, Assignment_ID, Student_ID_submit) REFERENCES Submission (ID, Assignment_ID, Student_ID)
			ON DELETE NO ACTION,

	CONSTRAINT CK_Peer_review_distinguish_student
		CHECK (Student_ID_review != Student_ID_submit)
);
GO


