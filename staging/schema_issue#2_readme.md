# MÔ TẢ QUYẾT ĐỊNH THIẾT KẾ — PHẦN 2 (MỤC 1.1 & 1.2)

**Phạm vi bảng:** `Course`, `Is_Prerequisite_To`, `Session`, `Enrolls`  
**Hệ quản trị:** MS SQL Server (T-SQL)

---

## 1. Quy ước chung & Đồng bộ kiểu dữ liệu với toàn nhóm

- **Quy ước khóa `ID` toàn hệ thống:** Nhóm thống nhất mọi bảng có thuộc tính `ID` tự sinh (`Department`, `Person`, `Resource`, `Submission`) đều dùng kiểu **`SMALLINT IDENTITY(1,1)`** (2 bytes, giá trị tối đa `32,767` bản ghi — hoàn toàn đủ cho quy mô một trường đại học trong phạm vi đồ án, tiết kiệm 50% dung lượng lưu trữ và tăng tốc độ đánh chỉ mục/JOIN so với `INT` 4 bytes).
- **Áp dụng cho Phần 2:** 4 bảng của Phần 2 không có cột `ID` tự tăng riêng (tuân thủ đúng Lược đồ quan hệ Bài 1), mà sử dụng khóa ngữ nghĩa `Course.Code` và khóa tổ hợp của `Session`, `Enrolls`. Tuy nhiên, toàn bộ khóa ngoại tham chiếu sang `ID` của Phần 1 (`Course.Department_ID`, `Session.Teacher_ID`, `Enrolls.Student_ID`) đều dùng **`SMALLINT NOT NULL`** để khớp 100% kiểu dữ liệu.
- **Đồng bộ khóa chính `Session` với Phần 1 (`Weekly_Schedule`):** 4 cột `(Course_Code, Semester, Education_Program, Number_Order)` sử dụng lần lượt `CHAR(6)`, `VARCHAR(10)`, `VARCHAR(10)`, `VARCHAR(10)` để khớp hoàn toàn với Phần 1.

---

## 2. Quyết định thiết kế cho từng bảng

### 2.1. Bảng `Course`

| Cột                 | Kiểu dữ liệu    | NULL / DEFAULT                         | Lý do lựa chọn                                                                                                                                                                     |
| :------------------ | :-------------- | :------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Code`              | `CHAR(6)`       | `NOT NULL`                             | Mã môn Bách Khoa cố định 6 ký tự (VD: `CO2014`). Dùng `CHAR(6)` cố định tối ưu tốc độ truy vấn hơn `VARCHAR`.                                                                      |
| `Title`             | `NVARCHAR(200)` | `NOT NULL`                             | Dùng `NVARCHAR` để lưu tiếng Việt có dấu (khi `INSERT` bắt buộc có tiền tố `N'...'`). Không đặt `UNIQUE` vì các Khoa khác nhau có thể đặt tên môn giống nhau (VD: _"Thực tập 1"_). |
| `Number_Of_Credits` | `TINYINT`       | `NOT NULL`                             | Số tín chỉ nhỏ (1–25), dùng `TINYINT` (1 byte, 0–255) tiết kiệm hơn `INT`.                                                                                                         |
| `Syllabus`          | `NVARCHAR(MAX)` | `NOT NULL`, `DEFAULT N'Chưa cập nhật'` | Mô tả đề cương dài, chứa tiếng Việt; có `DEFAULT` để tránh `NULL` khi môn mới mở chưa kịp soạn đề cương chi tiết.                                                                  |
| `Department_ID`     | `SMALLINT`      | `NOT NULL`                             | Khớp với `Department.ID (SMALLINT IDENTITY(1,1))` ở Phần 1; theo đặc tả (_Not null_ Hình 10), mọi môn học bắt buộc thuộc về 1 Khoa quản lý.                                        |

- **PK / FK / ON DELETE:** `PK_Course (Code)`; `FK_Course_Department` dùng **`ON DELETE NO ACTION`** (bảo vệ chương trình đào tạo, không cho xóa Khoa nếu vẫn còn môn học trực thuộc, phục vụ Procedure chặn xóa ở mục 2.1).
- **CHECK Constraints:**
  - `CK_Course_Code`: `Code COLLATE Latin1_General_BIN LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9]'` — Dùng `COLLATE Latin1_General_BIN` để ép buộc 2 ký tự đầu phải là chữ IN HOA (vì Collation mặc định của SQL Server không phân biệt hoa thường) và 4 ký tự sau là số.
  - `CK_Course_Title`: `LEN(LTRIM(RTRIM(Title))) > 0` — Chặn chuỗi rỗng hoặc toàn dấu cách.
  - `CK_Course_Credits`: `Number_Of_Credits > 0 AND Number_Of_Credits <= 25`.

