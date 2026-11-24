USE bk_db_ass2;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM Department)
BEGIN
    PRINT N'Database bk_db_ass2 already contains seed data. Skipping.';
    RETURN;
END

BEGIN TRANSACTION;

SET IDENTITY_INSERT Department ON;

INSERT INTO Department (ID, Name, Hotline)
VALUES
    (1, N'Khoa Khoa học và Kỹ thuật Máy tính (Faculty of Computer Science and Engineering)', '02838647256'),
    (2, N'Khoa Khoa học Ứng dụng (Faculty of Applied Science)', '02838637773'),
    (3, N'Khoa Điện - Điện tử (Faculty of Electrical and Electronics Engineering)', '02838654357'),
    (4, N'Khoa Quản lý Công nghiệp (School of Industrial Management)', '02838647257'),
    (5, N'Khoa Cơ khí (Faculty of Mechanical Engineering)', '02873014183'),
    (6, N'Khoa Kỹ thuật Hóa học (Faculty of Chemical Engineering)', '02822146888');

SET IDENTITY_INSERT Department OFF;

SET IDENTITY_INSERT Person ON;

INSERT INTO Person (
    ID, Email, Password_Hash, Phone_Number,
    First_Name, Middle_Name, Last_Name,
    Specialty, Country, Birthday, Department_ID
)
VALUES
    (1,  'ttanh@hcmut.edu.vn',           '$2b$10$hcmutSeedHashTeacher01aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0901000001', N'Anh',    N'Tuấn',      N'Trương',   N'Hệ thống Cơ sở Dữ liệu',   N'Việt Nam', '1975-03-15', 1),
    (2,  'dhaduc@hcmut.edu.vn',          '$2b$10$hcmutSeedHashTeacher02aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0901000002', N'Đức',    N'Huỳnh Anh', N'Dương',    N'Công nghệ Phần mềm',       N'Việt Nam', '1990-08-20', 1),
    (3,  'ptan@hcmut.edu.vn',            '$2b$10$hcmutSeedHashTeacher03aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0901000003', N'An',     N'Thành',     N'Phan',     N'Toán Giải tích Ứng dụng',  N'Việt Nam', '1972-11-10', 2),
    (4,  'nddung@hcmut.edu.vn',          '$2b$10$hcmutSeedHashTeacher04aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0901000004', N'Dũng',   N'Đức',       N'Nguyễn',   N'Khoa học Máy tính',        N'Việt Nam', '1974-05-05', 1),
    (5,  'fbaldacci@hcmut.edu.vn',       '$2b$10$hcmutSeedHashTeacher05aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0901000005', N'Fabien', NULL,         N'Baldacci', N'Trí tuệ Nhân tạo',         N'Pháp',     '1982-06-18', 1),
    (6,  'nbnguyen@hcmut.edu.vn',        '$2b$10$hcmutSeedHashTeacher06aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0901000006', N'Nguyên', N'Bắc',       N'Nguyễn',   N'Quản lý Hệ thống Công nghiệp', N'Việt Nam', '1980-01-25', 4),
    (7,  'hoang.luong240101@hcmut.edu.vn', '$2b$10$hcmutSeedHashStudent07aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000001', N'Hoàng',  N'Thế',       N'Lương',    N'Khoa học Máy tính',        N'Việt Nam', '2006-02-01', 1),
    (8,  'khoi.hoang240202@hcmut.edu.vn',  '$2b$10$hcmutSeedHashStudent08aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000002', N'Khôi',   N'Lâm Đăng',  N'Hoàng',    N'Khoa học Máy tính',        N'Việt Nam', '2006-04-12', 1),
    (9,  'viet.nguyen240303@hcmut.edu.vn', '$2b$10$hcmutSeedHashStudent09aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000003', N'Việt',   N'Quốc',      N'Nguyễn',   N'Kỹ thuật Máy tính',        N'Việt Nam', '2006-05-19', 1),
    (10, 'tuan.van230404@hcmut.edu.vn',    '$2b$10$hcmutSeedHashStudent10aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000004', N'Tuấn',   N'Lộc',       N'Văn',      N'Kỹ thuật Điện - Điện tử',  N'Việt Nam', '2005-08-22', 3),
    (11, 'lan.tran240505@hcmut.edu.vn',    '$2b$10$hcmutSeedHashStudent11aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000005', N'Lan',    N'Thị',       N'Trần',     N'Khoa học Máy tính',        N'Việt Nam', '2006-03-14', 1),
    (12, 'quan.pham240606@hcmut.edu.vn',   '$2b$10$hcmutSeedHashStudent12aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000006', N'Quân',   N'Minh',      N'Phạm',     N'Kỹ thuật Máy tính',        N'Việt Nam', '2006-07-08', 1),
    (13, 'tram.le240707@hcmut.edu.vn',     '$2b$10$hcmutSeedHashStudent13aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000007', N'Trâm',   N'Ngọc Bảo',  N'Lê',       N'Khoa học Máy tính',        N'Việt Nam', '2006-09-25', 1),
    (14, 'huy.do240808@hcmut.edu.vn',      '$2b$10$hcmutSeedHashStudent14aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000008', N'Huy',    N'Gia',       N'Đỗ',       N'Kỹ thuật Hóa học',         N'Việt Nam', '2006-11-03', 6),
    (15, 'vy.vu240909@hcmut.edu.vn',       '$2b$10$hcmutSeedHashStudent15aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000009', N'Vy',     N'Thảo',      N'Vũ',       N'Kỹ thuật Cơ khí',          N'Việt Nam', '2006-06-17', 5),
    (16, 'khanh.bui241010@hcmut.edu.vn',   '$2b$10$hcmutSeedHashStudent16aBcDeFgHiJkLmNoPqRsTuVwXyZ01234', '0351000010', N'Khánh',  N'Quốc',      N'Bùi',      N'Toán Ứng dụng',            N'Việt Nam', '2006-09-02', 2);

