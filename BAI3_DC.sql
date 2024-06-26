CREATE TABLE CHUCVU
(
	MACV VARCHAR(10) PRIMARY KEY,
	TENVC VARCHAR(50),
	HESOPC INT
)
GO
CREATE TABLE PHONG
(
	MAPH VARCHAR(10) PRIMARY KEY,
	TENPH VARCHAR(50),
	DIACHIPHONG VARCHAR(10)
)
GO 
CREATE TABLE NHANVIEN 
(
	MANV VARCHAR(10) PRIMARY KEY,
	TENNV VARCHAR(50),
	DIACHI VARCHAR(10),
	HSLUONG INT,
	MACV VARCHAR(10),
	MAPH VARCHAR(10),
	LUONG MONEY,
	THUCLINH MONEY,
	FOREIGN KEY (MACV) REFERENCES CHUCVU(MACV),
	FOREIGN KEY (MAPH) REFERENCES PHONG(MAPH)
)

INSERT INTO CHUCVU VALUES
('CV01','GIAM DOC',10),
('CV02','TRUONG PHONG',9),
('CV03','BAO VE',2),
('CV04','NHAN VIEN',5),
('CV05','PHO GIAM DOC',10)
GO
INSERT INTO PHONG VALUES
('PH01','PHONG GIAM DOC','TANG5'),
('PH02','PHONG LAM VIEC','TANG4'),
('PH03','PHONG TRUC BAN','TANG3'),
('PH04','PHONG QUAN LY','TANG2'),
('PH05','PHONG BAO VE','TANG1')
GO
INSERT INTO NHANVIEN VALUES
('NV01','NGUYEN TRONG THANH','HAI PHONG',30,'CV02','PH02',1500,1400),
('NV02','NGUYEN THU HUONG','HA LONG',7,'CV04','PH04',900,750),
('NV03','TRAN MINH GIAP','THAI BINH',25,'CV01','PH01',500,400),
('NV04','NGUYEN THI BINH','VU THU',12,'CV04','PH02',500,400),
('NV05','NGUYEN THU HUONG','THAI BINH',18,'CV04','PH02',500,400),
('NV06','TRAN VAN BINH','THAI BINH',10,'CV05','PH03',500,400),
('NV07','PHAM THI THUY','THANH HOA',7,'CV02','PH02',500,400),
('NV08','DANG YEN NHI','DA NANG',5,'CV02','PH03',500,400),
('NV09','TRAN THANH HUYEN','HUE',22,'CV05','PH04',500,400),
('NV010','TRAN NGOC TRINH','SAI GON',16,'CV02','PH04',500,400)

-- 2 HIEN THI DIA CHI CUA PHONG CO TEN LA 'PHONG GIAM DOC'
SELECT DIACHIPHONG FROM PHONG
WHERE TENPH = 'PHONG GIAM DOC'

-- 3 TAO VIEW LUU THONG TIN CUA PHONG LAM VIEC GOM CO MA NHAN VIEN , TEN NHAN VIEN , TEN PHONG 
CREATE VIEW V_TT AS
SELECT MANV,TENNV,TENPH
FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH
AND TENPH = 'PHONG LAM VIEC'

SELECT * FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH

SELECT * FROM V_TT

-- 4 TAO THU TUC HIEN THI TEN PHONG TONG SO NHAN VIEN CUA PHONG KHI BIET MA PHONG 
SELECT * FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH

CREATE PROC PR_1 AS
SELECT TENPH,COUNT(*) AS SL FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH
GROUP BY TENPH

EXEC PR_1

CREATE PROC PR_2 @CHECK VARCHAR(10)
AS
	SELECT TENPH,COUNT(*) AS SL FROM NHANVIEN,PHONG
	WHERE NHANVIEN.MAPH = PHONG.MAPH
	AND PHONG.MAPH = @CHECK
	GROUP BY TENPH

EXEC PR_2 'PH02'

-- 5 HIEN THI THONG TIN NHAN VIEN CO DIA CHI O THAI BINH 
-- THONG TIN GOM CO MANV,TENNV,TENPHONG
SELECT MANV,TENNV,TENPH FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH

-- 6 TAO RANG BUOC DEFAULT CHO COT THUC LINH BANG 0 
SELECT * INTO NHANVIEN_NEW FROM NHANVIEN -- TAO BANG MOI 

ALTER TABLE NHANVIEN_NEW -- THEM KHOA CHINH
ADD PRIMARY KEY (MANV)

CREATE DEFAULT DF1 AS 0  -- TAO DEFAULT
GO
EXEC sp_bindefault 'DF1','NHANVIEN_NEW.THUCLINH' -- RANG BUOC VAO COT

EXEC sp_unbindefault 'NHANVIEN_NEW.THUCLINH'  -- HUY RANG BUOC

DROP DEFAULT DF1  -- XOA DEFAULT

-- 7 TAO TRIGGER TINH TIEN THUC LINH CHO NHAN VIEN KHI HE SO PHU CAP THAY DOI 
-- BIET THUCLINH = LUONG + LUONG * HESOPC
SELECT * INTO CHUCVU_NEW FROM CHUCVU
GO 
ALTER TABLE CHUCVU_NEW ADD PRIMARY KEY (MACV)