### 2.2. Bảng `Is_Prerequisite_To`

| Cột                | Kiểu dữ liệu | NULL / DEFAULT | Lý do lựa chọn                          |
| :----------------- | :----------- | :------------- | :-------------------------------------- |
| `Pre_Course_Code`  | `CHAR(6)`    | `NOT NULL`     | Mã môn tiên quyết (khớp `Course.Code`). |
| `Post_Course_Code` | `CHAR(6)`    | `NOT NULL`     | Mã môn học sau (khớp `Course.Code`).    |

- **PK / FK / ON DELETE:** `PK_Is_Prerequisite_To (Pre_Course_Code, Post_Course_Code)`. Cả 2 FK trỏ về `Course(Code)` đều dùng **`ON DELETE NO ACTION`** vì:
  1. MS SQL Server nghiêm cấm dùng `CASCADE` khi 1 bảng có từ 2 FK trở lên trỏ về cùng 1 bảng cha (lỗi _Error 1785: multiple cascade paths_).
  2. Tránh xóa nhầm môn học đang làm điều kiện tiên quyết của môn khác.
- **CHECK Constraint:**
  - `CK_IsPrerequisiteTo_NoSelfLoop`: `Pre_Course_Code <> Post_Course_Code` — Chặn 1 môn tự làm tiên quyết cho chính nó ngay trong `CREATE TABLE`.

### 2.3. Bảng `Session`

- **PK tổ hợp 4 cột:** `(Course_Code, Semester, Education_Program, Number_Order)` — Thực thể yếu định danh thông qua `Course`.
- **Kiểu dữ liệu & DEFAULT:**
  - `Course_Code CHAR(6) NOT NULL`
  - `Semester VARCHAR(10) NOT NULL`
  - `Education_Program VARCHAR(10) NOT NULL CONSTRAINT DF_Session_EducationProgram DEFAULT 'CQ'` (mặc định hệ Chính quy).
  - `Number_Order VARCHAR(10) NOT NULL` (mã lớp như `CC01`, `DT01`, `L01`).
  - `Teacher_ID SMALLINT NOT NULL` — Khớp với `Teacher.ID (SMALLINT)` ở Phần 1; theo đặc tả (_Not null_ Hình 10), mỗi lớp học phần bắt buộc có 1 giảng viên phụ trách chính.
- **FK / ON DELETE:** Cả `FK_Session_Course` và `FK_Session_Teacher` đều dùng **`ON DELETE NO ACTION`** để bảo vệ lịch sử lớp học/điểm số và tránh xung đột multiple cascade paths với `Enrolls` và `Weekly_Schedule`.
- **CHECK Constraints:**
  - `CK_Session_Semester`: `Semester LIKE '[0-9][0-9][1-3]'` (2 số năm học + học kỳ 1, 2 hoặc 3).
  - `CK_Session_EducationProgram`: Giới hạn trong `('CLC', 'DT', 'CQ', 'KSTN', 'VP', 'SDH')`.
  - `CK_Session_NumberOrder`: `LEN(LTRIM(RTRIM(Number_Order))) > 0` (không cho phép chuỗi rỗng).

### 2.4. Bảng `Enrolls`

- **PK tổ hợp 5 cột:** `(Student_ID, Course_Code, Semester, Education_Program, Number_Order)`.
- **Kiểu dữ liệu & NULL / DEFAULT:**
  - `Student_ID SMALLINT NOT NULL` — Khớp với `Student.ID (SMALLINT)` ở Phần 1.
  - 4 cột khóa ngoại trỏ về `Session`: `NOT NULL`, đúng kiểu của `Session`.
  - `Final_Score DECIMAL(4, 2) NULL CONSTRAINT DF_Enrolls_FinalScore DEFAULT NULL` — Dùng `DECIMAL(4, 2)` (tối đa `10.00`) thay vì `FLOAT` để tránh sai số làm tròn nhị phân. Bắt buộc cho phép `NULL` (kèm `DEFAULT NULL`) vì sinh viên mới đăng ký đầu kỳ chưa có điểm tổng kết.