SET IDENTITY_INSERT Person OFF;

INSERT INTO Teacher (ID, Academic_Rank, Qualification)
VALUES
    (1, N'Phó Giáo sư', N'Tiến sĩ'),
    (2, N'Không có',    N'Thạc sĩ'),
    (3, N'Phó Giáo sư', N'Tiến sĩ'),
    (4, N'Giáo sư',     N'Tiến sĩ'),
    (5, N'Không có',    N'Tiến sĩ'),
    (6, N'Không có',    N'Tiến sĩ');

INSERT INTO Student (ID, Academic_Year)
VALUES
    (7,  2024),
    (8,  2024),
    (9,  2024),
    (10, 2023),
    (11, 2024),
    (12, 2024),
    (13, 2024),
    (14, 2024),
    (15, 2024),
    (16, 2024);

INSERT INTO Course (Code, Title, Number_Of_Credits, Syllabus, Department_ID)
VALUES
    ('CO1005', N'Nhập môn Điện toán (Introduction to Computing)', 3, N'Tổng quan về hệ thống máy tính, biểu diễn dữ liệu, tư duy thuật toán và lập trình cơ bản.', 1),
    ('CO1007', N'Cấu trúc Rời rạc cho Khoa học Máy tính (Discrete Structures for Computing)', 4, N'Logic mệnh đề, vị từ, tập hợp, quan hệ, đồ thị, cây và đại số Boolean ứng dụng trong tin học.', 1),
    ('CO1027', N'Kỹ thuật Lập trình (Programming Fundamentals)', 3, N'Cú pháp C++, con trỏ, cấp phát động, đệ quy, lập trình hướng đối tượng và thiết kế mô-đun.', 1),
    ('CO2003', N'Cấu trúc Dữ liệu và Giải thuật (Data Structures and Algorithms)', 4, N'Danh sách liên kết, ngăn xếp, hàng đợi, cây tìm kiếm nhị phân, cây AVL, bảng băm, đồ thị và thuật toán sắp xếp.', 1),
    ('CO2013', N'Hệ Cơ sở Dữ liệu (Database Systems)', 4, N'Mô hình EERD, mô hình quan hệ, đại số quan hệ, chuẩn hóa, SQL, thủ tục lưu trữ, trigger và quản lý giao tác.', 1),
    ('CO2017', N'Hệ Điều hành (Operating Systems)', 3, N'Tiến trình, tiểu trình, định thời CPU, đồng bộ hóa, tắc nghẽn, quản lý bộ nhớ và hệ thống tập tin.', 1),
    ('CO3001', N'Công nghệ Phần mềm (Software Engineering)', 3, N'Quy trình phát triển phần mềm, đặc tả yêu cầu, kiến trúc hệ thống, thiết kế UML, kiểm thử và bảo trì.', 1),
    ('CO3061', N'Nhập môn Trí tuệ Nhân tạo (Introduction to Artificial Intelligence)', 3, N'Tìm kiếm có thông tin, bài toán thỏa mãn ràng buộc, logic học, suy diễn xác suất và học máy cơ bản.', 1),
    ('CO3093', N'Mạng Máy tính (Computer Networks)', 3, N'Kiến trúc tầng mạng TCP/IP, lập trình socket, tầng ứng dụng, giao vận, mạng và liên kết dữ liệu.', 1),
    ('MT1003', N'Giải tích 1 (Calculus 1)', 4, N'Giới hạn, đạo hàm, tích phân hàm một biến, phương trình vi phân cấp 1 và cấp 2.', 2),
    ('MT1005', N'Giải tích 2 (Calculus 2)', 4, N'Hàm nhiều biến, tích phân bội, tích phân đường, tích phân mặt và lý thuyết chuỗi số.', 2),
    ('CH1003', N'Hóa Đại cương (General Chemistry)', 3, N'Cấu tạo nguyên tử, liên kết hóa học, nhiệt động học hóa học, động hóa học và dung dịch điện ly.', 6);

