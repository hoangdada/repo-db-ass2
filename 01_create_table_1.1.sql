IF DB_ID(N'bk_db_ass2') IS NULL
BEGIN
    CREATE DATABASE bk_db_ass2;
END
GO

USE bk_db_ass2;
GO

CREATE TABLE Department (
    ID          SMALLINT        IDENTITY(1,1) NOT NULL,
    Name        NVARCHAR(200)   NOT NULL,
    Hotline     VARCHAR(11)     NOT NULL,

    CONSTRAINT PK_Department PRIMARY KEY (ID),
    CONSTRAINT UQ_Department_Name UNIQUE (Name),
    CONSTRAINT UQ_Department_Hotline UNIQUE (Hotline),
    CONSTRAINT CK_Department_Name CHECK (
        LEN(LTRIM(RTRIM(Name))) > 0
    ),
    CONSTRAINT CK_Department_Hotline CHECK (
        Hotline LIKE '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        OR Hotline LIKE '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )
);
GO

CREATE TABLE Resource (
    ID              SMALLINT        IDENTITY(1,1) NOT NULL,
    Open_Date       DATE            NOT NULL CONSTRAINT DF_Resource_OpenDate DEFAULT CAST(SYSDATETIME() AS DATE),
    Description     NVARCHAR(MAX)   NULL,
    Upload_Time     DATETIME2       NOT NULL CONSTRAINT DF_Resource_UploadTime DEFAULT SYSDATETIME(),
    Title           NVARCHAR(255)   NOT NULL,

    CONSTRAINT PK_Resource PRIMARY KEY (ID),
    CONSTRAINT CK_Resource_Title CHECK (
        LEN(LTRIM(RTRIM(Title))) > 0
    )
);
GO