CREATE TRIGGER TG1 ON CHUCVU_NEW
FOR UPDATE
AS
	BEGIN
		UPDATE NHANVIEN
		SET THUCLINH = ( SELECT (LUONG + LUONG * THUCLINH) 
						FROM NHANVIEN,CHUCVU
						WHERE NHANVIEN.MACV = CHUCVU.MACV)
	END

DROP TRIGGER TG1
-- SUA CAU 7 
CREATE TRIGGER NEW ON CHUCVU
FOR UPDATE
AS
	BEGIN
		UPDATE NHANVIEN 
		SET NHANVIEN.THUCLINH = NHANVIEN.LUONG + NHANVIEN.LUONG * CHUCVU.HESOPC
		FROM CHUCVU
		WHERE CHUCVU.MACV = NHANVIEN.MACV
	END
-- 8 HIEN THI NHAN VIEN CO MA PHONG PH02 GOM CO MA , TEN VA DIA CHI CUA NHAN VIEN 
SELECT * FROM NHANVIEN
WHERE MAPH = 'PH02'

-- 9 TAO BO SUNG RA BUOC DEFAULT CHO DIA CHI LA CHUA XAC DINH
CREATE DEFAULT DF2 AS 'CHUAXD'  -- TAO DEFAULT
GO 
EXEC sp_bindefault 'DF2','NHANVIEN_NEW.DIACHI'  -- RANG BUOC

EXEC sp_unbindefault 'NHANVIEN_NEW.DIACHI'  -- HUY RANG BUOC

DROP DEFAULT DF2  -- XOA DEFAULT

-- 10 TAO TRIGGER TINH TIEN LUONG CHO NHAN VIEN MOI VAO CONG TY BIET LUONG = HESOLUONG *1500
CREATE TRIGGER TG2 ON NHANVIEN
FOR INSERT
AS
	BEGIN
		UPDATE NHANVIEN
		SET LUONG = (SELECT NHANVIEN.HSLUONG * 1500
					FROM NHANVIEN,inserted
					WHERE NHANVIEN.MANV = inserted.MANV)
	END

-- 11 HIEN THI THONG TIN CAC PHONG CO DIA CHI O TANG 5 GOM CO MA PHONG , TEN PHONG
SELECT MAPH,TENPH FROM PHONG
WHERE DIACHIPHONG = 'TANG5'

-- 12 TAO BO SUNG RANG BUOC RULE CHO COT HESOPC CHI NHAN GIA TRI TU 0 DEN 5
CREATE RULE R1 AS @CHECK >= 0 AND @CHECK <= 5
GO
EXEC sp_bindrule 'R1','CHUCVU_NEW.HESOPC' 

-- 13 TAO THU TUC HIEN THI TEN PHONG , TONG SO NHAN VIEN CUA PHONG KHI BIET MA PHONG 

SELECT * FROM PHONG, NHANVIEN
WHERE PHONG.MAPH = NHANVIEN.MAPH

CREATE PROC PR1 @CHECK VARCHAR(10) AS
SELECT TENPH,COUNT(*) AS SLNHANVIEN
FROM PHONG,NHANVIEN
WHERE PHONG.MAPH = NHANVIEN.MAPH
AND PHONG.MAPH = @CHECK
GROUP BY TENPH

EXEC PR1 'PH02' 

-- 14 HIEN THI NHUNG NHAN VIEN CO KHONG THUOC PHONG PH01 GOM MA NHAN VIEN , TEN NV, TEN PHONG
SELECT MANV,TENNV,TENPH FROM PHONG,NHANVIEN
WHERE PHONG.MAPH = NHANVIEN.MAPH
AND PHONG.MAPH <> 'PH01' 

-- 15 HIEN THI NHAN VIEN CO HE SO LUONG CAO NHAT . THONG TIN GOM CO MA,TEN NV VA HE SO LUONG
SELECT * FROM NHANVIEN
WHERE HSLUONG >= ALL(SELECT HSLUONG FROM NHANVIEN)

-- 16 TAO THU TUC HIEN THI MA,TEN NV HE SO LUONG
CREATE PROC PR2 AS
SELECT MANV,TENNV,HSLUONG
FROM NHANVIEN

EXEC PR2

-- 17 HIEN THI CAC PHONG KHONG THUOC TANG 5 GOM MA PHONG TENPHONG VA DIA CHI PHONG
SELECT MAPH,TENPH,DIACHIPHONG FROM PHONG
WHERE DIACHIPHONG <> 'TANG5'

-- 18 TAO VIEW LUU THONG TIN NHAN VIEN CUA PHONG LAM VIEC THONG TIN GOM MA,TEN NV VA TEN PHONG
SELECT * FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH

CREATE VIEW V1 AS
SELECT MANV,TENNV,TENPH
FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH
AND TENPH = 'PHONG LAM VIEC'

SELECT * FROM V1

-- 19 TAO THU TUC HIEN THI MA , TEN NV TEN PHONG KHI BIET MA PHONG 
CREATE PROC PR3 @CHECK VARCHAR(10) AS
SELECT MANV,TENNV,TENPH
FROM NHANVIEN,PHONG
WHERE NHANVIEN.MAPH = PHONG.MAPH
AND PHONG.MAPH = @CHECK

EXEC PR3 'PH02'