INSERT INTO Is_Prerequisite_To (Pre_Course_Code, Post_Course_Code)
VALUES
    ('CO1005', 'CO1027'),
    ('CO1027', 'CO2003'),
    ('CO1007', 'CO2003'),
    ('CO2003', 'CO2013'),
    ('CO2003', 'CO3061'),
    ('CO2013', 'CO3001'),
    ('MT1003', 'MT1005');

INSERT INTO Session (Course_Code, Semester, Education_Program, Number_Order, Teacher_ID)
VALUES
    ('CO1005', '241', 'CLC',  'CC01', 4),
    ('MT1003', '241', 'CLC',  'CC01', 3),
    ('CO1005', '242', 'CLC',  'CC02', 4),
    ('CO1027', '242', 'CLC',  'CC01', 4),
    ('CO1007', '242', 'CLC',  'CC01', 6),
    ('MT1005', '242', 'DT',   'DT01', 3),
    ('CO1027', '251', 'CLC',  'CC01', 4),
    ('CO1007', '251', 'CLC',  'CC01', 6),
    ('CO2003', '251', 'CLC',  'CC03', 4),
    ('CO2003', '252', 'CLC',  'CC01', 4),
    ('CO2013', '252', 'CLC',  'CC01', 1),
    ('CO2017', '252', 'CLC',  'CC01', 5),
    ('CO2013', '261', 'CLC',  'CC01', 1),
    ('CO2013', '261', 'CLC',  'CC06', 1),
    ('CO3001', '261', 'CLC',  'CC01', 2),
    ('CO3061', '261', 'CLC',  'CC01', 5),
    ('CO3093', '261', 'CQ',   'L01',  4),
    ('CH1003', '261', 'KSTN', 'TN01', 6);