CREATE TABLE Person (
    ID              SMALLINT        IDENTITY(1,1) NOT NULL,
    Email           VARCHAR(100)    NOT NULL,
    Password_Hash   VARCHAR(255)    NOT NULL,
    Phone_Number    CHAR(10)        NOT NULL,
    First_Name      NVARCHAR(50)    NOT NULL,
    Middle_Name     NVARCHAR(50)    NULL,
    Last_Name       NVARCHAR(50)    NOT NULL,
    Specialty       NVARCHAR(100)   NOT NULL,
    Country         NVARCHAR(64)    NOT NULL CONSTRAINT DF_Person_Country DEFAULT N'Việt Nam',
    Birthday        DATE            NOT NULL,
    Department_ID   SMALLINT        NOT NULL,

    CONSTRAINT PK_Person PRIMARY KEY (ID),
    CONSTRAINT UQ_Person_Email UNIQUE (Email),
    CONSTRAINT UQ_Person_Phone_Number UNIQUE (Phone_Number),
    CONSTRAINT FK_Person_Department FOREIGN KEY (Department_ID)
        REFERENCES Department(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Person_Email CHECK (
        Email LIKE '%_@__%.__%'
        AND Email NOT LIKE '% %'
    ),
    CONSTRAINT CK_Person_Phone_Number CHECK (
        Phone_Number LIKE '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    CONSTRAINT CK_Person_Birthday CHECK (
        Birthday <= CAST(GETDATE() AS DATE)
        AND Birthday >= DATEADD(YEAR, -150, CAST(GETDATE() AS DATE))
    ),
    CONSTRAINT CK_Person_FirstName CHECK (
        LEN(LTRIM(RTRIM(First_Name))) > 0
    ),
    CONSTRAINT CK_Person_LastName CHECK (
        LEN(LTRIM(RTRIM(Last_Name))) > 0
    ),
    CONSTRAINT CK_Person_Specialty CHECK (
        LEN(LTRIM(RTRIM(Specialty))) > 0
    )
);
GO

CREATE TABLE Course (
    Code                CHAR(6)         NOT NULL,
    Title               NVARCHAR(200)   NOT NULL,
    Number_Of_Credits   TINYINT         NOT NULL,
    Syllabus            NVARCHAR(MAX)   NOT NULL CONSTRAINT DF_Course_Syllabus DEFAULT N'Chưa cập nhật',
    Department_ID       SMALLINT        NOT NULL,

    CONSTRAINT PK_Course PRIMARY KEY (Code),
    CONSTRAINT FK_Course_Department FOREIGN KEY (Department_ID)
        REFERENCES Department(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Course_Code CHECK (
        Code COLLATE Latin1_General_BIN LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9]'
    ),
    CONSTRAINT CK_Course_Title CHECK (
        LEN(LTRIM(RTRIM(Title))) > 0
    ),
    CONSTRAINT CK_Course_Credits CHECK (
        Number_Of_Credits > 0 AND Number_Of_Credits <= 25
    )
);
GO

CREATE TABLE Quiz (
    ID              SMALLINT        NOT NULL,
    Attempt_Limit   INT             NULL,
    Time_Limit      INT             NOT NULL CONSTRAINT DF_Quiz_TimeLimit DEFAULT 86400,
    Grade_To_Pass   DECIMAL(4, 2)   NOT NULL CONSTRAINT DF_Quiz_GradeToPass DEFAULT 0.00,
    Deadline        DATETIME2       NULL,

    CONSTRAINT PK_Quiz PRIMARY KEY (ID),
    CONSTRAINT FK_Quiz_Resource FOREIGN KEY (ID)
        REFERENCES Resource(ID)
        ON DELETE CASCADE,
    CONSTRAINT CK_Quiz_AttemptLimit CHECK (
        Attempt_Limit IS NULL OR Attempt_Limit >= 1
    ),
    CONSTRAINT CK_Quiz_TimeLimit CHECK (
        Time_Limit > 0 AND Time_Limit <= 86400
    ),
    CONSTRAINT CK_Quiz_GradeToPass CHECK (
        Grade_To_Pass >= 0.00 AND Grade_To_Pass <= 10.00
    )
);
GO

CREATE TABLE Assignment (
    ID                          SMALLINT    NOT NULL,
    Number_Of_Review_Require    INT         NOT NULL CONSTRAINT DF_Assignment_NumberOfReviewRequire DEFAULT 0,
    Deadline                    DATETIME2   NOT NULL,

    CONSTRAINT PK_Assignment PRIMARY KEY (ID),
    CONSTRAINT FK_Assignment_Resource FOREIGN KEY (ID)
        REFERENCES Resource(ID)
        ON DELETE CASCADE,
    CONSTRAINT CK_Assignment_NumberOfReviewRequire CHECK (
        Number_Of_Review_Require >= 0
    )
);
GO

CREATE TABLE File_material (
    ID          SMALLINT        NOT NULL,
    File_Url    VARCHAR(300)    NOT NULL,

    CONSTRAINT PK_File_material PRIMARY KEY (ID),
    CONSTRAINT FK_File_material_Resource FOREIGN KEY (ID)
        REFERENCES Resource(ID)
        ON DELETE CASCADE,
    CONSTRAINT CK_File_material_FileUrl CHECK (
        LEN(LTRIM(RTRIM(File_Url))) > 0
    )
);
GO

CREATE TABLE Student (
    ID              SMALLINT    NOT NULL,
    Academic_Year   SMALLINT    NOT NULL,

    CONSTRAINT PK_Student PRIMARY KEY (ID),
    CONSTRAINT FK_Student_Person FOREIGN KEY (ID)
        REFERENCES Person(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Student_Academic_Year CHECK (
        Academic_Year >= 1957 AND Academic_Year <= YEAR(GETDATE())
    )
);
GO

CREATE TABLE Teacher (
    ID              SMALLINT        NOT NULL,
    Academic_Rank   NVARCHAR(50)    NOT NULL CONSTRAINT DF_Teacher_AcademicRank DEFAULT N'Không có',
    Qualification   NVARCHAR(50)    NOT NULL CONSTRAINT DF_Teacher_Qualification DEFAULT N'Không có',

    CONSTRAINT PK_Teacher PRIMARY KEY (ID),
    CONSTRAINT FK_Teacher_Person FOREIGN KEY (ID)
        REFERENCES Person(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Teacher_AcademicRank CHECK (
        LEN(LTRIM(RTRIM(Academic_Rank))) > 0
    ),
    CONSTRAINT CK_Teacher_Qualification CHECK (
        LEN(LTRIM(RTRIM(Qualification))) > 0
    )
);
GO

CREATE TABLE Is_Prerequisite_To (
    Pre_Course_Code     CHAR(6)     NOT NULL,
    Post_Course_Code    CHAR(6)     NOT NULL,

    CONSTRAINT PK_Is_Prerequisite_To PRIMARY KEY (Pre_Course_Code, Post_Course_Code),
    CONSTRAINT FK_IsPrerequisiteTo_PreCourse FOREIGN KEY (Pre_Course_Code)
        REFERENCES Course(Code)
        ON DELETE NO ACTION,
    CONSTRAINT FK_IsPrerequisiteTo_PostCourse FOREIGN KEY (Post_Course_Code)
        REFERENCES Course(Code)
        ON DELETE NO ACTION,
    CONSTRAINT CK_IsPrerequisiteTo_NoSelfLoop CHECK (
        Pre_Course_Code <> Post_Course_Code
    )
);
GO

CREATE TABLE Session (
    Course_Code         CHAR(6)         NOT NULL,
    Semester            VARCHAR(10)     NOT NULL,
    Education_Program   VARCHAR(10)     NOT NULL CONSTRAINT DF_Session_EducationProgram DEFAULT 'CQ',
    Number_Order        VARCHAR(10)     NOT NULL,
    Teacher_ID          SMALLINT        NOT NULL,

    CONSTRAINT PK_Session PRIMARY KEY (
        Course_Code, Semester, Education_Program, Number_Order
    ),
    CONSTRAINT FK_Session_Course FOREIGN KEY (Course_Code)
        REFERENCES Course(Code)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Session_Teacher FOREIGN KEY (Teacher_ID)
        REFERENCES Teacher(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Session_Semester CHECK (
        Semester LIKE '[0-9][0-9][1-3]'
    ),
    CONSTRAINT CK_Session_EducationProgram CHECK (
        Education_Program IN ('CLC', 'DT', 'CQ', 'KSTN', 'VP', 'SDH')
    ),
    CONSTRAINT CK_Session_NumberOrder CHECK (
        LEN(LTRIM(RTRIM(Number_Order))) > 0
    )
);
GO

CREATE TABLE Creates (
    Teacher_ID      SMALLINT    NOT NULL,
    Resource_ID     SMALLINT    NOT NULL,
    Upload_Person   BIT         NOT NULL CONSTRAINT DF_Creates_UploadPerson DEFAULT 0,

    CONSTRAINT PK_Creates PRIMARY KEY (Teacher_ID, Resource_ID),
    CONSTRAINT FK_Creates_Teacher FOREIGN KEY (Teacher_ID)
        REFERENCES Teacher(ID)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Creates_Resource FOREIGN KEY (Resource_ID)
        REFERENCES Resource(ID)
        ON DELETE CASCADE
);
GO

CREATE TABLE Weekly_Schedule (
    Course_Code         CHAR(6)         NOT NULL,
    Semester            VARCHAR(10)     NOT NULL,
    Education_Program   VARCHAR(10)     NOT NULL,
    Number_Order        VARCHAR(10)     NOT NULL,
    Day                 VARCHAR(10)     NOT NULL,
    Start_Time          TIME(0)         NOT NULL,
    Duration            INT             NOT NULL,
    Classroom           VARCHAR(20)     NOT NULL,

    CONSTRAINT PK_Weekly_Schedule PRIMARY KEY (
        Course_Code, Semester, Education_Program, Number_Order, Day, Start_Time, Duration, Classroom
    ),
    CONSTRAINT FK_Weekly_Schedule_Session FOREIGN KEY (
        Course_Code, Semester, Education_Program, Number_Order
    )
        REFERENCES Session(Course_Code, Semester, Education_Program, Number_Order)
        ON DELETE CASCADE,
    CONSTRAINT CK_Weekly_Schedule_Day CHECK (
        Day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
    ),
    CONSTRAINT CK_Weekly_Schedule_TimeRange CHECK (
        Start_Time >= CAST('06:00:00' AS TIME(0))
        AND Duration > 0
        AND (DATEDIFF(MINUTE, CAST('00:00:00' AS TIME(0)), Start_Time) + Duration) <= 1260
    ),
    CONSTRAINT CK_Weekly_Schedule_Classroom CHECK (
        LEN(LTRIM(RTRIM(Classroom))) > 0
    )
);
GO

CREATE TABLE Enrolls (
    Student_ID          SMALLINT        NOT NULL,
    Course_Code         CHAR(6)         NOT NULL,
    Semester            VARCHAR(10)     NOT NULL,
    Education_Program   VARCHAR(10)     NOT NULL,
    Number_Order        VARCHAR(10)     NOT NULL,
    Final_Score         DECIMAL(4, 2)   NULL CONSTRAINT DF_Enrolls_FinalScore DEFAULT NULL,

    CONSTRAINT PK_Enrolls PRIMARY KEY (
        Student_ID, Course_Code, Semester, Education_Program, Number_Order
    ),
    CONSTRAINT UQ_Enrolls_StudentCourseSemester UNIQUE (
        Student_ID, Course_Code, Semester
    ),
    CONSTRAINT FK_Enrolls_Student FOREIGN KEY (Student_ID)
        REFERENCES Student(ID)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Enrolls_Session FOREIGN KEY (
        Course_Code, Semester, Education_Program, Number_Order
    )
        REFERENCES Session(Course_Code, Semester, Education_Program, Number_Order)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Enrolls_FinalScore CHECK (
        Final_Score IS NULL OR (Final_Score >= 0.00 AND Final_Score <= 10.00)
    )
);
GO

CREATE TABLE Includes (
    Resource_ID         SMALLINT        NOT NULL,
    Course_Code         CHAR(6)         NOT NULL,
    Semester            VARCHAR(10)     NOT NULL,
    Education_Program   VARCHAR(10)     NOT NULL,
    Number_Order        VARCHAR(10)     NOT NULL,

    CONSTRAINT PK_Includes PRIMARY KEY (
        Resource_ID, Course_Code, Semester, Education_Program, Number_Order
    ),
    CONSTRAINT FK_Includes_Resource FOREIGN KEY (Resource_ID)
        REFERENCES Resource(ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Includes_Session FOREIGN KEY (
        Course_Code, Semester, Education_Program, Number_Order
    )
        REFERENCES Session(Course_Code, Semester, Education_Program, Number_Order)
        ON DELETE NO ACTION
);
GO

CREATE TABLE Attempt (
    Student_ID      SMALLINT        NOT NULL,
    Quiz_ID         SMALLINT        NOT NULL,
    Start_Time      DATETIME2       NOT NULL,
    Score           DECIMAL(4, 2)   NULL,
    Duration        INT             NOT NULL CONSTRAINT DF_Attempt_Duration DEFAULT 0,

    CONSTRAINT PK_Attempt PRIMARY KEY (Student_ID, Quiz_ID, Start_Time),
    CONSTRAINT FK_Attempt_Student FOREIGN KEY (Student_ID)
        REFERENCES Student(ID)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Attempt_Quiz FOREIGN KEY (Quiz_ID)
        REFERENCES Quiz(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Attempt_Duration CHECK (
        Duration >= 0 AND Duration <= 86400
    ),
    CONSTRAINT CK_Attempt_Score CHECK (
        Score IS NULL OR (Score >= 0.00 AND Score <= 10.00)
    )
);
GO

CREATE TABLE Submission (
    ID              SMALLINT        IDENTITY(1,1) NOT NULL,
    Assignment_ID   SMALLINT        NOT NULL,
    Student_ID      SMALLINT        NOT NULL,
    Title           NVARCHAR(250)   NOT NULL,
    Submit_Time     DATETIME2       NOT NULL CONSTRAINT DF_Submission_SubmitTime DEFAULT SYSDATETIME(),
    Final_Score     DECIMAL(4, 2)   NULL,

    CONSTRAINT PK_Submission PRIMARY KEY (ID, Assignment_ID, Student_ID),
    CONSTRAINT UQ_Submission_Assignment_Student UNIQUE (Assignment_ID, Student_ID),
    CONSTRAINT FK_Submission_Assignment FOREIGN KEY (Assignment_ID)
        REFERENCES Assignment(ID)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Submission_Student FOREIGN KEY (Student_ID)
        REFERENCES Student(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Submission_Title CHECK (
        LEN(LTRIM(RTRIM(Title))) > 0
    ),
    CONSTRAINT CK_Submission_Final_score CHECK (
        Final_Score IS NULL OR (Final_Score >= 0.00 AND Final_Score <= 10.00)
    )
);
GO

CREATE TABLE Submission_file_url (
    Submission_ID   SMALLINT        NOT NULL,
    Assignment_ID   SMALLINT        NOT NULL,
    Student_ID      SMALLINT        NOT NULL,
    File_Url        VARCHAR(300)    NOT NULL,

    CONSTRAINT PK_Submission_file_url PRIMARY KEY (
        Submission_ID, Assignment_ID, Student_ID, File_Url
    ),
    CONSTRAINT FK_Submission_file_url_Submission FOREIGN KEY (
        Submission_ID, Assignment_ID, Student_ID
    )
        REFERENCES Submission(ID, Assignment_ID, Student_ID)
        ON DELETE CASCADE,
    CONSTRAINT CK_Submission_file_url_FileUrl CHECK (
        LEN(LTRIM(RTRIM(File_Url))) > 0
    )
);
GO

CREATE TABLE Peer_review (
    Student_ID_Review   SMALLINT        NOT NULL,
    Submission_ID       SMALLINT        NOT NULL,
    Assignment_ID       SMALLINT        NOT NULL,
    Student_ID_Submit   SMALLINT        NOT NULL,
    Review_Date         DATETIME2       NOT NULL CONSTRAINT DF_PeerReview_ReviewDate DEFAULT SYSDATETIME(),
    Comment             NVARCHAR(1500)  NOT NULL,

    CONSTRAINT PK_Peer_review PRIMARY KEY (
        Student_ID_Review, Submission_ID, Assignment_ID, Student_ID_Submit
    ),
    CONSTRAINT FK_Peer_review_Student FOREIGN KEY (Student_ID_Review)
        REFERENCES Student(ID)
        ON DELETE NO ACTION,
    CONSTRAINT FK_Peer_review_Submission FOREIGN KEY (
        Submission_ID, Assignment_ID, Student_ID_Submit
    )
        REFERENCES Submission(ID, Assignment_ID, Student_ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Peer_review_distinguish_student CHECK (
        Student_ID_Review <> Student_ID_Submit
    ),
    CONSTRAINT CK_Peer_review_Comment CHECK (
        LEN(LTRIM(RTRIM(Comment))) > 0
    )
);
GO
