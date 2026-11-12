Attempt:
- Student_Email SMALLINT NOT NULL,
	maxium 32.000 id, phù hợp với scope
- Quiz_ID SMALLINT NOT NULL,
	maxium 32.000 id
- Start_time DATETIME2 NOT NULL,
	lưu cả ngày và giờ
- Score DECIMAL(4,2) NULL, 
	max là 10.00
	cơ chế: khi user bấm làm thì khởi tạo tuple (score = null), để đến lúc làm dở dang thì quay lại làm tiếp được
- Duration INT NOT NULL
	expect max là 24 tiếng = 86000 giây, nếu smallint max là 32000 nên ko đáp ứng đc
 	init ban đầu là 0, cứ 10 giây update 1 lần (i think so)