INSERT INTO Weekly_Schedule (
    Course_Code, Semester, Education_Program, Number_Order,
    Day, Start_Time, Duration, Classroom
)
VALUES
    ('CO1005', '241', 'CLC',  'CC01', 'Monday',    '07:00:00', 100, 'B4-201'),
    ('MT1003', '241', 'CLC',  'CC01', 'Tuesday',   '07:00:00', 150, 'H1-201'),
    ('CO1005', '242', 'CLC',  'CC02', 'Monday',    '09:00:00', 100, 'B4-201'),
    ('CO1027', '242', 'CLC',  'CC01', 'Wednesday', '07:00:00', 150, 'C6-302'),
    ('CO1007', '242', 'CLC',  'CC01', 'Thursday',  '12:00:00', 150, 'H6-305'),
    ('MT1005', '242', 'DT',   'DT01', 'Friday',    '07:00:00', 150, 'H1-201'),
    ('CO1027', '251', 'CLC',  'CC01', 'Tuesday',   '07:00:00', 150, 'C6-302'),
    ('CO1007', '251', 'CLC',  'CC01', 'Wednesday', '12:00:00', 150, 'H6-305'),
    ('CO2003', '251', 'CLC',  'CC03', 'Thursday',  '09:00:00', 150, 'B1-306'),
    ('CO2003', '252', 'CLC',  'CC01', 'Monday',    '14:00:00', 150, 'B1-306'),
    ('CO2013', '252', 'CLC',  'CC01', 'Wednesday', '07:00:00', 150, 'C4-304'),
    ('CO2017', '252', 'CLC',  'CC01', 'Tuesday',   '14:00:00', 110, 'C4-304'),
    ('CO2013', '261', 'CLC',  'CC01', 'Monday',    '07:00:00', 120, 'C4-304'),
    ('CO2013', '261', 'CLC',  'CC06', 'Monday',    '09:00:00', 100, 'C6-PM1'),
    ('CO3001', '261', 'CLC',  'CC01', 'Tuesday',   '12:00:00', 150, 'B4-201'),
    ('CO3061', '261', 'CLC',  'CC01', 'Wednesday', '14:00:00', 150, 'B1-306'),
    ('CO3093', '261', 'CQ',   'L01',  'Thursday',  '16:00:00', 150, 'C6-302'),
    ('CH1003', '261', 'KSTN', 'TN01', 'Friday',    '18:00:00', 120, 'H1-201');

INSERT INTO Enrolls (
    Student_ID, Course_Code, Semester, Education_Program, Number_Order, Final_Score
)
VALUES
    (7,  'CO1005', '241', 'CLC',  'CC01', 8.50),
    (7,  'MT1003', '241', 'CLC',  'CC01', 8.50),
    (7,  'CO1027', '242', 'CLC',  'CC01', 8.80),
    (7,  'CO1007', '242', 'CLC',  'CC01', 8.20),
    (7,  'MT1005', '242', 'DT',   'DT01', 8.00),
    (7,  'CO2003', '251', 'CLC',  'CC03', 9.00),
    (7,  'CO2017', '252', 'CLC',  'CC01', 8.60),
    (7,  'CO2013', '261', 'CLC',  'CC06', NULL),
    (7,  'CO3093', '261', 'CQ',   'L01',  NULL),
    (8,  'CO1005', '241', 'CLC',  'CC01', 8.00),
    (8,  'CO1027', '242', 'CLC',  'CC01', 8.20),
    (8,  'CO1007', '242', 'CLC',  'CC01', 7.80),
    (8,  'CO2003', '251', 'CLC',  'CC03', 8.40),
    (8,  'CO2017', '252', 'CLC',  'CC01', 7.90),
    (8,  'CO2013', '261', 'CLC',  'CC06', NULL),
    (8,  'CO3061', '261', 'CLC',  'CC01', NULL),
    (8,  'CO3093', '261', 'CQ',   'L01',  NULL),
    (9,  'CO1005', '241', 'CLC',  'CC01', 7.60),
    (9,  'CO1027', '242', 'CLC',  'CC01', 7.40),
    (9,  'CO1007', '242', 'CLC',  'CC01', 7.00),
    (9,  'CO2003', '251', 'CLC',  'CC03', 7.50),
    (9,  'CO2017', '252', 'CLC',  'CC01', NULL),
    (9,  'CO2013', '261', 'CLC',  'CC06', NULL),
    (10, 'CO1005', '241', 'CLC',  'CC01', 8.90),
    (10, 'CO1027', '242', 'CLC',  'CC01', 8.60),
    (10, 'CO1007', '242', 'CLC',  'CC01', 8.40),
    (10, 'CO2003', '251', 'CLC',  'CC03', 8.70),
    (10, 'CO2013', '252', 'CLC',  'CC01', 8.25),
    (10, 'CO2013', '261', 'CLC',  'CC06', NULL),
    (10, 'CO3001', '261', 'CLC',  'CC01', NULL),
    (11, 'CO1005', '241', 'CLC',  'CC01', 3.50),
    (11, 'MT1003', '241', 'CLC',  'CC01', 4.00),
    (11, 'CO1005', '242', 'CLC',  'CC02', 7.50),
    (11, 'CO1027', '251', 'CLC',  'CC01', 7.20),
    (11, 'CO1007', '251', 'CLC',  'CC01', 6.80),
    (11, 'CO2003', '252', 'CLC',  'CC01', 7.00),
    (11, 'CO2013', '261', 'CLC',  'CC06', NULL),
    (12, 'CO1005', '241', 'CLC',  'CC01', 5.50),
    (12, 'MT1003', '241', 'CLC',  'CC01', 5.20),
    (12, 'CO1027', '242', 'CLC',  'CC01', 6.00),
    (12, 'CO1007', '242', 'CLC',  'CC01', 5.80),
    (12, 'CO2003', '251', 'CLC',  'CC03', 6.20),
    (12, 'CO2013', '261', 'CLC',  'CC06', NULL),
    (13, 'CO1005', '241', 'CLC',  'CC01', 8.20),
    (13, 'CO1027', '242', 'CLC',  'CC01', 8.40),
    (13, 'CO1007', '242', 'CLC',  'CC01', 8.10),
    (13, 'CO2003', '251', 'CLC',  'CC03', 8.30),
    (13, 'CO2013', '261', 'CLC',  'CC01', NULL),
    (14, 'CO1007', '242', 'CLC',  'CC01', 7.50),
    (14, 'CH1003', '261', 'KSTN', 'TN01', NULL),
    (15, 'CO1005', '241', 'CLC',  'CC01', 7.80),
    (15, 'CO1027', '242', 'CLC',  'CC01', 7.60),
    (15, 'CO1007', '242', 'CLC',  'CC01', 7.90),
    (15, 'CO2003', '251', 'CLC',  'CC03', 7.70),
    (15, 'CO2013', '261', 'CLC',  'CC06', NULL);

