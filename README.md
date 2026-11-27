# Database System Learning Management System

Dự án xây dựng hệ thống quản lý học tập trực tuyến lấy cảm hứng từ nền tảng BKeL của trường Đại học Bách Khoa, kết hợp cơ chế chấm điểm chéo của Coursera. Hệ thống tập trung giải quyết bài toán quản lý dữ liệu đào tạo, tài nguyên học tập, tự động hóa quy trình đánh giá và ràng buộc tiến độ học tập của sinh viên.

## Tài liệu tham khảo

Báo cáo thiết kế cơ sở dữ liệu Assignment 1 ([Bản xem trước trên Google Drive](https://drive.google.com/file/d/1D2y3Way7Zo8E7oUq76t2z18sshrrlU8R/view))

## Quy tắc làm việc nhóm

* Tuyệt đối không đẩy mã nguồn trực tiếp lên nhánh main.
* Mọi tính năng hoặc bản vá lỗi phải được thực hiện trên nhánh độc lập và tạo Pull Request.
* Bắt buộc thực hiện đánh giá chéo. Một Pull Request muốn được gộp phải có ít nhất một sự chấp thuận từ thành viên khác nhóm nghiệp vụ.
* Chủ nhân của Pull Request tự chịu trách nhiệm giải quyết các xung đột mã nguồn.
* Các tệp lệnh cấu trúc bảng và dữ liệu mẫu tuân thủ nguyên tắc tiến không lùi. Các tệp lệnh chứa logic thủ tục, hàm, trigger áp dụng nguyên tắc ghi đè tại chỗ.

## Cấu trúc thư mục

Kho lưu trữ hiện có các tệp và thư mục sau.

```text
/
├── scripts/
│   └── reset_db.ps1
├── staging_1.1/
├── staging_2.1/
├── staging_2.2/
│   └── README.md
├── 01_create_table_1.1.sql
├── 02_seed_data_1.2.sql
├── 03_alter_student_total_credits.sql
├── 04_procedures_2.1.sql
├── 05_triggers_2.2.sql
├── README.md
└── reset_db.bat
```

### Vai trò 5 tệp SQL tại thư mục gốc

Toàn bộ bộ script chạy tuần tự từ `01` đến `05` để dựng trọn vẹn cơ sở dữ liệu `bk_db_ass2` từ trạng thái trắng.

| Thứ tự | Tệp SQL | Giai đoạn | Nguyên tắc thay đổi | Bối cảnh và vai trò hiện tại |
| --- | --- | --- | --- | --- |
| 01 | `01_create_table_1.1.sql` | Phần 1.1 | Tiến không lùi | Tạo cơ sở dữ liệu `bk_db_ass2` cùng toàn bộ 19 bảng vật lý, khóa chính, khóa ngoại và ràng buộc `CHECK` / `UNIQUE` chính thức. |
| 02 | `02_seed_data_1.2.sql` | Phần 1.2 | Tiến không lùi | Nạp 268 dòng dữ liệu mẫu đồng nhất cho cả 19 bảng theo kịch bản 10 sinh viên (`SV1` đến `SV10`) phục vụ kiểm thử thủ tục và trigger. |
| 03 | `03_alter_student_total_credits.sql` | Tiền đề 2.2 | Tiến không lùi | Migration bổ sung cột dẫn xuất `Student.Total_Credits` cùng `CK_Student_TotalCredits` và tính sẵn tổng tín chỉ ban đầu cho 10 sinh viên. Tách thành tệp `03` thay vì sửa thẳng vào `01` để giữ đúng nguyên tắc không sửa ngược lược đồ gốc. |
| 04 | `04_procedures_2.1.sql` | Phần 2.1 | Ghi đè tại chỗ | Gộp trọn 4 stored procedure quản lý bài nộp (`sp_DeleteSubmission`, `sp_InsertSubmission`, `sp_UpdateSubmission`, `sp_GradeSubmission`) với đầy đủ kiểm tra nghiệp vụ và xử lý giao dịch. |
| 05 | `05_triggers_2.2.sql` | Phần 2.2 | Ghi đè tại chỗ | Tệp đặt chỗ (hiện đang rỗng 0 byte, được runner bỏ qua an toàn) để chuẩn bị gộp 5 trigger sau khi nhóm hoàn tất phát triển song song trong [`staging_2.2/README.md`](staging_2.2/README.md). |

### Thư mục hỗ trợ và thư mục staging

* `reset_db.bat` và `scripts/reset_db.ps1` xóa sạch và khởi tạo lại `bk_db_ass2` trên Windows theo đúng thứ tự `01` đến `05`, bỏ qua tệp trống và in báo cáo kiểm chứng gồm 19 bảng, số dòng, Stored Procedure, Trigger và Function.
* `staging_1.1/`, `staging_2.1/` và `staging_2.2/` chứa mã nguồn nháp độc lập và tài liệu phân công của từng thành viên cho các giai đoạn 1.1, 2.1 và 2.2 nhằm tránh xung đột khi làm việc song song. Chi tiết phân công phần 2.2 xem tại [`staging_2.2/README.md`](staging_2.2/README.md).

## Quy trình khởi tạo và reset cơ sở dữ liệu

Bạn có thể dựng mới hoặc làm sạch `bk_db_ass2` bằng một trong hai cách dưới đây.

### Cách 1. Chạy tự động bằng reset_db.bat (khuyên dùng)

Tập lệnh `reset_db.bat` tự phát hiện instance SQL Server cục bộ (`localhost` hoặc `.\SQLEXPRESS`), xóa sạch cơ sở dữ liệu `bk_db_ass2` cũ kể cả khi bảng hoặc dữ liệu đang lỗi, rồi chạy tuần tự mọi tệp `01_*.sql` đến `05_*.sql` ở thư mục gốc theo đúng thứ tự số (tự động gắn `[SKIP]` cho tệp trống).

1. Nhấp đúp tệp `reset_db.bat` ở thư mục gốc của kho lưu trữ. Nếu chạy từ PowerShell hoặc Command Prompt, thực thi lệnh sau.

```powershell
.\reset_db.bat
```

2. Nếu máy dùng SQL Server Express hoặc một named instance riêng, truyền tên instance qua tham số `-Server`.

```powershell
.\reset_db.bat -Server ".\SQLEXPRESS"
```

3. Kiểm tra bảng thống kê số dòng của 19 bảng cùng số lượng `Procedures`, `Triggers` và `Functions` được in ra khi hoàn tất.
4. Mở SQL Server Management Studio (SSMS) và bấm **Refresh** trên `bk_db_ass2` để xem cấu trúc và dữ liệu mới.

### Cách 2. Chạy thủ công trong SSMS

Dùng cách này khi bạn muốn chạy trực tiếp từng tệp lệnh trong SQL Server Management Studio.

1. Mở SSMS và kết nối tới máy chủ SQL Server cục bộ.
2. Mở tệp `01_create_table_1.1.sql` và nhấn **Execute (F5)** để tạo cơ sở dữ liệu `bk_db_ass2` và 19 bảng.
3. Mở và chạy lần lượt `02_seed_data_1.2.sql`, `03_alter_student_total_credits.sql` và `04_procedures_2.1.sql` theo đúng thứ tự tăng dần.
4. Khi nhóm gộp xong `05_triggers_2.2.sql` (hoặc các tệp đánh số tiếp theo), tiếp tục mở và nhấn **Execute (F5)** theo đúng thứ tự số.

## Cấu hình môi trường

Phần này đang được để trống và sẽ cập nhật danh sách các biến môi trường cần thiết ở giai đoạn code web application.

## Quy trình cài đặt ứng dụng

Phần này đang được để trống và sẽ bổ sung hướng dẫn cài đặt chi tiết máy chủ Node.js và giao diện React sau khi hoàn thiện mã nguồn.

## Điểm nhấn kỹ thuật

* Thiết lập cơ sở dữ liệu vật lý với đầy đủ khóa chính, khóa ngoại, ràng buộc dữ liệu và dữ liệu mẫu sát thực tế.
* Xây dựng hệ thống Stored Procedure xử lý các thao tác thêm, sửa, xóa với cơ chế xác thực dữ liệu chặt chẽ và thông báo lỗi tường minh bằng RAISERROR.
* Triển khai Trigger để tự động chặn các vi phạm nghiệp vụ và tính toán các thuộc tính dẫn xuất theo hiệu ứng dây chuyền.
* Tối ưu hóa các Stored Procedure truy vấn và báo cáo, ứng dụng linh hoạt các kỹ thuật gom nhóm, hàm thống kê và liên kết nhiều bảng.
* Lập trình Function tính toán phức tạp sử dụng con trỏ và các cấu trúc điều khiển luồng.
* Xây dựng giao diện ứng dụng kết nối trực tiếp với cơ sở dữ liệu, hỗ trợ tìm kiếm, sắp xếp và bắt lỗi logic từ tầng dữ liệu đẩy lên.

## Thông tin dự án

**Lớp** CC06.Group 7 (Học kỳ 261)
**Giảng viên hướng dẫn**

* Dương Huỳnh Anh Đức (lab session)
* Trương Tuấn Anh (theory session)

**Danh sách thành viên**

| Họ và tên | Mã số sinh viên | Vai trò chính |
| --- | --- | --- |
| Lương Thế Hoàng | 2453471 | Lead, DDL tổng, Seed data, Insert Submission, Domino Tầng 1 |
| Hoàng Lâm Đăng Khôi | 2452575 | Update Submission, Domino Tầng 2 (`Total_Credits`) |
| Nguyễn Quốc Việt | 2453415 | Grade Submission, Check Prerequisite (`Enrolls`) |
| Văn Lộc Tuấn | 2453372 | Delete Submission, No-Cycle Prerequisite (`Is_Prerequisite_To`), Demo 2.2 |
