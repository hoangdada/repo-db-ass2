# HƯỚNG DẪN KỸ THUẬT PHẦN DDL (MS SQL SERVER) & CHECKLIST MỤC 1.1

Tài liệu này hệ thống hóa các điểm khác biệt giữa **Slide lý thuyết (chuẩn ANSI SQL)** và **Thực tế triển khai trên MS SQL Server (T-SQL)**, kèm theo các trường hợp biên (edge cases) và quy tắc bắt buộc khi nhóm viết script `01_schema_init.sql`.

## PHẦN 1: QUY TẮC KHỞI TẠO DATABASE & SCHEMA

* **Phân công:** Chỉ **1 người (Hoàng)** viết lệnh khởi tạo Database và Schema ở đầu file `01_schema_init.sql`. Các thành viên khác chỉ viết lệnh `CREATE TABLE` cho cụm bảng của mình.
  * **Vị trí file làm việc**: trong folder `staging`, mỗi người làm việc trong file tương ứng với issue mà mình đã nhận

* **Không dùng `AUTHORIZATION`:** Trong slide lý thuyết (trang 8) có cú pháp `CREATE SCHEMA ... AUTHORIZATION ...`. Trong bài tập lớn này, chúng ta chạy trên quyền quản trị cao nhất ở máy local và dùng chung schema mặc định `dbo`, nên bỏ qua phần phân quyền `AUTHORIZATION` vì nằm ngoài phạm vi chấm điểm.

## PHẦN 2: CHỌN KIỂU DỮ LIỆU (DATA TYPES) — SLIDE vs. MS SQL SERVER