SET IDENTITY_INSERT Resource ON;

INSERT INTO Resource (ID, Open_Date, Description, Upload_Time, Title)
VALUES
    (1,  '2026-09-15', N'Bài trắc nghiệm ôn tập Chương 1 và Chương 2 về mô hình thực thể kết hợp (ERD/EERD).', '2026-09-14T08:00:00', N'Quiz 1: Chapter 1-2 ERD Revision'),
    (2,  '2026-10-01', N'Bài trắc nghiệm về đại số quan hệ, phép nối và truy vấn SQL cơ bản.', '2026-09-30T09:00:00', N'Quiz 2: Relational Algebra & SQL'),
    (3,  '2026-02-03', N'Kiểm tra kiến thức về quản lý tiến trình, tiểu trình và định thời CPU.', '2026-02-02T10:00:00', N'Quiz 3: Process & Thread'),
    (4,  '2026-03-01', N'Kiểm tra kiến thức về đồng bộ hóa tiến trình, mutex, semaphore và deadlock.', '2026-02-28T10:00:00', N'Quiz 4: Synchronization'),
    (5,  '2025-09-10', N'Bài luyện tập tự do cấu trúc dữ liệu và giải thuật không giới hạn số lần làm.', '2025-09-09T08:30:00', N'Practice Quiz: DSA Review'),
    (6,  '2026-10-15', N'Bài trắc nghiệm tầng mạng, định tuyến IP và giao thức ICMP.', '2026-10-14T14:00:00', N'Quiz 1: Network Layer'),
    (7,  '2026-09-20', N'Bài tập lớn phần 1: Thiết kế mô hình EERD và chuyển đổi sang lược đồ quan hệ chuẩn 3NF.', '2026-09-19T09:00:00', N'Assignment 1: EERD & Relational Mapping'),
    (8,  '2026-11-01', N'Bài tập lớn phần 2: Cài đặt cơ sở dữ liệu, thủ tục lưu trữ, trigger và hàm trên SQL Server.', '2026-10-31T10:00:00', N'Assignment 2: SQL Server Database Implementation'),
    (9,  '2026-09-18', N'Bài thực hành 1: Vẽ lược đồ ERD cho hệ thống quản lý học tập BK-LMS.', '2026-09-17T08:00:00', N'Lab 1: ERD Modeling'),
    (10, '2026-10-10', N'Bài thực hành 2: Mô hình EERD mở rộng và ánh xạ quan hệ.', '2026-10-09T08:00:00', N'Lab 2: EERD & Relational Model'),
    (11, '2026-11-05', N'Bài thực hành 4: Lập trình ứng dụng client-server sử dụng TCP/UDP Socket.', '2026-11-04T15:00:00', N'Lab 4: Socket Programming'),
    (12, '2026-10-01', N'Lập kế hoạch dự án và đặc tả yêu cầu phần mềm theo chuẩn IEEE SRS.', '2026-09-30T11:00:00', N'Project Plan: Software Requirements'),
    (13, '2026-09-05', N'Đề cương chi tiết môn Hệ Cơ sở Dữ liệu CO2013 học kỳ 261.', '2026-09-04T08:00:00', N'Course Syllabus - CO2013'),
    (14, '2026-09-07', N'Bài giảng Chương 1: Tổng quan về hệ quản trị cơ sở dữ liệu.', '2026-09-06T09:00:00', N'Chap 1. Overview'),
    (15, '2026-09-14', N'Bài giảng Chương 2b: Mô hình thực thể kết hợp mở rộng EERD.', '2026-09-13T09:00:00', N'Chap 2b. EERD'),
    (16, '2026-09-21', N'Bài giảng Chương 3: Mô hình dữ liệu quan hệ và ràng buộc toàn vẹn.', '2026-09-20T09:00:00', N'Chap 3. Relational Data Model'),
    (17, '2026-10-05', N'Bài giảng Chương 4: Ngôn ngữ truy vấn SQL và SQL nâng cao.', '2026-10-04T09:00:00', N'Chap 4. SQL & Advanced SQL'),
    (18, '2026-09-10', N'Tài liệu hướng dẫn thí nghiệm Hóa Đại cương CH1003.', '2026-09-09T13:00:00', N'Lab Guide: General Chemistry');

