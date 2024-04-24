CREATE TABLE Sinhvien(
  Masv CHAR(30) PRIMARY KEY,
  Tensv CHAR(30),
  Ngaysinh DATE,
  gioitinh CHAR(30),
  diachi CHAR(30),
  malop CHAR(30)
  )
CREATE TABLE Giangvien(
  Magv CHAR(30) PRIMARY KEY,
  Tengv CHAR(30),
  diachi CHAR(30),
  )
CREATE TABLE Detai(
  Madt CHAR(30) PRIMARY KEY,
  Tendt CHAR(30),
  Sosv INT,
  Magv CHAR(30) REFERENCES Giangvien(Magv)
  )
CREATE TABLE Diemsv(
  Masv CHAR(30),
  Madt CHAR(30),
  loaidiem CHAR(30),
  diem FLOAT,
  PRIMARY KEY(Masv, Madt, loaidiem),
  FOREIGN KEY (Masv) REFERENCES Sinhvien(Masv),
  FOREIGN KEY (Madt) REFERENCES Detai(Madt)
  )
INSERT INTO Sinhvien VALUES
 ('SV01', 'A','2004-04-02','NAM','DIACHI1','LO1'),
 ('SV02', 'B','2005-05-02','NAM','DIACHI2','LO2'),
 ('SV03', 'C','2004-04-03','NAM','DIACHI3','LO1'),
 ('SV04', 'D','2004-06-02','NAM','DIACHI5','LO5'),
 ('SV05', 'E','2007-08-07','NU','DIACHI6','LO4')
INSERT INTO Giangvien VALUES
 ('GV01','GIANGVIEN1','HA NOI'),
 ('GV02','GIANGVIEN2','HA NAM'),
 ('GV03','GIANGVIEN3','HOA BINH'),
 ('GV04','GIANGVIEN4','HAI PHONG'),
 ('GV05','GIANGVIEN5','HA NAM')
 INSERT INTO Detai VALUES
  ('DT01','DETAI1',20,'GV01'),
  ('DT02','DETAI2',30,'GV02'),
  ('DT03','DETAI3',40,'GV03'),
  ('DT04','DETAI4',50,'GV04'),
  ('DT05','DETAI5',60,'GV05')
INSERT INTO Diemsv VALUES
 ('SV01','DT01','GIOI',10),
 ('SV02','DT02','KHA',7),
 ('SV03','DT03','YEU',0),
 ('SV04','DT04','GIOI',10),
 ('SV05','DT05','GIOI',10)
 CREATE RULE cotdiem 
 AS @DIEM BETWEEN 0 AND 10
 EXEC sp_bindrule 'cotdiem', 'Diemsv.diem'
CREATE PROC PR4 @CHECK CHAR(30) AS
SELECT * FROM Giangvien, Detai, Diemsv, Sinhvien
WHERE Diemsv.Masv = Sinhvien.Masv AND Diemsv.Madt = Detai.Madt AND Giangvien.Magv = Detai.Magv
AND Tengv = @CHECK
EXEC PR4 'GIANGVIEN1'
CREATE TRIGGER TG5 ON Diemsv
FOR INSERT, UPDATE , DELETE
AS
BEGIN
 UPDATE Detai 
 SET Sosv = (SELECT(COUNT (DISTINCT Masv)) FROM Diemsv WHERE Diemsv.Madt = Detai.Madt GROUP BY Madt)
END
