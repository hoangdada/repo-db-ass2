Attempt:
- Student_Email VARCHAR(254) NOT NULL,
	Theo chuẩn RFC 5321, độ dài tối đa của một địa chỉ email hợp lệ là 254 ký tự
- Quiz_ID SMALLINT NOT NULL,
	maxium 32.000 id
- Start_time DATETIME2 NOT NULL,
	lưu cả ngày và giờ
- Score DECIMAL(4,2) NULL, 
	max là 10.00
	lúc bấm làm thì khởi tạo sẵn, để đến lúc làm dở dang thì quay lại làm tiếp được
- Duration INT NULL
	max là 24 tiếng = 86000 giây, nếu smallint max là 32000 nên ko đáp ứng đc
 	init ban đầu là 0, cứ 10 giây update 1 lần