SET IDENTITY_INSERT Resource OFF;

INSERT INTO Quiz (ID, Attempt_Limit, Time_Limit, Grade_To_Pass, Deadline)
VALUES
    (1, 3,    1800,  5.00, '2026-12-20T23:59:00'),
    (2, 3,    900,   6.00, '2026-11-10T23:59:00'),
    (3, 2,    900,   5.00, '2026-05-15T23:59:00'),
    (4, 3,    1200,  5.00, '2026-06-05T23:59:00'),
    (5, NULL, 86400, 0.00, NULL),
    (6, 2,    600,   5.00, '2026-12-28T23:59:00');

INSERT INTO Assignment (ID, Number_Of_Review_Require, Deadline)
VALUES
    (7,  2, '2026-10-18T23:59:00'),
    (8,  2, '2026-12-25T23:59:00'),
    (9,  0, '2026-10-05T11:50:00'),
    (10, 2, '2026-11-01T11:50:00'),
    (11, 1, '2026-12-20T23:59:00'),
    (12, 1, '2026-11-10T23:59:00');

INSERT INTO File_material (ID, File_Url)
VALUES
    (13, 'https://lms.hcmut.edu.vn/mod/resource/view.php?id=701001'),
    (14, 'https://lms.hcmut.edu.vn/mod/resource/view.php?id=701002'),
    (15, 'https://lms.hcmut.edu.vn/mod/resource/view.php?id=701003'),
    (16, 'https://lms.hcmut.edu.vn/mod/resource/view.php?id=701004'),
    (17, 'https://lms.hcmut.edu.vn/mod/resource/view.php?id=701005'),
    (18, 'https://lms.hcmut.edu.vn/mod/resource/view.php?id=701006');

INSERT INTO Creates (Teacher_ID, Resource_ID, Upload_Person)
VALUES
    (1, 1,  1),
    (1, 2,  1),
    (5, 3,  1),
    (5, 4,  1),
    (4, 5,  1),
    (4, 6,  1),
    (1, 7,  1),
    (1, 8,  1),
    (1, 9,  1),
    (1, 10, 1),
    (4, 11, 1),
    (2, 12, 1),
    (1, 13, 1),
    (1, 14, 1),
    (1, 15, 1),
    (1, 16, 1),
    (1, 17, 1),
    (6, 18, 1),
    (2, 7,  0),
    (2, 8,  0),
    (2, 13, 0);

