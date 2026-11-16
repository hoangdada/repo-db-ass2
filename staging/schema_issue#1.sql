/*

[Schema] Phần 1: User & Structure Domain

https://github.com/hoangdada/repo-db-ass2/issues/1

*/

-- 1. Department Table
CREATE TABLE Department (
    ID          SMALLINT        IDENTITY(1,1) NOT NULL,
    Name        NVARCHAR(200)   NOT NULL,
    Hotline     VARCHAR(11)     NOT NULL,

    CONSTRAINT PK_Department PRIMARY KEY (ID),
    CONSTRAINT UQ_Department_Name UNIQUE (Name),
    CONSTRAINT UQ_Department_Hotline UNIQUE (Hotline),
    CONSTRAINT CK_Department_Hotline CHECK (
        -- Tính cả số di động và số bàn cho chắc
        Hotline LIKE '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        OR Hotline LIKE '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )
);
GO

-- 2. Person Table
CREATE TABLE Person (
    ID              SMALLINT        IDENTITY(1,1) NOT NULL,
    Email           VARCHAR(100)    NOT NULL,
    Password_Hash   VARCHAR(255)    NOT NULL, --Tùy thuật toán mà cố định số lượng ký tự sau
    Phone_Number    CHAR(10)        NOT NULL,
    First_Name      NVARCHAR(50)    NOT NULL,
    Middle_Name     NVARCHAR(50)    NULL,
    Last_Name       NVARCHAR(50)    NOT NULL,
    Specialty       NVARCHAR(100)   NULL,
    Country         NVARCHAR(10)    NOT NULL CONSTRAINT DF_Person_Country DEFAULT N'Việt Nam',
    Birthday        DATE            NOT NULL,
    Department_ID   SMALLINT        NOT NULL,

    CONSTRAINT PK_Person PRIMARY KEY (ID),
    CONSTRAINT UQ_Person_Email UNIQUE (Email),
    CONSTRAINT UQ_Person_Phone_Number UNIQUE (Phone_Number),
    CONSTRAINT FK_Person_Department FOREIGN KEY (Department_ID)
        REFERENCES Department(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Person_Email CHECK (Email LIKE '%_@__%.__%'),
    -- Số di động Việt Nam 10 chữ số bắt đầu bằng 03, 05, 07, 08, 09
    CONSTRAINT CK_Person_Phone_Number CHECK (
        Phone_Number LIKE '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    CONSTRAINT CK_Person_Birthday CHECK (
        Birthday <= CAST(GETDATE() AS DATE)
        AND Birthday >= DATEADD(YEAR, -150, CAST(GETDATE() AS DATE))
    )
);
GO

-- 3. Student Table
CREATE TABLE Student (
    ID              SMALLINT    NOT NULL,
    Academic_Year   SMALLINT    NOT NULL, -- Chọn SMALLINT cho tiết kiệm bộ nhớ
    Total_Credits   INT         NOT NULL CONSTRAINT DF_Student_Total_Credits DEFAULT 0,

    CONSTRAINT PK_Student PRIMARY KEY (ID),
    CONSTRAINT FK_Student_Person FOREIGN KEY (ID)
        REFERENCES Person(ID)
        ON DELETE NO ACTION,
    CONSTRAINT CK_Student_Academic_Year CHECK (Academic_Year >= 1957 AND Academic_Year <= YEAR(GETDATE())), -- Từ năm thành lập đến năm hiện tại
    CONSTRAINT CK_Student_Total_Credits CHECK (Total_Credits >= 0)
);
GO

-- 4. Teacher Table
CREATE TABLE Teacher (
    ID              SMALLINT        NOT NULL,
    Academic_Rank   NVARCHAR(50)    NOT NULL,
    Qualification   NVARCHAR(50)    NOT NULL,

    CONSTRAINT PK_Teacher PRIMARY KEY (ID),
    CONSTRAINT FK_Teacher_Person FOREIGN KEY (ID)
        REFERENCES Person(ID)
        ON DELETE NO ACTION
);
GO

-- Bảng tạm để test FK cho Weekly_Schedule (Nhớ xóa/comment lại trước khi merge vào file tổng)
CREATE TABLE Session (
    Course_Code         CHAR(6)         NOT NULL,
    Semester            VARCHAR(10)     NOT NULL,
    Education_Program   VARCHAR(10)     NOT NULL,
    Number_Order        VARCHAR(10)     NOT NULL,

    CONSTRAINT PK_Session PRIMARY KEY (
        Course_Code, Semester, Education_Program, Number_Order
    )
);
GO
-- 5. Weekly_Schedule Table
CREATE TABLE Weekly_Schedule (
    Course_Code         CHAR(6)         NOT NULL,
    Semester            VARCHAR(10)     NOT NULL,
    Education_Program   VARCHAR(10)     NOT NULL,
    Number_Order        VARCHAR(10)     NOT NULL,
    Day                 VARCHAR(10)     NOT NULL,
    Start_time          TIME(0)         NOT NULL,
    Duration            INT             NOT NULL, -- Đơn vị: phút (ví dụ: 50, 100, 150)
    Classroom           VARCHAR(20)     NOT NULL,

    CONSTRAINT PK_Weekly_Schedule PRIMARY KEY (
        Course_Code, Semester, Education_Program, Number_Order, Day, Start_time
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
        Start_time >= '06:00:00'
        AND Duration > 0
        AND (DATEDIFF(MINUTE, '00:00:00', Start_time) + Duration) <= 1260 -- Chỉ được bắt đầu lúc 6AM và kết thúc trước 9PM
    )
);

------------------------- INSERT -------------------------
INSERT INTO Department (Name, Hotline)
VALUES
    (N'Khoa Khoa học và Kỹ thuật Máy tính - Faculty of Computer Science and Engineering', '02345678901'),
    (N'Khoa Khoa học Ứng dụng - Faculty of Applied Science', '02345678902'),
    (N'Khoa Điện - Điện tử - Faculty of Electrical and Electronics Engineering', '02345678903'),
    (N'Khoa Cơ khí - Faculty of Mechanical Engineering', '02345678904'),
    (N'Khoa Quản lý Công nghiệp - Faculty of Industrial Management', '02345678905');
GO

INSERT INTO Person (Email, Password_Hash, Phone_Number, First_Name, Middle_Name, Last_Name, Specialty, Country, Birthday, Department_ID)
VALUES
    ('anh.nguyen@hcmut.edu.vn', '$2b$10$teacherHash00000000000000000000000000000000000001', '0901234561', N'Anh', N'Đức', N'Nguyễn', N'Hệ quản trị Cơ sở dữ liệu', N'Việt Nam', '1990-05-15', 1),
    ('jensen.huang@hcmut.edu.vn', '$2b$10$teacherHash00000000000000000000000000000000000002', '0901234562', 'Jensen', NULL, 'Huang', N'Công nghệ Phần mềm', 'The U.S.A', '1982-10-20', 1),
    ('tuan.trung@hcmut.edu.vn', '$2b$10$teacherHash00000000000000000000000000000000000003', '0901234563', N'Tuấn', N'Minh', N'Trung', N'Giải tích và Toán ứng dụng', N'Việt Nam', '1978-03-11', 2),
    ('elon.musk@hcmut.edu.vn', '$2b$10$teacherHash00000000000000000000000000000000000004', '0901234564', 'Elon', NULL, 'Musk', N'Kỹ thuật Điều khiển', 'The U.S.A', '1985-07-08', 3),
    ('fabien.baldacci@hcmut.edu.vn', '$2b$10$teacherHash00000000000000000000000000000000000005', '0901234565', N'Fabien', NULL, N'Baldacci', N'Trí tuệ Nhân tạo', N'Pháp', '1988-12-01', 1),

    ('hoang.luong@hcmut.edu.vn', '$2b$10$studentHash00000000000000000000000000000000000001', '0351234561', N'Hoàng', N'Thế', N'Lương', N'Khoa học Máy tính', N'Việt Nam', '2006-03-12', 1),
    ('khoi.hoang@hcmut.edu.vn', '$2b$10$studentHash00000000000000000000000000000000000002', '0351234562', N'Khôi', N'Lâm Đăng', N'Hoàng', N'Khoa học Máy tính', N'Việt Nam', '2006-08-25', 1),
    ('viet.nguyen@hcmut.edu.vn', '$2b$10$studentHash00000000000000000000000000000000000003', '0351234563', N'Việt', N'Quốc', N'Nguyễn', N'Kỹ thuật Máy tính', N'Việt Nam', '2006-01-19', 1),
    ('tuan.van@hcmut.edu.vn', '$2b$10$studentHash00000000000000000000000000000000000004', '0351234564', N'Tuấn', N'Lộc', N'Văn', N'Kỹ thuật Điện tử', N'Việt Nam', '2005-11-04', 3),
    ('lan.tran@hcmut.edu.vn', '$2b$10$studentHash00000000000000000000000000000000000005', '0351234565', N'Lan', N'Thị', N'Trần', N'Quản lý Công nghiệp', N'Việt Nam', '2006-06-30', 5);
GO

INSERT INTO Teacher (ID, Academic_Rank, Qualification)
VALUES
    (1, N'Không có', N'Thạc sĩ'),
    (2, N'Phó Giáo sư', N'Tiến sĩ'),
    (3, N'Phó Giáo sư', N'Tiến sĩ'),
    (4, N'Không có', N'Tiến sĩ'),
    (5, N'Không có', N'Tiến sĩ');
GO

INSERT INTO Student (ID, Academic_Year, Total_Credits)
VALUES
    (6, 2024, 72),
    (7, 2024, 75),
    (8, 2024, 68),
    (9, 2023, 104),
    (10, 2024, 64);
GO

INSERT INTO Session (Course_Code, Semester, Education_Program, Number_Order)
VALUES
    ('CO2014', '261', 'CLC', 'CC01'),
    ('CO2014', '261', 'CLC', 'CC06'),
    ('CO3061', '261', 'CLC', 'CC01'),
    ('MT1005', '261', 'DT', 'DT01'),
    ('EE2003', '261', 'CQ', 'L01');
GO

INSERT INTO Weekly_Schedule (Course_Code, Semester, Education_Program, Number_Order, Day, Start_time, Duration, Classroom)
VALUES
    ('CO2014', '261', 'CLC', 'CC01', 'Monday', '07:00:00', 100, 'B4-201'),
    ('CO2014', '261', 'CLC', 'CC06', 'Wednesday', '09:00:00', 150, 'C6-302'),
    ('CO3061', '261', 'CLC', 'CC01', 'Thursday', '13:00:00', 100, 'B1-212'),
    ('MT1005', '261', 'DT', 'DT01', 'Friday', '15:00:00', 150, 'B4-505'),
    ('EE2003', '261', 'CQ', 'L01', 'Saturday', '18:00:00', 150, 'B10-301');
GO

------------ PRINT ------------- 
SELECT * FROM Department;
SELECT * FROM Person;
SELECT * FROM Teacher;
SELECT * FROM Student;
SELECT * FROM Session;
SELECT * FROM Weekly_Schedule;
GO