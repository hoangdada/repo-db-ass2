# Database System Learning Management System

Dự án xây dựng hệ thống quản lý học tập trực tuyến lấy cảm hứng từ nền tảng BKeL của trường Đại học Bách Khoa, kết hợp cơ chế chấm điểm chéo của Coursera. Hệ thống tập trung giải quyết bài toán quản lý dữ liệu đào tạo, tài nguyên học tập, tự động hóa quy trình đánh giá và ràng buộc tiến độ học tập của sinh viên.

## Thông tin dự án

**Lớp:** CC06.Group 7 - Học kỳ 261
**Giảng viên hướng dẫn:**

* Dương Huỳnh Anh Đức phần thực hành
* Trương Tuấn Anh phần lý thuyết

**Danh sách thành viên:**

| Họ và tên | Mã số sinh viên | task |
| --- | --- | --- |
| Lương Thế Hoàng | 2453471 |  |
| Hoàng Lâm Đăng Khôi | 2452575 |  |
| Nguyễn Quốc Việt | 2453415 |  |
| Văn Lộc Tuấn | 2453372 |  |

## Điểm nhấn kỹ thuật

* Thiết lập cơ sở dữ liệu vật lý với đầy đủ khóa chính, khóa ngoại, ràng buộc dữ liệu và dữ liệu mẫu sát thực tế.
* Xây dựng hệ thống Stored Procedure xử lý các thao tác thêm, sửa, xóa với cơ chế xác thực dữ liệu chặt chẽ và thông báo lỗi tường minh bằng RAISERROR.
* Triển khai Trigger để tự động chặn các vi phạm nghiệp vụ và tính toán các thuộc tính dẫn xuất theo hiệu ứng dây chuyền.
* Tối ưu hóa các Stored Procedure truy vấn và báo cáo, ứng dụng linh hoạt các kỹ thuật gom nhóm, hàm thống kê và liên kết nhiều bảng.
* Lập trình Function tính toán phức tạp sử dụng con trỏ và các cấu trúc điều khiển luồng.
* Xây dựng giao diện ứng dụng kết nối trực tiếp với cơ sở dữ liệu, hỗ trợ tìm kiếm, sắp xếp và bắt lỗi logic từ tầng dữ liệu đẩy lên.

## Quy tắc làm việc nhóm

* Tuyệt đối không đẩy mã nguồn trực tiếp lên nhánh main.
* Mọi tính năng hoặc bản vá lỗi phải được thực hiện trên nhánh độc lập và tạo Pull Request.
* Bắt buộc thực hiện đánh giá chéo. Một Pull Request muốn được gộp phải có ít nhất một sự chấp thuận từ thành viên khác nhóm nghiệp vụ.
* Chủ nhân của Pull Request tự chịu trách nhiệm giải quyết các xung đột mã nguồn.
* Các tệp lệnh cấu trúc bảng và dữ liệu mẫu tuân thủ nguyên tắc tiến không lùi. Các tệp lệnh chứa logic thủ tục, hàm, trigger áp dụng nguyên tắc ghi đè tại chỗ.

## Cấu trúc thư mục

Phần này đang được để trống và sẽ bổ sung sau khi hoàn thiện kiến trúc dự án.

## Cấu hình môi trường

Phần này đang được để trống và sẽ cập nhật danh sách các biến môi trường cần thiết ở giai đoạn tích hợp hệ thống.

## Quy trình cài đặt

Phần này đang được để trống và sẽ bổ sung hướng dẫn cài đặt chi tiết trên máy cá nhân sau.

## Quy trình chạy Database Migration

Để khởi tạo cơ sở dữ liệu, người dùng cần thực thi các tệp lệnh SQL trong thư mục dữ liệu theo đúng số thứ tự ở đầu tên tệp từ trên xuống dưới. Trong các bản cập nhật tiếp theo, nhóm sẽ bổ sung tệp cấu hình để tự động hóa toàn bộ quá trình chạy tập lệnh này.

## Tài liệu tham khảo

Báo cáo thiết kế cơ sở dữ liệu Assignment 1: [Bản xem trước trên Google Drive](https://drive.google.com/file/d/1D2y3Way7Zo8E7oUq76t2z18sshrrlU8R/view)
