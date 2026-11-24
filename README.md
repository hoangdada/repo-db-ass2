# Database System Learning Management System

Dự án xây dựng hệ thống quản lý học tập trực tuyến lấy cảm hứng từ nền tảng BKeL của trường Đại học Bách Khoa, kết hợp cơ chế chấm điểm chéo của Coursera. Hệ thống tập trung giải quyết bài toán quản lý dữ liệu đào tạo, tài nguyên học tập, tự động hóa quy trình đánh giá và ràng buộc tiến độ học tập của sinh viên.

## Tài liệu tham khảo

Báo cáo thiết kế cơ sở dữ liệu Assignment 1: [Bản xem trước trên Google Drive](https://drive.google.com/file/d/1D2y3Way7Zo8E7oUq76t2z18sshrrlU8R/view)

## Quy tắc làm việc nhóm

* Tuyệt đối không đẩy mã nguồn trực tiếp lên nhánh main.
* Mọi tính năng hoặc bản vá lỗi phải được thực hiện trên nhánh độc lập và tạo Pull Request.
* Bắt buộc thực hiện đánh giá chéo. Một Pull Request muốn được gộp phải có ít nhất một sự chấp thuận từ thành viên khác nhóm nghiệp vụ.
* Chủ nhân của Pull Request tự chịu trách nhiệm giải quyết các xung đột mã nguồn.
* Các tệp lệnh cấu trúc bảng và dữ liệu mẫu tuân thủ nguyên tắc tiến không lùi. Các tệp lệnh chứa logic thủ tục, hàm, trigger áp dụng nguyên tắc ghi đè tại chỗ.

## Cấu trúc thư mục

Kho lưu trữ hiện có các tệp và thư mục sau:

```text
/
├── scripts/
│   └── reset_db.ps1
├── staging/
├── staging_2.1/
├── 01_create_table.sql
├── 02_seed_data_1.2.sql
├── README.md
└── reset_db.bat
```

* `01_create_table.sql` tạo cơ sở dữ liệu `bk_db_ass2` và toàn bộ lược đồ bảng chính thức sau khi nhóm kiểm duyệt.
* `02_seed_data_1.2.sql` nạp dữ liệu mẫu cho `bk_db_ass2`.
* `reset_db.bat` và `scripts/reset_db.ps1` xóa sạch và khởi tạo lại `bk_db_ass2` trên Windows mà không cần chỉnh đường dẫn.
* `staging/` và `staging_2.1/` chứa mã nguồn nháp độc lập của từng thành viên cho các giai đoạn 1.1 và 2.1 để tránh xung đột khi gộp mã.

## Quy trình khởi tạo và reset cơ sở dữ liệu

Bạn có thể dựng mới hoặc làm sạch `bk_db_ass2` bằng một trong hai cách dưới đây.

### Cách 1. Chạy tự động bằng reset_db.bat (khuyên dùng)

Tập lệnh `reset_db.bat` tự phát hiện instance SQL Server cục bộ (`localhost` hoặc `.\SQLEXPRESS`), xóa sạch cơ sở dữ liệu `bk_db_ass2` cũ kể cả khi bảng hoặc dữ liệu đang lỗi, rồi chạy tuần tự mọi tệp `01_*.sql`, `02_*.sql` ở thư mục gốc theo đúng thứ tự số.

1. Nhấp đúp tệp `reset_db.bat` ở thư mục gốc của kho lưu trữ. Nếu chạy từ PowerShell hoặc Command Prompt, thực thi lệnh:

```powershell
.\reset_db.bat
```

2. Nếu máy dùng SQL Server Express hoặc một named instance riêng, truyền tên instance qua tham số `-Server`:

```powershell
.\reset_db.bat -Server ".\SQLEXPRESS"
```

3. Kiểm tra bảng thống kê số dòng của từng bảng được in ra khi hoàn tất.
4. Mở SQL Server Management Studio (SSMS) và bấm **Refresh** trên `bk_db_ass2` để xem cấu trúc và dữ liệu mới.

### Cách 2. Chạy thủ công trong SSMS

Dùng cách này khi bạn muốn chạy trực tiếp từng tệp lệnh trong SQL Server Management Studio.

1. Mở SSMS và kết nối tới máy chủ SQL Server cục bộ.
2. Mở tệp `01_create_table.sql` và nhấn **Execute (F5)**. Tệp này tự tạo `bk_db_ass2` nếu cơ sở dữ liệu chưa tồn tại.
3. Mở tệp `02_seed_data_1.2.sql` và nhấn **Execute (F5)**.
4. Nếu kho lưu trữ có thêm các tệp lệnh đánh số tiếp theo (`03_*.sql`, `04_*.sql`), mở và nhấn **Execute (F5)** theo đúng thứ tự tăng dần.

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

**Lớp:** CC06.Group 7 - Học kỳ 261
**Giảng viên hướng dẫn:**

* Dương Huỳnh Anh Đức (lab session)
* Trương Tuấn Anh (theory session)

**Danh sách thành viên:**

| Họ và tên | Mã số sinh viên | task |
| --- | --- | --- |
| Lương Thế Hoàng | 2453471 |  |
| Hoàng Lâm Đăng Khôi | 2452575 |  |
| Nguyễn Quốc Việt | 2453415 |  |
| Văn Lộc Tuấn | 2453372 |  |