INSERT INTO Includes (
    Resource_ID, Course_Code, Semester, Education_Program, Number_Order
)
VALUES
    (1,  'CO2013', '261', 'CLC',  'CC01'),
    (1,  'CO2013', '261', 'CLC',  'CC06'),
    (2,  'CO2013', '261', 'CLC',  'CC01'),
    (2,  'CO2013', '261', 'CLC',  'CC06'),
    (3,  'CO2017', '252', 'CLC',  'CC01'),
    (4,  'CO2017', '252', 'CLC',  'CC01'),
    (5,  'CO2003', '251', 'CLC',  'CC03'),
    (6,  'CO3093', '261', 'CQ',   'L01'),
    (7,  'CO2013', '261', 'CLC',  'CC01'),
    (7,  'CO2013', '261', 'CLC',  'CC06'),
    (8,  'CO2013', '261', 'CLC',  'CC01'),
    (8,  'CO2013', '261', 'CLC',  'CC06'),
    (9,  'CO2013', '261', 'CLC',  'CC06'),
    (10, 'CO2013', '261', 'CLC',  'CC06'),
    (11, 'CO3093', '261', 'CQ',   'L01'),
    (12, 'CO3001', '261', 'CLC',  'CC01'),
    (13, 'CO2013', '261', 'CLC',  'CC06'),
    (14, 'CO2013', '261', 'CLC',  'CC06'),
    (15, 'CO2013', '261', 'CLC',  'CC06'),
    (16, 'CO2013', '261', 'CLC',  'CC06'),
    (17, 'CO2013', '261', 'CLC',  'CC06'),
    (18, 'CH1003', '261', 'KSTN', 'TN01');

INSERT INTO Attempt (Student_ID, Quiz_ID, Start_Time, Score, Duration)
VALUES
    (7,  1, '2026-09-20T09:00:00', 5.00, 1200),
    (7,  1, '2026-09-25T10:00:00', NULL, 600),
    (8,  2, '2026-10-05T14:00:00', 3.50, 720),
    (8,  2, '2026-10-12T14:30:00', 8.50, 840),
    (8,  2, '2026-10-20T15:00:00', 6.00, 900),
    (13, 1, '2026-09-22T08:30:00', 8.00, 1500),
    (7,  3, '2026-03-10T10:00:00', 8.50, 780),
    (8,  3, '2026-03-12T11:00:00', 7.50, 810),
    (7,  4, '2026-04-05T09:30:00', 9.00, 1050),
    (8,  4, '2026-04-06T16:00:00', 8.00, 1100),
    (7,  5, '2025-10-01T20:00:00', 9.50, 2400),
    (7,  6, '2026-10-20T19:00:00', 7.50, 540);

SET IDENTITY_INSERT Submission ON;

INSERT INTO Submission (ID, Assignment_ID, Student_ID, Title, Submit_Time, Final_Score)
VALUES
    (1, 8,  7,  N'Nộp bài Assignment 2 - Lược đồ SQL Server và Thủ tục', '2026-11-18T14:30:00', NULL),
    (2, 7,  8,  N'Báo cáo Assignment 1 - Thiết kế EERD và Chuẩn hóa 3NF', '2026-10-17T21:15:00', NULL),
    (3, 7,  9,  N'Assignment 1 - Mô hình thực thể kết hợp hệ thống BK-LMS', '2026-10-18T18:45:00', NULL),
    (4, 7,  10, N'Assignment 1 - Phân tích yêu cầu và Ánh xạ quan hệ', '2026-10-16T20:00:00', 8.75),
    (5, 7,  12, N'Assignment 1 - Nộp bổ sung bản hoàn chỉnh EERD', '2026-10-19T08:15:00', NULL),
    (6, 7,  13, N'Assignment 1 - Lược đồ EERD lớp CC01', '2026-10-18T23:59:00', NULL),
    (7, 9,  7,  N'Lab 1 - Lược đồ ERD cơ bản quản lý khóa học', '2026-10-04T10:30:00', NULL),
    (8, 10, 7,  N'Lab 2 - Lược đồ EERD mở rộng và bảng quan hệ', '2026-10-30T11:00:00', NULL),
    (9, 10, 8,  N'Lab 2 - Thiết kế phân cấp lớp con và ràng buộc khóa ngoại', '2026-10-31T09:45:00', NULL);

SET IDENTITY_INSERT Submission OFF;

