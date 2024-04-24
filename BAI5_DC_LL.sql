CREATE TABLE PHONG
(
	MAPH VARCHAR(10) PRIMARY KEY,
	TENPH VARCHAR(30),
	DIENTICH FLOAT,
	GIAPHONG FLOAT
)
GO
CREATE TABLE KHACHHANG
(
	MAKH VARCHAR(10) PRIMARY KEY,
	TENKH VARCHAR(30),
	DIACHI VARCHAR(10)
)
GO
CREATE TABLE THUEPHONG
(
	MAHD VARCHAR(10),
	MAKH VARCHAR(10),
	MAPH VARCHAR(10),
	NGAYBD DATE,
	NGAYKT DATE,
	THANHTIEN FLOAT,
	PRIMARY KEY (MAHD,MAKH,MAPH),
	FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH),
	FOREIGN KEY (MAPH) REFERENCES PHONG(MAPH)
)
GO
INSERT INTO PHONG VALUES
('PH01','PHONG1',50,500),
('PH02','PHONG2',40,600),
('PH03','PHONG3',30,700),
('PH04','PHONG4',20,800),
('PH05','PHONG5',10,900)
GO
INSERT INTO KHACHHANG VALUES
('KH01','TRAN MINH GIAP','THAI BINH'),
('KH02','PHAM THI THUY','THANH HOA'),
('KH03','DINH NGOC THAO MY','HA NOI'),
('KH04','NGUYEN QUANG HUY','HAI PHONG'),
('KH05','TRAN VAN BINH','THAI BINH'),
('KH06','DANG YEN NHI','THAI BINH'),
('KH07','PHAM HONG NGA','HA LONG'),
('KH08','DANG NGOC TRINH','THAI BINH')
GO
INSERT INTO THUEPHONG VALUES
('HD01','KH01','PH01','2022/02/03','2022/05/07',900),
('HD01','KH02','PH02','2022/03/10','2022/04/17',1000),
('HD01','KH03','PH03','2022/10/23','2023/05/27',1900),
('HD02','KH03','PH01','2021/11/28','2022/01/01',700),
('HD02','KH05','PH04','2022/07/03','2023/10/17',500),
('HD02','KH01','PH03','2020/08/04','2021/11/19',2000),
('HD03','KH03','PH05','2021/07/23','2022/09/10',1500),
('HD03','KH05','PH01','2022/02/28','2022/05/17',2000),
('HD03','KH02','PH04','2021/10/03','2022/08/16',4500),
('HD04','KH01','PH01','2022/11/22','2022/12/27',900),
('HD04','KH02','PH01','2020/01/13','2021/04/23',3600),
('HD05','KH03','PH02','2022/02/03','2022/05/07',1800),
('HD05','KH08','PH03','2022/07/26','2022/08/08',2200),
('HD06','KH04','PH05','2020/11/19','2021/05/07',200),
('HD06','KH06','PH02','2021/07/07','2022/08/08',3500),
('HD06','KH02','PH03','2022/12/23','2023/11/11',1700),
('HD07','KH03','PH01','2021/10/20','2022/05/28',700),
('HD07','KH08','PH02','2022/04/03','2022/05/05',1100),
('HD08','KH07','PH05','2019/08/13','2021/05/18',650),
('HD08','KH06','PH04','2022/12/12','2023/10/07',3000)
GO

-- 2 HIEN THI THONG TIN CUA KHACH HANG CHUA BAO GIO THUE PHONG 
SELECT * FROM KHACHHANG
WHERE MAKH NOT IN ( SELECT DISTINCT MAKH FROM THUEPHONG )

-- 3 TAO BO SUNG RANG BUOC DEFAULT CHO COT THANH TIEN BANG 0
CREATE DEFAULT DF1 AS 0
GO
EXEC sp_bindefault 'DF1','THUEPHONG.THANHTIEN'

EXEC sp_unbindefault 'THUEPHONG.THANHTIEN'

DROP DEFAULT DF1

--4 TAO THU TUC HIEN THI THONG TIN CUA KHACH HANG KHI BIET MA PHONG VA NGAY BAT DAU 
CREATE PROC PR1 @CHECK1 VARCHAR(10), @CHECK2 DATE AS
SELECT KHACHHANG.MAKH,TENKH,DIACHI FROM KHACHHANG,THUEPHONG
WHERE KHACHHANG.MAKH = THUEPHONG.MAKH
AND @CHECK1 = KHACHHANG.MAKH
AND @CHECK2 = NGAYBD

EXEC PR1 'KH01','2020/08/04'

SELECT * FROM KHACHHANG,THUEPHONG
WHERE KHACHHANG.MAKH = THUEPHONG.MAKH

-- 5 HIEN THI THONG TIN CUA CAC PHONG CHUA BAO GIO DUOC THUE
SELECT * FROM PHONG 
WHERE MAPH NOT IN ( SELECT MAPH FROM THUEPHONG ) 

-- 6 TAO BO SUNG RANG BUOC RULE CHO COT GIA PHONG >= 0
CREATE RULE R1 AS @CHECK >= 0
GO
EXEC sp_bindrule 'R1','PHONG.GIAPHONG'