* **Tài liệu tra cứu chính thức của Microsoft:** [Data types (Transact-SQL) - SQL Server](https://learn.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-ver17)

Khi chọn kiểu dữ liệu, cần đảm bảo tối ưu bộ nhớ và phản ánh đúng bản chất dữ liệu. Đặc biệt lưu ý: **Cột làm Khóa ngoại (FK) bắt buộc phải có cùng kiểu dữ liệu và cùng độ dài với cột Khóa chính (PK) mà nó trỏ tới.**

### 1. Chuỗi ký tự: `CHAR`, `VARCHAR`, `NVARCHAR`

* **Tiếng Việt có dấu (`NVARCHAR` vs `VARCHAR`):**

  * *Bản chất:* `VARCHAR` lưu 1 byte/ký tự (chỉ hỗ trợ bảng mã ASCII tiếng Anh). `NVARCHAR` lưu 2 bytes/ký tự theo chuẩn Unicode (UTF-16).

  * *Áp dụng:* Mọi cột lưu tên người, tên môn học, tiêu đề, nhận xét có khả năng chứa tiếng Việt bắt buộc dùng `NVARCHAR(n)` (hoặc `NCHAR(n)`).

  * *Lưu ý khi INSERT:* Bắt buộc có tiền tố `N` đặt sát trước dấu nháy đơn (ví dụ: `N'Nguyễn Văn A'`). Nếu quên chữ `N`, SQL Server sẽ ép kiểu về ASCII làm lỗi dấu chữ tiếng Việt (hiển thị thành dấu `?`).

* **Độ dài cố định vs. Độ dài thay đổi (`CHAR` vs `VARCHAR`):**

  * Dùng `CHAR(n)` cho các mã có độ dài cố định tuyệt đối (ví dụ: Mã số sinh viên Bách Khoa luôn có 7 ký tự `CHAR(7)`, Mã môn học `CHAR(6)`). Tốc độ truy vấn và lưu trữ trên `CHAR` cố định nhanh hơn `VARCHAR`.

  * Dùng `VARCHAR(n)` cho các chuỗi không có dấu nhưng độ dài biến thiên (ví dụ: `Email VARCHAR(100)`, `File_url VARCHAR(500)`).

* **Dữ liệu dạng số nhưng có số `0` ở đầu:**

  * *Ví dụ:* Số điện thoại (`0901234567`), Mã sinh viên/CCCD.

  * *Áp dụng:* Bắt buộc dùng `CHAR` hoặc `VARCHAR`. Nếu dùng kiểu số (`INT`, `BIGINT`), hệ thống sẽ hiểu là giá trị toán học và tự động cắt mất số `0` ở đầu (`901234567`). Ngoài ra, chúng ta không bao giờ thực hiện phép cộng/trừ toán học trên số điện thoại.

### 2. Kiểu Logic: `BOOLEAN` vs `BIT`

* **Khác biệt:** Slide lý thuyết (trang 12) có kiểu `BOOLEAN` (`TRUE`/`FALSE`), nhưng **MS SQL Server không có kiểu `BOOLEAN`** trong bảng.

* **Áp dụng:** Thay thế hoàn toàn bằng kiểu `BIT`. Giá trị nhận vào là `1` (tương đương True), `0` (tương đương False), hoặc `NULL`.

### 3. Kiểu Số thực: `FLOAT`/`REAL` vs `NUMERIC`/`DECIMAL`

* **Bản chất:** `FLOAT` và `REAL` là số thực dấu phẩy động lưu theo hệ nhị phân (chuẩn IEEE 754) nên chỉ mang tính **xấp xỉ**, thường bị sai số làm tròn ở phần thập phân (ví dụ: lưu `8.5` có thể bị lưu thành `8.49999999`).

* **Áp dụng:** Với các con số đòi hỏi độ chính xác tuyệt đối như Điểm số (`Score`, `Final_Score`, `Grade_to_pass`), bắt buộc dùng `DECIMAL(p, s)` hoặc `NUMERIC(p, s)` (trong MS SQL Server, 2 từ khóa này giống hệt nhau).

  * `p` (precision): Tổng số chữ số tối đa (cả trước và sau dấu phẩy).

  * `s` (scale): Số chữ số phần thập phân sau dấu phẩy.

  * *Ví dụ:* Điểm hệ 10 lấy 2 chữ số thập phân (như `10.00` hoặc `8.75`) phải khai báo là `DECIMAL(4, 2)` (tối đa 4 chữ số tất cả, trong đó có 2 chữ số sau dấu phẩy).

### 4. Kiểu Ngày Giờ: Tuyệt đối tránh bẫy `TIMESTAMP`

* **Khác biệt lớn nhất giữa Slide và MS SQL Server:**

  * Trong slide lý thuyết (trang 13 - chuẩn ANSI), `TIMESTAMP` là kiểu lưu Ngày + Giờ.

  * Nhưng trong **MS SQL Server**, từ khóa `TIMESTAMP` **KHÔNG lưu ngày giờ**. Nó là tên cũ của kiểu `ROWVERSION` — một dãy số nhị phân 8 bytes tự tăng mỗi khi dòng dữ liệu bị sửa đổi. Nếu khai báo cột `Submit_Time TIMESTAMP`, bạn sẽ không thể chèn ngày giờ vào đó.

* **Áp dụng chuẩn trong MS SQL Server:**

  * Chỉ lưu ngày (ví dụ: `Birthday`, `Open_date`): Dùng `DATE` (`YYYY-MM-DD`).

  * Chỉ lưu giờ trong ngày (ví dụ: `Start_time` của lịch học hàng tuần): Dùng `TIME(0)` (`HH:MM:SS`).

  * Lưu cả ngày và giờ (ví dụ: `Deadline`, `Submit_time`, `Upload_time`, `Start_time` của lần làm bài Quiz): Dùng `DATETIME2(0)` (chuẩn mới của Microsoft, chính xác và tốn ít bộ nhớ hơn `DATETIME` cũ). Nếu cần quản lý đa múi giờ theo chuẩn UTC thì dùng `DATETIMEOFFSET`.

## PHẦN 3: TÁI SỬ DỤNG KIỂU DỮ LIỆU (`CREATE DOMAIN` vs `CREATE TYPE`)

* **Khác biệt:** Slide lý thuyết (trang 14) dạy lệnh `CREATE DOMAIN` kèm điều kiện `CHECK` bên trong. Tuy nhiên, **MS SQL Server không hỗ trợ lệnh `CREATE DOMAIN`**.

* **Áp dụng trong MS SQL Server:**

  * Dùng lệnh `CREATE TYPE` (User-Defined Data Type) để định nghĩa các kiểu dữ liệu lặp đi lặp lại ở nhiều bảng (ví dụ: Mã sinh viên, Mã môn học, Điểm số), giúp đồng bộ kiểu dữ liệu giữa PK và FK, dễ bảo trì.

  * *Cú pháp:*

    ```
    CREATE TYPE StudentID_Type FROM CHAR(7) NOT NULL;
    CREATE TYPE Score_Type FROM DECIMAL(4, 2) NULL;
    
    ```

  * *Hạn chế của MS SQL Server:* `CREATE TYPE` chỉ định nghĩa được kiểu dữ liệu và `NULL`/`NOT NULL`, **không gắn trực tiếp mệnh đề `CHECK` vào trong `CREATE TYPE` được** như `CREATE DOMAIN` trên slide. Do đó, điều kiện `CHECK` vẫn phải viết ở từng bảng lúc `CREATE TABLE`.

## PHẦN 4: RÀNG BUỘC TOÀN VẸN (CONSTRAINTS) & CÁC TRƯỜNG HỢP BIÊN (EDGE CASES)

### 1. Bắt buộc đặt tên cho mọi Constraint (Naming Convention)

* **Tại sao:** Nếu bạn viết tắt `Code CHAR(6) PRIMARY KEY` hoặc `CHECK (Score >= 0)` mà không đặt tên, MS SQL Server sẽ tự sinh ra một cái tên ngẫu nhiên (ví dụ: `PK__Course__A25C5AA618E` hoặc `CK__Attempts__Score__49C3F6B7`). Sau này khi cần sửa hoặc xóa constraint bằng lệnh `ALTER TABLE ... DROP CONSTRAINT ...`, bạn sẽ không biết tên của nó là gì để xóa, và mỗi máy thành viên sẽ tự sinh một mã ngẫu nhiên khác nhau.

* **Quy ước đặt tên chuẩn (xem chi tiết tại `[Master] working docs`):**

  * **Cấu trúc chung:** `[Tiền_Tố_Loại_Constraint]_[Tên_Bảng]_[Tên_Cột_hoặc_Mô_Tả]`

  * **Quy tắc định dạng:** Sử dụng **PascalCase** hoặc **camelCase** (viết hoa chữ cái đầu của từng từ khi ghép tên) để dễ đọc (Ví dụ: `FK_ChiTietDonHang_DonHang`).

  * **Công thức cụ thể cho từng loại:**

    * **Khóa chính (Primary Key):** `PK_<TênBảng>`

    * **Khóa ngoại (Foreign Key):** `FK_<BảngCon>_<BảngCha>`

    * **Duy nhất (Unique):** `UQ_<TênBảng>_<TênCột>` *(Bắt buộc phải có tên cột vì 1 bảng có thể có nhiều UNIQUE)*.

    * **Kiểm tra miền giá trị (Check):** `CK_<TênBảng>_<Ý_Nghĩa_Của_Luật>`

    * **Mặc định (Default):** `DF_<TênBảng>_<TênCột>`

### 2. Nguyên lý hoạt động và "Điểm mù" của `CHECK` trong MS SQL Server

Khi viết `CHECK`, các thành viên bắt buộc phải nắm rõ 3 quy tắc sau của MS SQL Server để không viết code sai hoặc bị lọt dữ liệu bẩn:

1. **Phạm vi 1 dòng (Single-row scope):**
   `CHECK` chỉ nhìn thấy các cột nằm trên **cùng 1 dòng dữ liệu đang được thêm/sửa của chính bảng đó**. Nó không thể truy vấn sang dòng khác và không thể truy vấn sang bảng khác.

2. **Logic 3 giá trị (3-Valued Logic: `TRUE`, `FALSE`, `UNKNOWN`) — CỰC KỲ QUAN TRỌNG:**

   * Trong SQL (slide trang 53), mọi phép so sánh với `NULL` đều trả về `UNKNOWN` (ví dụ: khi `Score` là `NULL`, biểu thức `Score >= 0 AND Score <= 10` trả về `UNKNOWN`).

   * **Cơ chế của `CHECK`:** Ràng buộc `CHECK` chỉ chặn dữ liệu khi biểu thức trả về **`FALSE`**. Nếu biểu thức trả về **`TRUE` hoặc `UNKNOWN`**, nó đều **CHO PHÉP DỮ LIỆU LỌT QUA**.

   * *Hệ quả:* Nếu bạn chỉ viết `Score DECIMAL(4,2) CHECK (Score >= 0)` mà quên khai báo `NOT NULL`, người dùng vẫn chèn được `NULL` vào cột đó bình thường. Muốn chặn tuyệt đối không cho rỗng, bắt buộc phải kết hợp cả **`NOT NULL`** và **`CHECK`**.

3. **Cấm hàm đa dòng và hàm động:**
   Trong `CHECK` không được dùng các hàm tổng hợp (`SUM`, `COUNT`, `AVG`, `MAX`, `MIN`), không dùng câu lệnh `SELECT` con (Subquery), và không dùng `NEXT VALUE FOR`. Mọi quy tắc dính đến các thành phần này đều phải chuyển sang viết ở **Trigger (Mục 2.2)**.

### 3. Cơ chế Xóa/Cập nhật (`DROP`, `ALTER`, và `FOREIGN KEY`)

* **Khác biệt giữa Slide và MS SQL Server ở lệnh `DROP`:**

  * Slide lý thuyết (trang 25-26) có cú pháp `DROP TABLE Department CASCADE;` hoặc `DROP COLUMN Address CASCADE;` để tự động xóa luôn bảng và các ràng buộc liên quan.

  * **MS SQL Server KHÔNG hỗ trợ từ khóa `CASCADE` trong lệnh `DROP TABLE`, `DROP SCHEMA`, hay `ALTER TABLE ... DROP COLUMN`**. Microsoft thiết kế như vậy để bắt lập trình viên phải tường minh, tránh việc gõ 1 lệnh `DROP ... CASCADE` làm bay màu ngầm hàng loạt object phụ thuộc trong hệ thống.

* **Hành vi mặc định trong MS SQL Server:**

  * Luôn hoạt động giống chế độ `RESTRICT`: Nếu Bảng A đang được Bảng B trỏ khóa ngoại (`FOREIGN KEY`) vào, bạn **không thể `DROP TABLE A`** ngay được. Bạn bắt buộc phải xóa bảng con B trước (hoặc `ALTER TABLE B DROP CONSTRAINT FK_...` trước), rồi mới xóa được bảng cha A.

  * *Mẹo trên SSMS:* Nếu đồ thị phụ thuộc giữa các bảng quá phức tạp không biết xóa bảng nào trước, có thể chuột phải vào Database/Table trên SSMS -> `Tasks` -> `Generate Scripts` để công cụ tự sinh ra đoạn code xóa theo đúng thứ tự.

* **Quy tắc khi dùng `ALTER TABLE`:**
  Không gộp nhiều thao tác thay đổi vào chung một câu lệnh `ALTER TABLE`. Hãy tách rời từng lệnh riêng biệt để khi chạy script bị lỗi ở dòng nào, SSMS sẽ chỉ chính xác số dòng bị lỗi, giúp debug nhanh hơn.

## PHẦN 5: CHECKLIST BẮT BUỘC TRƯỚC KHI PUSH CODE MỤC 1.1

Để lấy trọn **2.0 điểm của Mục 1.1** và không bị phạt lỗi *"lạm dụng Trigger cho những thứ dùng CHECK được"*, mỗi thành viên sau khi viết xong lệnh `CREATE TABLE` cho mỗi bảng phải tự kiểm tra qua **5 câu hỏi** dưới đây:

### 1. Kiểm tra Khóa chính (Primary Key) & Khóa thay thế (Unique)

* \[ \] Đã khai báo `CONSTRAINT PK_<TênBảng> PRIMARY KEY (...)` chưa?

* \[ \] Nếu là khóa chính gồm nhiều cột (như bảng `Session`, `Enrolls`, `Weekly_Schedule`), đã gom tất cả các cột đó vào chung 1 dòng `PRIMARY KEY (Col1, Col2, ...)` ở cuối bảng chưa? (Tuyệt đối không viết từ khóa `PRIMARY KEY` rời rạc ở từng cột vì SQL Server chỉ cho phép 1 PK/bảng).

* \[ \] Có cột nào không phải PK nhưng cấm trùng lặp (như `Email` của `Person`, tên `Department`) cần gắn `CONSTRAINT UQ_<TênBảng>_<TênCột> UNIQUE` không?

### 2. Kiểm tra Kiểu dữ liệu & `NULL` / `DEFAULT` (Data Constraints)

* \[ \] Cột lưu tiếng Việt đã dùng `NVARCHAR` chưa?

* \[ \] Cột lưu điểm/tỷ lệ đã dùng `DECIMAL(p, s)` thay vì `FLOAT` chưa?

* \[ \] Cột lưu ngày giờ đã dùng `DATE` / `TIME(0)` / `DATETIME2(0)` (và né hoàn toàn từ khóa `TIMESTAMP`) chưa?

* \[ \] Đã rà soát từng cột để quyết định `NOT NULL` hay `NULL` chưa? (Nhớ quy tắc 3-Valued Logic: Cột nào bắt buộc phải có dữ liệu khi tạo mới thì phải ghi rõ `NOT NULL`).

* \[ \] Các thuộc tính dẫn xuất (Derived Attributes từ EERD như `Total_Credits`, `Review_Count`, `Final_Score`) đã được tạo thành cột vật lý kèm giá trị `DEFAULT 0` (cho bộ đếm) hoặc `DEFAULT NULL` (cho điểm chưa chấm) để chuẩn bị cho Trigger 2.2.2 chưa?

### 3. Kiểm tra Khóa ngoại (Foreign Key Constraints)

* \[ \] Kiểu dữ liệu và độ dài của cột FK ở bảng này đã **giống hệt 100%** với cột PK ở bảng cha chưa?

* \[ \] Nếu bảng con tham chiếu đến một bảng cha có khóa chính gồm nhiều cột (ví dụ: bảng `Enrolls` hoặc `Includes` tham chiếu đến bảng `Session` có PK gồm 4 cột `Course_Code, Semester, Education_Program, Number_Order`), bạn đã khai báo FK tổ hợp cả 4 cột đó cùng lúc chưa?

* \[ \] Đã thống nhất hành vi `ON DELETE NO ACTION` (đối với các bảng thực thể chính để phục vụ Procedure chặn xóa ở mục 2.1) hoặc `ON DELETE CASCADE` (chỉ dành cho bảng đa trị phụ thuộc hoàn toàn như `Submission_File_url`, `Weekly_Schedule`) chưa?

### 4. Phân loại Ràng buộc Ngữ nghĩa (Semantic Constraints: `CHECK` vs `TRIGGER`)

Với mỗi quy tắc nghiệp vụ ở Mục 1.3 (Assignment 1) liên quan đến bảng này, hãy trả lời câu hỏi phân loại sau:

* \[ \] **Câu hỏi phân loại:** *"Để kiểm tra quy tắc này, mình chỉ cần nhìn vào các cột trên cùng 1 dòng của bảng hiện tại, hay phải lấy dữ liệu từ dòng khác / bảng khác?"*

  * **Nếu chỉ nhìn trong 1 dòng hiện tại:** BẮT BUỘC viết ngay bằng `CONSTRAINT CK_<TênBảng>_<Ý_Nghĩa_Của_Luật> CHECK (...)` bên trong `CREATE TABLE`.

    * *Danh sách phải dùng CHECK:* Điểm số nằm trong đoạn `[0, 10]`; Số tín chỉ `> 0`; Thời gian làm bài (`Time_limit`) và Số lần thử (`Attempt_limit`) `> 0`; Định dạng số điện thoại Việt Nam (`LIKE '0[0-9]...'`); Mã môn học bắt đầu bằng mã Khoa (`Code LIKE Department_ID + '%'`); Giờ kết thúc/hạn chót lớn hơn giờ mở (`Deadline > Open_date` nếu cả 2 cột nằm cùng 1 bảng).

  * **Nếu phải đọc dòng khác hoặc JOIN sang bảng khác:** Ghi chú lại vào tài liệu nhóm để chuyển sang viết bằng **Trigger (Mục 2.2.1)** hoặc **Stored Procedure (Mục 2.1)**, tuyệt đối không cố nhét vào `CHECK`.

    * *Danh sách phải dùng Trigger/Procedure:* Kiểm tra môn tiên quyết; Kiểm tra trùng lịch dạy giảng viên; Kiểm tra số lần làm bài thực tế của sinh viên không vượt quá `Quiz.Attempt_limit`; Kiểm tra thời gian nộp bài/review so với `Deadline` nằm ở bảng khác.

### 5. Kiểm tra Thứ tự tạo bảng (Execution Order)

* \[ \] Bảng cha mà bảng này tham chiếu tới (`REFERENCES`) đã được đặt ở phía trên bảng này trong file script tổng chưa? (Nếu có tham chiếu vòng, tạo bảng trước rồi dùng `ALTER TABLE ... ADD CONSTRAINT FK_...` ở cuối file).