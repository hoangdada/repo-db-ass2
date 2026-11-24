/*

[Schema] Phần 3: Resource & Assessment Domain

https://github.com/hoangdada/repo-db-ass2/issues/3

*/

CREATE TABLE Resource (
    ID SMALLINT PRIMARY KEY,
    Open_date DATE,
    Description NVARCHAR(MAX),
    Upload_time DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
    Title NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE Quiz (
    ID SMALLINT PRIMARY KEY,
    Attempt_Limit INT,
    Time_limit INT DEFAULT 86400 NOT NULL,
    Grade_To_Pass DECIMAL(4, 2) DEFAULT 0.00 NOT NULL,
    Deadline DATETIME2,

    CONSTRAINT FK_Quiz_Resource FOREIGN KEY (ID)
        REFERENCES Resource(ID) ON DELETE CASCADE,

    -- Domain Checks (SQL Server CHECK constraints naturally allow NULLs unless forbidden)
    CONSTRAINT CHK_Quiz_Attempt_Limit CHECK (Attempt_Limit >= 1),
    CONSTRAINT CHK_Quiz_Time_Limit CHECK (Time_limit > 0 AND Time_limit <= 86400),
    CONSTRAINT CHK_Quiz_Grade_To_Pass CHECK (Grade_To_Pass >= 0.00 AND Grade_To_Pass <= 10.00)
);
GO

CREATE TABLE Assignment (
    ID SMALLINT PRIMARY KEY,
    number_of_review_require INT,
    Deadline DATETIME2,

    CONSTRAINT FK_Assignment_Resource FOREIGN KEY (ID)
        REFERENCES Resource(ID) ON DELETE CASCADE,

    CONSTRAINT CHK_Assignment_Review_Count CHECK (number_of_review_require >= 0)
);
GO

CREATE TABLE File_material (
    ID SMALLINT PRIMARY KEY,
    File_url NVARCHAR(300) NOT NULL,

    CONSTRAINT FK_File_Resource FOREIGN KEY (ID)
        REFERENCES Resource(ID) ON DELETE CASCADE
);
GO

CREATE TABLE Creates (
    Teacher_ID SMALLINT NOT NULL,
    Resource_ID SMALLINT NOT NULL,
    Upload_person BIT DEFAULT 0 NOT NULL,

    CONSTRAINT PK_Create PRIMARY KEY (Teacher_ID, Resource_ID),

    CONSTRAINT FK_Create_Teacher FOREIGN KEY (Teacher_ID) 
        REFERENCES Teacher(ID) ON DELETE NO ACTION,

    CONSTRAINT FK_Create_Resource FOREIGN KEY (Resource_ID) 
        REFERENCES Resource(ID) ON DELETE CASCADE
);
GO

CREATE TABLE Includes (
    Resource_ID SMALLINT NOT NULL,
    Session_Course_Code VARCHAR(20) NOT NULL,
    Session_Semester VARCHAR(20) NOT NULL,
    Session_Education_Program VARCHAR(50) NOT NULL,
    Section_Number_Order SMALLINT NOT NULL,
    
    CONSTRAINT PK_Include PRIMARY KEY (
        Resource_ID, 
        Session_Course_Code, 
        Session_Semester, 
        Session_Education_Program, 
        Section_Number_Order
    ),
    
    CONSTRAINT FK_Include_Resource FOREIGN KEY (Resource_ID) 
        REFERENCES Resource(ID) ON DELETE CASCADE,
        
    CONSTRAINT FK_Include_Session FOREIGN KEY (
        Session_Course_Code, 
        Session_Semester, 
        Session_Education_Program, 
        Section_Number_Order
    ) REFERENCES Session(
        Course_Code, 
        Semester, 
        Education_Program, 
        Number_Order
    ) ON DELETE NO ACTION
);
GO