/*

[Schema] Phần 2: Course & Enrollment Domain

https://github.com/hoangdada/repo-db-ass2/issues/2

*/
-- 1. Course Table
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

-- 2. Is_Prerequisite_To Table
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

-- 3. Session Table
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

-- 4. Enrolls Table
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

------------------------- INSERT -------------------------

INSERT INTO Course (Code, Title, Number_Of_Credits, Syllabus, Department_ID)
VALUES
    ('CO1005', N'Nhập môn Điện toán', 3, N'Tổng quan về khoa học máy tính và lập trình căn bản C/C++.', 1),
    ('CO2003', N'Cấu trúc Dữ liệu và Giải thuật', 4, N'Danh sách liên kết, cây, đồ thị, thuật toán sắp xếp và tìm kiếm.', 1),
    ('CO2013', N'Hệ cơ sở dữ liệu', 4, N'Mô hình EERD, đại số quan hệ, SQL, chuẩn hóa và giao tác.', 1),
    ('CO1007', N'Cấu trúc rời rạc', 1, N'Mệnh đề, tập hợp, hàm, quan hệ và logic.', 1),
    ('CO2011', N'Mô hình hóa toán học', 3, N'Automata, biểu thức chính quy, ngữ nghĩa.', 1),
    ('MT1003', N'Giải tích 1', 4, N'Giới hạn, đạo hàm, tích phân hàm một biến và chuỗi số.', 2),
    ('MT1005', N'Giải tích 2', 4, N'Hàm nhiều biến, tích phân bội, tích phân đường và mặt.', 2),
    ('EE2003', N'Kỹ thuật Điều khiển Tự động', 3, N'Mô hình hóa hệ thống tuyến tính, ổn định và điều khiển PID.', 3),
    ('MT1007', N'Đại số tuyến tính', 3, N'Ma trận, định thức, không gian vector, giá trị riêng và vector riêng.', 2),
    ('MT2013', N'Xác suất thống kê', 4, N'Xác suất, biến ngẫu nhiên, phân phối xác suất và thống kê mô tả.', 2);
GO

INSERT INTO Is_Prerequisite_To (Pre_Course_Code, Post_Course_Code)
VALUES
    ('CO1005', 'CO2003'),
    ('CO2003', 'CO2013'),
    ('CO1007', 'CO2011'),
    ('MT1007', 'MT2013'),
    ('MT1003', 'MT1005');
GO

INSERT INTO Session (Course_Code, Semester, Education_Program, Number_Order, Teacher_ID)
VALUES
    ('CO1005', '251', 'CLC', 'CC01', 2),
    ('MT1003', '251', 'DT',  'DT01', 3),
    ('CO2003', '252', 'CLC', 'CC01', 2),
    ('MT1007', '252', 'CLC', 'CC01', 1),
    ('CO2013', '252', 'CLC', 'CC01', 1),
    ('CO2011', '252', 'CLC', 'CC01', 1),
    ('CO2013', '261', 'CLC', 'CC01', 1),
    ('CO2013', '261', 'CLC', 'CC06', 1),
    ('MT2013', '261', 'CLC', 'CC01', 1),
    ('MT1005', '261', 'DT',  'DT01', 3),
    ('EE2003', '261', 'CQ',  'L01',  4);
GO

INSERT INTO Enrolls (Student_ID, Course_Code, Semester, Education_Program, Number_Order, Final_Score)
VALUES
    (6, 'CO1005', '251', 'CLC', 'CC01', 8.50),
    (6, 'CO2003', '252', 'CLC', 'CC01', 7.80),
    (7, 'CO2003', '252', 'CLC', 'CC01', 8.00),
    (7, 'CO2013', '252', 'CLC', 'CC01', 8.25),
    (8, 'CO1005', '251', 'CLC', 'CC01', 3.50),
    (9, 'MT1003', '251', 'DT',  'DT01', 7.00),

    (6,  'CO2013', '261', 'CLC', 'CC01', NULL),
    (7,  'CO2013', '261', 'CLC', 'CC06', NULL),
    (7,  'MT2013', '261', 'CLC', 'CC01', NULL),
    (9,  'MT1005', '261', 'DT',  'DT01', NULL),
    (10, 'EE2003', '261', 'CQ',  'L01',  NULL);
GO

------------ PRINT -------------
SELECT * FROM Course;
SELECT * FROM Is_Prerequisite_To;
SELECT * FROM Session;
SELECT * FROM Enrolls;
GO