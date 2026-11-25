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

Cấu trúc hiện tại của dự án được tổ chức như sau:

```text
/
├── staging/
│   ├── readme_1.1.md
│   ├── schema_issue#1.sql
│   ├── schema_issue#2.sql
│   ├── schema_issue#3.sql
│   └── schema_issue#4.sql
├── 01_create_table.sql
└── README.md
```

Thư mục staging dùng để chứa mã nguồn nháp độc lập của 4 thành viên, giúp phân tách không gian làm việc và tránh xung đột khi gộp mã. Tệp 01_create_table.sql là nơi tập hợp lược đồ cơ sở dữ liệu chính thức sau khi nhóm đã kiểm duyệt.

## Quy trình khởi tạo Cơ sở dữ liệu

Để thiết lập và chạy thử cơ sở dữ liệu trên máy tính cá nhân, vui lòng thực hiện tuần tự các bước sau:

1. Mở phần mềm SQL Server Management Studio và đăng nhập vào máy chủ cục bộ.
2. Tạo một cơ sở dữ liệu trống hoàn toàn mới.
3. Mở các tệp lệnh SQL trong kho lưu trữ bằng SQL Server Management Studio.
4. Thực thi các tệp lệnh tuần tự theo đúng số thứ tự tiền tố của tên tệp từ 01 trở đi.

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