-- 7 TAO THU TUC HIEN THI THONG TIN CUA CAC PHONG CO NHIEU NGUOI THUE NHAT 
SELECT PHONG.MAPH,TENPH,COUNT(*) AS SL FROM THUEPHONG,PHONG
WHERE THUEPHONG.MAPH = PHONG.MAPH
GROUP BY PHONG.MAPH,TENPH
HAVING COUNT(*) >= ALL( SELECT COUNT(*) FROM THUEPHONG
						GROUP BY MAPH )

						
SELECT TOP 1 PHONG.MAPH,TENPH,COUNT(*) AS SL FROM THUEPHONG,PHONG
WHERE THUEPHONG.MAPH = PHONG.MAPH
GROUP BY PHONG.MAPH,TENPH
ORDER BY COUNT(*) DESC

-- 8 HIEN THI THONG TIN CUA NHUNG KHACH HANG DA THUE PHONG CO MA PH01
SELECT DISTINCT KHACHHANG.MAKH,TENKH,DIACHI FROM KHACHHANG,THUEPHONG
WHERE KHACHHANG.MAKH = THUEPHONG.MAKH
AND MAPH = 'PH01'

-- 9 TAO BO SUNG RANG BUOC DEFAULT DIA CHI LA CHUA XD.
CREATE DEFAULT DF9 AS 'CHUA_XD'
EXEC sp_bindefault 'DF9','KHACHHANG.DIACHI'

-- 10 TRIGGER THUC HIEN KIEM TRA NGAY BAT DAU VA NGAY KET THUC KHI THEM HAY SUA PHAI THOA MAN 
-- LON HON HOAC BANG NGAY HIEN TAI
CREATE TRIGGER TG1 ON THUEPHONG
FOR INSERT,UPDATE
AS
	BEGIN
		IF((SELECT NGAYBD FROM inserted) < GETDATE() OR (SELECT NGAYKT FROM inserted) < GETDATE())
		BEGIN
			PRINT'NGAY BAT DAU VA NGAY KET THUC PHAI LON HON NGAY HIEN TAI !'
			ROLLBACK TRAN
		END
	END

DROP TRIGGER TG1

-- 11 HIEN THI THONG TIN CUA CAC PHONG DO KHACH HANG MA KH01 THUE
SELECT DISTINCT PHONG.MAPH,TENPH,DIENTICH FROM THUEPHONG,PHONG
WHERE THUEPHONG.MAPH = PHONG.MAPH
AND MAKH = 'KH01'

-- 12 TAO VIEW HIEN THI THONG TIN CUA KHACH HANG CO DIA CHI O HA NOI
CREATE VIEW V1 AS
SELECT * FROM KHACHHANG
WHERE DIACHI = 'HA NOI'

SELECT * FROM V1

-- 13 TAO TRIGGER TU CAP NHAT THANH TIEN MOI KHI THEM DU LIEU VAO BANG THUE PHONG 
-- BIET THANHTIEN = GIAPHONG * SONGAY

ALTER TRIGGER TG13 ON THUEPHONG
FOR INSERT
AS
	BEGIN
		UPDATE THUEPHONG
		SET THANHTIEN = P.GIAPHONG * DATEDIFF(DAY,I.NGAYBD,I.NGAYKT)
		FROM inserted I , PHONG P , THUEPHONG
		WHERE P.MAPH = I.MAPH
		AND I.MAHD = THUEPHONG.MAHD
		AND I.MAKH = THUEPHONG.MAKH
		AND I.MAPH = THUEPHONG.MAPH
	END

-- 15 TAO VIEW HIEN THI TEN KHACH HANG VA SO PHONG MA CAC KHACH HANG DO THUE 
CREATE VIEW V15
AS
SELECT KH.TENKH, COUNT( DISTINCT THUEPHONG.MAPH) AS SoLuongPhongThue
FROM KHACHHANG KH
LEFT JOIN THUEPHONG ON KH.MAKH = THUEPHONG.MAKH
GROUP BY KH.TENKH

-- KIEM TRA ( NGHI LA CAN PHAI LEFT JOIN BOI PHAI TINH DEN SO KHACH KO THUE PHONG NUA )
 

CREATE VIEW V_BANDAU AS
SELECT TENKH,COUNT (*) AS SOLUONG FROM KHACHHANG,THUEPHONG
WHERE KHACHHANG.MAKH = THUEPHONG.MAKH
GROUP BY TENKH

SELECT * FROM KHACHHANG,THUEPHONG
WHERE KHACHHANG.MAKH = THUEPHONG.MAKH


CREATE VIEW V15_NEW
AS
SELECT KH.TENKH, COUNT(THUEPHONG.MAPH) AS SoLuongPhongThue
FROM KHACHHANG KH
LEFT JOIN THUEPHONG ON KH.MAKH = THUEPHONG.MAKH
GROUP BY KH.TENKH

SELECT * FROM V15_NEW
SELECT * FROM V_BANDAU

CREATE VIEW V_BANDAU_NEW AS
SELECT TENKH,COUNT (DISTINCT MAPH) AS SOLUONG FROM KHACHHANG,THUEPHONG
WHERE KHACHHANG.MAKH = THUEPHONG.MAKH
GROUP BY TENKH
SELECT * FROM V15
SELECT * FROM V_BANDAU_NEW 
-- GROUP XONG KHONG DEM COUNT (*) NUA MA TA DEM CAI KHAC => PHAI LINH HOAT !