- **UNIQUE Constraint (Thay cho Trigger):**
  - `UQ_Enrolls_StudentCourseSemester`: `UNIQUE (Student_ID, Course_Code, Semester)` — Hiện thực hóa trực tiếp ràng buộc _"Mỗi sinh viên chỉ được đăng ký tối đa 1 Session của 1 Course trong cùng 1 học kỳ"_ (Mục 1.3 Assignment 1) ngay trong `CREATE TABLE` theo đúng Note của đề bài.
- **FK / ON DELETE:** Cả `FK_Enrolls_Student` và `FK_Enrolls_Session` đều dùng **`ON DELETE NO ACTION`**.
- **CHECK Constraint:**
  - `CK_Enrolls_FinalScore`: `Final_Score IS NULL OR (Final_Score >= 0.00 AND Final_Score <= 10.00)` — Theo logic 3 giá trị của SQL Server, viết tường minh `IS NULL OR ...` để cho phép trạng thái chưa có điểm, đồng thời chặn điểm ngoài đoạn `[0, 10]`. Không đặt `CHECK (Final_Score > 4.00)` vì sinh viên vẫn có thể bị rớt môn (`<= 4.00`).

---

## 3. Ghi chú các Semantic Constraints chuyển sang Mục 2.1 / 2.2 (Không dùng `CHECK`)

Theo quy tắc của MS SQL Server (`CHECK` chỉ kiểm tra được trên 1 dòng của chính bảng đó), các ràng buộc liên quan đến Phần 2 sau đây được ghi chú để triển khai bằng **Trigger (Mục 2.2)** hoặc **Procedure (Mục 2.1)**:

1. **Course code formatting (đối chiếu Khoa quản lý):** Do `Department.ID` được chuẩn hóa thành `SMALLINT IDENTITY(1,1)` (`1, 2, 3...`) để tối ưu lưu trữ/JOIN (và thực tế một Khoa như _Khoa Khoa học Ứng dụng_ quản lý nhiều đầu mã môn như `MT`, `AS`, `SP`), nên không thể dùng `CHECK (Code LIKE Department_ID + '%')`. Ở Mục 1.1 dùng `CHECK` kiểm tra đúng định dạng `[A-Z][A-Z][0-9][0-9][0-9][0-9]`, còn việc đối chiếu 2 chữ cái đầu của `Course.Code` với `Department.Name` sẽ xử lý bằng **Trigger (Mục 2.2.1)**.
2. **Chặn vòng lặp tiên quyết bắc cầu ($A \to B \to A$):** Cần duyệt đệ quy nhiều dòng trên `Is_Prerequisite_To` _(Trigger Mục 2.2.1)_.
3. **Prerequisite courses & Passing condition (`> 4.00`):** Khi `INSERT` vào `Enrolls`, phải truy vấn `Is_Prerequisite_To` và lịch sử `Enrolls` các học kỳ trước xem sinh viên đã đậu (`Final_Score > 4.00`) hết môn tiên quyết chưa _(Trigger Mục 2.2.1 / Procedure Mục 2.1)_.
4. **Cập nhật thuộc tính dẫn xuất `Student.Total_Credits` (phối hợp Phần 1):** Khi `Final_Score` trong `Enrolls` thay đổi, tự động cộng dồn tín chỉ các `Course_Code` khác nhau có `Final_Score > 4.00` để cập nhật vào bảng `Student` _(Trigger Mục 2.2.2)_.
5. **Instructor scheduling conflicts (phối hợp `Weekly_Schedule` - Phần 1):** Khi cập nhật đổi `Teacher_ID` trên `Session`, cần JOIN với `Weekly_Schedule` kiểm tra giảng viên mới có bị trùng khung giờ dạy với lớp khác hay không _(Trigger Mục 2.2.1)_.
