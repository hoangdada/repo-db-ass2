description for file schemas_issue#4.sql:

============ Tổng thế ===============

ON DELETE NO ACTION (Dùng để bảo vệ): 
- Áp dụng cho các thực thể gốc, tồn tại độc lập (Người, Môn học, Bài tập) nhằm chặn đứng thảm họa vô tình xóa mất dữ liệu quan trọng.
ON DELETE CASCADE (Dùng để dọn rác): 
- Áp dụng cho các thực thể phụ hoặc bảng trung gian (File đính kèm, Bảng nối) để hệ thống tự động dọn sạch khi dữ liệu cha không còn.


============ TABLE ===============


Submission:

- ID SMALLINT NOT NULL,
	max 32000 id, phù hợp với scope asssigment
- Assignement_ID SMALLINT NOT NULL,
	max 32000 id
- Student_ID SMALLINT NOT NULL,
	max 32000 id
- Title NVARCHAR(120) NOT NULL
	lưu tiếng việt cho nên dùng NVARCHAR
	max 120 kí tự
	ví dụ 80 kí tự: 'Báo cáo Assignment 1 - Nhóm 5 - Lớp L01 - Môn Cơ sở dữ liệu - Phiên bản cuối cùng'
- Submit_time DATETIME2(0) NOT NULL,
	lưu ngày + giờ
- Final_score DECIMAL(4,2) NULL,
	[-99,99 ; 99,99] -> phù hợp với [0.00 ; 10.00] điểm
	cho phép null vì submit xong thì phải chờ GV chấm



Attempt:

- Student_ID SMALLINT NOT NULL,
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