INSERT INTO Submission_file_url (Submission_ID, Assignment_ID, Student_ID, File_Url)
VALUES
    (1, 8,  7,  'https://lms.hcmut.edu.vn/pluginfile.php/718101/assignsubmission_file/2453471_01_create_table.sql'),
    (1, 8,  7,  'https://lms.hcmut.edu.vn/pluginfile.php/718101/assignsubmission_file/2453471_report_ass2.pdf'),
    (2, 7,  8,  'https://lms.hcmut.edu.vn/pluginfile.php/717174/assignsubmission_file/CC06_SV2_Assignment1.pdf'),
    (3, 7,  9,  'https://lms.hcmut.edu.vn/pluginfile.php/717175/assignsubmission_file/CC06_SV3_Assignment1.pdf'),
    (4, 7,  10, 'https://lms.hcmut.edu.vn/pluginfile.php/717176/assignsubmission_file/CC06_SV4_Assignment1.pdf'),
    (4, 7,  10, 'https://lms.hcmut.edu.vn/pluginfile.php/717176/assignsubmission_file/CC06_SV4_EERD_Diagram.png'),
    (6, 7,  13, 'https://lms.hcmut.edu.vn/pluginfile.php/717177/assignsubmission_file/CC01_SV7_Assignment1.pdf'),
    (7, 9,  7,  'https://lms.hcmut.edu.vn/pluginfile.php/707370/assignsubmission_file/2453471_database_lab1.zip'),
    (8, 10, 7,  'https://lms.hcmut.edu.vn/pluginfile.php/708410/assignsubmission_file/2453471_database_lab2.pdf'),
    (9, 10, 8,  'https://lms.hcmut.edu.vn/pluginfile.php/708411/assignsubmission_file/2453472_database_lab2.pdf');

INSERT INTO Peer_review (
    Student_ID_Review, Submission_ID, Assignment_ID, Student_ID_Submit, Review_Date, Comment
)
VALUES
    (8,  3, 7,  9,  '2026-10-20T09:15:00', N'Mô hình EERD xác định đúng các thực thể yếu và bản số, cần bổ sung chú thích rõ hơn cho ràng buộc phủ toàn phần.'),
    (8,  4, 7,  10, '2026-10-20T10:00:00', N'Lược đồ quan hệ chuyển đổi chuẩn xác, khóa chính và khóa ngoại nhất quán với sơ đồ EERD.'),
    (9,  4, 7,  10, '2026-10-21T14:20:00', N'Báo cáo trình bày rõ ràng, phần phân tích quy tắc nghiệp vụ và chuẩn hóa 3NF rất thuyết phục.'),
    (9,  8, 10, 7,  '2026-11-03T08:45:00', N'Ánh xạ phân cấp lớp con tài nguyên bằng phương pháp tách bảng hợp lý, đảm bảo tính rời nhau.'),
    (9,  9, 10, 8,  '2026-11-03T09:30:00', N'Các ràng buộc khóa ngoại và miền giá trị đầy đủ, đề xuất bổ sung thêm ví dụ minh họa cho thực thể yếu.'),
    (10, 2, 7,  8,  '2026-10-21T16:10:00', N'Thiết kế EERD chặt chẽ, các quan hệ nhiều nhiều được tách thành bảng trung gian kèm thuộc tính hợp lý.'),
    (10, 3, 7,  9,  '2026-10-21T16:40:00', N'Cấu trúc khóa chính kết hợp cho Submission chính xác, cần kiểm tra lại cách đặt tên thuộc tính dẫn xuất.'),
    (12, 2, 7,  8,  '2026-10-22T11:05:00', N'Lược đồ quan hệ rõ ràng, thể hiện tốt quan hệ tiên quyết tự tham chiếu của bảng Course.'),
    (12, 6, 7,  13, '2026-10-22T11:40:00', N'Sơ đồ lớp CC01 đầy đủ các thực thể và thuộc tính khóa, trình bày mạch lạc và dễ theo dõi.'),
    (13, 4, 7,  10, '2026-10-23T15:00:00', N'Tài liệu phân tích tốt các ràng buộc ngoài chuẩn, bảng ánh xạ rõ ràng từ EERD sang mô hình quan hệ.');

COMMIT TRANSACTION;
GO
