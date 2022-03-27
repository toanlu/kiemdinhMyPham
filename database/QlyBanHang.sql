USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name='WEBBANMP')
BEGIN
        DROP DATABASE WEBBANMP
END
CREATE DATABASE WEBBANMP
GO
USE WEBBANMP
GO

CREATE TABLE TAIKHOAN (
    ID VARCHAR(15) NOT NULL, -- CREATE AUTO
    USERNAME VARCHAR(50), -- mã thành viên
    PW VARBINARY(50), -- MÃ HÓA + salt
    CONSTRAINT PK_TK PRIMARY KEY (ID)
)
CREATE TABLE THONGTINTAIKHOAN (
    ID VARCHAR(20) NOT NULL, -- CREATE AUTO
    HOTEN NVARCHAR(50), -- HỌ TÊN
    NGSINH DATE, -- NGÀY SINH
    GTINH BIT, -- 1: NAM, 0: NỮ, NULL: CHƯA BIẾT(QUY VỀ 0)
    NGTAO DATE, -- NGÀY TẠO
    EMAIL VARCHAR(50) unique, -- ĐỊA CHỈ EMAIL
    SDT VARCHAR(11) unique, -- SDT (chỉ 10 số theo format của Việt Nam)
    ID_TAIKHOAN VARCHAR(15) REFERENCES TAIKHOAN(ID),
    CONSTRAINT PK_TTTK PRIMARY KEY (ID)
)
CREATE TABLE TINHTHANH (
	ID INT IDENTITY NOT NULL,
	TEN NVARCHAR(90),
	CONSTRAINT PK_TINHTHANH PRIMARY KEY (ID)
)
CREATE TABLE QUANHUYEN (
	ID INT IDENTITY NOT NULL,
	TEN NVARCHAR(90),
	ID_TINHTHANH INT REFERENCES TINHTHANH(ID),
	CONSTRAINT PK_QH PRIMARY KEY (ID),
)
CREATE TABLE XAPHUONG (
	ID INT IDENTITY NOT NULL,
	TEN NVARCHAR(90),
	ID_QH INT REFERENCES QUANHUYEN(ID),
	CONSTRAINT PK_XP PRIMARY KEY (ID)
)
CREATE TABLE DIACHIGH ( -- địa chỉ giao hàng
	ID INT IDENTITY NOT NULL,
	SONHA NVARCHAR(100),
	IDTINH INT REFERENCES TINHTHANH(ID), -- TỈNH THÀNH
	IDHUYEN INT REFERENCES QUANHUYEN(ID), -- HUYỆN
	IDXA INT REFERENCES XAPHUONG(ID), -- XÃ
	ID_TTTK VARCHAR(20) REFERENCES THONGTINTAIKHOAN(ID),
	CONSTRAINT PK_DCGH PRIMARY KEY (ID, ID_TTTK)
)
CREATE TABLE KHACHHANG (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    ID_TK VARCHAR(15),
    DIEMTICHLUY INT,
    CONSTRAINT PK_KH PRIMARY KEY (ID),
    CONSTRAINT FK_KH_TK FOREIGN KEY (ID_TK) REFERENCES TAIKHOAN(ID)
)
CREATE TABLE NHANVIEN (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    ID_TK VARCHAR(15),
    CONSTRAINT PK_NV PRIMARY KEY (ID),
    CONSTRAINT FK_NV_TK FOREIGN KEY (ID_TK) REFERENCES TAIKHOAN(ID)
)
CREATE TABLE LOAISP (
    ID VARCHAR(6) NOT NULL,
    TENLOAI NVARCHAR(50),
    CONSTRAINT PK_LSP PRIMARY KEY (ID)
)
CREATE TABLE DANHMUC (
    ID INT IDENTITY NOT NULL,
    TENDANHMUC NVARCHAR(50),
    CONSTRAINT PK_DMUC PRIMARY KEY (ID)
)
CREATE TABLE CHITIETDANHMUC (
	ID_DANHMUC INT NOT NULL REFERENCES DANHMUC(ID),
	ID_LOAISP VARCHAR(6) NOT NULL REFERENCES LOAISP(ID),
	CONSTRAINT PL_CTTDM PRIMARY KEY (ID_DANHMUC, ID_LOAISP)
)
CREATE TABLE SANPHAM ( 
    ID VARCHAR(5) NOT NULL, -- CREATE AUTO
    TENSP NVARCHAR(MAX), -- TÊN SẢN PHẨM
    MOTA NVARCHAR(MAX), -- MÔ TẢ
    SOLUONG INT, -- SỐ LƯỢNG TỒN KHO
    NSX NVARCHAR(30), -- NHÀ SẢN XUẤT
    HINHANH VARCHAR(50),
    ID_LOAI VARCHAR(6) REFERENCES LOAISP(ID),
    CONSTRAINT PK_SP PRIMARY KEY (ID)
)

CREATE TABLE KHUYENMAI (
    ID INT IDENTITY NOT NULL,
    GIATRI FLOAT, -- GIÁ TRỊ SALE
    NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT SALE LẤY NGÀY GẦN NHẤT
    NGKETTHUC DATETIME, -- NGÀY KẾT THÚC
	HIEULUC BIT, -- hiệu lực (1 là còn hiệu lực)
    ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID), -- khuyến mãi dành cho khách hàng nào (nếu null là dành cho tất cả)
	ID_LOAI VARCHAR(6) REFERENCES LOAISP(ID), -- dành cho 1 loại sp nào đó vd như son, phấn ....
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID), -- dành cho sp cụ thể nào đó
    CONSTRAINT PK_SALE PRIMARY KEY (ID)
)
CREATE TABLE DONGIA (
    ID INT IDENTITY NOT NULL,
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    GIA FLOAT, -- GIÁ
    NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT - LẤY NGÀY MỚI NHẤT
    CONSTRAINT PK_DG PRIMARY KEY (ID, ID_SP)
)
CREATE TABLE HOADON (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    NGTAO DATE, -- NGÀY TẠO HÓA ĐƠN
    DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ)
    ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID), -- Hiển thị các thông tin cơ bản của Khách Hàng
    CONSTRAINT PK_HD PRIMARY KEY (ID)
)
CREATE TABLE CHITIETHD (
    ID INT IDENTITY NOT NULL,
    ID_HD VARCHAR(10) REFERENCES HOADON(ID),
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
	IDKM INT REFERENCES KHUYENMAI(ID),
    CONSTRAINT PK_CTHD PRIMARY KEY (ID, ID_HD) 
)

-- CREATE TABLE VIEW 
CREATE VIEW rndVIEW
AS
SELECT RAND() rndResult
GO

----------------------------------------------------------
--  ___   Proc                     _   ___   Func       --
-- | _ \_ _ ___  __   __ _ _ _  __| | | __|  _ _ _  __  --
-- |  _/ '_/ _ \/ _| / _` | ' \/ _` | | _| || | ' \/ _| --
-- |_| |_| \___/\__| \__,_|_||_\__,_| |_| \_,_|_||_\__| --
----------------------------------------------------------

-- function
CREATE FUNCTION fn_hash(@text VARCHAR(50))
RETURNS VARBINARY(MAX)
AS
BEGIN
	RETURN HASHBYTES('SHA2_256', @text);
END
GO

CREATE FUNCTION fn_getRandom ( -- TRẢ VỀ 1 SỐ NGẪU NHIÊN
	@min int, 
	@max int
)
RETURNS INT
AS
BEGIN
    RETURN FLOOR((SELECT rndResult FROM rndVIEW) * (@max - @min + 1) + @min);
END
GO

CREATE FUNCTION fn_getCodeGr(@tenGr VARCHAR(50)) -- TRẢ VỀ CODE GR
RETURNS CHAR(2)
AS
BEGIN
    DECLARE @CODEGR CHAR(2)
    SELECT @CODEGR = CODEGR FROM GRTK WHERE TEN = @tenGr

    RETURN @CODEGR
END
GO

CREATE FUNCTION fn_autoIDTK(@TENGR VARCHAR(50)) -- id TÀI KHOẢN
RETURNS VARCHAR(15)
AS
BEGIN
	DECLARE @ID VARCHAR(15)
	DECLARE @maCodeGr CHAR(2)
	DECLARE @IDGR INT

    -- LẤY MÃ GR
    SELECT @IDGR=ID, @maCodeGr = CODEGR FROM GRTK WHERE TEN = @TENGR

	IF (SELECT COUNT(ID) FROM TAIKHOAN WHERE ID_GR = @IDGR) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM TAIKHOAN WHERE ID_GR = @IDGR

    DECLARE @ngayTao VARCHAR(8) = convert(VARCHAR, getdate(), 112) -- format yyyymmdd
    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @ngayTao + @maCodeGr + @stt
		WHEN @ID >=  9 THEN @ngayTao + @maCodeGr + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @ngayTao + @maCodeGr + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDKH() -- id KHÁCH HÀNG
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ID VARCHAR(10)

	IF (SELECT COUNT(ID) FROM KHACHHANG) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM KHACHHANG

    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(2) = 'KH'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDNV() -- id NHÂN VIÊN
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ID VARCHAR(10)

	IF (SELECT COUNT(ID) FROM NHANVIEN) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM NHANVIEN

    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(2) = 'NV'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDHD() -- id HÓA ĐƠN
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ID VARCHAR(10)

	IF (SELECT COUNT(ID) FROM HOADON) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM HOADON

    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(2) = 'HD'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDLSP() -- id LOẠI SP 
RETURNS VARCHAR(6)
AS
BEGIN
	DECLARE @ID VARCHAR(6)

	IF (SELECT COUNT(ID) FROM LOAISP) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM LOAISP

    DECLARE @stt VARCHAR(3) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(3) = 'LSP'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDSP() -- id SP
RETURNS VARCHAR(5)
AS
BEGIN
	DECLARE @ID VARCHAR(5)

	IF (SELECT COUNT(ID) FROM SANPHAM) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM SANPHAM

    DECLARE @stt VARCHAR(3) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
	
    DECLARE @maCode CHAR(2) = 'SP'
	
	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END
	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDTTND(
    @idLogin VARCHAR(15)
) -- id CỦA THÔNG TIN NGƯỜI DÙNG: IDLOGIN + mã rand
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @randNumber INT = DBO.fn_getRandom(100, 999)
    
    DECLARE @ID VARCHAR(20) = @idLogin + convert(CHAR, @randNumber)

	RETURN @ID
END
GO
-- proc 
CREATE PROC sp_getIDDMUC
@tenDMuc NVARCHAR(50)
AS
    DECLARE @IDDM INT
    SELECT @IDDM = ID FROM DANHMUC WHERE TENDANHMUC = @tenDMuc

    RETURN @IDDM
GO


CREATE PROC sp_getIDGR -- TRẢ VỀ ID GR
@tenGr NVARCHAR(50)
AS
    DECLARE @IDGR INT
    SELECT @IDGR = ID FROM GRTK WHERE TEN = @tenGr

    RETURN @IDGR 
GO

CREATE PROC sp_GetErrorInfo  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS 'Message';
GO 

CREATE PROC sp_AddDMUC
@tenDanhMuc NVARCHAR(50)
AS
    BEGIN TRY
		IF EXISTS(SELECT * FROM DANHMUC WHERE TENDANHMUC = @tenDanhMuc)
			THROW 51000, N'Tên danh mục đã tồn tại.', 1;
		
		INSERT DANHMUC
		SELECT @tenDanhMuc
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_AddLSP -- THÊM LOẠI SP
@tenLSP NVARCHAR(50),
@tenDanhMuc NVARCHAR(50)
AS 
    BEGIN TRY
        DECLARE @idDanhMuc INT
        EXEC @idDanhMuc = sp_getIDDMUC @tenDanhMuc

        IF EXISTS(SELECT * FROM CHITIETDANHMUC WHERE ID_DANHMUC = @idDanhMuc AND ID_LOAISP = (SELECT ID FROM LOAISP WHERE TENLOAI = @tenLSP))
			THROW 51000, N'Loại sản phẩm đã tồn tại.', 1;

		DECLARE @IDLSP VARCHAR(6) = DBO.fn_autoIDLSP()
		
		INSERT LOAISP
		SELECT @IDLSP, UPPER(@tenLSP); 

		INSERT CHITIETDANHMUC
		SELECT @idDanhMuc, @IDLSP
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_SetDG -- SET ĐƠN GIÁ
@tenSP NVARCHAR(50),
@gia FLOAT
AS
	BEGIN
		DECLARE @maSP VARCHAR(10)
		SELECT @maSP = ID FROM SANPHAM WHERE TENSP = @tenSP

		INSERT DONGIA(ID_SP, GIA)
		VALUES (@maSP, @gia)
	END
GO

CREATE PROC sp_GetMaHD
@maHD VARCHAR(10) OUTPUT
AS
	SELECT @maHD = DBO.fn_autoIDHD()
GO

CREATE PROC sp_AddHD
@maHD VARCHAR(10),
@tenKH NVARCHAR(50),
@username VARCHAR(50),
@tenSP NVARCHAR(MAX),
@soLuong INT
AS
	BEGIN TRY
		DECLARE @maKH VARCHAR(10), @maSP VARCHAR(5)

		IF NOT EXISTS (SELECT * FROM HOADON WHERE ID = @maHD)
		BEGIN
			INSERT HOADON(ID) SELECT @maHD

			-- LẤY MÃ KHÁCH HÀNG
			SELECT @maKH = ID FROM KHACHHANG WHERE ID_TK = (SELECT ID_TAIKHOAN FROM THONGTINTAIKHOAN tttk join TAIKHOAN on tttk.ID_TAIKHOAN=TAIKHOAN.ID WHERE HOTEN = @tenKH and ID_GR = 3 and USERNAME = @username)

			-- ADD MÃ KHÁCH HÀNG VÀ NHÂN VIÊN VÀO HÓA ĐƠN
			UPDATE HOADON SET ID_KH = @maKH WHERE ID = @maHD
		END

		-- LẤY MÃ SẢN PHẨM 
		SELECT @maSP = ID FROM SANPHAM WHERE TENSP = @tenSP

		-- kiểm tra kho
		DECLARE @MESSAGE NVARCHAR(70) = @tenSP + N' đã hết hàng'
		IF @soLuong > (SELECT SOLUONG FROM SANPHAM WHERE TENSP = @tenSP)
			THROW 51000, @MESSAGE, 1;

		-- THÊM THÔNG TIN CHO HÓA ĐƠN
		INSERT CHITIETHD(ID_HD, ID_SP, SOLUONG) SELECT @maHD, @maSP, @soLuong

		-- cập nhật lại số lượng sản phẩm
		UPDATE SANPHAM SET SOLUONG = SOLUONG - @soLuong WHERE ID = @maSP

		-- CẬP NHẬT ĐƠN GIÁ ---------------------- kiểm tra ngày mới nhất trong đơn giá
		DECLARE @donGia FLOAT -- đơn giá của sản phẩm x

		SELECT TOP 1 @donGia = SUM(@soLuong * GIA)
		FROM DONGIA
		WHERE ID_SP = @maSP
		GROUP BY NGCAPNHAT
		ORDER BY NGCAPNHAT DESC
		
		UPDATE HOADON SET DONGIA = DONGIA + @donGia WHERE ID = @maHD

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

--ID VARCHAR(5) NOT NULL, -- CREATE AUTO
--TENSP NVARCHAR(50), -- TÊN SẢN PHẨM
--MOTA NVARCHAR(MAX), -- MÔ TẢ
--SOLUONG INT, -- SỐ LƯỢNG TỒN KHO
---- DONGIA FLOAT, -- ĐƠN GIÁ
--NSX NVARCHAR(30), -- NHÀ SẢN XUẤT
--HINHANH VARCHAR(50),
--ID_LOAI VARCHAR(6) REFERENCES LOAISP(ID),
CREATE PROC sp_AddSP
@tenSP NVARCHAR(MAX),
@moTa NVARCHAR(MAX),
@soLuong INT,
@gia FLOAT,
@nxs NVARCHAR(30),
@urlImage VARCHAR(50),
@tenLSP NVARCHAR(50),
@tenDM NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDSP VARCHAR(15) = DBO.fn_autoIDSP() -- id SP
		-- select DBO.fn_autoIDSP() select * from sanpham
		IF EXISTS(SELECT * FROM SANPHAM WHERE TENSP = @tenSP)
			THROW 51000, N'Sản phẩm đã tồn tại.', 1;

		DECLARE @IDLSP VARCHAR(6)

		SELECT @IDLSP = ID 
		FROM LOAISP JOIN CHITIETDANHMUC CTDM
			ON LOAISP.ID=CTDM.ID_LOAISP 
		WHERE TENLOAI = @tenLSP AND ID_DANHMUC = (SELECT ID FROM DANHMUC WHERE TENDANHMUC=@tenDM)
		
				
		INSERT SANPHAM(ID, TENSP, MOTA, SOLUONG, NSX, HINHANH, ID_LOAI)
		VALUES (@IDSP, @tenSP, @moTa, @soLuong, @nxs, @urlImage, @IDLSP)

		INSERT DONGIA(ID_SP, GIA)
		VALUES (@IDSP, @gia)
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

-- ID VARCHAR(20)
-- HOTEN NVARCHAR(50), -- HỌ TÊN
-- NGSINH DATE, -- NGÀY SINH
-- GTINH BIT, -- 1: NAM, 0: NỮ, NULL: CHƯA BIẾT(QUY VỀ 0)
-- NGTAO DATE, -- NGÀY TẠO
-- EMAIL VARCHAR(50), -- ĐỊA CHỈ EMAIL
-- SDT VARCHAR(11), -- SDT
-- DCHI NVARCHAR(50)
CREATE PROC sp_AddAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50),
@hoTen NVARCHAR(50),
@ngSinh DATE,
@gioiTinh NVARCHAR(5),
@email VARCHAR(50),
@sdt VARCHAR(11),
@dChi NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @ID VARCHAR(15) = DBO.fn_autoIDTK(@GRNAME) -- id login

		DECLARE	@createPW VARBINARY(MAX) = SubString(DBO.fn_hash(@ID), 1, len(DBO.fn_hash(@ID))/2) + DBO.fn_hash(@pw + @ID)

		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		IF EXISTS(SELECT * FROM TAIKHOAN WHERE ID_GR = @IDGR AND USERNAME = @userName)
			THROW 51000, N'Username đã tồn tại.', 1;

		-- tạo tài khoản
		INSERT TAIKHOAN
		SELECT @ID, @userName, @createPW, @IDGR; 

        IF (UPPER(@GRNAME) = N'NHÂN VIÊN')
        BEGIN
            INSERT NHANVIEN (ID_TK)
            SELECT @ID
        END

        IF (UPPER(@GRNAME) = N'KHÁCH HÀNG')
        BEGIN
            INSERT KHACHHANG(ID_TK)
            SELECT @ID
        END

        DECLARE @GTINH BIT = 0
        IF (UPPER(@gioiTinh) = N'NAM')
            SET @GTINH = 1;

        -- tạo thông tin người dùng
        INSERT THONGTINTAIKHOAN(ID, HOTEN, NGSINH, GTINH, EMAIL, SDT, DCHI, ID_TAIKHOAN)
        VALUES(DBO.fn_autoIDTTND(@ID), UPPER(@hoTen), @ngSinh, @GTINH, @email, @sdt, @dChi, @ID)
		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_UpTTTK
@maTK VARCHAR(15),
@hoTen NVARCHAR(50),
@ngSinh DATE,
@gioiTinh NVARCHAR(5),
@email VARCHAR(50),
@sdt VARCHAR(11),
@dChi NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @GTINH BIT = 0
        IF (UPPER(@gioiTinh) = N'NAM')
            SET @GTINH = 1;

        -- tạo thông tin người dùng
		UPDATE THONGTINTAIKHOAN SET HOTEN = @hoTen, 
									NGSINH=@ngSinh, 
									GTINH=@GTINH, 
									EMAIL=@email,
									SDT=@sdt,
									DCHI=@dChi
				WHERE ID_TAIKHOAN=@maTK

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_CKUsername
@userName VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		IF EXISTS(SELECT * FROM TAIKHOAN WHERE ID_GR = @IDGR AND USERNAME = @userName)
			THROW 51000, N'Username đã tồn tại.', 1;

		SELECT N'ok' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_CKAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		DECLARE	@createPW VARBINARY(MAX) = SubString(DBO.fn_hash(@IDTK), 1, len(DBO.fn_hash(@IDTK))/2) + DBO.fn_hash(@pw + @IDTK)

		IF NOT EXISTS(SELECT * FROM TAIKHOAN WHERE ID_GR = @IDGR AND USERNAME = @userName AND PW = @createPW)
			THROW 51000, N'Thông tin đăng nhập không chính xác.', 1;

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_ChangeAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		DECLARE	@createPW VARBINARY(MAX) = SubString(DBO.fn_hash(@IDTK), 1, len(DBO.fn_hash(@IDTK))/2) + DBO.fn_hash(@pw + @IDTK)

		UPDATE TAIKHOAN SET PW = @createPW WHERE ID = @IDTK AND ID_GR = @IDGR

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

-- TẠO RÀNG BUỘC
ALTER TABLE THONGTINTAIKHOAN
ADD CONSTRAINT DF_NGTAO_TTTK DEFAULT GETDATE() FOR NGTAO

ALTER TABLE DONGIA
ADD CONSTRAINT DF_NGCAPNHAT_DG DEFAULT GETDATE() FOR NGCAPNHAT

ALTER TABLE KHUYENMAI
ADD CONSTRAINT DF_NGCAPNHAT_S DEFAULT GETDATE() FOR NGCAPNHAT

ALTER TABLE KHACHHANG
ADD CONSTRAINT DF_ID_KH DEFAULT DBO.fn_autoIDKH() FOR ID,
    CONSTRAINT DF_DIEMTICHLUY DEFAULT 0 FOR DIEMTICHLUY

ALTER TABLE NHANVIEN 
ADD CONSTRAINT DF_ID_NV DEFAULT DBO.fn_autoIDNV() FOR ID

ALTER TABLE HOADON 
ADD CONSTRAINT DF_NGTAO_HD DEFAULT GETDATE() FOR NGTAO,
    CONSTRAINT DF_ID DEFAULT DBO.fn_autoIDHD() FOR ID,
	CONSTRAINT DF_DONGIA DEFAULT 0 FOR DONGIA

ALTER TABLE CHITIETHD
ADD CONSTRAINT CK_SL CHECK (SOLUONG > 0)

ALTER TABLE THONGKETRUYCAP
ADD CONSTRAINT DF_NGGHI DEFAULT GETDATE() FOR NGGHI,
    CONSTRAINT DF_ISONL DEFAULT 1 FOR ISONL

GO

--------------------------------
--  ___           _   data    --
-- |   \   __ _  | |_   __ _  --
-- | |) | / _` | |  _| / _` | --
-- |___/  \__,_|  \__| \__,_| --
--------------------------------

-- BẢNG TB_GRTK
INSERT GRTK VALUES(N'ADMIN', '00')
INSERT GRTK VALUES(N'NHÂN VIÊN', '01')
INSERT GRTK VALUES(N'KHÁCH HÀNG', '02')

-- BẢNG TAIKHOAN
EXEC sp_AddAcc 'admin', 'admin@123456789', N'ADMIN', N'Admin', '2-5-2001', N'nam', 'admin@gmail.com', '000000000', null

EXEC sp_AddAcc 'tuhueson', '123456789', N'Khách Hàng', N'Từ Huệ Sơn', '2-5-2001', N'nam', 'tuhueson@gmail.com', '0938252793', null
EXEC sp_AddAcc 'leductai', '123456789', N'Khách Hàng', N'Lê Đức Tài', '12-4-2001', N'nam', 'leductai@gmail.com', '000000000', null
EXEC sp_AddAcc 'huynhmytran', '123456789', N'Khách Hàng', N'Huỳnh Mỹ Trân', '9-2-2001', N'nữ', 'huynhmytran@gmail.com', '000000000', null
EXEC sp_AddAcc 'tranthanhtam', '123456789', N'Khách Hàng', N'Trần Thành Tâm', '12-21-2001', N'nam', 'tranthanhtam@gmail.com', '000000000', null
-- BẢNG DANH MỤC
EXEC sp_AddDMUC N'Chăm sóc da' 
EXEC sp_AddDMUC N'Chăm sóc cơ thể' 
EXEC sp_AddDMUC N'Chăm sóc tóc' 
EXEC sp_AddDMUC N'Trang điểm' 

-- BẢNG LOẠI SP
-- chăm sóc da
EXEC sp_AddLSP N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddLSP N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddLSP N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddLSP N'Toner', N'Chăm sóc da'
EXEC sp_AddLSP N'Serum', N'Chăm sóc da'
EXEC sp_AddLSP N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddLSP N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddLSP N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddLSP N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddLSP N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddLSP N'Chống nắng', N'Chăm sóc da'
-- chăm sóc cơ thể
EXEC sp_AddLSP N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddLSP N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddLSP N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddLSP N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddLSP N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddLSP N'Nước hoa', N'Chăm sóc cơ thể'
-- Chăm sóc tóc
EXEC sp_AddLSP N'Dầu gội', N'Chăm sóc tóc'
EXEC sp_AddLSP N'Dầu xả', N'Chăm sóc tóc'
EXEC sp_AddLSP N'Kem ủ tóc', N'Chăm sóc tóc'
EXEC sp_AddLSP N'Đặc trị tóc', N'Chăm sóc tóc'
EXEC sp_AddLSP N'Nhuộm tóc', N'Chăm sóc tóc'
-- Trang điểm
EXEC sp_AddLSP N'Kem lót', N'Trang điểm'
EXEC sp_AddLSP N'Kem nền', N'Trang điểm'
EXEC sp_AddLSP N'Che khuyết điểm', N'Trang điểm'
EXEC sp_AddLSP N'Phấn phủ', N'Trang điểm'
EXEC sp_AddLSP N'Tạo khối', N'Trang điểm'
EXEC sp_AddLSP N'Kẻ chân mày', N'Trang điểm'
EXEC sp_AddLSP N'Phấn mắt', N'Trang điểm'
EXEC sp_AddLSP N'Kẻ mắt', N'Trang điểm'
EXEC sp_AddLSP N'Mascara', N'Trang điểm'
EXEC sp_AddLSP N'Má hồng', N'Trang điểm'
EXEC sp_AddLSP N'Son thỏi', N'Trang điểm'
EXEC sp_AddLSP N'Son kem', N'Trang điểm'

-- BẢNG SẢN PHẨM
-- EXEC sp_AddSP N'TÊN SP', N'MÔ TẢ', 5, 1000000, N'NHÀ SẢN XUẤT', 'URL_IMAGE', N'Tẩy trang'

--Chăm sóc da
EXEC sp_AddSP N'Nước Tẩy Trang L''Oreal Paris Skincare Make Up Remover Micellar Refreshing Tươi Mát 400ml', N'Làm sạch sâu. Giúp thông thoáng lỗ chân lông. Dưỡng ẩm cho da. Ngăn ngừa mụn. Thúc đẩy quá trình tái tạo tế bào da mới.', 15, 500000, N'Mỹ', 'TayTrang1.jpg', N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Tẩy trang dưỡng trắng Senka All Clear Water Micellar Formula White (230ml)', N'Làm sạch sâu. Giúp thông thoáng lỗ chân lông. Dưỡng ẩm cho da. Ngăn ngừa mụn. Thúc đẩy quá trình tái tạo tế bào da mới.', 20, 400000, N'Nhật', 'TayTrang2.jpg', N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Tẩy Trang Dành Cho Da Nhạy Cảm Bioderma Sensibio H20 250ml', N'Làm sạch sâu. Giúp thông thoáng lỗ chân lông. Dưỡng ẩm cho da. Ngăn ngừa mụn. Thúc đẩy quá trình tái tạo tế bào da mới.', 10, 600000, N'Pháp', 'TayTrang3.jpg', N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Làm Sạch Sâu Và Tẩy Trang La Roche-Posay Dành Cho Da Nhạy Cảm 400ml', N'Làm sạch sâu. Giúp thông thoáng lỗ chân lông. Dưỡng ẩm cho da. Ngăn ngừa mụn. Thúc đẩy quá trình tái tạo tế bào da mới.', 12, 450000, N'Pháp', 'TayTrang4.jpg', N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Tẩy Trang Cocoon Rose Hoa Hồng Làm Sạch Da Và Cấp Ẩm 500ml', N'Làm sạch sâu. Giúp thông thoáng lỗ chân lông. Dưỡng ẩm cho da. Ngăn ngừa mụn. Thúc đẩy quá trình tái tạo tế bào da mới.', 16, 230000, N'Việt Nam', 'TayTrang5.jpg', N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Tẩy trang Yves Rocher Pure Blue Gentle Makeup Remover 200ml', N'Làm sạch sâu. Giúp thông thoáng lỗ chân lông. Dưỡng ẩm cho da. Ngăn ngừa mụn. Thúc đẩy quá trình tái tạo tế bào da mới.', 22, 550000, N'Mỹ', 'TayTrang6.jpg', N'Tẩy trang', N'Chăm sóc da'
EXEC sp_AddSP N'Sữa Rửa Mặt Cosrx Pure Fit Cica Cleanser 150ml', N'Tác dụng hỗ trợ ngăn ngừa và điều trị mụn. Se khít lỗ chân lông.Cân bằng độ ẩm cho da. Giúp da hấp thu dưỡng chất tốt hơn trong các bước dưỡng sau đó', 10, 500000, N'Mỹ', 'Srm1.jpg', N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddSP N'Gel Rửa Mặt Cosrx Good Morning Low PH Cleanser 150ml', N'Tác dụng hỗ trợ ngăn ngừa và điều trị mụn. Se khít lỗ chân lông.Cân bằng độ ẩm cho da. Giúp da hấp thu dưỡng chất tốt hơn trong các bước dưỡng sau đó', 15, 300000, N'Mỹ', 'Srm2.jpg', N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddSP N'Sữa Rửa Mặt Làm Sạch Sâu Và Tẩy Da Chết Skinfood Black Sugar Perfect Scrub Foam 180g', N'Tác dụng hỗ trợ ngăn ngừa và điều trị mụn. Se khít lỗ chân lông.Cân bằng độ ẩm cho da. Giúp da hấp thu dưỡng chất tốt hơn trong các bước dưỡng sau đó', 25, 250000, N'Mỹ', 'Srm3.jpg', N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddSP N'Sữa Rửa Mặt Dr. Belmeur Daily Repair Foam Cleanser', N'Tác dụng hỗ trợ ngăn ngừa và điều trị mụn. Se khít lỗ chân lông.Cân bằng độ ẩm cho da. Giúp da hấp thu dưỡng chất tốt hơn trong các bước dưỡng sau đó', 12, 350000, N'Pháp', 'Srm4.jpg', N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddSP N'Sữa rửa mặt tạo bọt Cerave Foaming Facial Cleanser', N'Tác dụng hỗ trợ ngăn ngừa và điều trị mụn. Se khít lỗ chân lông.Cân bằng độ ẩm cho da. Giúp da hấp thu dưỡng chất tốt hơn trong các bước dưỡng sau đó', 20, 100000, N'Mỹ', 'Srm5.jpg', N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddSP N'Sữa Rửa Mặt Sủi Bọt Some By Mi Bye Blackhead 30Days Greentea Tox Trị Mụn Đầu Đen 120ml', N'Tác dụng hỗ trợ ngăn ngừa và điều trị mụn. Se khít lỗ chân lông.Cân bằng độ ẩm cho da. Giúp da hấp thu dưỡng chất tốt hơn trong các bước dưỡng sau đó', 6, 300000, N'Mỹ', 'Srm6.jpg', N'Sữa rửa mặt', N'Chăm sóc da'
EXEC sp_AddSP N'Tẩy Da Chết Mặt Cocoon Coffee Face Polish 150ml', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da', 15, 100000, N'Việt Nam', 'TBC1.jpg', N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddSP N'Tẩy Tế Bào Chết Naruko Tea Tree', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da', 12, 200000, N'Mỹ', 'TBC2.jpg', N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddSP N'Tẩy Da Chết Huxley Secret Of Sahara Scrub Mask', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da', 22, 300000, N'Pháp', 'TBC3.jpg', N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddSP N'Gel tẩy tế bào chết Bioderma cho làn da thanh khiết và mịn màng hơn.', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da', 10, 250000, N'Anh', 'TBC4.jpg', N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddSP N'Tẩy Tế Bào Chết Da Mặt Rosette Peeling Gel', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da', 6, 150000, N'Nhật', 'TBC5.jpg', N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddSP N'Gel Tẩy Da Chết Mamonde Aqua Peel Peeling Gel Plum Blossom 100ml', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da', 8, 400000, N'Hàn Quốc', 'TBC6.jpg', N'Tẩy tế bào chết', N'Chăm sóc da'
EXEC sp_AddSP N'Toner Some By Mi Super Matcha Pore Tightening Cải Thiện Làn Da 150ml', N'Dưỡng ẩm. Làm sáng da', 15, 160000, N'Hàn Quốc', 'Toner1.jpg', N'Toner', N'Chăm sóc da'
EXEC sp_AddSP N'Dung Dịch Trị Mụn Obagi Medical Salicylic Acid', N'Dưỡng ẩm. Làm sáng da', 25, 400000, N'Mỹ', 'Toner2.jpg', N'Toner', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Hoa Hồng I''m from Chiết Xuất Gạo Dưỡng Sáng Da 150ml', N'Dưỡng ẩm. Làm sáng da', 12, 300000, N'Hàn Quốc', 'Toner3.jpg', N'Toner', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Hoa Hồng Muji Moisture Toner 200ml', N'dDưỡng ẩm. Làm sáng da', 10, 200000, N'Nhật', 'Toner4.jpg', N'Toner', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Hoa Hồng Không Cồn Thayers Cucumber 355ml', N'Dưỡng ẩm. Làm sáng da', 8, 2300000, N'Mỹ', 'Toner5.jpg', N'Toner', N'Chăm sóc da'
EXEC sp_AddSP N'Nước hoa hồng Skin1004 Madagascar Centella Toning Toner 210ml', N'Dưỡng ẩm. Làm sáng da', 9, 100000, N'Hàn Quốc', 'Toner6.jpg', N'Toner', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất Làm Dịu Da COSRX PURE FIT CICA SERUM 30ml', N'Chống lão hóa. hạn chế nếp nhăn và tình trạng chảy xệ của da.', 10, 180000, N'Hàn Quốc', 'Serum1.jpg', N'Serum', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất The Ordinary Hyaluronic Acid 2% + B5', N'Chống lão hóa. hạn chế nếp nhăn và tình trạng chảy xệ của da.', 14, 160000, N'Canada', 'Serum2.jpg', N'Serum', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất The Ordinary Amino Acids + B5', N'Chống lão hóa. Hạn chế nếp nhăn và tình trạng chảy xệ của da.', 23, 200000, N'Canada', 'Serum3.jpg', N'Serum', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất Some By Mi Trị Mụn Và Dưỡng Da 30 Ngày Miracle Serum 50ml', N'Chống lão hóa. Hạn chế nếp nhăn và tình trạng chảy xệ của da.', 21, 400000, N'Hàn Quốc', 'Serum4.jpg', N'Serum', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất Dưỡng Ẩm Chiết Xuất Xương Rồng Huxley Essence; Grab Water 30ml', N'Chống lão hóa. Hạn chế nếp nhăn và tình trạng chảy xệ của da.', 11, 300000, N'Hàn Quốc', 'Serum5.jpg', N'Serum', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh chất rau má trị mụn Skin1004 Madagascar Centella Ampoule', N'Chống lão hóa. Hạn chế nếp nhăn và tình trạng chảy xệ của da.', 16, 230000, N'Hàn Quốc', 'Serum6.jpg', N'Serum', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Ngải Cứu I''m From Mugwort Cream', N'Ngăn ngừa khô da. Làm chậm tiến trình lão hóa. Ngăn ngừa và hỗ trợ điều trị mụn. Bảo vệ da khỏi các tác nhân bên ngoài. Ngăn ngừa kích ứng da. Kiểm soát dầu thừa hiệu quả', 15, 1000000, N'Hàn Quốc', 'KemDuong1.jpg', N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Da I''M From Honey Glow Cream', N'Ngăn ngừa khô da. Làm chậm tiến trình lão hóa. Ngăn ngừa và hỗ trợ điều trị mụn. Bảo vệ da khỏi các tác nhân bên ngoài. Ngăn ngừa kích ứng da. Kiểm soát dầu thừa hiệu quả', 12, 2000000, N'Anh', 'KemDuong2.jpg', N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Cosrx Snail 92 All In One Cream', N'Ngăn ngừa khô da. Làm chậm tiến trình lão hóa. Ngăn ngừa và hỗ trợ điều trị mụn. Bảo vệ da khỏi các tác nhân bên ngoài. Ngăn ngừa kích ứng da. Kiểm soát dầu thừa hiệu quả', 22, 3000000, N'Pháp', 'KemDuong3.jpg', N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Cosrx Green Tea Aqua Soothing Gel Cream', N'Ngăn ngừa khô da. Làm chậm tiến trình lão hóa. Ngăn ngừa và hỗ trợ điều trị mụn. Bảo vệ da khỏi các tác nhân bên ngoài. Ngăn ngừa kích ứng da. Kiểm soát dầu thừa hiệu quả', 8, 1500000, N'Nhật', 'KemDuong4.jpg', N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Some By Mi Trị Mụn Và Dưỡng Da 30 Ngày Miracle Cream', N'Ngăn ngừa khô da. Làm chậm tiến trình lão hóa. Ngăn ngừa và hỗ trợ điều trị mụn. Bảo vệ da khỏi các tác nhân bên ngoài. Ngăn ngừa kích ứng da. Kiểm soát dầu thừa hiệu quả', 10, 2400000, N'Mỹ', 'KemDuong5.jpg', N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Some By Mi Snail Truecica Miracle Repair Cream Phục Hồi Da', N'Ngăn ngừa khô da. Làm chậm tiến trình lão hóa. Ngăn ngừa và hỗ trợ điều trị mụn. Bảo vệ da khỏi các tác nhân bên ngoài. Ngăn ngừa kích ứng da. Kiểm soát dầu thừa hiệu quả', 3, 1200000, N'Nhật', 'KemDuong6.jpg', N'Kem dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Thanh Lăn Trị Thâm Bọng Mắt Eveline Bio Hyaluron 4D', N'Là sản phẩm chuyên dùng để chăm sóc cho vùng da quanh mắt, giúp bạn giữ độ ẩm, làm giảm quầng thâm, bọng mắt và cải thiện các vùng da bị nếp nhăn.', 13, 500000, N'Mỹ', 'KemMat1.jpg', N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddSP N'Kem dưỡng mắt Propolis Essential Eye Cream', N'Là sản phẩm chuyên dùng để chăm sóc cho vùng da quanh mắt, giúp bạn giữ độ ẩm, làm giảm quầng thâm, bọng mắt và cải thiện các vùng da bị nếp nhăn.', 20, 500000, N'Nhật', 'KemMat2.jpg', N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Mắt AHC Time Rewind Real Eye Cream', N'Là sản phẩm chuyên dùng để chăm sóc cho vùng da quanh mắt, giúp bạn giữ độ ẩm, làm giảm quầng thâm, bọng mắt và cải thiện các vùng da bị nếp nhăn.', 9, 450000, N'Nhật', 'KemMat3.jpg', N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Mắt AHC Youth Lasting Real Eye Cream', N'Là sản phẩm chuyên dùng để chăm sóc cho vùng da quanh mắt, giúp bạn giữ độ ẩm, làm giảm quầng thâm, bọng mắt và cải thiện các vùng da bị nếp nhăn.', 15, 300000, N'Pháp', 'KemMat4.jpg', N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Dưỡng Mắt Bioderma Sensibio Eye Contour Gel', N'Là sản phẩm chuyên dùng để chăm sóc cho vùng da quanh mắt, giúp bạn giữ độ ẩm, làm giảm quầng thâm, bọng mắt và cải thiện các vùng da bị nếp nhăn.', 23, 400000, N'Mỹ', 'KemMat5.jpg', N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddSP N'Kem dưỡng giúp giảm nếp nhăn quầng thâm & bọng mắt Vichy Liftactiv Supreme Eyes', N'Là sản phẩm chuyên dùng để chăm sóc cho vùng da quanh mắt, giúp bạn giữ độ ẩm, làm giảm quầng thâm, bọng mắt và cải thiện các vùng da bị nếp nhăn.', 14, 300000, N'Canada', 'KemMat6.jpg', N'Dưỡng mắt', N'Chăm sóc da'
EXEC sp_AddSP N'Son dưỡng Môi Burt''s Bees Beeswax Lip Balm with Vitamin E & Peppermint', N'Dưỡng ẩm và ngăn chặn môi nứt nẻ. Chống lão hóa môi. Ngăn chặn ánh nắng mặt trời làm hại môi', 25, 400000, N'Mỹ', 'LipBalm1.jpg', N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Son Dưỡng Môi Burt''s Bee Moisturizing Lip Balm Pomegranate', N'Dưỡng ẩm và ngăn chặn môi nứt nẻ. Chống lão hóa môi. Ngăn chặn ánh nắng mặt trời làm hại môi', 15, 500000, N'Mỹ', 'LipBalm2.jpg', N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Son Dưỡng Môi Burt''s Bees Mango Moisturizing Lip Balm', N'Dưỡng ẩm và ngăn chặn môi nứt nẻ. Chống lão hóa môi. Ngăn chặn ánh nắng mặt trời làm hại môi', 35, 350000, N'Mỹ', 'LipBalm3.jpg', N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Son Dưỡng Dầu Dừa Cocoon Ben Tre Coconut Lip Balm With Shea Butter & Vitamin E 5g', N'Dưỡng ẩm và ngăn chặn môi nứt nẻ. Chống lão hóa môi. Ngăn chặn ánh nắng mặt trời làm hại môi', 23, 450000, N'Việt Nam', 'LipBalm4.jpg', N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Son Dưỡng Môi Yves Rocher Hương Cherry', N'Dưỡng ẩm và ngăn chặn môi nứt nẻ. Chống lão hóa môi. Ngăn chặn ánh nắng mặt trời làm hại môi', 14, 410000, N'Pháp', 'LipBalm5.jpg', N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Son dưỡng DHC Lip Cream', N'Dưỡng ẩm và ngăn chặn môi nứt nẻ. Chống lão hóa môi. Ngăn chặn ánh nắng mặt trời làm hại môi', 15, 230000, N'Nhật', 'LipBalm6.jpeg', N'Son dưỡng', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Xịt Khoáng La Roche-Posay Giúp Làm Dịu & Bảo Vệ Da 50ml', N'Cấp ẩm tức thời. Xịt khoáng làm dịu da. Bảo vệ da khỏi các tác nhân bên ngoài. Xịt khoáng giúp giữ lớp trang điểm bền hơn.Làm sạch da tạm thời.', 15, 300000, N'Anh', 'XitKhoang1.jpg', N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Xịt Khoáng Dưỡng Da Vichy Thermale 300ml', N'Cấp ẩm tức thời. Xịt khoáng làm dịu da. Bảo vệ da khỏi các tác nhân bên ngoài. Xịt khoáng giúp giữ lớp trang điểm bền hơn. Làm sạch da tạm thời.', 25, 400000, N'Pháp', 'XitKhoang2.jpg', N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Xịt Khoáng Evoluderm Cấp Ẩm Làm Dịu Da 400m', N'Cấp ẩm tức thời. Xịt khoáng làm dịu da. Bảo vệ da khỏi các tác nhân bên ngoài. Xịt khoáng giúp giữ lớp trang điểm bền hơn. Làm sạch da tạm thời.', 12, 350000, N'Pháp', 'XitKhoang3.jpg', N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Xịt Khoáng Bioderma Hydrabio Brume 300ml', N'Cấp ẩm tức thời. Xịt khoáng làm dịu da. Bảo vệ da khỏi các tác nhân bên ngoài. Xịt khoáng giúp giữ lớp trang điểm bền hơn. Làm sạch da tạm thời.', 9, 320000, N'Nhật', 'XitKhoang4.png', N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Xịt Khoáng Avene 300ml ', N'Cấp ẩm tức thời. Xịt khoáng làm dịu da. Bảo vệ da khỏi các tác nhân bên ngoài. Xịt khoáng giúp giữ lớp trang điểm bền hơn. Làm sạch da tạm thời.', 10, 280000, N'Mỹ', 'XitKhoang5.jpg', N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddSP N'Nước Xịt Khoáng Dưỡng Da Bio-Essence Water 300ml', N'Cấp ẩm tức thời. Xịt khoáng làm dịu da. Bảo vệ da khỏi các tác nhân bên ngoài. Xịt khoáng giúp giữ lớp trang điểm bền hơn. Làm sạch da tạm thời.', 22, 290000, N'Hàn Quốc', 'XitKhoang6.jpg', N'Xịt khoáng', N'Chăm sóc da'
EXEC sp_AddSP N'Mặt Nạ Some By Mi Super Matcha Pore Clean Clay Từ Đất Sét Cải Thiện Vấn Đề Của Da 100g', N'Làm sạch da. Giữ ẩm. Cung cấp dưỡng chất và kết hợp điều trị một số vấn đề về da. Thư giãn', 5, 400000, N'Hàn Quốc', 'MN1.jpg', N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddSP N'Mặt Nạ Đất sét Amazon Red Clay', N'Làm sạch da. Giữ ẩm. Cung cấp dưỡng chất và kết hợp điều trị một số vấn đề về da. Thư giãn', 15, 300000, N'Hàn Quốc', 'MN2.png', N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddSP N'Mặt Nạ Đất Sét Rare Earth Deep Pore Cleansing Masque', N'Làm sạch da. Giữ ẩm. Cung cấp dưỡng chất và kết hợp điều trị một số vấn đề về da. Thư giãn', 25, 250000, N'Anh', 'MN3.jpg', N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddSP N'Mặt Nạ BNBG Vita Genic Whitening Jelly Mask Dưỡng Trắng 30ml', N'Làm sạch da. Giữ ẩm. Cung cấp dưỡng chất và kết hợp điều trị một số vấn đề về da. Thư giãn', 19, 290000, N'Hàn Quốc', 'MN4.jpg', N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddSP N'Mặt Nạ BNBG Vita Tea Tree Healing Face Mask Pack Thải Độc Da Giảm Mụn 30ml', N'Làm sạch da. Giữ ẩm. Cung cấp dưỡng chất và kết hợp điều trị một số vấn đề về da. Thư giãn', 20, 190000, N'Hàn Quốc', 'MN5.jpg', N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddSP N'Mặt Nạ Làm Dịu, Ngừa Mụn Skin1004 Madagascar Centella Watergel Sheet Ampoule Mask 25ml', N'Làm sạch da. Giữ ẩm.Cung cấp dưỡng chất và kết hợp điều trị một số vấn đề về da. Thư giãn', 22, 330000, N'Hàn Quốc', 'MN6.jpg', N'Mặt nạ', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Chống Nắng La Roche-Posay Anthelios Shaka Fluid Không Nhờn Rít SPF50+ (UVB + UVA) 50ml', N'Ngăn ngừa bức xạ UV. Tránh lão hóa sớm. Làm giảm nguy cơ cháy nắng. Ngừa các vết sạm da', 10, 190000, N'Pháp', 'KCN1.jpg', N'Chống nắng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Chống nắng Skin1004 Madagascar Centella Air-Fit SunCream SPF50+ PA++++', N'Ngăn ngừa bức xạ UV. Tránh lão hóa sớm. Làm giảm nguy cơ cháy nắng. Ngừa các vết sạm da', 12, 230000, N'Hàn Quốc', 'KCN2.jpg', N'Chống nắng', N'Chăm sóc da'
EXEC sp_AddSP N'Sữa Chống Nắng Dưỡng Da Anessa Perfect UV SPF50+/PA++++ 60ml', N'Ngăn ngừa bức xạ UV. Tránh lão hóa sớm. Làm giảm nguy cơ cháy nắng. Ngừa các vết sạm da', 22, 200000, N'Nhật ', 'KCN3.jpg', N'Chống nắng', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất Chống Nắng Anessa Dành Cho Da Nhạy Cảm & Trẻ Em UV SPF35/PA+++ 60ml', N'Ngăn ngừa bức xạ UV. Tránh lão hóa sớm. Làm giảm nguy cơ cháy nắng. Ngừa các vết sạm da', 6, 100000, N'Nhật ', 'KCN4.jpg', N'Chống nắng', N'Chăm sóc da'
EXEC sp_AddSP N'Tinh Chất chống nắng Skin Aqua-Tone Up UV 50g', N'Ngăn ngừa bức xạ UV. Tránh lão hóa sớm. Làm giảm nguy cơ cháy nắng. Ngừa các vết sạm da', 10, 250000, N'Nhật', 'KCN5.jpg', N'Chống nắng', N'Chăm sóc da'
EXEC sp_AddSP N'Kem Chống Nắng L''Oreal Paris Skincare UV Perfect Aqua Essence Dưỡng Ẩm 30ml', N'Ngăn ngừa bức xạ UV. Tránh lão hóa sớm. Làm giảm nguy cơ cháy nắng. Ngừa các vết sạm da', 8, 250000, N'Indonesia', 'KCN6.jpg', N'Chống nắng', N'Chăm sóc da'

-- chăm sóc tóc
EXEC sp_AddSP N'Xit Dưỡng Tóc Tsubaki Premium Repair Hair Water', N'Giúp cung cấp độ ẩm làm mềm mượt tự nhiên.Dưỡng tóc với những hạt nano giúp mái tóc mềm mịn.Giữ độ ẩm và giúp cho mái tóc luôn sáng bóng, óng ả.', 20, 100000, N'Anh', 'DTToc1.jpg', N'Đặc trị tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Xịt Dưỡng Tóc Hairburst Volume and Growth Elixir', N'Cải thiện độ chắc khỏe và chất lượng của từng sợi tóc.Chứa chiết xuất đậu hữu cơ giúp làm giảm rụng tóc, cải thiện mật độ của tóc và kéo dài vòng đời của tóc.Hỗ trợ bảo vệ tóc trước tác động của nhiệt độ cao, tia cực tím và ô nhiễm môi trường.', 20, 100000, N'Anh', 'DTToc2.jpg', N'Đặc trị tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'hai Nước Dưỡng Tóc Cocoon Tinh Dầu Bưởi Pomelo Hair Tonic',N'Giảm gãy rụng và phục hồi hư tổn.Tăng cường độ bóng và chắc khỏe của tóc.Cung cấp dưỡng chất giúp tóc suôn mượt và mềm mại.',20,110000,N'Anh','DTToc3.jpg',N'Đặc trị tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Dưỡng Tóc L''Oreal Tinh Dầu Hoa Tự Nhiên 100mlElseve Extraodinary Oil', N'Chiết xuất từ 6 loại hoa thiên nhiên giúp nuôi dưỡng mái tóc mềm mại, suôn mượt.Thành phần dưỡng ẩm giúp phục hồi tóc khô xơ, hư tổn.Nuôi dưỡng tóc chắc khỏe, bồng bềnh, giảm thiểu tình trạng rụng tóc.', 20, 120000, N'Đức', 'DTToc4.jpg', N'Đặc trị tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Tinh dầu dưỡng tóc Argan Oil of Morocco Healing Dry Oil', N'Không gây bết dính giống như dầu dừa, nên khi thoa lên tóc sẽ không gây nhờn rít mà lại thẩm thấu cực nhanh vào tóc giúp phục hồi từ sâu bên trong, làm cho tóc được phục hồi và trẻ lại hết xơ rối và vô cùng óng ả.', 20, 180000, N'Anh', 'DTToc5.jpg', N'Đặc trị tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Dưỡng Tóc Mise En Scène Perfect Serum Rose', N'Ngăn chặn tác động của bụi mịn bằng cách tạo thành một lớp bảo vệ tóc phủ lên bề mặt để bụi mịn không bị hấp thụ vào giữa các lớp biểu bì đang mở của các sợi tóc hư tổn.', 20, 190000, N'Anh', 'DTToc6.jpg', N'Đặc trị tóc', N'Chăm sóc tóc'

EXEC sp_AddSP N'Dầu Gội Đầu OGX Biotin Collagen', N'Giảm tóc hư tổn và khô xơ do sử dụng hóa chất', 50, 200000, N'Nhật Bản', 'DG1.jpg', N'Dầu gội', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Gội TRESemmé Keratin Smooth', N'Giúp phục hồi hư tổn bề mặt tóc tức thời và nuôi dưỡng sâu giúp tái cấu trúc sợi tóc từ bên trong, cho mái tóc bạn chắc khỏe dài lâu.Sau mỗi lần gội, tóc bạn được phục hồi hư tổn, đẹp và chắc khỏe.',50,220000,N'Mỹ','DG2.jpg',N'Dầu gội', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Gội Tsubaki',N'Chiết xuất tinh dầu hoa trà Nhật giúp làm giảm tình trạng tóc bết dính để mái tóc trông bồng bềnh hơn.Hương thơm bưởi tươi và bạc hà tươi mát, giúp mang lại cảm giác thoải mái, thư giãn.', 60, 230000, N'Nhật Bản', 'DG3.jpg', N'Dầu gội', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Gội Love Beauty And Planet', N'Giảm tóc hư tổn và khô xơ giúp tóc bồng bếnh', 50, 290000, N'Mỹ', 'DG4.jpg', N'Dầu gội', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Gội MISE EN SCENE PERFECT SERUM', N'Hoạt chất Bio-Serum từ thiên nhiên như hướng dương, trà xanh giúp ngăn gãy rụng từ gốc, cho tóc chắc khỏe gấp 5 lần.', 50, 250000, N'Việt Nam', 'DG5.png', N'Dầu gội', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Gội Dove', N'Phục hồi tóc hư tổn, hỗ trợ ngăn ngừa gàu, giảm thiểu tình trạng rụng tóc.', 50, 300000, N'Nhật Bản', 'DG6.jpg', N'Dầu gội', N'Chăm sóc tóc'

EXEC sp_AddSP N'Dầu Xả OGX Keratin Vào Nếp Suôn Mượt', N'Protein Keratin đóng vai trò như lớp sừng bảo vệ tóc khỏi các tác nhân tổn thương và đảm bảo độ hoàn thiện cho cấu trúc tóc, mang lại những lọn tóc quyến rũ, gợn sóng, đầy sức sống.', 30, 200000, N'Việt Nam','DX1.jpg', N'Dầu xả', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Xả OGX Argan Oil Giúp Phục Hồi Tóc Hư Tổn', N'Công thức chứa dầu Argan từ vùng Moroc giàu dưỡng chất như các chất chống oxy hóa, vitamin và khoáng chất quý giá giúp hỗ trợ phục hồi hư tổn cho mái tóc.', 30, 100000, N'Nhật Bản', 'DX2.jpg', N'Dầu xả', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Xả OGX Biotin & Collagen Làm Dày Tóc', N'Kết hợp giữa Biotin và Collagen giúp nhân đôi khả năng cải thiện những khuyết điểm về tóc, đảm bảo phát triển khỏe mạnh, bảo vệ tóc khỏi những tác động có hại từ bên ngoài.', 30, 200000, N'Việt Nam', 'DX3.jpg', N'Dầu xả', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Xả Love Beauty And Planet Phục Hồi Hư Tổn', N'Murumuru là người chị em của dầu dừa. Bơ murumuru được trích từ chất béo trắng có trong hạt cọ murumuru ở vùng Amazon. Chất béo này nổi tiếng với khả năng dưỡng ẩm sâu.', 30, 400000, N'Hàn Quốc', 'DX4.jpg', N'Dầu xả', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Xả Dove Giúp Tóc Bóng Mượt Chiết Xuất Hoa Sen Và Dầu', N'Nuôi dưỡng tóc từ gốc đến ngọn.Phục hồi cấu trúc sợi tóc.Hương hoa xanh và hương trái cây hòa quyện mang lại cảm giác thanh mát tươi mới', 20, 500000, N'Việt Nam', 'DX5.jpg', N'Dầu xả', N'Chăm sóc tóc'
EXEC sp_AddSP N'Dầu Xả TRESemmé Gừng & Trà Xanh Detox Tóc Chắc Khỏe', N'Công thức chứa thành phần thiên nhiên gồm Gừng và Trà Xanh, giúp Detox* và nuôi dưỡng tóc, giúp khôi phục lại mái tóc chắc khỏe đẹp chuẩn Sàn diễn.', 30, 200000, N'Nhật Bản', 'DX6.jpg', N'Dầu xả', N'Chăm sóc tóc'

EXEC sp_AddSP N'Kem Ủ TRESemmé Vào Nếp Mềm Mượt Tóc', N'Phục hồi Protein nuôi dưỡng tóc mềm mượt, khỏe mạnh.', 50, 200000, N'Mỹ', 'KemU1.jpg', N'Kem ủ tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Kem Ủ Tóc Cao Cấp TSUBAKI Phục Hồi Hư Tổn', N'Kết hợp các thành phần làm đẹp giàu dưỡng chất như tinh dầu hoa trà, protein ngọc trai, khoáng chất mật ong, Amino Acid, Glycerin… dưới dạng kích thước nhỏ, có khả năng thẩm thấu trực tiếp vào tóc để nuôi dưỡng và phục hồi lại mái tóc bóng mượt, khỏe mạnh.', 50, 210000, N'Mỹ', 'KemU2.jpg', N'Kem ủ tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Kem Ủ L''Oréal Paris Ngăn Rụng Tóc', N'Bổ sung Arginine cùng axit amin giúp cải thiện, phục hồi và nuôi dưỡng mái tóc gãy rụng. Chắc chắn sẽ mang đến cho bạn mái tóc chắc khỏe, suôn mượt tràn đầy sức sống.', 50, 200000, N'Mỹ', 'KemU3.jpg', N'Kem ủ tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Kem Ủ Tóc Ogx Renewing Argan Oil Of Morocco', N'Chiết xuất tinh dầu Argan có tác dụng dưỡng ẩm, làm suôn mượt và làm mềm mái tóc khô rối, dễ gãy, tăng cường tính năng chăm sóc nhằm mang lại cho bạn một mái tóc óng ả và dễ vào nếp.', 50, 200000, N'Mỹ', 'KemU4.png', N'Kem ủ tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Kem ủ tóc Tigi Bed Head Treatment Đỏ', N'Phục hồi Protein nuôi dưỡng tóc mềm mượt, khỏe mạnh.', 50, 260000, N'Mỹ', 'KemU5.jpg', N'Kem ủ tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Kem Ủ L''Oréal Paris Hỗ Trợ Phục Hồi Tóc Hư Tổn ', N'Giúp nuôi dưỡng tóc, đầy lùi 5 dấu hiệu hư tổn: Khô xơ, chẻ ngọn, gãy rụng, xỉn màu, thô cứng.', 50, 270000, N'Mỹ', 'KemU6.jpg', N'Kem ủ tóc', N'Chăm sóc tóc'

EXEC sp_AddSP N'Thuốc Nhuộm Tóc Hello Bubble Màu 6A Dusty Ash', N'Bảo vệ màu nhuộm lâu phai nhờ hợp chất Taurine & Theanine.', 20, 200000, N'Hàn Quốc', 'TNT1.jpg', N'Nhuộm tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Thuốc Nhuộm Tóc Hello Bubble Rose Gold 11RG', N'Công thức độc đáo dạng tạo bọt chuyên biệt giúp bạn dễ dàng nhuộm tóc tại nhà, cho mái tóc nhuộm đều màu tuyệt đẹp.', 10, 200000, N'Hàn Quốc', 'TNT2.jpg', N'Nhuộm tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Thuốc Nhuộm Tóc Ezn Shaking Pudding Ash Lavender', N'Thuốc nhuộm dạng dịch lỏng nên rất dễ thẩm thấu tới tận chân tóc, đảm bảo cho mái tóc đẹp, đều màu.', 30, 400000, N'Hàn Quốc', 'TNT3.jpg', N'Nhuộm tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Thuốc Nhuộm Tóc Ezn Shaking Pudding Ash Blue Gray', N'Công nghệ độc quyền bảo vệ nuôi dưỡng tóc 360 độ với gói cân bằng độ pH đưa tóc về trạng thái chuẩn sau khi nhuộm nhằm tránh hư tổn, kết hợp với gói serum sau nhuộm cung cấp dưỡng chất mang lại mái tóc suôn mềm óng ả.', 30, 200000, N'Nhật Bản', 'TNT4.jpg', N'Nhuộm tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Thuốc Nhuộm Tóc Beautylabo Vanity Color Màu Nâu Tây Lạnh', N'Bảng màu nhuộm thời trang cá tính, theo xu hướng.Hiệu qủa vượt trội từ công thức nhuộm cải tiến.', 40, 130000, N'Hàn Quốc', 'TNT5.jpg', N'Nhuộm tóc', N'Chăm sóc tóc'
EXEC sp_AddSP N'Thuốc Nhuộm Tóc Tạo Bọt Beautylabo Nâu Chocolate', N'Không lưu lai thuốc thừa sau khi nhuộm.Thành phần an toàn da đầu, không gây kích ứng da.', 30, 100000, N'Mỹ', 'TNT6.jpg', N'Nhuộm tóc', N'Chăm sóc tóc'


--chăm sóc cơ thể
EXEC sp_AddSP N'Sữa tắm Bath & Body Works RESTFUL MOON', N'Phòng chống viêm lỗ chân lông. Việc mồ hôi, bụi bẩn không được làm sạch kỹ, lưu lại trên da lâu ngày sẽ dẫn đến tình trạng viêm lỗ chân lông', 15, 500000, N'Mỹ', 'ST1.jpg', N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Sữa tắm Bath & Body Works AWAKENING SUN', N'Phòng chống viêm lỗ chân lông. Việc mồ hôi, bụi bẩn không được làm sạch kỹ, lưu lại trên da lâu ngày sẽ dẫn đến tình trạng viêm lỗ chân lông', 25, 600000, N'Mỹ', 'ST2.jpg', N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Sữa tắm Bath & Body Works ELDERFLOWER', N'Phòng chống viêm lỗ chân lông. Việc mồ hôi, bụi bẩn không được làm sạch kỹ, lưu lại trên da lâu ngày sẽ dẫn đến tình trạng viêm lỗ chân lông', 35, 400000, N'Mỹ', 'ST3.jpg', N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Sữa tắm Bath & Body Works SAGE MINT', N'Phòng chống viêm lỗ chân lông. Việc mồ hôi, bụi bẩn không được làm sạch kỹ, lưu lại trên da lâu ngày sẽ dẫn đến tình trạng viêm lỗ chân lông', 10, 300000, N'Mỹ', 'ST4.jpg', N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Sữa tắm Bath & Body Works HONEY WILDFLOWER', N'Phòng chống viêm lỗ chân lông. Việc mồ hôi, bụi bẩn không được làm sạch kỹ, lưu lại trên da lâu ngày sẽ dẫn đến tình trạng viêm lỗ chân lông', 22, 200000, N'Mỹ', 'ST5.jpg', N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Sữa tắm Bath & Body Works SWEET WHISKEY', N'Phòng chống viêm lỗ chân lông. Việc mồ hôi, bụi bẩn không được làm sạch kỹ, lưu lại trên da lâu ngày sẽ dẫn đến tình trạng viêm lỗ chân lông', 9, 290000, N'Mỹ', 'ST6.jpg', N'Sữa tắm', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Tẩy Tế Bào Chết Dak Lak Coffee Body Polish Từ Cà Phê Đak Lak 200ml ', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da. Giúp cải thiện kết cấu da.', 10, 200000, N'Canada', 'TTBC1.jpg', N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Tẩy Tế Bào Chết St.Ives Fresh Skin Body Scrub', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da. Giúp cải thiện kết cấu da.', 15, 300000, N'Pháp', 'TTBC2.jpg', N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Tẩy Tế Bào Chết Tree Hut Almond & Honey 510g', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da. Giúp cải thiện kết cấu da.', 27, 400000, N'Anh', 'TTBC3.jpg', N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Tẩy Tế Bào Chết Tree Hut Coconut Lime 510g', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da. Giúp cải thiện kết cấu da.', 8, 500000, N'Mỹ', 'TTBC4.jpg', N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Tẩy Tế Bào Chết Tree Hut Moroccan Rose 510g', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da. Giúp cải thiện kết cấu da.', 11, 490000, N'Nhật', 'TTBC5.jpg', N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Tẩy Tế Bào Chết TreeHut Tropical Mango 510g', N'Làm thông thoáng lỗ chân lông. Ngăn ngừa khuyết điểm trên da. Tẩy da chết làm đều màu da. Giúp cải thiện kết cấu da.', 22, 340000, N'Mỹ', 'TTBC6.jpg', N'Tẩy tế bào chết', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Body Lotion Bath & Body Works WHITE PUMPKIN & CHAI', N'Giúp làm sáng da, chống lõa hóa da, dưỡng ẩm tốt, giúp cho da mềm mại', 22, 1000000, N'Mỹ', 'DT1.jpg', N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Body Lotion Bath & Body Works RUBY APPLE & ROSEWOOD ', N'Giúp làm sáng da, chống lõa hóa da, dưỡng ẩm tốt, giúp cho da mềm mại', 16, 1000000, N'Mỹ', 'DT2.jpg', N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Body Lotion Bath & Body Works MAGNOLIA CHARM', N'Giúp làm sáng da, chống lõa hóa da, dưỡng ẩm tốt, giúp cho da mềm mại', 12, 1000000, N'Mỹ', 'DT3.jpg', N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Body Lotion Bath & Body Works RASPBERRY CHIFFON', N'Giúp làm sáng da, chống lõa hóa da, dưỡng ẩm tốt, giúp cho da mềm mại', 8, 1000000, N'Mỹ', 'DT4.jpg', N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Body Lotion Bath & Body Works PUMPKIN PECAN WAFFLES', N'Giúp làm sáng da, chống lõa hóa da, dưỡng ẩm tốt, giúp cho da mềm mại', 20, 1000000, N'Mỹ Quốc', 'DT5.jpg', N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Body Lotion Bath & Body Works CRISP MORNING AIR', N'Giúp làm sáng da, chống lõa hóa da, dưỡng ẩm tốt, giúp cho da mềm mại', 9, 1000000, N'Mỹ', 'DT6.jpg', N'Lotion', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Kem Dưỡng Tay Frudia Re:proust Essential Blending Earthy Từ Dầu Đàn Hương & Dầu Hoa Cúc 50g', N'Chăm sóc da tay mọi lúc mọi nơi. Kem dưỡng da tay không chỉ dưỡng ẩm cho da tay mà còn mang lại cảm giác thoải mái cho làn da.', 25, 500000, N'Hàn Quốc', 'KDT1.jpg', N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Kem Dưỡng Tay Frudia Re:proust Essential Blending Greenery Từ Dầu Cam & Dầu Phong Lữ 50g', N'Chăm sóc da tay mọi lúc mọi nơi. Kem dưỡng da tay không chỉ dưỡng ẩm cho da tay mà còn mang lại cảm giác thoải mái cho làn da.', 16, 600000, N'Hàn Quốc', 'KDT2.jpg', N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Kem Dưỡng Tay Frudia Re:proust Essential Blending Dazzling Từ Dầu Quýt & Dầu Hương Thảo 50g', N'Chăm sóc da tay mọi lúc mọi nơi. Kem dưỡng da tay không chỉ dưỡng ẩm cho da tay mà còn mang lại cảm giác thoải mái cho làn da.', 29, 700000, N'Hàn Quốc', 'KDT3.jpg', N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Kem Dưỡng Tay Dermaclassen French Honey Hand Balm 75ml', N'Chăm sóc da tay mọi lúc mọi nơi. Kem dưỡng da tay không chỉ dưỡng ẩm cho da tay mà còn mang lại cảm giác thoải mái cho làn da.', 11, 680000, N'Dermaclassen', 'KDT4.jpg', N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Kem Dưỡng Tay Dermaclassen Shea Butter Hand Balm 75ml', N'Chăm sóc da tay mọi lúc mọi nơi. Kem dưỡng da tay không chỉ dưỡng ẩm cho da tay mà còn mang lại cảm giác thoải mái cho làn da.', 9, 350000, N'Dermaclassen', 'KDT5.jpg', N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Kem Dưỡng Tay Dermaclassen Aromatic Hand Balm 75ml', N'Chăm sóc da tay mọi lúc mọi nơi. Kem dưỡng da tay không chỉ dưỡng ẩm cho da tay mà còn mang lại cảm giác thoải mái cho làn da.', 17, 420000, N'Hàn Quốc', 'KDT6.jpg', N'Kem dưỡng da tay', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Lăn Khử Mùi Mờ Thâm, Dưỡng Trắng Da Angel''s Liquid Glutathione+ Niacinamide Fresh Deodorant 60ml', N'Giảm tiết mồ hôi vùng mũi. Giảm tiết mồ hôi và ngăn mùi hôi chân. Ngăn mồ hôi dưới ngực. Làm khô tay.', 20, 200000, N'Anh', 'KM1.jpg', N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Lăn Khử Mùi Perspirex Strong 20ml', N'Giảm tiết mồ hôi vùng mũi. Giảm tiết mồ hôi và ngăn mùi hôi chân. Ngăn mồ hôi dưới ngực. Làm khô tay.', 24, 300000, N'Pháp', 'KM2.jpg', N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Lăn Khử Mùi Perspirex Original 20ml', N'Giảm tiết mồ hôi vùng mũi. Giảm tiết mồ hôi và ngăn mùi hôi chân. Ngăn mồ hôi dưới ngực. Làm khô tay.', 9, 290000, N'Mỹ', 'KM3.jpg', N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Lăn khử mùi Scion 75ml', N'Giảm tiết mồ hôi vùng mũi. Giảm tiết mồ hôi và ngăn mùi hôi chân. Ngăn mồ hôi dưới ngực. Làm khô tay.', 27, 390000, N'Hàn Quốc', 'KM4.jpg', N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Xịt Khử Mùi Dove Silk Dry', N'Giảm tiết mồ hôi vùng mũi. Giảm tiết mồ hôi và ngăn mùi hôi chân. Ngăn mồ hôi dưới ngực. Làm khô tay.', 10, 260000, N'Đức', 'KM5.jpg', N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Xịt Khử Mùi Dành Cho Da Nhạy Cảm Dove', N'Giảm tiết mồ hôi vùng mũi. Giảm tiết mồ hôi và ngăn mùi hôi chân. Ngăn mồ hôi dưới ngực. Làm khô tay.', 12, 290000, N'Nhật', 'KM6.jpg', N'Sản phẩm khử mùi', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Nước Hoa My Burberry Blush', N'Mùi thơm. Cải thiện tâm trạng. Tăng niềm tin. Làm cho bạn hấp dẫn', 10, 1000000, N'Mỹ', 'NH1.jpg', N'Nước hoa', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Nước Hoa My Burberry EDP', N'Mùi thơm. Cải thiện tâm trạng. Tăng niềm tin. Làm cho bạn hấp dẫn', 22, 2000000, N'Anh', 'NH2.jpg', N'Nước hoa', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Nước Hoa Dior Miss Dior', N'Mùi thơm. Cải thiện tâm trạng. Tăng niềm tin. Làm cho bạn hấp dẫn', 9, 1500000, N'Canada', 'NH3.jpg', N'Nước hoa', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Nước Hoa Marc Jacobs Daisy Love', N'Mùi thơm. Cải thiện tâm trạng. Tăng niềm tin. Làm cho bạn hấp dẫn', 23, 3000000, N'Hàn Quốc', 'NH4.png', N'Nước hoa', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Nước Hoa Marc Jacobs Daisy Eau So Fresh', N'Mùi thơm. Cải thiện tâm trạng. Tăng niềm tin. Làm cho bạn hấp dẫn', 19, 1800000, N'Pháp', 'NH5.jpg', N'Nước hoa', N'Chăm sóc cơ thể'
EXEC sp_AddSP N'Nước Hoa Chloe’ For Women EDP', N'Mùi thơm. Cải thiện tâm trạng. Tăng niềm tin. Làm cho bạn hấp dẫn', 20, 2000000, N'Mỹ', 'NH6.jpg', N'Nước hoa', N'Chăm sóc cơ thể'

-- trang điểm
EXEC sp_AddSP N'Kem Che Khuyết Điểm Merzy The First Creamy Concealer', N'Che phủ hiệu quả quầng thâm và các khuyết điểm như mụn, thâm, sạm. Che phủ khuyết điểm và màu da tức thì, mang đến làn ra sáng mịn, rạng ngời', 20, 200000, N'Hàn Quốc', 'CKD1.jpg', N'Che khuyết điểm', N'Trang điểm'
EXEC sp_AddSP N'Kem Che Khuyết Điểm Clio Kill Cover Liquid Concealer', N'Chất kem mỏng, có độ sệt và bám trên da để tán ra dễ dàng hơn. Phù hợp với da thường, da hỗn hợp, da có dầu. Bám trên da và giữ màu rất lâu, không thấm nước, không trôi.', 20, 700000, N'Mỹ', 'CKD2.jpg', N'Che khuyết điểm', N'Trang điểm'
EXEC sp_AddSP N'Kem Che Khuyết Điểm Mịn Lì Fit Me Maybelline ', N'Không dầy cộm, không gây hằn, Maybelline Fit me Concealer trên da nhẹ tênh. Đôi mắt cũng sáng lên khi quầng thâm và những nếp nhăn đã được kem che khuyết điểm Maybelline Fit me Concealer che đậy.', 20, 100000, N'Mỹ', 'CKD3.jpg', N'Che khuyết điểm', N'Trang điểm'
EXEC sp_AddSP N'Kem Che Khuyết Điểm Banila Co Covericious Power Fit Foundation', N'Nó cũng giảm thiểu các nếp nhăn, quầng thâm, dấu hiệu mệt mỏi những vùng quanh mắt cho làn da luôn tươi mới cả ngày.', 20, 220000, N'Mỹ', 'CKD4.jpg', N'Che khuyết điểm', N'Trang điểm'
EXEC sp_AddSP N'Kem Che Khuyết Điểm L''Oreal True Match 1R/1C Rose Ivory',N'Giàu chất Caffeine làm sáng da, chống xỉn màu, che mờ quầng thâm.', 20, 200000, N'Mỹ', 'CKD5.jpg', N'Che khuyết điểm', N'Trang điểm'
EXEC sp_AddSP N'Kem che khuyết điểm Stay Naked Correcting Concealer', N'Che khuyết điểm có màu như ý nhất, ngoài ra còn che được một phần những khuyết điểm như đốm nâu, quầng thâm mắt, khoé miệng.', 20, 230000, N'Mỹ', 'CKD6.jpg', N'Che khuyết điểm', N'Trang điểm'

EXEC sp_AddSP N'Chì Kẻ Mày Ngang Sắc Nét, Lâu Trôi Merzy The First Brow Pencil B3', N'Kết cấu chì kẻ mềm mịn, dễ vẽ không gây kích ứng da vừa tô đậm màu sắc chân mày, kích thích và tạo hiệu ứng chân mày dày và đều đặn hơn với bột chân mày có độ bám cao, màu sắc tự nhiên trendy dễ dàng hợp với màu tóc.', 20, 200000, N'Hàn Quốc', 'EB1.jpg', N'Kẻ chân mày', N'Trang điểm'
EXEC sp_AddSP N'Chì Kẻ Mày Ngang Sắc Nét, Lâu Trôi Merzy The First Brow Pencil B4', N'Bảng màu trendy, thích hợp cho nhiều tone màu tóc và màu da. Đặc biệt là sắc nâu, tone màu lạnh là xu hướng màu chân mày mix với màu tóc được ưa chuộng của người Châu Á.', 20, 300000, N'Hàn Quốc', 'EB2.jpg', N'Kẻ chân mày', N'Trang điểm'
EXEC sp_AddSP N'Chì kẻ chân mày Anastasia Beverly Hills Brow Wiz Skinny Brow Pencil', N'Đường kính của đầu chì chỉ khoảng 1mm tương đương với các loại kẻ mắt eyeliner. Điều này rất thích hợp cho việc tạo dáng các sợi lông mày tự nhiên, chính xác hơn.', 20, 310000, N'Hàn Quốc', 'EB3.jpg', N'Kẻ chân mày', N'Trang điểm'
EXEC sp_AddSP N'Chì Kẻ Mày Ngang 2 Đầu The Saem Saemmul Artlook Eyebrow', N'Thiết kế kết hợp 1 đầu chì và một đầu chải mascara, bạn có thể linh hoạt vẽ lông mày một cách xinh đẹp và tự nhiên hơn.', 20, 300000, N'Hàn Quốc', 'EB4.jpg', N'Kẻ chân mày', N'Trang điểm'
EXEC sp_AddSP N'Chì Kẻ Chân Mày COLOURPOP BROW BOSS PENCIL', N'Độ waxy và creamy vừa đủ, đầu chì nhỏ dễ phẩy nét, vặn lên vặn xuống vô tư không sợ phí sản phẩm', 20, 310000, N'Hàn Quốc', 'EB5.jpg', N'Kẻ chân mày', N'Trang điểm'
EXEC sp_AddSP N'Chì Kẻ Chân Mày DARK BROW BOSS PENCIL', N'Dành cho tóc màu chocolate lẫn dark brown, nâu đậm, màu gần như tưong đương với darkbrown của abh', 20, 300000, N'Hàn Quốc', 'EB6.jpg', N'Kẻ chân mày', N'Trang điểm'

EXEC sp_AddSP N'Kẻ Mắt Nước Chống Trôi Hiệu Quả Cho Đôi Mắt Sắc Nét Merzy The Heritage Pen Eyeliner', N'Eyeliner đậm nét, giúp bạn tạo ra một đường kẻ sắc sảo, đen tuyền chỉ với một đường kẻ tinh tế với đầu cọ microfiber chỉ 0.12mm cho đường liner sắc nét dễ vẽ ', 20, 300000, N'Mỹ', 'KMat1.jpg', N'Kẻ mắt', N'Trang điểm'
EXEC sp_AddSP N'Kẻ Mắt Nước Missha Ultra Powerproof Liquid Eyeliner', N'Nhờ đầu cọ cực kỳ sắc nét linh hoạt, bạn có thể sáng tạo thêm những họa tiết để mắt trông thật nổi bật và thể hiện cá tính của riêng mình.', 20, 330000, N'Mỹ', 'KMat2.jpg', N'Kẻ mắt', N'Trang điểm'
EXEC sp_AddSP N'Kẻ Mắt Kat Von D Tattoo Liner', N'Thiết kế đầu cọ mảnh, mềm dẻo, thông minh, không quá cứng nhưng cũng không quá mềm nên rất dễ kẻ', 20, 360000, N'Mỹ', 'KMat3.jpg', N'Kẻ mắt', N'Trang điểm'
EXEC sp_AddSP N'Kẻ mắt OFÉLIA', N'Tạo nên những đường kẻ mềm mại và chuẩn xác trong tích tắc. Khả năng chống nước cao và độ bền màu lên đến 12 giờ sẽ thích hợp dùng cho kẻ mí trên và cả mí dưới.', 20, 370000, N'Đức', 'KMat4.jpg', N'Kẻ mắt', N'Trang điểm'
EXEC sp_AddSP N'Kẻ Mắt Kiss Me Heroine Make Smooth Liquid Eyeliner', N'Thiết kế đầu siêu mảnh chỉ 0,1mm rất dễ dàng để các cô gái “biến hóa” cho đôi mắt thành những đường nét thanh mảnh, tự nhiên hay sắc nét, gợi cảm.', 20, 380000, N'Anh', 'KMat5.jpg', N'Kẻ mắt', N'Trang điểm'
EXEC sp_AddSP N'Kẻ Mắt Nước Kiss Me Heroine Make', N'Chì kẻ mắt không lem Isehan Kiss Me tuy bền màu và không dễ bị trôi nhưng vẫn rất dễ dàng tẩy trang. Không hổ danh là dòng kẻ mắt cao cấp vừa giúp chị em ăn gian độ to tròn của mắt, đôi lông mày cực chuẩn và hơn hết là luôn dưỡng ẩm bảo vệ lông mi.', 20, 390000, N'Mỹ', 'KMat6.jpg', N'Kẻ mắt', N'Trang điểm'


EXEC sp_AddSP N'Kem Lót Wet N Wild CoverAll Face Primer', N'Che phủ lỗ chân lông một cách tối ưu, giảm thiểu tối đa sẹo lõm do mụn để lại.', 20, 300000, N'Anh', 'KL1.jpg', N'Kem lót', N'Trang điểm'
EXEC sp_AddSP N'Kem Lót Maybelline New York Baby Skin Pore Eraser Primer', N'Giúp làm mịn da, che khuyết điểm, tạo hiệu ứng lỗ chân lông thu nhỏ, cho lớp nền mịn màng hoàn hảo. Cấu trúc gel trong suốt, mịn nhẹ dễ tán, hiệu quả trong việc che lỗ chân lông ngay tức thì.', 20, 320000, N'Anh', 'KL2.jpg', N'Kem lót', N'Trang điểm'
EXEC sp_AddSP N'Kem Lót ColourPop Pretty Fresh Tinted Moisturizer', N'Mang trong mình nhiều dưỡng chất từ axit hyaluronic nên cảm giác bóng mướt tuyệt vời khi apply, glow finish nên bạn nào da ít khuyết điểm mà thích một dạng kem không gây bí da.', 20, 300000, N'Mỹ', 'KL3.jpg', N'Kem lót', N'Trang điểm'
EXEC sp_AddSP N'Kem Lót Banila Co Prime Primer Classic', N'Kem lót trang điểm giúp che phủ lỗ chân lông, nếp nhăn và duy trì lớp trang điểm bền màu.', 20, 300000, N'Ý', 'KL4.jpg', N'Kem lót', N'Trang điểm'
EXEC sp_AddSP N'Kem Lót eSpoir', N'Tinh chất làm sáng da của ngọc trai cùng khả năng trẻ hóa của serum trong primer sẽ giúp bạn khắc phục nhanh chóng tình trạng da mệt mỏi và lão hóa.', 20, 390000, N'Nhật Bản', 'KL5.jpg', N'Kem lót', N'Trang điểm'
EXEC sp_AddSP N'Kem Lót Urban Decay All Nighter Face Primer Longwear Foundation Grip', N'Loại kem nền mỏng mịn, giúp bảo vệ làn da khỏi tác hại của các sản phẩm make up.', 20, 360000, N'Canada', 'KL6.jpg', N'Kem lót', N'Trang điểm'

EXEC sp_AddSP N'Cushion Rom&nd Zero Later Foundation', N'Kem nền được thiết kế trang trọng, chất phấn mỏng nhẹ, cải tiến, khả năng che phủ hoàn hảo tựa như không bôi gì, lớp phấn mỏng nhẹ dính tiệp vào da một cách tự nhiên nhất, khắc phục mọi khuyết điểm.', 20, 400000, N'Đức', 'Cushion1.jpg', N'Kem nền', N'Trang điểm'
EXEC sp_AddSP N'Cushion Merzy The First Cushion Glow', N'Thành phần dưỡng ẩm cho da: nước trà xanh, chiết xuất hoa anh thảo chiều, lá cây thùa, petanol, Hydrolyzed Collagen', 20, 410000, N'Anh', 'Cushion2.jpg', N'Kem nền', N'Trang điểm'
EXEC sp_AddSP N'Cushion April Skin Magic Snow Cushion', N'Lớp nền mịn màng, che phủ cực tốt các khuyết điểm lớn nhỏ trên da, mà còn cực kỳ lâu trôi và bền màu.', 20, 470000, N'Anh', 'Cushion3.jpg', N'Kem nền', N'Trang điểm'
EXEC sp_AddSP N'Kem Nền Romand Zero Layer Foundation', N'Thiết kế gọn nhẹ chắc chắn, dễ dàng cầm chắc tay. Thiết kế lọ kem nền trong suốt giúp bạn quan sát được màu sắc bên trong, phần nắp có thiết kế gam màu sáng đặc trưng của Romand cho cảm giác gần gũi, kem nền có vòi pum giúp ướt lượng được lượng sản phẩm lấy ra và dễ dàng tiết kiệm', 20, 400000, N'Đức', 'KN1.jpg', N'Kem nền', N'Trang điểm'
EXEC sp_AddSP N'Kem Nền Merzy The First Foundation SPF 20 PA++', N'Có khả năng che phủ các khuyết điểm trên da, giúp lớp nền bám lâu không lo bị trôi và xuống tông mang đến lớp nền hoàn hảo với làn da không tì vết', 20, 400000, N'Mỹ','KN2.jpg', N'Kem nền', N'Trang điểm'
EXEC sp_AddSP N'Kem Nền Maybelline Fit Me Matte + Poreless Màu', N'Kem lỏng nhẹ, dễ dàng tán đều lên da, che phủ hoàn toàn các khuyết điểm trên da. Bao gồm vết thâm nám, quầng thâm mắt và đặc biệt là lỗ chân lông to khiến da mịn màng, tươi tắn, đẹp không tì vết.', 20, 460000, N'Canada', 'KN3.jpg', N'Kem nền', N'Trang điểm'


EXEC sp_AddSP N'Bảng Phấn Mắt Merzy The Heritage Shadow Palette S1 Amusing Rose', N'Gam màu hài hòa, dễ dùng và đa năng, ngoài chức năng là phấn mắt còn có thể sử dụng thay thế cho phấn má hồng và tạo khối giúp tiết kiệm thời gian trang điểm cho gương mặt thêm xinh xắn ', 20, 410000, N'Hà Lan', 'PM1.png', N'Phấn mắt', N'Trang điểm'
EXEC sp_AddSP N'Bảng Phấn Mắt Merzy The Heritage Shadow Palette S2 Joyful Coral', N'Độ lên màu chuẩn rõ hạn chế Fall-Out. Lớp nhũ óng ánh với độ phản sáng cao và bám dính tốt cả ngày.', 20, 430000, N'Ý', 'PM2.png', N'Phấn mắt', N'Trang điểm'
EXEC sp_AddSP N'Bảng Phấn Mắt Rom&nd Better Than Eyes M02 DRY ROSE', N'Kết cấu hạt phấn siêu nhỏ và mịn sẽ giúp chỉnh đốn vùng mắt xung quanh mà không cần dùng đến phấn phủ bột hay kem lót mắt, giúp xóa đi mọi nếp nhăn quanh mắt dù là nhỏ nhất ', 20, 410000, N'Mỹ', 'PM3.jpg', N'Phấn mắt', N'Trang điểm'
EXEC sp_AddSP N'Bảng Phấn Mắt Rom&nd Better Than Eyes M03 DRY COSMOS', N'Không bị rơi phấn, không gây vón cục khó chịu, dù dùng cọ hay dùng tay đều dễ tán đều.Bền màu, dộ bám màu cao, giữ màu lâu trong thời gian dài ', 20, 400000, N'Tây Ban Nha', 'PM4.jpg', N'Phấn mắt', N'Trang điểm'
EXEC sp_AddSP N'Bảng Phấn Mắt BH Cosmetics Ultimate Neutrals Eyeshadow Palette ', N'Chất phấn bám lâu mềm và mịn. Hơn nữa còn rất tự nhiên khi bạn Blend đều bởi sắc màu nào cũng lên rất vừa phải và chuẩn màu.', 20, 400000, N'Anh', 'PM5.jpg', N'Phấn mắt', N'Trang điểm'
EXEC sp_AddSP N'Bảng Phấn Mắt BH Cosmetics BFF Shadow Palette', N'Đi cùng bảng mắt là một vỏ giấy bên ngoài và một miếng nhựa trong phủ lên về mặt các ô phấn, à các ô phấn trong palette này đều không có tên nhé', 20, 400000, N'Anh', 'PM6.jpg', N'Phấn mắt', N'Trang điểm'

EXEC sp_AddSP N'Phấn má hồng Wet n Wild Coloricon Ombre Blush', N'Màu má ombre có thể sử dụng để tạo hiệu ứng đậm nhạt lan toả trong make up chuyên nghiệp khi miết chổi theo 1 đường duy nhất thật đơn giản', 30, 200000, N'Mỹ', 'MH1.png', N'Má hồng', N'Trang điểm'
EXEC sp_AddSP N'Phấn má hồng Merzy The Heritage Blusher BL3 Burnt Sienna', N'Làm từ đá hổ phách với những gam màu trong trẻo dịu dành tôn lên nét đẹp vừa truyền thống vừa hiện đại, vừa nhẹ nhàng như có chất phấn mềm mịn', 20, 210000, N'Anh', 'MH2.jpg', N'Má hồng', N'Trang điểm'
EXEC sp_AddSP N'Phấn má hồng Merzy The Heritage Blusher BL2 Terra Cotta', N'Khả năng kiềm dầu và giữ mài lâu trôi, cùng bảng màu cam đất hài hoà tự nhiên giúp gương mặt bạn nên xinh xắn rạng rỡ cuốn hút.', 40, 200000, N'Đức', 'MH3.png', N'Má hồng', N'Trang điểm'
EXEC sp_AddSP N'Phấn má hồng I’m Afternoon Tae Blusher Palatte', N'Những tông màu nhẹ nhàng dễ dùng, lấu cảm hứng màu sắc và mùi hương từ các loại trà.', 30, 250000, N'Pháp', 'MH4.png', N'Má hồng', N'Trang điểm'
EXEC sp_AddSP N'Phấn má hồng Too Face Love Flush ', N'Độ bám rất cao, giữ màu rất lâu, màu sắc lên tự nhiên với công thức đã được kiểm chứng giúp đôi má của bạn ửng hồng lến đến 16 tiếng.', 20, 200000, N'Ý', 'MH5.jpg', N'Má hồng', N'Trang điểm'
EXEC sp_AddSP N'Phấn má hồng BH Cosmetics Essential Blush', N'Chất phấn siêu mềm mịn, những hạt phấn li ti không chỉ có độ bám tốt. lâu phai màu mà còn giúp các nàng dễ dàng blend màu thật tự nhiên nữa.', 20, 210000, N'Anh', 'MH6.jpg', N'Má hồng', N'Trang điểm'


EXEC sp_AddSP N'Mascara Merzy The First Mascara Volume Perm VM1', N'Giúp hàng mi cong và dày một cách hoàn hảo.', 30, 210000, N'Mỹ', 'M1.png', N'Mascara', N'Trang điểm'
EXEC sp_AddSP N'Mascara Missha Ultra Power Proof Mascara', N'Sở hữu nhờ khả năng chống nước vượt trội và công dụng làm cong mi suốt cả ngày dài.', 50, 180000, N'Nhật Bản', 'M2.jpg', N'Mascara', N'Trang điểm'
EXEC sp_AddSP N'Mascara Maybelline Volum’ Express Hyper', N'Công thức tối ưu kết hợp với đầu cọ được thiết kế dễ dàng chải tận gốc sợi mi, giúp mascara được bao phủ hiệu quả, cho bạn đôi mi dày ấn tượng, cong quyến rũ.', 20, 100000, N'Hàn Quốc', 'M3.jpg', N'Mascara', N'Trang điểm'
EXEC sp_AddSP N'Mascara Colourpop bff Volumizing Mascara', N'Khả năng làm cong mi và dày mi cùng thiết kế đầu chải giúp các sợi mi tơi làm cho cặp mi giống vừa mới nối.', 20, 190000, N'Canada', 'M4.jpg', N'Mascara', N'Trang điểm'
EXEC sp_AddSP N'Mascara Isehan Kiss Me Heroine Make Curl Super Waterproof', N'Làm mi dài miên man với sợi nối fiber thì Kiss me Heroine make sẽ làm cho mi bạn vừa dài vừa cong vút cả ngày mà không lo nặng mắt, lem trôi dù mưa hay.', 10, 100000, N'Anh', 'M5.jpg', N'Mascara', N'Trang điểm'
EXEC sp_AddSP N'Mascara Isehan Kiss Me Heroine Make Volume', N'Không gây vón cục, khi sử dụng rất tơi mi.Mascara màu đen cho bạn đôi mắt đen tuyền, trông to và sáng hơn.', 40, 100000, N'Đức', 'M6.jpg', N'Mascara', N'Trang điểm'


EXEC sp_AddSP N'Son Thỏi Colourpop Lux Lipstick', N'Chất son mịn mướt, son Lux Lipstick khi apply lên môi rất chuẩn màu và siêu lâu trôi', 20, 300000, N'Mỹ', 'SThoi1.jpg', N'Son thỏi', N'Trang điểm'
EXEC sp_AddSP N'Son Thỏi 3CE Soft Matte Giving Pleasure', N'Cực kỳ phù hợp với style trang điểm trong suốt, tự nhiên, mộc mạc nhưng cũng không kém phần sành điệu', 46, 310000, N'Anh', 'SThoi2.jpg', N'Son thỏi', N'Trang điểm'
EXEC sp_AddSP N'Son Thỏi Cao Cấp 3CE Stylenanda Matte Lip Color Brunch-Time', N'Được khoác lên mình lớp vỏ màu vàng hồng sáng loáng vô cùng sang chảnh. Chưa hết, trên thân thỏi son còn in tên cực kỳ nổi bật và xinh xắn.', 40, 300000, N'Anh', 'SThoi3.jpg', N'Son thỏi', N'Trang điểm'
EXEC sp_AddSP N'Son Thỏi Rom&nd Zero Matte Lipstick Midnight', N'Đơn giản nhưng mang cảm giác thanh lịch tinh tế, cùng bảng màu thân thiện dễ dùng, son có độ lên tốt, màu lên môi chuẩn và rõ ràng cùng chất son lì siêu mịn cho bạn sự hài lòng khi sử dùng dòng son này.', 80, 390000, N'Đức', 'SThoi4.png', N'Son thỏi', N'Trang điểm'
EXEC sp_AddSP N'Son Thỏi Maybelline New York', N'Chất son lì siêu mịn mượt như bơ lướt nhẹ trên môi, tạo hiệu ứng lì cực hoàn hảo chỉ với 1 lần lướt son với 10 tông màu  thời thượng. Sắc son thể hiện phong cách trẻ trung, cá tính và không gây khô môi.', 70, 370000, N'Anh', 'SThoi5.jpg', N'Son thỏi', N'Trang điểm'
EXEC sp_AddSP N'Son Thỏi Espoir Lipstick No Wear Chiffon Matte BR901 Groovy', N'Son để lâu cũng không hề có hiện tượng bong vẩy như những dòng son khác . Độ bền màu của son Espoir lên đến gần 8 tiếng cho các chị em thoài mái vui chơi.', 30, 380000, N'Hàn Quốc', 'SThoi6.png', N'Son thỏi', N'Trang điểm'

EXEC sp_AddSP N'Phấn Highlight Too Cool For School Enlumineur Art Class By Rodin Highlighter', N'Được bắt đầu từ ý tưởng của hình khối hội họa và sáng tạo những góc sáng tối độc đáo, Phấn tạo khối Art Class By Rodin của hãng Too Cool For School với 3 ô màu kì diệu tạo nên sự đa dạng và hài hòa tạo đường nét trên khuôn mặt.', 20, 300000, N'Anh', 'H1.jpg', N'Tạo khối', N'Trang điểm'
EXEC sp_AddSP N'Phấn Highlight Wet n Wild MegaGlo Highlighting Powder', N'Chất phấn mềm mịn, hạt phấn cực kỳ nhỏ dễ dàng tán đều trên da, che phủ được lỗ chân lông.', 20, 400000, N'Anh', 'H2.png', N'Tạo khối', N'Trang điểm'
EXEC sp_AddSP N'Phấn Highlight Canmake Shading Powder', N'Chất phấn không dày với tone màu trung tính tự nhiên, khá nhạt nên khi đánh sẽ rất tự nhiên. Sản phẩm không gây bí bức, hạn chế tình trạng đổ dầu.', 40, 400000, N'Pháp', 'H3.jpg', N'Tạo khối', N'Trang điểm'
EXEC sp_AddSP N'Phấn Tạo Khối Too Faced Chocolate Soleil Matte Bronzer', N'Phấn Tạo Khối Too Faced Chocolate Soleil Matte Bronzer chắc chắn sẽ là bảo bối giúp bạn có đường nét gương mặt sắc sảo hơn khi makeup.', 40, 420000, N'Hàn Quốc', 'TK1.jpg', N'Tạo khối', N'Trang điểm'
EXEC sp_AddSP N'Phấn Tạo khối Canmake Shading Powder Honey Rusk Brown', N'Tạo khổi từ sợi nylon mềm dẻo. Đầu cọ dẹt, dễ dàng sử dụng ở mọi đường nét trên khuôn mặt của bạn và thuận tiện để mang theo trong túi trang điểm của bạn.', 10, 470000, N'Anh', 'TK2.jpg', N'Tạo khối', N'Trang điểm'
EXEC sp_AddSP N'Phấn Tạo Khối Too Cool For School duContourArt class By Rodin Shading', N'Giúp khuôn mặt bạn được thon gọn và rạng rỡ, mang lại vẻ đẹp tự nhiên và thanh thoát hơn sau khi trang điểm.', 70, 400000, N'Anh', 'TK3.jpg', N'Tạo khối', N'Trang điểm'

EXEC sp_AddSP N'Phấn phủ Too Cool For School Artclass By Rodin Finish Setting Pact', N'Phấn phủ kiềm dầu Too Cool For School Artclass By Rodin Finish Setting Pact là giải pháp tuyệt vời giúp da chống dầu, lớp make-up bền màu lâu trôi hơn, chống chịu tốt hơn trước thời tiết nắng nóng ở Việt Nam.', 20, 100000, N'Mỹ', 'P1.jpg', N'Phấn phủ', N'Trang điểm'
EXEC sp_AddSP N'Phấn Phủ Kiềm Dầu Saemmul Perfect Pore Pink', N'Phấn phủ dạng nén kiềm dầu The Saem Saemmul Perfect Pore Pact có khả năng kiểm soát dầu tốt, cân bằng độ ẩm với thành phần trà xanh và tràm trà, tạo cảm giác khô ráo, giúp da đều màu và mịn màng.', 60, 100000, N'Hàn Quốc', 'P2.jpg', N'Phấn phủ', N'Trang điểm'
EXEC sp_AddSP N'Phấn Phủ Catrice All Matt Lasts Up To 12H Plus', N'Lớp màng bảo vệ có tác dụng phản chiếu ánh sáng mặt trời từ các thành phần khoáng giúp bảo vệ da khỏi tác hại của ánh nắng.', 20, 100000, N'Anh', 'P3.jpg', N'Phấn phủ', N'Trang điểm'
EXEC sp_AddSP N'Phấn phủ Missha Pro Touch Face Powder', N'Bột BN thu được từ chiết xuất mật ong hảo hạng và dầu dừa nguyên chất tạo nên lớp màng chắn bảo vệ và lưu giữ độ ẩm, cho làn da mềm mại, căng mọng hơn. Chiết xuất cây Thục Quỳ, hoa Elder, cây Phỉ cải thiện độ săn chắc, đàn hồi, làm mềm và dịu da nhạy cảm.', 10, 110000, N'Anh', 'P4.jpg', N'Phấn phủ', N'Trang điểm'
EXEC sp_AddSP N'Phấn Phủ BH Cosmetics Studio Pro Matte Finish Pressed Powder', N'Bột phấn siêu mịn, che phủ rất tốt các khuyết điểm trên khuôn mặt và có khả năng kiềm dầu cao. Phấn dễ dàng tán đều khi lên da, không gây hiện tượng bị cakey.', 50, 100000, N'Đức', 'P5.jpg', N'Phấn phủ', N'Trang điểm'
EXEC sp_AddSP N'Phấn Phủ Eglips Blur Powder Pact', N'Powder Pact có thể làm mờ khuyết điểm rất tốt đặc biệt là các vùng lỗ chân lông to hay vùng quầng thâm dưới mắt. Kết cấu phấn nhẹ tênh như các loại phấn phủ bột và cho lớp nền không quá lì.', 30, 120000, N'Anh', 'P6.png', N'Phấn phủ', N'Trang điểm'

EXEC sp_AddSP N'Son Kem Lì Wet n Wild MegaLast Liquid Catsuit Matte Lipstick', N'Son Kem Lì Wet n Wild MegaLast Liquid Catsuit Matte Lipstick có khả năng bám màu cực “trâu” luôn, kéo dài cả ngày bất chấp bạn ăn uống, lau miệng nhiều. Son cũng không hề bám vào cốc hay dây ra khẩu trang. ', 30, 170000, N'Anh', 'SK1.png', N'Son kem', N'Trang điểm'
EXEC sp_AddSP N'Son Kem Lì ColourPop Ultra Matte Liquid Lipstick', N'Khả năng bền màu của dòng son này khoảng 5 – 6 tiếng, tùy thuộc vào thói quen ăn uống của mỗi cô nàng. Khi ăn uống son sẽ trôi nhẹ, tuy nhiên lớp base bền màu giúp môi luôn tươi tắn ngay cả khi lớp son màu đã trôi hết sạch.', 60, 150000, N'Mỹ', 'SK2.jpg', N'Son kem', N'Trang điểm'
EXEC sp_AddSP N'Son Kem Lì 3CE Kem Cloud Lip Tint', N'Mang cảm giác ấm áp, sự trở lại của những màu đẹp nhất với chất son mềm mại như nhung, nhẹ tựa không khí cùng hiệu ứng bludging và bảng màu trendy vô cùng đa dạng, sự kết hợp hoàn hảo mang đến sự hài lòng cho bạn', 60, 190000, N'Anh', 'SK3.jpg', N'Son kem', N'Trang điểm'
EXEC sp_AddSP N'Son Kem Lì Romand Zero Velvet Tint ', N'Son Kem Lì Wet n Wild MegaLast Liquid Catsuit Matte Lipstick có khả năng bám màu cực “trâu” luôn, kéo dài cả ngày bất chấp bạn ăn uống, lau miệng nhiều. Son cũng không hề bám vào cốc hay dây ra khẩu trang.', 70, 170000, N'Hà Lan', 'SK4.jpg', N'Son kem', N'Trang điểm'
EXEC sp_AddSP N'Son Kem Lì Merzy The Heritage Velvet Tint', N'Chất son được cải tiến cho độ lên màu đậm rõ và duy trì sự rạng rỡ như mới được apply lên môi trong nhiều giờ liền . ', 20, 100000, N'Ý', 'SK5.png', N'Son kem', N'Trang điểm'
EXEC sp_AddSP N'Son Kem Lì Hera Sensual Spicy Nude Gloss', N'Chất son lỏng nhẹ, mịn mướt với các hạt nhũ óng ánh, cho môi căng tràn, đầy đặn và làm mờ hoàn hảo vết nhăn, rãnh môi.', 40, 100000, N'Anh', 'SK6.jpg', N'Son kem', N'Trang điểm'

--------------------------------------------------------------------------------
-- NHẬP CÁC BẢNG TINHTHANH, QUANHUYEN, XAPHUONG
--Tỉnh thành
INSERT TINHTHANH VALUES(N'An Giang')
INSERT TINHTHANH VALUES(N'Bà Rịa - Vũng Tàu')
INSERT TINHTHANH VALUES(N'Bạc Liêu')
INSERT TINHTHANH VALUES(N'Bắc Giang')
INSERT TINHTHANH VALUES(N'Bắc Cạn') -- 5
INSERT TINHTHANH VALUES(N'Bắc Ninh')
INSERT TINHTHANH VALUES(N'Bến Tre')
INSERT TINHTHANH VALUES(N'Bình Dương')
INSERT TINHTHANH VALUES(N'Bình Định')
INSERT TINHTHANH VALUES(N'Bình Phước') -- 10
INSERT TINHTHANH VALUES(N'Bình Thuận')
INSERT TINHTHANH VALUES(N'Cà Mau')
INSERT TINHTHANH VALUES(N'Cần Thơ')
INSERT TINHTHANH VALUES(N'Cao Bằng')
INSERT TINHTHANH VALUES(N'Đà Nẵng') -- 15
INSERT TINHTHANH VALUES(N'Đắk Lắk')
INSERT TINHTHANH VALUES(N'Đắk Nông')
INSERT TINHTHANH VALUES(N'Điện Biên')
INSERT TINHTHANH VALUES(N'Đồng Nai')
INSERT TINHTHANH VALUES(N'Đồng Tháp') -- 20
INSERT TINHTHANH VALUES(N'Gia Lai')
INSERT TINHTHANH VALUES(N'Hà Giang')
INSERT TINHTHANH VALUES(N'Hà Nam')
INSERT TINHTHANH VALUES(N'Hà Nội')
INSERT TINHTHANH VALUES(N'Hồ Chí Minh') -- 25
-- INSERT TINHTHANH VALUES(N'Hà Tĩnh') 
-- INSERT TINHTHANH VALUES(N'Hải Dương')
-- INSERT TINHTHANH VALUES(N'Hải Phòng')
-- INSERT TINHTHANH VALUES(N'Hậu Giang')
-- INSERT TINHTHANH VALUES(N'Hòa Bình') -- 30
-- INSERT TINHTHANH VALUES(N'Hưng Yên')
-- INSERT TINHTHANH VALUES(N'Khánh Hòa')
-- INSERT TINHTHANH VALUES(N'Kiên Giang')
-- INSERT TINHTHANH VALUES(N'Kon Tum')
-- INSERT TINHTHANH VALUES(N'Lai Châu') -- 35
-- INSERT TINHTHANH VALUES(N'Lạng Sơn')
-- INSERT TINHTHANH VALUES(N'Lào Cai')
-- INSERT TINHTHANH VALUES(N'Lâm Đồng')
-- INSERT TINHTHANH VALUES(N'Long An')
-- INSERT TINHTHANH VALUES(N'Nam Định') -- 40
-- INSERT TINHTHANH VALUES(N'Nghệ An')
-- INSERT TINHTHANH VALUES(N'Ninh Bình')
-- INSERT TINHTHANH VALUES(N'Ninh Thuận')
-- INSERT TINHTHANH VALUES(N'Phú Thọ')
-- INSERT TINHTHANH VALUES(N'Phú Yên') -- 45
-- INSERT TINHTHANH VALUES(N'Quảng Bình')
-- INSERT TINHTHANH VALUES(N'Quảng Nam')
-- INSERT TINHTHANH VALUES(N'Quảng Ngãi')
-- INSERT TINHTHANH VALUES(N'Quảng Ninh')
-- INSERT TINHTHANH VALUES(N'Quảng Trị') -- 50
-- INSERT TINHTHANH VALUES(N'Sóc Trăng')
-- INSERT TINHTHANH VALUES(N'Sơn La')
-- INSERT TINHTHANH VALUES(N'Tây Ninh')
-- INSERT TINHTHANH VALUES(N'Thái Bình')
-- INSERT TINHTHANH VALUES(N'Thái Nguyên') -- 55
-- INSERT TINHTHANH VALUES(N'Thanh Hóa')
-- INSERT TINHTHANH VALUES(N'Thừa Thiên Huế')
-- INSERT TINHTHANH VALUES(N'Tiền Giang')
-- INSERT TINHTHANH VALUES(N'Trà Vinh')
-- INSERT TINHTHANH VALUES(N'Tuyên Quang') -- 60
-- INSERT TINHTHANH VALUES(N'Vĩnh Long')
-- INSERT TINHTHANH VALUES(N'Vĩnh Phúc')
-- INSERT TINHTHANH VALUES(N'Yên Bái')

--Quận/Huyện
INSERT QUANHUYEN VALUES(N'Huyện An Phú', 1)
INSERT QUANHUYEN VALUES(N'Huyện Châu Phú', 1)
INSERT QUANHUYEN VALUES(N'Huyện Châu Thành', 1)
INSERT QUANHUYEN VALUES(N'Huyện Chợ Mới', 1)
INSERT QUANHUYEN VALUES(N'Huyện Phú Tân', 1) --5
INSERT QUANHUYEN VALUES(N'Huyện Thoại Sơn', 1)
INSERT QUANHUYEN VALUES(N'Huyện Tịnh Biên', 1)
INSERT QUANHUYEN VALUES(N'Huyện Tri Tôn', 1)
INSERT QUANHUYEN VALUES(N'TP. Châu Đốc', 1)
INSERT QUANHUYEN VALUES(N'TP. Long Xuyên', 1) -- 10
INSERT QUANHUYEN VALUES(N'TX. Tân Châu', 1)

INSERT QUANHUYEN VALUES(N'Huyện Châu Đức', 2)
INSERT QUANHUYEN VALUES(N'Huyện Côn Đảo', 2)
INSERT QUANHUYEN VALUES(N'Huyện Đất Đỏ', 2)
INSERT QUANHUYEN VALUES(N'Huyện Long Điền', 2) --  15
INSERT QUANHUYEN VALUES(N'Huyện Xuyên Mộc', 2)
INSERT QUANHUYEN VALUES(N'Thị Xã Phú Mỹ', 2)
INSERT QUANHUYEN VALUES(N'TP. Bà Rịa', 2)
INSERT QUANHUYEN VALUES(N'TP. Vũng Tàu', 2)
INSERT QUANHUYEN VALUES(N'TX. Phú Mỹ', 2) -- 20

INSERT QUANHUYEN VALUES(N'Huyện Đông Hải', 3)
INSERT QUANHUYEN VALUES(N'Huyện Hòa Bình', 3)
INSERT QUANHUYEN VALUES(N'Huyện Hồng Dân', 3)
INSERT QUANHUYEN VALUES(N'Huyện Phước Long', 3)
INSERT QUANHUYEN VALUES(N'Huyện Vĩnh Lợi', 3) -- 25
INSERT QUANHUYEN VALUES(N'TP. Bạc Liêu', 3)
INSERT QUANHUYEN VALUES(N'TX. Giá Rai', 3)

INSERT QUANHUYEN VALUES(N'Huyện Hiệp Hòa', 4)
INSERT QUANHUYEN VALUES(N'Huyện Lạng Giang', 4)
INSERT QUANHUYEN VALUES(N'Huyện Lục Nam', 4) -- 30
INSERT QUANHUYEN VALUES(N'Huyện Lục Ngạn', 4)
INSERT QUANHUYEN VALUES(N'Huyện Sơn Động', 4)
INSERT QUANHUYEN VALUES(N'Huyện Tân Yên', 4)
INSERT QUANHUYEN VALUES(N'Huyện Việt Yên', 4)
INSERT QUANHUYEN VALUES(N'Huyện Yên Dũng', 4) -- 35
INSERT QUANHUYEN VALUES(N'Huyện Yên Thế', 4)
INSERT QUANHUYEN VALUES(N'TP. Bắc Giang', 4)

INSERT QUANHUYEN VALUES(N'Huyện Ba Bể', 5)
INSERT QUANHUYEN VALUES(N'Huyện Bạch Thông', 5)
INSERT QUANHUYEN VALUES(N'Huyện Chợ Đồn', 5) -- 40
INSERT QUANHUYEN VALUES(N'Huyện Chợ Mới', 5)
INSERT QUANHUYEN VALUES(N'Huyện Na Rì', 5)
INSERT QUANHUYEN VALUES(N'Huyện Ngân Sơn', 5)
INSERT QUANHUYEN VALUES(N'Huyện Pác Nặm', 5)
INSERT QUANHUYEN VALUES(N'TP. Bắc Kạn', 5) -- 45

INSERT QUANHUYEN VALUES(N'Huyện Gia Bình', 6)
INSERT QUANHUYEN VALUES(N'Huyện Lương Tài', 6)
INSERT QUANHUYEN VALUES(N'Huyện Quế Võ', 6)
INSERT QUANHUYEN VALUES(N'Huyện Thuận Thành', 6)
INSERT QUANHUYEN VALUES(N'Huyện Tiên Du', 6) -- 50
INSERT QUANHUYEN VALUES(N'Huyện Yên Phong', 6)
INSERT QUANHUYEN VALUES(N'TP. Bắc Ninh', 6)
INSERT QUANHUYEN VALUES(N'TX. Từ Sơn', 6)

INSERT QUANHUYEN VALUES(N'Huyện Ba Tri', 7)
INSERT QUANHUYEN VALUES(N'Huyện Bình Đại', 7) -- 55
INSERT QUANHUYEN VALUES(N'Huyện Châu Thành', 7)
INSERT QUANHUYEN VALUES(N'Huyện Chợ Lách', 7)
INSERT QUANHUYEN VALUES(N'Huyện Giồng Trôm', 7)
INSERT QUANHUYEN VALUES(N'Huyện Mỏ Cày Bắc', 7)
INSERT QUANHUYEN VALUES(N'Huyện Mỏ Cày Nam', 7) -- 60
INSERT QUANHUYEN VALUES(N'Huyện Thạnh Phú', 7)
INSERT QUANHUYEN VALUES(N'TP. Bến Tre', 7)

INSERT QUANHUYEN VALUES(N'Huyện Bắc Tân Uyên', 8)
INSERT QUANHUYEN VALUES(N'Huyện Bàu Bàng', 8)
INSERT QUANHUYEN VALUES(N'Huyện Dầu Tiếng', 8) -- 65
INSERT QUANHUYEN VALUES(N'Huyện Phú Giáo', 8)
INSERT QUANHUYEN VALUES(N'TP. Dĩ An', 8)
INSERT QUANHUYEN VALUES(N'TP. Thủ Dầu Một', 8)
INSERT QUANHUYEN VALUES(N'TP.Thuận An', 8)
INSERT QUANHUYEN VALUES(N'TX. Bến Cát', 8) -- 70
INSERT QUANHUYEN VALUES(N'TX. Tân Uyên', 8)

INSERT QUANHUYEN VALUES(N'Huyện An Lão', 9)
INSERT QUANHUYEN VALUES(N'Huyện Hoài Ân', 9)
INSERT QUANHUYEN VALUES(N'Huyện Phù Cát', 9)
INSERT QUANHUYEN VALUES(N'Huyện Phù Mỹ', 9) -- 75
INSERT QUANHUYEN VALUES(N'Huyện Tây Sơn', 9)
INSERT QUANHUYEN VALUES(N'Huyện Tuy Phước', 9)
INSERT QUANHUYEN VALUES(N'Huyện Vân Canh', 9)
INSERT QUANHUYEN VALUES(N'Huyện Vĩnh Thạnh', 9)
INSERT QUANHUYEN VALUES(N'TP. Quy Nhơn', 9) -- 80
INSERT QUANHUYEN VALUES(N'TX. An Nhơn', 9)
INSERT QUANHUYEN VALUES(N'TX. Hoài Nhơn', 9)

INSERT QUANHUYEN VALUES(N'Huyện Bù Đăng', 10)
INSERT QUANHUYEN VALUES(N'Huyện Bù Đốp', 10)
INSERT QUANHUYEN VALUES(N'Huyện Bù Gia Mập', 10) -- 85
INSERT QUANHUYEN VALUES(N'Huyện Chơn Thành', 10)
INSERT QUANHUYEN VALUES(N'Huyện Đồng Phú', 10)
INSERT QUANHUYEN VALUES(N'Huyện Hớn Quản', 10)
INSERT QUANHUYEN VALUES(N'Huyện Lộc Ninh', 10)
INSERT QUANHUYEN VALUES(N'Huyện Phú Riềng', 10) -- 90
INSERT QUANHUYEN VALUES(N'TP. Đồng Xoài', 10)
INSERT QUANHUYEN VALUES(N'TX. Bình Long', 10)
INSERT QUANHUYEN VALUES(N'TX. Phước Long', 10)

INSERT QUANHUYEN VALUES(N'Huyện Bắc Bình', 11)
INSERT QUANHUYEN VALUES(N'Huyện Đức Linh', 11) -- 95
INSERT QUANHUYEN VALUES(N'Huyện Hàm Tân', 11)
INSERT QUANHUYEN VALUES(N'Huyện Hàm Thuận Bắc', 11)
INSERT QUANHUYEN VALUES(N'Huyện Hàm Thuận Nam', 11)
INSERT QUANHUYEN VALUES(N'Huyện Phú Quý', 11)
INSERT QUANHUYEN VALUES(N'Huyện Tánh Linh', 11) -- 100
INSERT QUANHUYEN VALUES(N'Huyện Tuy Phong', 11)
INSERT QUANHUYEN VALUES(N'TP. Phan Thiết', 11)
INSERT QUANHUYEN VALUES(N'TX. La Gi', 11)

INSERT QUANHUYEN VALUES(N'Huyện Cái Nước', 12)
INSERT QUANHUYEN VALUES(N'Huyện Đầm Dơi', 12) -- 105
INSERT QUANHUYEN VALUES(N'Huyện Năm Căn', 12)
INSERT QUANHUYEN VALUES(N'Huyện Ngọc Hiển', 12)
INSERT QUANHUYEN VALUES(N'Huyện Phú Tân', 12)
INSERT QUANHUYEN VALUES(N'Huyện Thới Bình', 12)
INSERT QUANHUYEN VALUES(N'Huyện Trần Văn Thời', 12) -- 110
INSERT QUANHUYEN VALUES(N'Huyện U Minh', 12) 
INSERT QUANHUYEN VALUES(N'TP. Cà Mau', 12)

INSERT QUANHUYEN VALUES(N'Quận Bình Thủy', 13)
INSERT QUANHUYEN VALUES(N'Quận Cái Răng', 13)
INSERT QUANHUYEN VALUES(N'Quận Ninh Kiều', 13) -- 115
INSERT QUANHUYEN VALUES(N'Quận Ô Môn', 13)
INSERT QUANHUYEN VALUES(N'Quận Thốt Nốt', 13)
INSERT QUANHUYEN VALUES(N'Huyện Cờ Đỏ', 13)
INSERT QUANHUYEN VALUES(N'Huyện Phong Điền', 13)
INSERT QUANHUYEN VALUES(N'Huyện Thới Lai', 13) -- 120
INSERT QUANHUYEN VALUES(N'Huyện Vĩnh Thạnh', 13)

INSERT QUANHUYEN VALUES(N'Huyện Bảo Lạc', 14)
INSERT QUANHUYEN VALUES(N'Huyện Bảo Lâm', 14)
INSERT QUANHUYEN VALUES(N'Huyện Hạ Lang', 14)
INSERT QUANHUYEN VALUES(N'Huyện Hà Quảng', 14) -- 125
INSERT QUANHUYEN VALUES(N'Huyện Hòa An', 14)
INSERT QUANHUYEN VALUES(N'Huyện Nguyên Bình', 14)
INSERT QUANHUYEN VALUES(N'Huyện Phục Hòa', 14)
INSERT QUANHUYEN VALUES(N'Huyện Quảng Hòa', 14)
INSERT QUANHUYEN VALUES(N'Huyện Quảng Uyên', 14) -- 130
INSERT QUANHUYEN VALUES(N'Huyện Thạch An', 14)
INSERT QUANHUYEN VALUES(N'Huyện Thông Nông', 14)
INSERT QUANHUYEN VALUES(N'Huyện Trùng Khánh', 14)
INSERT QUANHUYEN VALUES(N'TP. Cao Bằng', 14)

INSERT QUANHUYEN VALUES(N'Quận Cẩm Lệ', 15) -- 135
INSERT QUANHUYEN VALUES(N'Quận Hải Châu', 15)
INSERT QUANHUYEN VALUES(N'Quận Liên Chiểu', 15)
INSERT QUANHUYEN VALUES(N'Quận Ngũ Hành Sơn', 15)
INSERT QUANHUYEN VALUES(N'Quận Sơn Trà', 15)
INSERT QUANHUYEN VALUES(N'Quận Thanh Khê', 15) -- 140
INSERT QUANHUYEN VALUES(N'Huyện Hòa Vang', 15)

INSERT QUANHUYEN VALUES(N'Huyện Buôn Đôn', 16)
INSERT QUANHUYEN VALUES(N'Huyện Cư Kuin', 16)
INSERT QUANHUYEN VALUES(N'Huyện Cư M''gar', 16)
INSERT QUANHUYEN VALUES(N'Huyện Ea H''leo', 16) -- 145
INSERT QUANHUYEN VALUES(N'Huyện Ea Kar', 16)
INSERT QUANHUYEN VALUES(N'Huyện Ea Súp', 16)
INSERT QUANHUYEN VALUES(N'Huyện Krông Ana', 16)
INSERT QUANHUYEN VALUES(N'Huyện Krông Bông', 16)
INSERT QUANHUYEN VALUES(N'Huyện Krông Búk', 16) -- 150
INSERT QUANHUYEN VALUES(N'Huyện Krông Năng', 16)
INSERT QUANHUYEN VALUES(N'Huyện Krông Pắc', 16)
INSERT QUANHUYEN VALUES(N'Huyện Lăk', 16)
INSERT QUANHUYEN VALUES(N'Huyện M''Đrăk', 16)
INSERT QUANHUYEN VALUES(N'TP. Buôn Ma Thuột', 16) -- 155
INSERT QUANHUYEN VALUES(N'TX. Buôn Hồ', 16)

INSERT QUANHUYEN VALUES(N'Huyện Cư Jút', 17)
INSERT QUANHUYEN VALUES(N'Huyện Đăk Glong', 17)
INSERT QUANHUYEN VALUES(N'Huyện Đăk Mil', 17)
INSERT QUANHUYEN VALUES(N'Huyện Đăk R''Lấp', 17) -- 160
INSERT QUANHUYEN VALUES(N'Huyện Đăk Song', 17)
INSERT QUANHUYEN VALUES(N'Huyện Krông Nô', 17)
INSERT QUANHUYEN VALUES(N'Huyện Tuy Đức', 17)
INSERT QUANHUYEN VALUES(N'TP. Gia Nghĩa', 17)

INSERT QUANHUYEN VALUES(N'Huyện Điện Biên', 18) -- 165
INSERT QUANHUYEN VALUES(N'Huyện Điện Biên Đông', 18)
INSERT QUANHUYEN VALUES(N'Huyện Mường Ảng', 18)
INSERT QUANHUYEN VALUES(N'Huyện Mường Chà', 18)
INSERT QUANHUYEN VALUES(N'Huyện Mường Nhé', 18)
INSERT QUANHUYEN VALUES(N'Huyện Nậm Pồ', 18) -- 170
INSERT QUANHUYEN VALUES(N'Huyện Tủa Chùa', 18)
INSERT QUANHUYEN VALUES(N'Huyện Tuần Giáo', 18)
INSERT QUANHUYEN VALUES(N'TP. Điện Biên Phủ', 18)
INSERT QUANHUYEN VALUES(N'TX. Mường Lay', 18)

INSERT QUANHUYEN VALUES(N'Huyện Cẩm Mỹ', 19) -- 175
INSERT QUANHUYEN VALUES(N'Huyện Định Quán', 19)
INSERT QUANHUYEN VALUES(N'Huyện Long Thành', 19)
INSERT QUANHUYEN VALUES(N'Huyện Nhơn Trạch', 19)
INSERT QUANHUYEN VALUES(N'Huyện Tân Phú', 19)
INSERT QUANHUYEN VALUES(N'Huyện Thống Nhất', 19) -- 180
INSERT QUANHUYEN VALUES(N'Huyện Trảng Bom', 19)
INSERT QUANHUYEN VALUES(N'Huyện Vĩnh Cửu', 19)
INSERT QUANHUYEN VALUES(N'Huyện Xuân Lộc', 19)
INSERT QUANHUYEN VALUES(N'TP. Biên Hòa', 19)
INSERT QUANHUYEN VALUES(N'TP. Long Khánh', 19) -- 185

INSERT QUANHUYEN VALUES(N'Huyện Cao Lãnh', 20)
INSERT QUANHUYEN VALUES(N'Huyện Châu Thành', 20)
INSERT QUANHUYEN VALUES(N'Huyện Hồng Ngự', 20)
INSERT QUANHUYEN VALUES(N'Huyện Lai Vung', 20)
INSERT QUANHUYEN VALUES(N'Huyện Lấp Vò', 20) -- 190
INSERT QUANHUYEN VALUES(N'Huyện Tam Nông', 20)
INSERT QUANHUYEN VALUES(N'Huyện Tân Hồng', 20)
INSERT QUANHUYEN VALUES(N'Huyện Thanh Bình', 20)
INSERT QUANHUYEN VALUES(N'Huyện Tháp Mười', 20)
INSERT QUANHUYEN VALUES(N'TP. Cao Lãnh', 20) -- 195
INSERT QUANHUYEN VALUES(N'TP. Hồng Ngự', 20)
INSERT QUANHUYEN VALUES(N'TP. Sa Đéc', 20)

INSERT QUANHUYEN VALUES(N'Huyện Chư Păh', 21)
INSERT QUANHUYEN VALUES(N'Huyện Chư Prông', 21)
INSERT QUANHUYEN VALUES(N'Huyện Chư Pưh', 21) -- 200
INSERT QUANHUYEN VALUES(N'Huyện Chư Sê', 21)
INSERT QUANHUYEN VALUES(N'Huyện Đăk Đoa', 21)
INSERT QUANHUYEN VALUES(N'Huyện Đắk Pơ', 21)
INSERT QUANHUYEN VALUES(N'Huyện Đức Cơ', 21)
INSERT QUANHUYEN VALUES(N'Huyện Ia Grai', 21) -- 205
INSERT QUANHUYEN VALUES(N'Huyện Ia Pa', 21)
INSERT QUANHUYEN VALUES(N'Huyện KBang', 21)
INSERT QUANHUYEN VALUES(N'Huyện Kông Chro', 21)
INSERT QUANHUYEN VALUES(N'Huyện Krông Pa', 21)
INSERT QUANHUYEN VALUES(N'Huyện Mang Yang', 21) -- 210
INSERT QUANHUYEN VALUES(N'Huyện Phú Thiện', 21)
INSERT QUANHUYEN VALUES(N'TP. Pleiku', 21)
INSERT QUANHUYEN VALUES(N'TX. An Khê', 21)
INSERT QUANHUYEN VALUES(N'TX. Ayun Pa', 21)

INSERT QUANHUYEN VALUES(N'Huyện Bắc Mê', 22) -- 215
INSERT QUANHUYEN VALUES(N'Huyện Bắc Quang', 22)
INSERT QUANHUYEN VALUES(N'Huyện Đồng Văn', 22)
INSERT QUANHUYEN VALUES(N'Huyện Hoàng Su Phì', 22)
INSERT QUANHUYEN VALUES(N'Huyện Mèo Vạc', 22)
INSERT QUANHUYEN VALUES(N'Huyện Quản Bạ', 22) -- 220
INSERT QUANHUYEN VALUES(N'Huyện Quang Bình', 22)
INSERT QUANHUYEN VALUES(N'Huyện Vị Xuyên', 22)
INSERT QUANHUYEN VALUES(N'Huyện Xín Mần', 22)
INSERT QUANHUYEN VALUES(N'Huyện Yên Minh', 22)
INSERT QUANHUYEN VALUES(N'TP. Hà Giang', 22) -- 225

INSERT QUANHUYEN VALUES(N'Huyện Bình Lục', 23)
INSERT QUANHUYEN VALUES(N'Huyện Kim Bảng', 23)
INSERT QUANHUYEN VALUES(N'Huyện Lý Nhân', 23)
INSERT QUANHUYEN VALUES(N'Huyện Thanh Liêm', 23)
INSERT QUANHUYEN VALUES(N'TP. Phủ Lý', 23) -- 230
INSERT QUANHUYEN VALUES(N'TX. Duy Tiên', 23)

INSERT QUANHUYEN VALUES(N'Quận Ba Đình', 24)
INSERT QUANHUYEN VALUES(N'Quận Bắc Từ Liêm', 24)
INSERT QUANHUYEN VALUES(N'Quận Cầu Giấy', 24)
INSERT QUANHUYEN VALUES(N'Quận Đống Đa', 24) --235
INSERT QUANHUYEN VALUES(N'Quận Hà Đông', 24)
INSERT QUANHUYEN VALUES(N'Quận Hai Bà Trưng', 24)
INSERT QUANHUYEN VALUES(N'Quận Hoàn Kiếm', 24)
INSERT QUANHUYEN VALUES(N'Quận Hoàng Mai', 24)
INSERT QUANHUYEN VALUES(N'Quận Long Biên', 24) -- 240
INSERT QUANHUYEN VALUES(N'Quận Nam Từ Liêm', 24)
INSERT QUANHUYEN VALUES(N'Quận Tây Hồ', 24)
INSERT QUANHUYEN VALUES(N'Quận Thanh Xuân', 24)
INSERT QUANHUYEN VALUES(N'Huyện Ba Vì', 24)
INSERT QUANHUYEN VALUES(N'Huyện Chương Mỹ', 24) -- 245
INSERT QUANHUYEN VALUES(N'Huyện Đan Phượng', 24)
INSERT QUANHUYEN VALUES(N'Huyện Đông Anh', 24)
INSERT QUANHUYEN VALUES(N'Huyện Gia Lâm', 24)
INSERT QUANHUYEN VALUES(N'Huyện Hoài Đức', 24)
INSERT QUANHUYEN VALUES(N'Huyện Mê Linh', 24) -- 250
INSERT QUANHUYEN VALUES(N'Huyện Mỹ Đức', 24)
INSERT QUANHUYEN VALUES(N'Huyện Phú Xuyên', 24)
INSERT QUANHUYEN VALUES(N'Huyện Phúc Thọ', 24)
INSERT QUANHUYEN VALUES(N'Huyện Quốc Oai', 24)
INSERT QUANHUYEN VALUES(N'Huyện Sóc Sơn', 24)  -- 255
INSERT QUANHUYEN VALUES(N'Huyện Thạch Thất', 24)
INSERT QUANHUYEN VALUES(N'Huyện Thanh Oai', 24)
INSERT QUANHUYEN VALUES(N'Huyện Thanh Trì', 24)
INSERT QUANHUYEN VALUES(N'Huyện Thường Tín', 24)
INSERT QUANHUYEN VALUES(N'Huyện Ứng Hòa', 24) -- 260
INSERT QUANHUYEN VALUES(N'TX. Sơn Tây', 24)

INSERT QUANHUYEN VALUES(N'TP. Thủ Đức (Gồm Q2, Q9, Q.TĐ)', 25)
INSERT QUANHUYEN VALUES(N'Quận 1', 25)
INSERT QUANHUYEN VALUES(N'Quận 3', 25)
INSERT QUANHUYEN VALUES(N'Quận 4', 25) -- 265
INSERT QUANHUYEN VALUES(N'Quận 5', 25)
INSERT QUANHUYEN VALUES(N'Quận 6', 25)
INSERT QUANHUYEN VALUES(N'Quận 7', 25)
INSERT QUANHUYEN VALUES(N'Quận 8', 25)
INSERT QUANHUYEN VALUES(N'Quận 10', 25) --270
INSERT QUANHUYEN VALUES(N'Quận 11', 25)
INSERT QUANHUYEN VALUES(N'Quận 12', 25)
INSERT QUANHUYEN VALUES(N'Quận Bình Tân', 25)
INSERT QUANHUYEN VALUES(N'Quận Bình Thạnh', 25)
INSERT QUANHUYEN VALUES(N'Quận Gò Vấp', 25) -- 275
INSERT QUANHUYEN VALUES(N'Quận Phú Nhuận', 25)
INSERT QUANHUYEN VALUES(N'Quận Tân Bình', 25)
INSERT QUANHUYEN VALUES(N'Quận Tân Phú', 25)
INSERT QUANHUYEN VALUES(N'Huyện Bình Chánh', 25)
INSERT QUANHUYEN VALUES(N'Huyện Cần Giờ', 25) -- 280
INSERT QUANHUYEN VALUES(N'Huyện Củ Chi', 25)
INSERT QUANHUYEN VALUES(N'Huyện Hóc Môn', 25)
INSERT QUANHUYEN VALUES(N'Huyện Nhà Bè', 25)

-- xã / phường
INSERT XAPHUONG VALUES(N'Thị trấn An Phú', 1)
INSERT XAPHUONG VALUES(N'Thị trấn Long Bình', 1)
INSERT XAPHUONG VALUES(N'Xã Đa Phước', 1)
INSERT XAPHUONG VALUES(N'Xã Khánh An', 1)
INSERT XAPHUONG VALUES(N'Xã Khánh Bình', 1)
INSERT XAPHUONG VALUES(N'Xã Nhơn Hội', 1)
INSERT XAPHUONG VALUES(N'Xã Phú Hội', 1)
INSERT XAPHUONG VALUES(N'Xã Phú Hữu', 1)
INSERT XAPHUONG VALUES(N'Xã Phước Hưng', 1)
INSERT XAPHUONG VALUES(N'Xã Quốc Thái', 1)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hậu', 1)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hội Đông', 1)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Lộc', 1)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Trường', 1)

INSERT XAPHUONG VALUES(N'Thị trấn Vĩnh Thạnh Trung', 2)
INSERT XAPHUONG VALUES(N'Thị trấn Cái Dầu', 2)
INSERT XAPHUONG VALUES(N'Xã Bình Chánh', 2)
INSERT XAPHUONG VALUES(N'Xã Bình Long', 2)
INSERT XAPHUONG VALUES(N'Xã Bình Mỹ', 2)
INSERT XAPHUONG VALUES(N'Xã Bình Phú', 2)
INSERT XAPHUONG VALUES(N'Xã Bình Thủy', 2)
INSERT XAPHUONG VALUES(N'Xã Đào Hữu Cảnh', 2)
INSERT XAPHUONG VALUES(N'Xã Khánh Hòa', 2)
INSERT XAPHUONG VALUES(N'Xã Mỹ Đức', 2)
INSERT XAPHUONG VALUES(N'Xã Mỹ Phú', 2)
INSERT XAPHUONG VALUES(N'Xã ô Long Vỹ', 2)
INSERT XAPHUONG VALUES(N'Xã Thạnh Mỹ Tây', 2)

INSERT XAPHUONG VALUES(N'Thị trấn An Châu', 3)
INSERT XAPHUONG VALUES(N'Thị Trấn Vĩnh Bình', 3)
INSERT XAPHUONG VALUES(N'Xã An Hòa', 3)
INSERT XAPHUONG VALUES(N'Xã Bình Hòa', 3)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh', 3)
INSERT XAPHUONG VALUES(N'Xã Cần Đăng', 3)
INSERT XAPHUONG VALUES(N'Xã Hòa Bình Thạnh', 3)
INSERT XAPHUONG VALUES(N'Xã Tân Phú', 3)
INSERT XAPHUONG VALUES(N'Xã Vĩnh An', 3)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hanh', 3)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Lợi', 3)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Nhuận', 3)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thành', 3)

INSERT XAPHUONG VALUES(N'Thị trấn Chợ Mới', 4)
INSERT XAPHUONG VALUES(N'Thị trấn Mỹ Luông', 4)
INSERT XAPHUONG VALUES(N'Xã An Thạnh Trung', 4)
INSERT XAPHUONG VALUES(N'Xã Bình Phước Xuân', 4)
INSERT XAPHUONG VALUES(N'Xã Hòa An', 4)
INSERT XAPHUONG VALUES(N'Xã Hòa Bình', 4)
INSERT XAPHUONG VALUES(N'Xã Hội An', 4)
INSERT XAPHUONG VALUES(N'Xã Kiến An', 4)
INSERT XAPHUONG VALUES(N'Xã Kiến Thành', 4)
INSERT XAPHUONG VALUES(N'Xã Long Điền A', 4)
INSERT XAPHUONG VALUES(N'Xã Long Điền B', 4)
INSERT XAPHUONG VALUES(N'Xã Long Giang', 4)
INSERT XAPHUONG VALUES(N'Xã Long Kiến', 4)
INSERT XAPHUONG VALUES(N'Xã Mỹ An', 4)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hiệp', 4)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hội Đông', 4)
INSERT XAPHUONG VALUES(N'Xã Nhơn Mỹ', 4)
INSERT XAPHUONG VALUES(N'Xã Tấn Mỹ', 4)

INSERT XAPHUONG VALUES(N'Thị trấn Chợ Vàm', 5)
INSERT XAPHUONG VALUES(N'Thị trấn Phú Mỹ', 5)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh Đông', 5)
INSERT XAPHUONG VALUES(N'Xã Hiệp Xương', 5)
INSERT XAPHUONG VALUES(N'Xã Hòa Lạc', 5)
INSERT XAPHUONG VALUES(N'Xã Long Hòa', 5)
INSERT XAPHUONG VALUES(N'Xã Phú An', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Bình', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Hiệp', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Hưng', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Lâm', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Long', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Thành', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Thạnh', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Thọ', 5)
INSERT XAPHUONG VALUES(N'Xã Phú Xuân', 5)
INSERT XAPHUONG VALUES(N'Xã Tân Hòa', 5)
INSERT XAPHUONG VALUES(N'Xã Tân Trung', 5)

INSERT XAPHUONG VALUES(N'Thị trấn Núi Sập', 6)
INSERT XAPHUONG VALUES(N'Thị trấn óc Eo', 6)
INSERT XAPHUONG VALUES(N'Thị Trấn Phú Hòa', 6)
INSERT XAPHUONG VALUES(N'Xã An Bình', 6)
INSERT XAPHUONG VALUES(N'Xã Bình Thành', 6)
INSERT XAPHUONG VALUES(N'Xã Định Mỹ', 6)
INSERT XAPHUONG VALUES(N'Xã Định Thành', 6)
INSERT XAPHUONG VALUES(N'Xã Mỹ Phú Đông', 6)
INSERT XAPHUONG VALUES(N'Xã Phú Thuận', 6)
INSERT XAPHUONG VALUES(N'Xã Tây Phú', 6)
INSERT XAPHUONG VALUES(N'Xã Thoại Giang', 6)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Chánh', 6)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Khánh', 6)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Phú', 6)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Trạch', 6)
INSERT XAPHUONG VALUES(N'Xã Vọng Đông', 6)
INSERT XAPHUONG VALUES(N'Xã Vọng Thê', 6)

INSERT XAPHUONG VALUES(N'Thị trấn Chi Lăng', 7)
INSERT XAPHUONG VALUES(N'Thị trấn Nhà Bàng', 7)
INSERT XAPHUONG VALUES(N'Thị trấn Tịnh Biên', 7)
INSERT XAPHUONG VALUES(N'Xã An Cư', 7)
INSERT XAPHUONG VALUES(N'Xã An Hảo', 7)
INSERT XAPHUONG VALUES(N'Xã An Nông', 7)
INSERT XAPHUONG VALUES(N'Xã An Phú', 7)
INSERT XAPHUONG VALUES(N'Xã Nhơn Hưng', 7)
INSERT XAPHUONG VALUES(N'Xã Núi Voi', 7)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 7)
INSERT XAPHUONG VALUES(N'Xã Tân Lợi', 7)
INSERT XAPHUONG VALUES(N'Xã Thới Sơn', 7)
INSERT XAPHUONG VALUES(N'Xã Văn Giáo', 7)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Trung', 7)

INSERT XAPHUONG VALUES(N'Thị trấn Ba Chúc', 8)
INSERT XAPHUONG VALUES(N'Thị Trấn Cô Tô', 8)
INSERT XAPHUONG VALUES(N'Thị trấn Tri Tôn', 8)
INSERT XAPHUONG VALUES(N'Xã An Tức', 8)
INSERT XAPHUONG VALUES(N'Xã Châu Lăng', 8)
INSERT XAPHUONG VALUES(N'Xã Lạc Quới', 8)
INSERT XAPHUONG VALUES(N'Xã Lê Trì', 8)
INSERT XAPHUONG VALUES(N'Xã Lương An Trà', 8)
INSERT XAPHUONG VALUES(N'Xã Lương Phi', 8)
INSERT XAPHUONG VALUES(N'Xã Núi Tô', 8)
INSERT XAPHUONG VALUES(N'Xã ô Lâm', 8)
INSERT XAPHUONG VALUES(N'Xã Tà Đảnh', 8)
INSERT XAPHUONG VALUES(N'Xã Tân Tuyến', 8)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Gia', 8)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Phước', 8)

INSERT XAPHUONG VALUES(N'Phường Châu Phú A', 9)
INSERT XAPHUONG VALUES(N'Phường Châu Phú B', 9)
INSERT XAPHUONG VALUES(N'Phường Núi Sam', 9)
INSERT XAPHUONG VALUES(N'Phường Vĩnh Mỹ', 9)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Châu', 9)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Ngươn', 9)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Tế', 9)

INSERT XAPHUONG VALUES(N'Phường Bình Đức', 10)
INSERT XAPHUONG VALUES(N'Phường Bình Khánh', 10)
INSERT XAPHUONG VALUES(N'Phường Đông Xuyên', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Bình', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Hòa', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Long', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Phước', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Quý', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Thạnh', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Thới', 10)
INSERT XAPHUONG VALUES(N'Phường Mỹ Xuyên', 10)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hoà Hưng', 10)
INSERT XAPHUONG VALUES(N'Xã Mỹ Khánh', 10)

INSERT XAPHUONG VALUES(N'Phường Long Sơn', 11)
INSERT XAPHUONG VALUES(N'Phường Long Châu', 11)
INSERT XAPHUONG VALUES(N'Phường Long Hưng', 11)
INSERT XAPHUONG VALUES(N'Phường Long Phú', 11)
INSERT XAPHUONG VALUES(N'Phường Long Thạnh', 11)
INSERT XAPHUONG VALUES(N'Xã Châu Phong', 11)
INSERT XAPHUONG VALUES(N'Xã Lê Chánh', 11)
INSERT XAPHUONG VALUES(N'Xã Long An', 11)
INSERT XAPHUONG VALUES(N'Xã Phú Lộc', 11)
INSERT XAPHUONG VALUES(N'Xã Phú Vĩnh', 11)
INSERT XAPHUONG VALUES(N'Xã Tân An', 11)
INSERT XAPHUONG VALUES(N'Xã Tân Thạnh', 11)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hòa', 11)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Xương', 11)

INSERT XAPHUONG VALUES(N'Thị trấn Ngãi Giao', 12)
INSERT XAPHUONG VALUES(N'Xã Bàu Chinh', 12)
INSERT XAPHUONG VALUES(N'Xã Bình Ba', 12)
INSERT XAPHUONG VALUES(N'Xã Bình Giã', 12)
INSERT XAPHUONG VALUES(N'Xã Bình Trung', 12)
INSERT XAPHUONG VALUES(N'Xã Cù Bị', 12)
INSERT XAPHUONG VALUES(N'Xã Đá Bạc', 12)
INSERT XAPHUONG VALUES(N'Xã Kim Long', 12)
INSERT XAPHUONG VALUES(N'Xã Láng Lớn', 12)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Thành', 12)
INSERT XAPHUONG VALUES(N'Xã Quảng Thành', 12)
INSERT XAPHUONG VALUES(N'Xã Sơn Bình', 12)
INSERT XAPHUONG VALUES(N'Xã Suối Nghệ', 12)
INSERT XAPHUONG VALUES(N'Xã Suối Rao', 12)
INSERT XAPHUONG VALUES(N'Xã Xà Bang', 12)
INSERT XAPHUONG VALUES(N'Xã Xuân Sơn', 12)

INSERT XAPHUONG VALUES(N'Thị trấn Côn Đảo', 13)

INSERT XAPHUONG VALUES(N'Thị trấn Đất Đỏ', 14)
INSERT XAPHUONG VALUES(N'Thị Trấn Phước Hải', 14)
INSERT XAPHUONG VALUES(N'Xã Láng Dài', 14)
INSERT XAPHUONG VALUES(N'Xã Lộc An', 14)
INSERT XAPHUONG VALUES(N'Xã Long Mỹ', 14)
INSERT XAPHUONG VALUES(N'Xã Long Tân', 14)
INSERT XAPHUONG VALUES(N'Xã Phước Hội', 14)
INSERT XAPHUONG VALUES(N'Xã Phước Long Thọ', 14)

INSERT XAPHUONG VALUES(N'Thị trấn Long Điền', 15)
INSERT XAPHUONG VALUES(N'Thị trấn Long Hải', 15)
INSERT XAPHUONG VALUES(N'Xã An Ngãi', 15)
INSERT XAPHUONG VALUES(N'Xã An Nhứt', 15)
INSERT XAPHUONG VALUES(N'Xã Phước Hưng', 15)
INSERT XAPHUONG VALUES(N'Xã Phước Tỉnh', 15)
INSERT XAPHUONG VALUES(N'Xã Tam Phước', 15)

INSERT XAPHUONG VALUES(N'Thị trấn Phước Bửu', 16)
INSERT XAPHUONG VALUES(N'Xã Bàu Lâm', 16)
INSERT XAPHUONG VALUES(N'Xã Bình Châu', 16)
INSERT XAPHUONG VALUES(N'Xã Bông Trang', 16)
INSERT XAPHUONG VALUES(N'Xã Bưng Riềng', 16)
INSERT XAPHUONG VALUES(N'Xã Hòa Bình', 16)
INSERT XAPHUONG VALUES(N'Xã Hòa Hiệp', 16)
INSERT XAPHUONG VALUES(N'Xã Hòa Hội', 16)
INSERT XAPHUONG VALUES(N'Xã Hòa Hưng', 16)
INSERT XAPHUONG VALUES(N'Xã Phước Tân', 16)
INSERT XAPHUONG VALUES(N'Xã Phước Thuận', 16)
INSERT XAPHUONG VALUES(N'Xã Tân Lâm', 16)
INSERT XAPHUONG VALUES(N'Xã Xuyên Mộc', 16)

INSERT XAPHUONG VALUES(N'Thị trấn Phú Mỹ', 17)
INSERT XAPHUONG VALUES(N'Xã Châu Pha', 17)
INSERT XAPHUONG VALUES(N'Xã Hắc Dịch', 17)
INSERT XAPHUONG VALUES(N'Xã Mỹ Xuân', 17)
INSERT XAPHUONG VALUES(N'Xã Phước Hoà', 17)
INSERT XAPHUONG VALUES(N'Xã Sông Xoài', 17)
INSERT XAPHUONG VALUES(N'Xã Tân Hải', 17)
INSERT XAPHUONG VALUES(N'Xã Tân Hoà', 17)
INSERT XAPHUONG VALUES(N'Xã Tân Phước', 17)
INSERT XAPHUONG VALUES(N'Xã Tóc Tiên', 17)

INSERT XAPHUONG VALUES(N'Phường Kim Dinh', 18)
INSERT XAPHUONG VALUES(N'Phường Long Hương', 18)
INSERT XAPHUONG VALUES(N'Phường Long Tâm', 18)
INSERT XAPHUONG VALUES(N'Phường Long Toàn', 18)
INSERT XAPHUONG VALUES(N'Phường Phước Hiệp', 18)
INSERT XAPHUONG VALUES(N'Phường Phước Hưng', 18)
INSERT XAPHUONG VALUES(N'Phường Phước Nguyên', 18)
INSERT XAPHUONG VALUES(N'Phường Phước Trung', 18)
INSERT XAPHUONG VALUES(N'Xã Hoà Long', 18)
INSERT XAPHUONG VALUES(N'Xã Long Phước', 18)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 18)

INSERT XAPHUONG VALUES(N'Phường 1', 19)
INSERT XAPHUONG VALUES(N'Phường 2', 19)
INSERT XAPHUONG VALUES(N'Phường 3', 19)
INSERT XAPHUONG VALUES(N'Phường 4', 19)
INSERT XAPHUONG VALUES(N'Phường 5', 19)
INSERT XAPHUONG VALUES(N'Phường 7', 19)
INSERT XAPHUONG VALUES(N'Phường 8', 19)
INSERT XAPHUONG VALUES(N'Phường 9', 19)
INSERT XAPHUONG VALUES(N'Phường 10', 19)
INSERT XAPHUONG VALUES(N'Phường 11', 19)
INSERT XAPHUONG VALUES(N'Phường 12', 19)
INSERT XAPHUONG VALUES(N'Phường Nguyễn An Ninh', 19)
INSERT XAPHUONG VALUES(N'Phường Rạch Dừa', 19)
INSERT XAPHUONG VALUES(N'Phường Thắng Nhất', 19)
INSERT XAPHUONG VALUES(N'Phường Thắng Nhì', 19)
INSERT XAPHUONG VALUES(N'Phường Thắng Tam', 19)
INSERT XAPHUONG VALUES(N'Xã Long Sơn', 19)

INSERT XAPHUONG VALUES(N'Phường Hắc Dịch', 20)
INSERT XAPHUONG VALUES(N'Phường Mỹ Xuân', 20)
INSERT XAPHUONG VALUES(N'Phường Phú Mỹ', 20)
INSERT XAPHUONG VALUES(N'Phường Phước Hòa', 20)
INSERT XAPHUONG VALUES(N'Phường Tân Phước', 20)
INSERT XAPHUONG VALUES(N'Xã Châu Pha', 20)
INSERT XAPHUONG VALUES(N'Xã Sông Xoài', 20)
INSERT XAPHUONG VALUES(N'Xã Tân Hải', 20)
INSERT XAPHUONG VALUES(N'Xã Tân Hòa', 20)
INSERT XAPHUONG VALUES(N'Xã Tóc Tiên', 20)

INSERT XAPHUONG VALUES(N'Thị trấn Gành Hào', 21)
INSERT XAPHUONG VALUES(N'Xã An Phúc', 21)
INSERT XAPHUONG VALUES(N'Xã An Trạch', 21)
INSERT XAPHUONG VALUES(N'Xã An Trạch A', 21)
INSERT XAPHUONG VALUES(N'Xã Điền Hải', 21)
INSERT XAPHUONG VALUES(N'Xã Định Thành', 21)
INSERT XAPHUONG VALUES(N'Xã Định Thành A', 21)
INSERT XAPHUONG VALUES(N'Xã Long Điền', 21)
INSERT XAPHUONG VALUES(N'Xã Long Điền Đông', 21)
INSERT XAPHUONG VALUES(N'Xã Long Điền Đông A', 21)
INSERT XAPHUONG VALUES(N'Xã Long Điền Tây', 21)

INSERT XAPHUONG VALUES(N'Thị trấn Hòa Bình', 22)
INSERT XAPHUONG VALUES(N'Xã Minh Diệu', 22)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Bình', 22)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hậu', 22)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hậu A', 22)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Mỹ A', 22)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Mỹ B', 22)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thịnh', 22)

INSERT XAPHUONG VALUES(N'Thị trấn Ngan Dừa', 23)
INSERT XAPHUONG VALUES(N'Xã Lộc Ninh', 23)
INSERT XAPHUONG VALUES(N'Xã Ninh Hòa', 23)
INSERT XAPHUONG VALUES(N'Xã Ninh Quới', 23)
INSERT XAPHUONG VALUES(N'Xã Ninh Quới A', 23)
INSERT XAPHUONG VALUES(N'Xã Ninh Thạnh Lợi', 23)
INSERT XAPHUONG VALUES(N'Xã Ninh Thạnh Lợi A', 23)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Lộc', 23)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Lộc A', 23)

INSERT XAPHUONG VALUES(N'Thị trấn Phước Long', 24)
INSERT XAPHUONG VALUES(N'Xã Hưng Phú', 24)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh Tây A', 24)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh Tây B', 24)
INSERT XAPHUONG VALUES(N'Xã Phước Long', 24)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Phú Đông', 24)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Phú Tây', 24)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thanh', 24)

INSERT XAPHUONG VALUES(N'Thị trấn Châu Hưng', 25)
INSERT XAPHUONG VALUES(N'Xã Châu Hưng A', 25)
INSERT XAPHUONG VALUES(N'Xã Châu Thới', 25)
INSERT XAPHUONG VALUES(N'Xã Hưng Hội', 25)
INSERT XAPHUONG VALUES(N'Xã Hưng Thành', 25)
INSERT XAPHUONG VALUES(N'Xã Long Thạnh', 25)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hưng', 25)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hưng A', 25)

INSERT XAPHUONG VALUES(N'Phường 1', 26)
INSERT XAPHUONG VALUES(N'Phường 2', 26)
INSERT XAPHUONG VALUES(N'Phường 3', 26)
INSERT XAPHUONG VALUES(N'Phường 5', 26)
INSERT XAPHUONG VALUES(N'Phường 7', 26)
INSERT XAPHUONG VALUES(N'Phường 8', 26)
INSERT XAPHUONG VALUES(N'Phường Nhà Mát', 26)
INSERT XAPHUONG VALUES(N'Xã Hiệp Thành', 26)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Trạch', 26)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Trạch Đông', 26)

INSERT XAPHUONG VALUES(N'Phường 01', 27)
INSERT XAPHUONG VALUES(N'Phường Hộ Phòng', 27)
INSERT XAPHUONG VALUES(N'Phường Láng Tròn', 27)
INSERT XAPHUONG VALUES(N'Xã Phong Tân', 27)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh', 27)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh A', 27)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh Đông', 27)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh Đông A', 27)
INSERT XAPHUONG VALUES(N'Xã Phong Thạnh Tây', 27)
INSERT XAPHUONG VALUES(N'Xã Tân Phong', 27)
INSERT XAPHUONG VALUES(N'Xã Tân Thạnh', 27)

INSERT XAPHUONG VALUES(N'Thị trấn Thắng', 28)
INSERT XAPHUONG VALUES(N'Xã Bắc Lý', 28)
INSERT XAPHUONG VALUES(N'Xã Châu Minh', 28)
INSERT XAPHUONG VALUES(N'Xã Đại Thành', 28)
INSERT XAPHUONG VALUES(N'Xã Danh Thắng', 28)
INSERT XAPHUONG VALUES(N'Xã Đoan Bái', 28)
INSERT XAPHUONG VALUES(N'Xã Đông Lỗ', 28)
INSERT XAPHUONG VALUES(N'Xã Đồng Tân', 28)
INSERT XAPHUONG VALUES(N'Xã Đức Thắng', 28)
INSERT XAPHUONG VALUES(N'Xã Hòa Sơn', 28)
INSERT XAPHUONG VALUES(N'Xã Hoàng An', 28)
INSERT XAPHUONG VALUES(N'Xã Hoàng Lương', 28)
INSERT XAPHUONG VALUES(N'Xã Hoàng Thanh', 28)
INSERT XAPHUONG VALUES(N'Xã Hoàng Vân', 28)
INSERT XAPHUONG VALUES(N'Xã Hợp Thịnh', 28)
INSERT XAPHUONG VALUES(N'Xã Hùng Sơn', 28)
INSERT XAPHUONG VALUES(N'Xã Hương Lâm', 28)
INSERT XAPHUONG VALUES(N'Xã Lương Phong', 28)
INSERT XAPHUONG VALUES(N'Xã Mai Đình', 28)
INSERT XAPHUONG VALUES(N'Xã Mai Trung', 28)
INSERT XAPHUONG VALUES(N'Xã Ngọc Sơn', 28)
INSERT XAPHUONG VALUES(N'Xã Quang Minh', 28)
INSERT XAPHUONG VALUES(N'Xã Thái Sơn', 28)
INSERT XAPHUONG VALUES(N'Xã Thanh Vân', 28)
INSERT XAPHUONG VALUES(N'Xã Thường Thắng', 28)
INSERT XAPHUONG VALUES(N'Xã Xuân Cẩm', 28)

INSERT XAPHUONG VALUES(N'Thị trấn Kép', 29)
INSERT XAPHUONG VALUES(N'Thị trấn Vôi', 29)
INSERT XAPHUONG VALUES(N'Xã An Hà', 29)
INSERT XAPHUONG VALUES(N'Xã Đại Lâm', 29)
INSERT XAPHUONG VALUES(N'Xã Đào Mỹ', 29)
INSERT XAPHUONG VALUES(N'Xã Dương Đức', 29)
INSERT XAPHUONG VALUES(N'Xã Hương Lạc', 29)
INSERT XAPHUONG VALUES(N'Xã Hương Sơn', 29)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hà', 29)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thái', 29)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Hòa', 29)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Hưng', 29)
INSERT XAPHUONG VALUES(N'Xã Phi Mô', 29)
INSERT XAPHUONG VALUES(N'Xã Quang Thịnh', 29)
INSERT XAPHUONG VALUES(N'Xã Tân Dĩnh', 29)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 29)
INSERT XAPHUONG VALUES(N'Xã Tân Thanh', 29)
INSERT XAPHUONG VALUES(N'Xã Tân Thịnh', 29)
INSERT XAPHUONG VALUES(N'Xã Thái Đào', 29)
INSERT XAPHUONG VALUES(N'Xã Tiên Lục', 29)
INSERT XAPHUONG VALUES(N'Xã Xuân Hương', 29)
INSERT XAPHUONG VALUES(N'Xã Xương Lâm', 29)
INSERT XAPHUONG VALUES(N'Xã Yên Mỹ', 29)

INSERT XAPHUONG VALUES(N'Thị trấn Đồi Ngô', 30)
INSERT XAPHUONG VALUES(N'Thị trấn Lục Nam', 30)
INSERT XAPHUONG VALUES(N'Xã Bắc Lũng', 30)
INSERT XAPHUONG VALUES(N'Xã Bảo Đài', 30)
INSERT XAPHUONG VALUES(N'Xã Bảo Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Bình Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Cẩm Lý', 30)
INSERT XAPHUONG VALUES(N'Xã Chu Điện', 30)
INSERT XAPHUONG VALUES(N'Xã Cương Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Đan Hội', 30)
INSERT XAPHUONG VALUES(N'Xã Đông Hưng', 30)
INSERT XAPHUONG VALUES(N'Xã Đông Phú', 30)
INSERT XAPHUONG VALUES(N'Xã Huyền Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Khám Lạng', 30)
INSERT XAPHUONG VALUES(N'Xã Lan Mẫu', 30)
INSERT XAPHUONG VALUES(N'Xã Lục Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Phương', 30)
INSERT XAPHUONG VALUES(N'Xã Phương Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Tam Dị', 30)
INSERT XAPHUONG VALUES(N'Xã Thanh Lâm', 30)
INSERT XAPHUONG VALUES(N'Xã Tiên Hưng', 30)
INSERT XAPHUONG VALUES(N'Xã Tiên Nha', 30)
INSERT XAPHUONG VALUES(N'Xã Trường Giang', 30)
INSERT XAPHUONG VALUES(N'Xã Trường Sơn', 30)
INSERT XAPHUONG VALUES(N'Xã Vô Tranh', 30)
INSERT XAPHUONG VALUES(N'Xã Vũ Xá', 30)
INSERT XAPHUONG VALUES(N'Xã Yên Sơn', 30)

INSERT XAPHUONG VALUES(N'Thị trấn Chũ', 31)
INSERT XAPHUONG VALUES(N'Xã Biển Động', 31)
INSERT XAPHUONG VALUES(N'Xã Biên Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Cấm Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Đèo Gia', 31)
INSERT XAPHUONG VALUES(N'Xã Đồng Cốc', 31)
INSERT XAPHUONG VALUES(N'Xã Giáp Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Hộ Đáp', 31)
INSERT XAPHUONG VALUES(N'Xã Hồng Giang', 31)
INSERT XAPHUONG VALUES(N'Xã Kiên Lao', 31)
INSERT XAPHUONG VALUES(N'Xã Kiên Thành', 31)
INSERT XAPHUONG VALUES(N'Xã Kim Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Mỹ An', 31)
INSERT XAPHUONG VALUES(N'Xã Nam Dương', 31)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Hồ', 31)
INSERT XAPHUONG VALUES(N'Xã Phì Điền', 31)
INSERT XAPHUONG VALUES(N'Xã Phong Minh', 31)
INSERT XAPHUONG VALUES(N'Xã Phong Vân', 31)
INSERT XAPHUONG VALUES(N'Xã Phú Nhuận', 31)
INSERT XAPHUONG VALUES(N'Xã Phượng Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Quý Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Sơn Hải', 31)
INSERT XAPHUONG VALUES(N'Xã Tân Hoa', 31)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 31)
INSERT XAPHUONG VALUES(N'Xã Tân Mộc', 31)
INSERT XAPHUONG VALUES(N'Xã Tân Quang', 31)
INSERT XAPHUONG VALUES(N'Xã Tân Sơn', 31)
INSERT XAPHUONG VALUES(N'Xã Thanh Hải', 31)
INSERT XAPHUONG VALUES(N'Xã Trù Hựu', 31)
INSERT XAPHUONG VALUES(N'Xã Xa Lý', 31)

INSERT XAPHUONG VALUES(N'Thị trấn An Châu', 32)
INSERT XAPHUONG VALUES(N'Thị Trấn Thanh Sơn', 32)
INSERT XAPHUONG VALUES(N'Xã An Bá', 32)
INSERT XAPHUONG VALUES(N'Xã An Châu', 32)
INSERT XAPHUONG VALUES(N'Xã An Lạc', 32)
INSERT XAPHUONG VALUES(N'Xã An Lập', 32)
INSERT XAPHUONG VALUES(N'Xã Bồng Am', 32)
INSERT XAPHUONG VALUES(N'Xã Cẩm Đàn', 32)
INSERT XAPHUONG VALUES(N'Xã Đại Sơn', 32)
INSERT XAPHUONG VALUES(N'Xã Dương Hưu', 32)
INSERT XAPHUONG VALUES(N'Xã Giáo Liêm', 32)
INSERT XAPHUONG VALUES(N'Xã Hữu Sản', 32)
INSERT XAPHUONG VALUES(N'Xã Lệ Viễn', 32)
INSERT XAPHUONG VALUES(N'Xã Long Sơn', 32)
INSERT XAPHUONG VALUES(N'Xã Phúc Thắng', 32)
INSERT XAPHUONG VALUES(N'Xã Quế Sơn', 32)
INSERT XAPHUONG VALUES(N'Xã Thạch Sơn', 32)
INSERT XAPHUONG VALUES(N'Xã Thanh Luận', 32)
INSERT XAPHUONG VALUES(N'Xã Tuấn Đạo', 32)
INSERT XAPHUONG VALUES(N'Xã Tuấn Mậu', 32)
INSERT XAPHUONG VALUES(N'Xã Vân Sơn', 32)
INSERT XAPHUONG VALUES(N'Xã Vĩnh An', 32)
INSERT XAPHUONG VALUES(N'Xã Yên Định', 32)

INSERT XAPHUONG VALUES(N'Thị trấn Cao Thượng', 33)
INSERT XAPHUONG VALUES(N'Thị trấn Nhã Nam', 33)
INSERT XAPHUONG VALUES(N'Xã An Dương', 33)
INSERT XAPHUONG VALUES(N'Xã Cao Thượng', 33)
INSERT XAPHUONG VALUES(N'Xã Cao Xá', 33)
INSERT XAPHUONG VALUES(N'Xã Đại Hóa', 33)
INSERT XAPHUONG VALUES(N'Xã Hợp Đức', 33)
INSERT XAPHUONG VALUES(N'Xã Lam Cốt', 33)
INSERT XAPHUONG VALUES(N'Xã Lan Giới', 33)
INSERT XAPHUONG VALUES(N'Xã Liên Chung', 33)
INSERT XAPHUONG VALUES(N'Xã Liên Sơn', 33)
INSERT XAPHUONG VALUES(N'Xã Ngọc Châu', 33)
INSERT XAPHUONG VALUES(N'Xã Ngọc Lý', 33)
INSERT XAPHUONG VALUES(N'Xã Ngọc Thiện', 33)
INSERT XAPHUONG VALUES(N'Xã Ngọc Vân', 33)
INSERT XAPHUONG VALUES(N'Xã Nhã Nam', 33)
INSERT XAPHUONG VALUES(N'Xã Phúc Hòa', 33)
INSERT XAPHUONG VALUES(N'Xã Phúc Sơn', 33)
INSERT XAPHUONG VALUES(N'Xã Quang Tiến', 33)
INSERT XAPHUONG VALUES(N'Xã Quế Nham', 33)
INSERT XAPHUONG VALUES(N'Xã Song Vân', 33)
INSERT XAPHUONG VALUES(N'Xã Tân Trung', 33)
INSERT XAPHUONG VALUES(N'Xã Việt Lập', 33)
INSERT XAPHUONG VALUES(N'Xã Việt Ngọc', 33)

INSERT XAPHUONG VALUES(N'Thị trấn Bích Động', 34)
INSERT XAPHUONG VALUES(N'Thị trấn Nếnh', 34)
INSERT XAPHUONG VALUES(N'Xã Bích Sơn', 34)
INSERT XAPHUONG VALUES(N'Xã Hoàng Ninh', 34)
INSERT XAPHUONG VALUES(N'Xã Hồng Thái', 34)
INSERT XAPHUONG VALUES(N'Xã Hương Mai', 34)
INSERT XAPHUONG VALUES(N'Xã Minh Đức', 34)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Trung', 34)
INSERT XAPHUONG VALUES(N'Xã Ninh Sơn', 34)
INSERT XAPHUONG VALUES(N'Xã Quang Châu', 34)
INSERT XAPHUONG VALUES(N'Xã Quảng Minh', 34)
INSERT XAPHUONG VALUES(N'Xã Tăng Tiến', 34)
INSERT XAPHUONG VALUES(N'Xã Thượng Lan', 34)
INSERT XAPHUONG VALUES(N'Xã Tiên Sơn', 34)
INSERT XAPHUONG VALUES(N'Xã Trung Sơn', 34)
INSERT XAPHUONG VALUES(N'Xã Tự Lạn', 34)
INSERT XAPHUONG VALUES(N'Xã Vân Hà', 34)
INSERT XAPHUONG VALUES(N'Xã Vân Trung', 34)
INSERT XAPHUONG VALUES(N'Xã Việt Tiến', 34)

INSERT XAPHUONG VALUES(N'Thị trấn Neo', 35)
INSERT XAPHUONG VALUES(N'Thị trấn Nham Biền', 35)
INSERT XAPHUONG VALUES(N'Thị Trấn Tân Dân', 35)
INSERT XAPHUONG VALUES(N'Xã Cảnh Thụy', 35)
INSERT XAPHUONG VALUES(N'Xã Đồng Phúc', 35)
INSERT XAPHUONG VALUES(N'Xã Đồng Việt', 35)
INSERT XAPHUONG VALUES(N'Xã Đức Giang', 35)
INSERT XAPHUONG VALUES(N'Xã Hương Gián', 35)
INSERT XAPHUONG VALUES(N'Xã Lãng Sơn', 35)
INSERT XAPHUONG VALUES(N'Xã Lão Hộ', 35)
INSERT XAPHUONG VALUES(N'Xã Nham Sơn', 35)
INSERT XAPHUONG VALUES(N'Xã Nội Hoàng', 35)
INSERT XAPHUONG VALUES(N'Xã Quỳnh Sơn', 35)
INSERT XAPHUONG VALUES(N'Xã Tân An', 35)
INSERT XAPHUONG VALUES(N'Xã Tân Liễu', 35)
INSERT XAPHUONG VALUES(N'Xã Thắng Cương', 35)
INSERT XAPHUONG VALUES(N'Xã Tiến Dũng', 35)
INSERT XAPHUONG VALUES(N'Xã Tiền Phong', 35)
INSERT XAPHUONG VALUES(N'Xã Trí Yên', 35)
INSERT XAPHUONG VALUES(N'Xã Tư Mại', 35)
INSERT XAPHUONG VALUES(N'Xã Xuân Phú', 35)
INSERT XAPHUONG VALUES(N'Xã Yên Lư', 35)

INSERT XAPHUONG VALUES(N'Đồng Tâm', 36)
INSERT XAPHUONG VALUES(N'Thị trấn Bố Hạ', 36)
INSERT XAPHUONG VALUES(N'Thị Trấn Phồn Xương', 36)
INSERT XAPHUONG VALUES(N'Xã An Thượng', 36)
INSERT XAPHUONG VALUES(N'Xã Bố Hạ', 36)
INSERT XAPHUONG VALUES(N'Xã Canh Nậu', 36)
INSERT XAPHUONG VALUES(N'Xã Đồng Hưu', 36)
INSERT XAPHUONG VALUES(N'Xã Đồng Kỳ', 36)
INSERT XAPHUONG VALUES(N'Xã Đồng Lạc', 36)
INSERT XAPHUONG VALUES(N'Xã Đông Sơn', 36)
INSERT XAPHUONG VALUES(N'Xã Đồng Tiến', 36)
INSERT XAPHUONG VALUES(N'Xã Đồng Vương', 36)
INSERT XAPHUONG VALUES(N'Xã Hồng Kỳ', 36)
INSERT XAPHUONG VALUES(N'Xã Hương Vĩ', 36)
INSERT XAPHUONG VALUES(N'Xã Tam Hiệp', 36)
INSERT XAPHUONG VALUES(N'Xã Tam Tiến', 36)
INSERT XAPHUONG VALUES(N'Xã Tân Hiệp', 36)
INSERT XAPHUONG VALUES(N'Xã Tân Sỏi', 36)
INSERT XAPHUONG VALUES(N'Xã Tiến Thắng', 36)
INSERT XAPHUONG VALUES(N'Xã Xuân Lương', 36)

INSERT XAPHUONG VALUES(N'Phường Hoàng Văn Thụ', 37)
INSERT XAPHUONG VALUES(N'Phường Lê Lợi', 37)
INSERT XAPHUONG VALUES(N'Phường Mỹ Độ', 37)
INSERT XAPHUONG VALUES(N'Phường Ngô Quyền', 37)
INSERT XAPHUONG VALUES(N'Phường Thọ Xương', 37)
INSERT XAPHUONG VALUES(N'Phường Trần Nguyên Hãn', 37)
INSERT XAPHUONG VALUES(N'Phường Trần Phú', 37)
INSERT XAPHUONG VALUES(N'Xã Đa Mai', 37)
INSERT XAPHUONG VALUES(N'Xã Dĩnh Kế', 37)
INSERT XAPHUONG VALUES(N'Xã Dĩnh Trì', 37)
INSERT XAPHUONG VALUES(N'Xã Đồng Sơn', 37)
INSERT XAPHUONG VALUES(N'Xã Song Khê', 37)
INSERT XAPHUONG VALUES(N'Xã Song Mai', 37)
INSERT XAPHUONG VALUES(N'Xã Tân Mỹ', 37)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 37)
INSERT XAPHUONG VALUES(N'Xã Xương Giang', 37)

INSERT XAPHUONG VALUES(N'Thị trấn Chợ Rã', 38)
INSERT XAPHUONG VALUES(N'Xã Bành Trạch', 38)
INSERT XAPHUONG VALUES(N'Xã Cao Thượng', 38)
INSERT XAPHUONG VALUES(N'Xã Cao Trĩ', 38)
INSERT XAPHUONG VALUES(N'Xã Chu Hương', 38)
INSERT XAPHUONG VALUES(N'Xã Địa Linh', 38)
INSERT XAPHUONG VALUES(N'Xã Đồng Phúc', 38)
INSERT XAPHUONG VALUES(N'Xã Hà Hiệu', 38)
INSERT XAPHUONG VALUES(N'Xã Hoàng Trĩ', 38)
INSERT XAPHUONG VALUES(N'Xã Khang Ninh', 38)
INSERT XAPHUONG VALUES(N'Xã Mỹ Phương', 38)
INSERT XAPHUONG VALUES(N'Xã Nam Mẫu', 38)
INSERT XAPHUONG VALUES(N'Xã Phúc Lộc', 38)
INSERT XAPHUONG VALUES(N'Xã Quảng Khê', 38)
INSERT XAPHUONG VALUES(N'Xã Thượng Giáo', 38)
INSERT XAPHUONG VALUES(N'Xã Yến Dương', 38)

INSERT XAPHUONG VALUES(N'Thị trấn Phủ Thông', 39)
INSERT XAPHUONG VALUES(N'Xã Cẩm Giàng', 39)
INSERT XAPHUONG VALUES(N'Xã Cao Sơn', 39)
INSERT XAPHUONG VALUES(N'Xã Đôn Phong', 39)
INSERT XAPHUONG VALUES(N'Xã Dương Phong', 39)
INSERT XAPHUONG VALUES(N'Xã Hà Vị', 39)
INSERT XAPHUONG VALUES(N'Xã Lục Bình', 39)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thanh', 39)
INSERT XAPHUONG VALUES(N'Xã Nguyên Phúc', 39)
INSERT XAPHUONG VALUES(N'Xã Phương Linh', 39)
INSERT XAPHUONG VALUES(N'Xã Quân Hà', 39)
INSERT XAPHUONG VALUES(N'Xã Quang Thuận', 39)
INSERT XAPHUONG VALUES(N'Xã Sĩ Bình', 39)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 39)
INSERT XAPHUONG VALUES(N'Xã Vi Hương', 39)
INSERT XAPHUONG VALUES(N'Xã Vũ Muộn', 39)

INSERT XAPHUONG VALUES(N'Thị trấn Bằng Lũng', 40)
INSERT XAPHUONG VALUES(N'Xã Bản Thi', 40)
INSERT XAPHUONG VALUES(N'Xã Bằng Lãng', 40)
INSERT XAPHUONG VALUES(N'Xã Bằng Phúc', 40)
INSERT XAPHUONG VALUES(N'Xã Bình Trung', 40)
INSERT XAPHUONG VALUES(N'Xã Đại Sảo', 40)
INSERT XAPHUONG VALUES(N'Xã Đồng Lạc', 40)
INSERT XAPHUONG VALUES(N'Xã Đồng Thắng', 40)
INSERT XAPHUONG VALUES(N'Xã Đông Viên', 40)
INSERT XAPHUONG VALUES(N'Xã Lương Bằng', 40)
INSERT XAPHUONG VALUES(N'Xã Nam Cường', 40)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Tá', 40)
INSERT XAPHUONG VALUES(N'Xã Ngọc Phái', 40)
INSERT XAPHUONG VALUES(N'Xã Phong Huân', 40)
INSERT XAPHUONG VALUES(N'Xã Phương Viên', 40)
INSERT XAPHUONG VALUES(N'Xã Quảng Bạch', 40)
INSERT XAPHUONG VALUES(N'Xã Rã Bản', 40)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 40)
INSERT XAPHUONG VALUES(N'Xã Xuân Lạc', 40)
INSERT XAPHUONG VALUES(N'Xã Yên Mỹ', 40)
INSERT XAPHUONG VALUES(N'Xã Yên Nhuận', 40)
INSERT XAPHUONG VALUES(N'Xã Yên Phong', 40)
INSERT XAPHUONG VALUES(N'Xã Yên Thịnh', 40)
INSERT XAPHUONG VALUES(N'Xã Yên Thượng', 40)

INSERT XAPHUONG VALUES(N'Thị trấn Chợ Mới', 41)
INSERT XAPHUONG VALUES(N'Thị trấn Đồng Tâm', 41)
INSERT XAPHUONG VALUES(N'Xã Bình Văn', 41)
INSERT XAPHUONG VALUES(N'Xã Cao Kỳ', 41)
INSERT XAPHUONG VALUES(N'Xã Hoà Mục', 41)
INSERT XAPHUONG VALUES(N'Xã Mai Lạp', 41)
INSERT XAPHUONG VALUES(N'Xã Như Cố', 41)
INSERT XAPHUONG VALUES(N'Xã Nông Hạ', 41)
INSERT XAPHUONG VALUES(N'Xã Nông Thịnh', 41)
INSERT XAPHUONG VALUES(N'Xã Quảng Chu', 41)
INSERT XAPHUONG VALUES(N'Xã Tân Sơn', 41)
INSERT XAPHUONG VALUES(N'Xã Thanh Bình', 41)
INSERT XAPHUONG VALUES(N'Xã Thanh Mai', 41)
INSERT XAPHUONG VALUES(N'Xã Thanh Vận', 41)
INSERT XAPHUONG VALUES(N'Xã Yên Cư', 41)
INSERT XAPHUONG VALUES(N'Xã Yên Đĩnh', 41)
INSERT XAPHUONG VALUES(N'Xã Yên Hân', 41)

INSERT XAPHUONG VALUES(N'Thị trấn Yến Lạc', 42)
INSERT XAPHUONG VALUES(N'Xã Côn Minh', 42)
INSERT XAPHUONG VALUES(N'Xã Cư Lễ', 42)
INSERT XAPHUONG VALUES(N'Xã Cường Lợi', 42)
INSERT XAPHUONG VALUES(N'Xã Đổng Xá', 42)
INSERT XAPHUONG VALUES(N'Xã Dương Sơn', 42)
INSERT XAPHUONG VALUES(N'Xã Hữu Thác', 42)
INSERT XAPHUONG VALUES(N'Xã Kim Hỷ', 42)
INSERT XAPHUONG VALUES(N'Xã Kim Lư', 42)
INSERT XAPHUONG VALUES(N'Xã Lam Sơn', 42)
INSERT XAPHUONG VALUES(N'Xã Lạng San', 42)
INSERT XAPHUONG VALUES(N'Xã Liêm Thuỷ', 42)
INSERT XAPHUONG VALUES(N'Xã Lương Hạ', 42)
INSERT XAPHUONG VALUES(N'Xã Lương Thành', 42)
INSERT XAPHUONG VALUES(N'Xã Lương Thượng', 42)
INSERT XAPHUONG VALUES(N'Xã Quang Phong', 42)
INSERT XAPHUONG VALUES(N'Xã Trần Phú', 42)
INSERT XAPHUONG VALUES(N'Xã Văn Học', 42)
INSERT XAPHUONG VALUES(N'Xã Văn Lang', 42)
INSERT XAPHUONG VALUES(N'Xã Văn Minh', 42)
INSERT XAPHUONG VALUES(N'Xã Văn Vũ', 42)
INSERT XAPHUONG VALUES(N'Xã Vũ Loan', 42)
INSERT XAPHUONG VALUES(N'Xã Xuân Dương', 42)

INSERT XAPHUONG VALUES(N'Thị trấn Nà Phặc', 43)
INSERT XAPHUONG VALUES(N'Xã Bằng Vân', 43)
INSERT XAPHUONG VALUES(N'Xã Cốc Đán', 43)
INSERT XAPHUONG VALUES(N'Xã Đức Vân', 43)
INSERT XAPHUONG VALUES(N'Xã Hiệp Lực', 43)
INSERT XAPHUONG VALUES(N'Xã Lãng Ngâm', 43)
INSERT XAPHUONG VALUES(N'Xã Thuần Mang', 43)
INSERT XAPHUONG VALUES(N'Xã Thượng ân', 43)
INSERT XAPHUONG VALUES(N'Xã Thượng Quan', 43)
INSERT XAPHUONG VALUES(N'Xã Trung Hoà', 43)
INSERT XAPHUONG VALUES(N'Xã Vân Tùng', 43)

INSERT XAPHUONG VALUES(N'Xã An Thắng', 44)
INSERT XAPHUONG VALUES(N'Xã Bằng Thành', 44)
INSERT XAPHUONG VALUES(N'Xã Bộc Bố', 44)
INSERT XAPHUONG VALUES(N'Xã Cao Tân', 44)
INSERT XAPHUONG VALUES(N'Xã Cổ Linh', 44)
INSERT XAPHUONG VALUES(N'Xã Công Bằng', 44)
INSERT XAPHUONG VALUES(N'Xã Giáo Hiệu', 44)
INSERT XAPHUONG VALUES(N'Xã Nghiên Loan', 44)
INSERT XAPHUONG VALUES(N'Xã Nhạn Môn', 44)
INSERT XAPHUONG VALUES(N'Xã Xuân La', 44)

INSERT XAPHUONG VALUES(N'Phường Đức Xuân', 45)
INSERT XAPHUONG VALUES(N'Phường Phùng Chí Kiên', 45)
INSERT XAPHUONG VALUES(N'Phường Sông Cầu', 45)
INSERT XAPHUONG VALUES(N'Phường. Nguyễn Thị Minh Khai', 45)
INSERT XAPHUONG VALUES(N'Xã Dương Quang', 45)
INSERT XAPHUONG VALUES(N'Xã Huyền Tụng', 45)
INSERT XAPHUONG VALUES(N'Xã Nông Thượng', 45)
INSERT XAPHUONG VALUES(N'Xã Xuất Hoá', 45)

INSERT XAPHUONG VALUES(N'Thị trấn Gia Bình', 46)
INSERT XAPHUONG VALUES(N'Xã Bình Dương', 46)
INSERT XAPHUONG VALUES(N'Xã Cao Đức', 46)
INSERT XAPHUONG VALUES(N'Xã Đại Bái', 46)
INSERT XAPHUONG VALUES(N'Xã Đại Lai', 46)
INSERT XAPHUONG VALUES(N'Xã Đông Cứu', 46)
INSERT XAPHUONG VALUES(N'Xã Giang Sơn', 46)
INSERT XAPHUONG VALUES(N'Xã Lãng Ngâm', 46)
INSERT XAPHUONG VALUES(N'Xã Nhân Thắng', 46)
INSERT XAPHUONG VALUES(N'Xã Quỳnh Phú', 46)
INSERT XAPHUONG VALUES(N'Xã Song Giang', 46)
INSERT XAPHUONG VALUES(N'Xã Thái Bảo', 46)
INSERT XAPHUONG VALUES(N'Xã Vạn Ninh', 46)
INSERT XAPHUONG VALUES(N'Xã Xuân Lai', 46)

INSERT XAPHUONG VALUES(N'Thị trấn Thứa', 47)
INSERT XAPHUONG VALUES(N'Xã An Thịnh', 47)
INSERT XAPHUONG VALUES(N'Xã Bình Định', 47)
INSERT XAPHUONG VALUES(N'Xã Lai Hạ', 47)
INSERT XAPHUONG VALUES(N'Xã Lâm Thao', 47)
INSERT XAPHUONG VALUES(N'Xã Minh Tân', 47)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hương', 47)
INSERT XAPHUONG VALUES(N'Xã Phú Hòa', 47)
INSERT XAPHUONG VALUES(N'Xã Phú Lương', 47)
INSERT XAPHUONG VALUES(N'Xã Quảng Phú', 47)
INSERT XAPHUONG VALUES(N'Xã Tân Lãng', 47)
INSERT XAPHUONG VALUES(N'Xã Trung Chính', 47)
INSERT XAPHUONG VALUES(N'Xã Trung Kênh', 47)
INSERT XAPHUONG VALUES(N'Xã Trừng Xá', 47)

INSERT XAPHUONG VALUES(N'Thị trấn Phố Mới', 48)
INSERT XAPHUONG VALUES(N'Xã Bằng An', 48)
INSERT XAPHUONG VALUES(N'Xã Bồng Lai', 48)
INSERT XAPHUONG VALUES(N'Xã Cách Bi', 48)
INSERT XAPHUONG VALUES(N'Xã Châu Phong', 48)
INSERT XAPHUONG VALUES(N'Xã Chi Lăng', 48)
INSERT XAPHUONG VALUES(N'Xã Đại Xuân', 48)
INSERT XAPHUONG VALUES(N'Xã Đào Viên', 48)
INSERT XAPHUONG VALUES(N'Xã Đức Long', 48)
INSERT XAPHUONG VALUES(N'Xã Hán Quảng', 48)
INSERT XAPHUONG VALUES(N'Xã Mộ Đạo', 48)
INSERT XAPHUONG VALUES(N'Xã Ngọc Xá', 48)
INSERT XAPHUONG VALUES(N'Xã Nhân Hòa', 48)
INSERT XAPHUONG VALUES(N'Xã Phù Lãng', 48)
INSERT XAPHUONG VALUES(N'Xã Phù Lương', 48)
INSERT XAPHUONG VALUES(N'Xã Phương Liễu', 48)
INSERT XAPHUONG VALUES(N'Xã Phượng Mao', 48)
INSERT XAPHUONG VALUES(N'Xã Quế Tân', 48)
INSERT XAPHUONG VALUES(N'Xã Việt Hùng', 48)
INSERT XAPHUONG VALUES(N'Xã Việt Thống', 48)

INSERT XAPHUONG VALUES(N'Thị trấn Hồ', 49)
INSERT XAPHUONG VALUES(N'Xã An Bình', 49)
INSERT XAPHUONG VALUES(N'Xã Đại Đồng Thành', 49)
INSERT XAPHUONG VALUES(N'Xã Đình Tổ', 49)
INSERT XAPHUONG VALUES(N'Xã Gia Đông', 49)
INSERT XAPHUONG VALUES(N'Xã Hà Mãn', 49)
INSERT XAPHUONG VALUES(N'Xã Hoài Thượng', 49)
INSERT XAPHUONG VALUES(N'Xã Mão Điền', 49)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Đạo', 49)
INSERT XAPHUONG VALUES(N'Xã Ngũ Thái', 49)
INSERT XAPHUONG VALUES(N'Xã Nguyệt Đức', 49)
INSERT XAPHUONG VALUES(N'Xã Ninh Xá', 49)
INSERT XAPHUONG VALUES(N'Xã Song Hồ', 49)
INSERT XAPHUONG VALUES(N'Xã Song Liễu', 49)
INSERT XAPHUONG VALUES(N'Xã Thanh Khương', 49)
INSERT XAPHUONG VALUES(N'Xã Trạm Lộ', 49)
INSERT XAPHUONG VALUES(N'Xã Trí Quả', 49)
INSERT XAPHUONG VALUES(N'Xã Xuân Lâm', 49)

INSERT XAPHUONG VALUES(N'Thị trấn Lim', 50)
INSERT XAPHUONG VALUES(N'Xã Cảnh Hưng', 50)
INSERT XAPHUONG VALUES(N'Xã Đại Đồng', 50)
INSERT XAPHUONG VALUES(N'Xã Hiên Vân', 50)
INSERT XAPHUONG VALUES(N'Xã Hoàn Sơn', 50)
INSERT XAPHUONG VALUES(N'Xã Lạc Vệ', 50)
INSERT XAPHUONG VALUES(N'Xã Liên Bão', 50)
INSERT XAPHUONG VALUES(N'Xã Minh Đạo', 50)
INSERT XAPHUONG VALUES(N'Xã Nội Duệ', 50)
INSERT XAPHUONG VALUES(N'Xã Phật Tích', 50)
INSERT XAPHUONG VALUES(N'Xã Phú Lâm', 50)
INSERT XAPHUONG VALUES(N'Xã Tân Chi', 50)
INSERT XAPHUONG VALUES(N'Xã Tri Phương', 50)
INSERT XAPHUONG VALUES(N'Xã Việt Đoàn', 50)

INSERT XAPHUONG VALUES(N'Thị trấn Chờ', 51)
INSERT XAPHUONG VALUES(N'Xã Đông Phong', 51)
INSERT XAPHUONG VALUES(N'Xã Đông Thọ', 51)
INSERT XAPHUONG VALUES(N'Xã Đông Tiến', 51)
INSERT XAPHUONG VALUES(N'Xã Dũng Liệt', 51)
INSERT XAPHUONG VALUES(N'Xã Hòa Tiến', 51)
INSERT XAPHUONG VALUES(N'Xã Long Châu', 51)
INSERT XAPHUONG VALUES(N'Xã Tam Đa', 51)
INSERT XAPHUONG VALUES(N'Xã Tam Giang', 51)
INSERT XAPHUONG VALUES(N'Xã Thụy Hòa', 51)
INSERT XAPHUONG VALUES(N'Xã Trung Nghĩa', 51)
INSERT XAPHUONG VALUES(N'Xã Văn Môn', 51)
INSERT XAPHUONG VALUES(N'Xã Yên Phụ', 51)
INSERT XAPHUONG VALUES(N'Xã Yên Trung', 51)

INSERT XAPHUONG VALUES(N'Phường Đại Phúc', 52)
INSERT XAPHUONG VALUES(N'Phường Đáp Cầu', 52)
INSERT XAPHUONG VALUES(N'Phường Kim Chân', 52)
INSERT XAPHUONG VALUES(N'Phường Kinh Bắc', 52)
INSERT XAPHUONG VALUES(N'Phường Ninh Xá', 52)
INSERT XAPHUONG VALUES(N'Phường Phong Khê', 52)
INSERT XAPHUONG VALUES(N'Phường Suối Hoa', 52)
INSERT XAPHUONG VALUES(N'Phường Thị Cầu', 52)
INSERT XAPHUONG VALUES(N'Phường Tiền An', 52)
INSERT XAPHUONG VALUES(N'Phường Vệ An', 52)
INSERT XAPHUONG VALUES(N'Phường Võ Cường', 52)
INSERT XAPHUONG VALUES(N'Phường Vũ Ninh', 52)
INSERT XAPHUONG VALUES(N'Xã Hạp Lĩnh', 52)
INSERT XAPHUONG VALUES(N'Xã Hòa Long', 52)
INSERT XAPHUONG VALUES(N'Xã Khắc Niệm', 52)
INSERT XAPHUONG VALUES(N'Xã Khúc Xuyên', 52)
INSERT XAPHUONG VALUES(N'Xã Nam Sơn', 52)
INSERT XAPHUONG VALUES(N'Xã Vạn An', 52)
INSERT XAPHUONG VALUES(N'Xã Vân Dương', 52)

INSERT XAPHUONG VALUES(N'Phường Châu Khê', 53)
INSERT XAPHUONG VALUES(N'Phường Đình Bảng', 53)
INSERT XAPHUONG VALUES(N'Phường Đồng Kỵ', 53)
INSERT XAPHUONG VALUES(N'Phường Đông Ngàn', 53)
INSERT XAPHUONG VALUES(N'Phường Đồng Nguyên', 53)
INSERT XAPHUONG VALUES(N'Phường Tân Hồng', 53)
INSERT XAPHUONG VALUES(N'Phường Trang Hạ', 53)
INSERT XAPHUONG VALUES(N'Xã Hương Mạc', 53)
INSERT XAPHUONG VALUES(N'Xã Phù Chẩn', 53)
INSERT XAPHUONG VALUES(N'Xã Phù Khê', 53)
INSERT XAPHUONG VALUES(N'Xã Tam Sơn', 53)
INSERT XAPHUONG VALUES(N'Xã Tương Giang', 53)

INSERT XAPHUONG VALUES(N'Thị trấn Ba Tri', 54)
INSERT XAPHUONG VALUES(N'Xã An Bình Tây', 54)
INSERT XAPHUONG VALUES(N'Xã An Đức', 54)
INSERT XAPHUONG VALUES(N'Xã An Hiệp', 54)
INSERT XAPHUONG VALUES(N'Xã An Hòa Tây', 54)
INSERT XAPHUONG VALUES(N'Xã An Ngãi Tây', 54)
INSERT XAPHUONG VALUES(N'Xã An Ngãi Trung', 54)
INSERT XAPHUONG VALUES(N'Xã An Phú Trung', 54)
INSERT XAPHUONG VALUES(N'Xã An Thủy', 54)
INSERT XAPHUONG VALUES(N'Xã Bảo Thạnh', 54)
INSERT XAPHUONG VALUES(N'Xã Bảo Thuận', 54)
INSERT XAPHUONG VALUES(N'Xã Mỹ Chánh', 54)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hòa', 54)
INSERT XAPHUONG VALUES(N'Xã Mỹ Nhơn', 54)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thạnh', 54)
INSERT XAPHUONG VALUES(N'Xã Phú Lễ', 54)
INSERT XAPHUONG VALUES(N'Xã Phú Ngãi', 54)
INSERT XAPHUONG VALUES(N'Xã Phước Ngãi', 54)
INSERT XAPHUONG VALUES(N'Xã Phước Tuy', 54)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 54)
INSERT XAPHUONG VALUES(N'Xã Tân Mỹ', 54)
INSERT XAPHUONG VALUES(N'Xã Tân Thủy', 54)
INSERT XAPHUONG VALUES(N'Xã Tân Xuân', 54)
INSERT XAPHUONG VALUES(N'Xã Vĩnh An', 54)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hòa', 54)

INSERT XAPHUONG VALUES(N'Thị trấn Bình Đại', 55)
INSERT XAPHUONG VALUES(N'Xã Bình Thắng', 55)
INSERT XAPHUONG VALUES(N'Xã Bình Thới', 55)
INSERT XAPHUONG VALUES(N'Xã Châu Hưng', 55)
INSERT XAPHUONG VALUES(N'Xã Đại Hòa Lộc', 55)
INSERT XAPHUONG VALUES(N'Xã Định Trung', 55)
INSERT XAPHUONG VALUES(N'Xã Lộc Thuận', 55)
INSERT XAPHUONG VALUES(N'Xã Long Định', 55)
INSERT XAPHUONG VALUES(N'Xã Long Hòa', 55)
INSERT XAPHUONG VALUES(N'Xã Phú Long', 55)
INSERT XAPHUONG VALUES(N'Xã Phú Thuận', 55)
INSERT XAPHUONG VALUES(N'Xã Phú Vang', 55)
INSERT XAPHUONG VALUES(N'Xã Tam Hiệp', 55)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phước', 55)
INSERT XAPHUONG VALUES(N'Xã Thạnh Trị', 55)
INSERT XAPHUONG VALUES(N'Xã Thới Lai', 55)
INSERT XAPHUONG VALUES(N'Xã Thới Thuận', 55)
INSERT XAPHUONG VALUES(N'Xã Thừa Đức', 55)
INSERT XAPHUONG VALUES(N'Xã Vang Quới Đông', 55)
INSERT XAPHUONG VALUES(N'Xã Vang Quới Tây', 55)

INSERT XAPHUONG VALUES(N'Thị trấn Châu Thành', 56)
INSERT XAPHUONG VALUES(N'Xã An Hiệp', 56)
INSERT XAPHUONG VALUES(N'Xã An Hóa', 56)
INSERT XAPHUONG VALUES(N'Xã An Khánh', 56)
INSERT XAPHUONG VALUES(N'Xã An Phước', 56)
INSERT XAPHUONG VALUES(N'Xã Giao Hòa', 56)
INSERT XAPHUONG VALUES(N'Xã Giao Long', 56)
INSERT XAPHUONG VALUES(N'Xã Hữu Định', 56)
INSERT XAPHUONG VALUES(N'Xã Phú An Hòa', 56)
INSERT XAPHUONG VALUES(N'Xã Phú Đức', 56)
INSERT XAPHUONG VALUES(N'Xã Phú Túc', 56)
INSERT XAPHUONG VALUES(N'Xã Phước Thạnh', 56)
INSERT XAPHUONG VALUES(N'Xã Qưới Sơn', 56)
INSERT XAPHUONG VALUES(N'Xã Quới Thành', 56)
INSERT XAPHUONG VALUES(N'Xã Sơn Hòa', 56)
INSERT XAPHUONG VALUES(N'Xã Tam Phước', 56)
INSERT XAPHUONG VALUES(N'Xã Tân Phú', 56)
INSERT XAPHUONG VALUES(N'Xã Tân Thạch', 56)
INSERT XAPHUONG VALUES(N'Xã Thành Triệu', 56)
INSERT XAPHUONG VALUES(N'Xã Tiên Long', 56)
INSERT XAPHUONG VALUES(N'Xã Tiên Thủy', 56)
INSERT XAPHUONG VALUES(N'Xã Tường Đa', 56)

INSERT XAPHUONG VALUES(N'Thị trấn Chợ Lách', 57)
INSERT XAPHUONG VALUES(N'Xã Hòa Nghĩa', 57)
INSERT XAPHUONG VALUES(N'Xã Hưng Khánh Trung B', 57)
INSERT XAPHUONG VALUES(N'Xã Long Thới', 57)
INSERT XAPHUONG VALUES(N'Xã Phú Phụng', 57)
INSERT XAPHUONG VALUES(N'Xã Phú Sơn', 57)
INSERT XAPHUONG VALUES(N'Xã Sơn Định', 57)
INSERT XAPHUONG VALUES(N'Xã Tân Thiềng', 57)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Bình', 57)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hòa', 57)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thành', 57)

INSERT XAPHUONG VALUES(N'Thị trấn Giồng Trôm', 58)
INSERT XAPHUONG VALUES(N'Xã Bình Hoà', 58)
INSERT XAPHUONG VALUES(N'Xã Bình Thành', 58)
INSERT XAPHUONG VALUES(N'Xã Châu Bình', 58)
INSERT XAPHUONG VALUES(N'Xã Châu Hòa', 58)
INSERT XAPHUONG VALUES(N'Xã Hưng Lễ', 58)
INSERT XAPHUONG VALUES(N'Xã Hưng Nhượng', 58)
INSERT XAPHUONG VALUES(N'Xã Hưng Phong', 58)
INSERT XAPHUONG VALUES(N'Xã Long Mỹ', 58)
INSERT XAPHUONG VALUES(N'Xã Lương Hòa', 58)
INSERT XAPHUONG VALUES(N'Xã Lương Phú', 58)
INSERT XAPHUONG VALUES(N'Xã Lương Quới', 58)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thạnh', 58)
INSERT XAPHUONG VALUES(N'Xã Phong Mỹ', 58)
INSERT XAPHUONG VALUES(N'Xã Phong Nẫm', 58)
INSERT XAPHUONG VALUES(N'Xã Phước Long', 58)
INSERT XAPHUONG VALUES(N'Xã Sơn Phú', 58)
INSERT XAPHUONG VALUES(N'Xã Tân Hào', 58)
INSERT XAPHUONG VALUES(N'Xã Tân Lợi Thạnh', 58)
INSERT XAPHUONG VALUES(N'Xã Tân Thanh', 58)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phú Đông', 58)
INSERT XAPHUONG VALUES(N'Xã Thuận Điền', 58)

INSERT XAPHUONG VALUES(N'Xã Hòa Lộc', 59)
INSERT XAPHUONG VALUES(N'Xã Hưng Khánh Trung A', 59)
INSERT XAPHUONG VALUES(N'Xã Khánh Thạnh Tân', 59)
INSERT XAPHUONG VALUES(N'Xã Nhuận Phú Tân', 59)
INSERT XAPHUONG VALUES(N'Xã Phú Mỹ', 59)
INSERT XAPHUONG VALUES(N'Xã Phước Mỹ Trung', 59)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 59)
INSERT XAPHUONG VALUES(N'Xã Tân Phú Tây', 59)
INSERT XAPHUONG VALUES(N'Xã Tân Thành Bình', 59)
INSERT XAPHUONG VALUES(N'Xã Tân Thanh Tây', 59)
INSERT XAPHUONG VALUES(N'Xã Thành An', 59)
INSERT XAPHUONG VALUES(N'Xã Thạnh Ngãi', 59)
INSERT XAPHUONG VALUES(N'Xã Thanh Tân', 59)

INSERT XAPHUONG VALUES(N'Thành Thới A', 60)
INSERT XAPHUONG VALUES(N'Thị trấn Mỏ Cày', 60)
INSERT XAPHUONG VALUES(N'Xã An Định', 60)
INSERT XAPHUONG VALUES(N'Xã An Thạnh', 60)
INSERT XAPHUONG VALUES(N'Xã An Thới', 60)
INSERT XAPHUONG VALUES(N'Xã Bình Khánh', 60)
INSERT XAPHUONG VALUES(N'Xã Cẩm Sơn', 60)
INSERT XAPHUONG VALUES(N'Xã Đa Phước Hội', 60)
INSERT XAPHUONG VALUES(N'Xã Định Thủy', 60)
INSERT XAPHUONG VALUES(N'Xã Hương Mỹ', 60)
INSERT XAPHUONG VALUES(N'Xã Minh Đức', 60)
INSERT XAPHUONG VALUES(N'Xã Ngãi Đăng', 60)
INSERT XAPHUONG VALUES(N'Xã Phước Hiệp', 60)
INSERT XAPHUONG VALUES(N'Xã Tân Hội', 60)
INSERT XAPHUONG VALUES(N'Xã Tân Trung', 60)
INSERT XAPHUONG VALUES(N'Xã Thành Thới A', 60)
INSERT XAPHUONG VALUES(N'Xã Thành Thới B', 60)

INSERT XAPHUONG VALUES(N'Thị trấn Thạnh Phú', 61)
INSERT XAPHUONG VALUES(N'Xã An Điền', 61)
INSERT XAPHUONG VALUES(N'Xã An Nhơn', 61)
INSERT XAPHUONG VALUES(N'Xã An Quy', 61)
INSERT XAPHUONG VALUES(N'Xã An Thạnh', 61)
INSERT XAPHUONG VALUES(N'Xã An Thuận', 61)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh', 61)
INSERT XAPHUONG VALUES(N'Xã Đại Điền', 61)
INSERT XAPHUONG VALUES(N'Xã Giao Thạnh', 61)
INSERT XAPHUONG VALUES(N'Xã Hòa Lợi', 61)
INSERT XAPHUONG VALUES(N'Xã Mỹ An', 61)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hưng', 61)
INSERT XAPHUONG VALUES(N'Xã Phú Khánh', 61)
INSERT XAPHUONG VALUES(N'Xã Quới Điền', 61)
INSERT XAPHUONG VALUES(N'Xã Tân Phong', 61)
INSERT XAPHUONG VALUES(N'Xã Thạnh Hải', 61)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phong', 61)
INSERT XAPHUONG VALUES(N'Xã Thới Thạnh', 61)

INSERT XAPHUONG VALUES(N'Phường 1', 62)
INSERT XAPHUONG VALUES(N'Phường 2', 62)
INSERT XAPHUONG VALUES(N'Phường 3', 62)
INSERT XAPHUONG VALUES(N'Phường 4', 62)
INSERT XAPHUONG VALUES(N'Phường 5', 62)
INSERT XAPHUONG VALUES(N'Phường 6', 62)
INSERT XAPHUONG VALUES(N'Phường 7', 62)
INSERT XAPHUONG VALUES(N'Phường 8', 62)
INSERT XAPHUONG VALUES(N'Phường An Hội', 62)
INSERT XAPHUONG VALUES(N'Phường Phú Khương', 62)
INSERT XAPHUONG VALUES(N'Phường Phú Tân', 62)
INSERT XAPHUONG VALUES(N'Xã Bình Phú', 62)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thạnh An', 62)
INSERT XAPHUONG VALUES(N'Xã Nhơn Thạnh', 62)
INSERT XAPHUONG VALUES(N'Xã Phú Hưng', 62)
INSERT XAPHUONG VALUES(N'Xã Phú Nhuận', 62)

INSERT XAPHUONG VALUES(N'Thị Trấn Tân Thành', 63)
INSERT XAPHUONG VALUES(N'Xã Bình Mỹ', 63)
INSERT XAPHUONG VALUES(N'Xã Đất Cuốc', 63)
INSERT XAPHUONG VALUES(N'Xã Hiếu Liêm', 63)
INSERT XAPHUONG VALUES(N'Xã Lạc An', 63)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 63)
INSERT XAPHUONG VALUES(N'Xã Tân Định', 63)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 63)
INSERT XAPHUONG VALUES(N'Xã Tân Mỹ', 63)
INSERT XAPHUONG VALUES(N'Xã Thường Tân', 63)

INSERT XAPHUONG VALUES(N'Thị Trấn Lai Uyên', 64)
INSERT XAPHUONG VALUES(N'Xã Cây Trường II', 64)
INSERT XAPHUONG VALUES(N'Xã Hưng Hòa', 64)
INSERT XAPHUONG VALUES(N'Xã Lai Hưng', 64)
INSERT XAPHUONG VALUES(N'Xã Long Nguyên', 64)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 64)
INSERT XAPHUONG VALUES(N'Xã Trừ Văn Thố', 64)

INSERT XAPHUONG VALUES(N'Thị trấn Dầu Tiếng', 65)
INSERT XAPHUONG VALUES(N'Xã An Lập', 65)
INSERT XAPHUONG VALUES(N'Xã Định An', 65)
INSERT XAPHUONG VALUES(N'Xã Định Hiệp', 65)
INSERT XAPHUONG VALUES(N'Xã Định Thành', 65)
INSERT XAPHUONG VALUES(N'Xã Long Hoà', 65)
INSERT XAPHUONG VALUES(N'Xã Long Tân', 65)
INSERT XAPHUONG VALUES(N'Xã Minh Hoà', 65)
INSERT XAPHUONG VALUES(N'Xã Minh Tân', 65)
INSERT XAPHUONG VALUES(N'Xã Minh Thạnh', 65)
INSERT XAPHUONG VALUES(N'Xã Thanh An', 65)
INSERT XAPHUONG VALUES(N'Xã Thanh Tuyền', 65)

INSERT XAPHUONG VALUES(N'Thị trấn Phước Vĩnh', 66)
INSERT XAPHUONG VALUES(N'Xã An Bình', 66)
INSERT XAPHUONG VALUES(N'Xã An Linh', 66)
INSERT XAPHUONG VALUES(N'Xã An Long', 66)
INSERT XAPHUONG VALUES(N'Xã An Thái', 66)
INSERT XAPHUONG VALUES(N'Xã Phước Hoà', 66)
INSERT XAPHUONG VALUES(N'Xã Phước Sang', 66)
INSERT XAPHUONG VALUES(N'Xã Tam Lập', 66)
INSERT XAPHUONG VALUES(N'Xã Tân Hiệp', 66)
INSERT XAPHUONG VALUES(N'Xã Tân Long', 66)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hoà', 66)

INSERT XAPHUONG VALUES(N'Phường An Bình', 67)
INSERT XAPHUONG VALUES(N'Phường Bình An', 67)
INSERT XAPHUONG VALUES(N'Phường Bình Thắng', 67)
INSERT XAPHUONG VALUES(N'Phường Dĩ An', 67)
INSERT XAPHUONG VALUES(N'Phường Đông Hòa', 67)
INSERT XAPHUONG VALUES(N'Phường Tân Bình', 67)
INSERT XAPHUONG VALUES(N'Phường Tân Đông Hiệp', 67)

INSERT XAPHUONG VALUES(N'Phường Chánh Nghĩa', 68)
INSERT XAPHUONG VALUES(N'Phường Định Hòa', 68)
INSERT XAPHUONG VALUES(N'Phường Hiệp An', 68)
INSERT XAPHUONG VALUES(N'Phường Hiệp Thành', 68)
INSERT XAPHUONG VALUES(N'Phường Phú Cường', 68)
INSERT XAPHUONG VALUES(N'Phường Phú Hòa', 68)
INSERT XAPHUONG VALUES(N'Phường Phú Lợi', 68)
INSERT XAPHUONG VALUES(N'Phường Phú Mỹ', 68)
INSERT XAPHUONG VALUES(N'Phường Phú Tân', 68)
INSERT XAPHUONG VALUES(N'Phường Phú Thọ', 68)
INSERT XAPHUONG VALUES(N'Phường Tân An', 68)
INSERT XAPHUONG VALUES(N'Hòa Phú', 68)
INSERT XAPHUONG VALUES(N'Xã Chánh Mỹ', 68)
INSERT XAPHUONG VALUES(N'Xã Tương Bình Hiệp', 68)

INSERT XAPHUONG VALUES(N'Phường An Phú', 69)
INSERT XAPHUONG VALUES(N'Phường An Thạnh', 69)
INSERT XAPHUONG VALUES(N'Phường Bình Chuẩn', 69)
INSERT XAPHUONG VALUES(N'Phường Bình Hòa', 69)
INSERT XAPHUONG VALUES(N'Phường Bình Nhâm', 69)
INSERT XAPHUONG VALUES(N'Phường Hưng Định', 69)
INSERT XAPHUONG VALUES(N'Phường Lái Thiêu', 69)
INSERT XAPHUONG VALUES(N'Phường Thuận Giao', 69)
INSERT XAPHUONG VALUES(N'Phường Vĩnh Phú', 69)
INSERT XAPHUONG VALUES(N'Xã An Sơn', 69)

INSERT XAPHUONG VALUES(N'Phường Chánh Phú Hòa', 70)
INSERT XAPHUONG VALUES(N'Phường Hòa Lợi', 70)
INSERT XAPHUONG VALUES(N'Phường Mỹ Phước', 70)
INSERT XAPHUONG VALUES(N'Phường Tân Định', 70)
INSERT XAPHUONG VALUES(N'Phường Thới Hòa', 70)
INSERT XAPHUONG VALUES(N'Xã An Điền', 70)
INSERT XAPHUONG VALUES(N'Xã An Tây', 70)
INSERT XAPHUONG VALUES(N'Xã Phú An', 70)

INSERT XAPHUONG VALUES(N'Phường Khánh Bình', 71)
INSERT XAPHUONG VALUES(N'Phường Tân Vĩnh Hiệp', 71)
INSERT XAPHUONG VALUES(N'Phường Thái Hòa', 71)
INSERT XAPHUONG VALUES(N'Phường Uyên Hưng', 71)
INSERT XAPHUONG VALUES(N'Thị Trấn Tân Phước Khánh', 71)
INSERT XAPHUONG VALUES(N'Xã Bạch Đằng', 71)
INSERT XAPHUONG VALUES(N'Xã Hội Nghĩa', 71)
INSERT XAPHUONG VALUES(N'Xã Phú Chánh', 71)
INSERT XAPHUONG VALUES(N'Xã Tân Hiệp', 71)
INSERT XAPHUONG VALUES(N'Xã Thạnh Hội', 71)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phước', 71)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Tân', 71)

INSERT XAPHUONG VALUES(N'Thị trấn An Lão', 72)
INSERT XAPHUONG VALUES(N'Xã An Dũng', 72)
INSERT XAPHUONG VALUES(N'Xã An Hòa', 72)
INSERT XAPHUONG VALUES(N'Xã An Hưng', 72)
INSERT XAPHUONG VALUES(N'Xã An Nghĩa', 72)
INSERT XAPHUONG VALUES(N'Xã An Quang', 72)
INSERT XAPHUONG VALUES(N'Xã An Tân', 72)
INSERT XAPHUONG VALUES(N'Xã An Toàn', 72)
INSERT XAPHUONG VALUES(N'Xã An Trung', 72)
INSERT XAPHUONG VALUES(N'Xã An Vinh', 72)

INSERT XAPHUONG VALUES(N'Thị trấn Tăng Bạt Hổ', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Đức', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Hảo Đông', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Hảo Tây', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Hữu', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Mỹ', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Nghĩa', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Phong', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Sơn', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Thạnh', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Tín', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Tường Đông', 73)
INSERT XAPHUONG VALUES(N'Xã Ân Tường Tây', 73)
INSERT XAPHUONG VALUES(N'Xã Bok Tới', 73)
INSERT XAPHUONG VALUES(N'Xã Dak Mang', 73)

INSERT XAPHUONG VALUES(N'Thị trấn Ngô Mây', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Chánh', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Hải', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Hanh', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Hiệp', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Hưng', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Khánh', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Lâm', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Minh', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Nhơn', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Sơn', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Tài', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Tân', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Thắng', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Thành', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Tiến', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Trinh', 74)
INSERT XAPHUONG VALUES(N'Xã Cát Tường', 74)

INSERT XAPHUONG VALUES(N'Thị trấn Bình Dương', 75)
INSERT XAPHUONG VALUES(N'Thị trấn Phù Mỹ', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ An', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Cát', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Chánh', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Chánh Tây', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Châu', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Đức', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hiệp', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hòa', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Lộc', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Lợi', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Phong', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Quang', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Tài', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thắng', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thành', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thọ', 75)
INSERT XAPHUONG VALUES(N'Xã Mỹ Trinh', 75)

INSERT XAPHUONG VALUES(N'Thị trấn Phú Phong', 76)
INSERT XAPHUONG VALUES(N'Xã Bình Hòa', 76)
INSERT XAPHUONG VALUES(N'Xã Bình Nghi', 76)
INSERT XAPHUONG VALUES(N'Xã Bình Tân', 76)
INSERT XAPHUONG VALUES(N'Xã Bình Thành', 76)
INSERT XAPHUONG VALUES(N'Xã Bình Thuận', 76)
INSERT XAPHUONG VALUES(N'Xã Bình Tường', 76)
INSERT XAPHUONG VALUES(N'Xã Tây An', 76)
INSERT XAPHUONG VALUES(N'Xã Tây Bình', 76)
INSERT XAPHUONG VALUES(N'Xã Tây Giang', 76)
INSERT XAPHUONG VALUES(N'Xã Tây Phú', 76)
INSERT XAPHUONG VALUES(N'Xã Tây Thuận', 76)
INSERT XAPHUONG VALUES(N'Xã Tây Vinh', 76)
INSERT XAPHUONG VALUES(N'Xã Tây Xuân', 76)
INSERT XAPHUONG VALUES(N'Xã Vĩnh An', 76)

INSERT XAPHUONG VALUES(N'Thị trấn Diêu Trì', 77)
INSERT XAPHUONG VALUES(N'Thị trấn Tuy Phước', 77)
INSERT XAPHUONG VALUES(N'Xã Phước An', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Hiệp', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Hòa', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Hưng', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Lộc', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Nghĩa', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Quang', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Sơn', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Thắng', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Thành', 77)
INSERT XAPHUONG VALUES(N'Xã Phước Thuận', 77)

INSERT XAPHUONG VALUES(N'Thị trấn Vân Canh', 78)
INSERT XAPHUONG VALUES(N'Xã Canh Hiển', 78)
INSERT XAPHUONG VALUES(N'Xã Canh Hiệp', 78)
INSERT XAPHUONG VALUES(N'Xã Canh Hòa', 78)
INSERT XAPHUONG VALUES(N'Xã Canh Liên', 78)
INSERT XAPHUONG VALUES(N'Xã Canh Thuận', 78)
INSERT XAPHUONG VALUES(N'Xã Canh Vinh', 78)

INSERT XAPHUONG VALUES(N'Thị trấn Vĩnh Thạnh', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hảo', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hiệp', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hòa', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Kim', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Quang', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Sơn', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thịnh', 79)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thuận', 79)

INSERT XAPHUONG VALUES(N'Phường Bùi Thị Xuân', 80)
INSERT XAPHUONG VALUES(N'Phường Đống Đa', 80)
INSERT XAPHUONG VALUES(N'Phường Ghềnh Ráng', 80)
INSERT XAPHUONG VALUES(N'Phường Hải Cảng', 80)
INSERT XAPHUONG VALUES(N'Phường Lê Hồng Phong', 80)
INSERT XAPHUONG VALUES(N'Phường Lê Lợi', 80)
INSERT XAPHUONG VALUES(N'Phường Lý Thường Kiệt', 80)
INSERT XAPHUONG VALUES(N'Phường Ngô Mây', 80)
INSERT XAPHUONG VALUES(N'Phường Nguyễn Văn Cừ', 80)
INSERT XAPHUONG VALUES(N'Phường Nhơn Bình', 80)
INSERT XAPHUONG VALUES(N'Phường Nhơn Phú', 80)
INSERT XAPHUONG VALUES(N'Phường Quang Trung', 80)
INSERT XAPHUONG VALUES(N'Phường Thị Nại', 80)
INSERT XAPHUONG VALUES(N'Phường Trần Hưng Đạo', 80)
INSERT XAPHUONG VALUES(N'Phường Trần Phú', 80)
INSERT XAPHUONG VALUES(N'Phường Trần Quang Diệu', 80)
INSERT XAPHUONG VALUES(N'Xã Nhơn Châu', 80)
INSERT XAPHUONG VALUES(N'Xã Nhơn Hải', 80)
INSERT XAPHUONG VALUES(N'Xã Nhơn Hội', 80)
INSERT XAPHUONG VALUES(N'Xã Nhơn Lý', 80)
INSERT XAPHUONG VALUES(N'Xã Phước Mỹ', 80)

INSERT XAPHUONG VALUES(N'Phường Bình Định', 81)
INSERT XAPHUONG VALUES(N'Phường Đập Đá', 81)
INSERT XAPHUONG VALUES(N'Phường Nhơn Hòa', 81)
INSERT XAPHUONG VALUES(N'Phường Nhơn Hưng', 81)
INSERT XAPHUONG VALUES(N'Phường Nhơn Thành', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn An', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Hạnh', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Hậu', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Khánh', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Lộc', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Mỹ', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Phong', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Phúc', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Tân', 81)
INSERT XAPHUONG VALUES(N'Xã Nhơn Thọ', 81)

INSERT XAPHUONG VALUES(N'Phường Bồng Sơn', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Đức', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Hảo', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Hương', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Tân', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Thanh', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Thanh Tây', 82)
INSERT XAPHUONG VALUES(N'Phường Hoài Xuân', 82)
INSERT XAPHUONG VALUES(N'Phường Tam Quan', 82)
INSERT XAPHUONG VALUES(N'Phường Tam Quan Bắc', 82)
INSERT XAPHUONG VALUES(N'Phường Tam Quan Nam', 82)
INSERT XAPHUONG VALUES(N'Xã Hoài Châu', 82)
INSERT XAPHUONG VALUES(N'Xã Hoài Châu Bắc', 82)
INSERT XAPHUONG VALUES(N'Xã Hoài Hải', 82)
INSERT XAPHUONG VALUES(N'Xã Hoài Mỹ', 82)
INSERT XAPHUONG VALUES(N'Xã Hoài Phú', 82)
INSERT XAPHUONG VALUES(N'Xã Hoài Sơn', 82)

INSERT XAPHUONG VALUES(N'Thị trấn Đức Phong', 83)
INSERT XAPHUONG VALUES(N'Xã Bình Minh', 83)
INSERT XAPHUONG VALUES(N'Xã Bom Bo', 83)
INSERT XAPHUONG VALUES(N'Xã Đắk Nhau', 83)
INSERT XAPHUONG VALUES(N'Xã Đăng Hà', 83)
INSERT XAPHUONG VALUES(N'Xã Đoàn Kết', 83)
INSERT XAPHUONG VALUES(N'Xã Đồng Nai', 83)
INSERT XAPHUONG VALUES(N'Xã Đức Liễu', 83)
INSERT XAPHUONG VALUES(N'Xã Đường 10', 83)
INSERT XAPHUONG VALUES(N'Xã Minh Hưng', 83)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Bình', 83)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Trung', 83)
INSERT XAPHUONG VALUES(N'Xã Phú Sơn', 83)
INSERT XAPHUONG VALUES(N'Xã Phước Sơn', 83)
INSERT XAPHUONG VALUES(N'Xã Thọ Sơn', 83)
INSERT XAPHUONG VALUES(N'Xã Thống Nhất', 83)

INSERT XAPHUONG VALUES(N'Thị Trấn Thanh Bình', 84)
INSERT XAPHUONG VALUES(N'Xã Hưng Phước', 84)
INSERT XAPHUONG VALUES(N'Xã Phước Thiện', 84)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 84)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 84)
INSERT XAPHUONG VALUES(N'Xã Thanh Hòa', 84)
INSERT XAPHUONG VALUES(N'Xã Thiện Hưng', 84)

INSERT XAPHUONG VALUES(N'Xã Bình Thắng', 85)
INSERT XAPHUONG VALUES(N'Xã Bù Gia Mập', 85)
INSERT XAPHUONG VALUES(N'Xã Đa Kia', 85)
INSERT XAPHUONG VALUES(N'Xã Đak Ơ', 85)
INSERT XAPHUONG VALUES(N'Xã Đức Hạnh', 85)
INSERT XAPHUONG VALUES(N'Xã Phú Nghĩa', 85)
INSERT XAPHUONG VALUES(N'Xã Phú Văn', 85)
INSERT XAPHUONG VALUES(N'Xã Phước Minh', 85)

INSERT XAPHUONG VALUES(N'Thị trấn Chơn Thành', 86)
INSERT XAPHUONG VALUES(N'Xã Minh Hưng', 86)
INSERT XAPHUONG VALUES(N'Xã Minh Lập', 86)
INSERT XAPHUONG VALUES(N'Xã Minh Long', 86)
INSERT XAPHUONG VALUES(N'Xã Minh Thắng', 86)
INSERT XAPHUONG VALUES(N'Xã Minh Thành', 86)
INSERT XAPHUONG VALUES(N'Xã Nha Bích', 86)
INSERT XAPHUONG VALUES(N'Xã Quang Minh', 86)
INSERT XAPHUONG VALUES(N'Xã Tân Quan', 86)
INSERT XAPHUONG VALUES(N'Xã Thành Tâm', 86)

INSERT XAPHUONG VALUES(N'Thị trấn Tân Phú', 87)
INSERT XAPHUONG VALUES(N'Xã Đồng Tâm', 87)
INSERT XAPHUONG VALUES(N'Xã Đồng Tiến', 87)
INSERT XAPHUONG VALUES(N'Xã Tân Hoà', 87)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 87)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 87)
INSERT XAPHUONG VALUES(N'Xã Tân lợi', 87)
INSERT XAPHUONG VALUES(N'Xã Tân Phước', 87)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 87)
INSERT XAPHUONG VALUES(N'Xã Thuận Lợi', 87)
INSERT XAPHUONG VALUES(N'Xã Thuận Phú', 87)

INSERT XAPHUONG VALUES(N'Thị Trấn Tân Khai', 88)
INSERT XAPHUONG VALUES(N'Xã An Khương', 88)
INSERT XAPHUONG VALUES(N'Xã An Phú', 88)
INSERT XAPHUONG VALUES(N'Xã Đồng Nơ', 88)
INSERT XAPHUONG VALUES(N'Xã Minh Đức', 88)
INSERT XAPHUONG VALUES(N'Xã Minh Tâm', 88)
INSERT XAPHUONG VALUES(N'Xã Phước An', 88)
INSERT XAPHUONG VALUES(N'Xã Tân Hiệp', 88)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 88)
INSERT XAPHUONG VALUES(N'Xã Tân Lợi', 88)
INSERT XAPHUONG VALUES(N'Xã Tân Quan', 88)
INSERT XAPHUONG VALUES(N'Xã Thanh An', 88)
INSERT XAPHUONG VALUES(N'Xã Thanh Bình', 88)

INSERT XAPHUONG VALUES(N'Thị trấn Lộc Ninh', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc An', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Điền', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Hiệp', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Hòa', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Hưng', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Khánh', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Phú', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Quang', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Tấn', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Thái', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Thành', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Thạnh', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Thiện', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Thịnh', 89)
INSERT XAPHUONG VALUES(N'Xã Lộc Thuận', 89)

INSERT XAPHUONG VALUES(N'Long Hưng', 90)
INSERT XAPHUONG VALUES(N'Xã Bình Sơn', 90)
INSERT XAPHUONG VALUES(N'Xã Bình Tân', 90)
INSERT XAPHUONG VALUES(N'Xã Bù Nho', 90)
INSERT XAPHUONG VALUES(N'Xã Long Bình', 90)
INSERT XAPHUONG VALUES(N'Xã Long Hà', 90)
INSERT XAPHUONG VALUES(N'Xã Long Hưng', 90)
INSERT XAPHUONG VALUES(N'Xã Long Tân', 90)
INSERT XAPHUONG VALUES(N'Xã Phú Riềng', 90)
INSERT XAPHUONG VALUES(N'Xã Phú Trung', 90)
INSERT XAPHUONG VALUES(N'Xã Phước Tân', 90)

INSERT XAPHUONG VALUES(N'Phường Tân Bình', 91)
INSERT XAPHUONG VALUES(N'Phường Tân Đồng', 91)
INSERT XAPHUONG VALUES(N'Phường Tân Phú', 91)
INSERT XAPHUONG VALUES(N'Phường Tân Thiện', 91)
INSERT XAPHUONG VALUES(N'Phường Tân Xuân', 91)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 91)
INSERT XAPHUONG VALUES(N'Xã Tiến Hưng', 91)
INSERT XAPHUONG VALUES(N'Xã Tiến Thành', 91)

INSERT XAPHUONG VALUES(N'Phường An Lộc', 92)
INSERT XAPHUONG VALUES(N'Hưng Chiến', 92)
INSERT XAPHUONG VALUES(N'Phú Đức', 92)
INSERT XAPHUONG VALUES(N'Phú Thịnh', 92)
INSERT XAPHUONG VALUES(N'Xã An Phú', 92)
INSERT XAPHUONG VALUES(N'Xã Thanh Bình', 92)
INSERT XAPHUONG VALUES(N'Xã Thanh Lương', 92)
INSERT XAPHUONG VALUES(N'Xã Thanh Phú', 92)

INSERT XAPHUONG VALUES(N'Phường Long Phước', 93)
INSERT XAPHUONG VALUES(N'Phường Long Thủy', 93)
INSERT XAPHUONG VALUES(N'Phường Phước Bình', 93)
INSERT XAPHUONG VALUES(N'Phường Sơn Giang', 93)
INSERT XAPHUONG VALUES(N'Phường Thác Mơ', 93)
INSERT XAPHUONG VALUES(N'Xã Long Giang', 93)
INSERT XAPHUONG VALUES(N'Xã Phước Tín', 93)

INSERT XAPHUONG VALUES(N'Thị trấn Chợ Lầu', 94)
INSERT XAPHUONG VALUES(N'Xã Bình An', 94)
INSERT XAPHUONG VALUES(N'Xã Bình Tân', 94)
INSERT XAPHUONG VALUES(N'Xã Hải Ninh', 94)
INSERT XAPHUONG VALUES(N'Xã Hòa Thắng', 94)
INSERT XAPHUONG VALUES(N'Xã Hồng Phong', 94)
INSERT XAPHUONG VALUES(N'Xã Hồng Thái', 94)
INSERT XAPHUONG VALUES(N'Xã Lương Sơn', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Điền', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Hiệp', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Hòa', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Lâm', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Rí Thành', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Sơn', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Thanh', 94)
INSERT XAPHUONG VALUES(N'Xã Phan Tiến', 94)
INSERT XAPHUONG VALUES(N'Xã Sông Bình', 94)
INSERT XAPHUONG VALUES(N'Xã Sông Lũy', 94)

INSERT XAPHUONG VALUES(N'Thị trấn Đức Tài', 95)
INSERT XAPHUONG VALUES(N'Thị trấn Võ Xu', 95)
INSERT XAPHUONG VALUES(N'Xã Đa Kai', 95)
INSERT XAPHUONG VALUES(N'Xã Đông Hà', 95)
INSERT XAPHUONG VALUES(N'Xã Đức Chính', 95)
INSERT XAPHUONG VALUES(N'Xã Đức Hạnh', 95)
INSERT XAPHUONG VALUES(N'Xã Đức Tín', 95)
INSERT XAPHUONG VALUES(N'Xã Mê Pu', 95)
INSERT XAPHUONG VALUES(N'Xã Nam Chính', 95)
INSERT XAPHUONG VALUES(N'Xã Sùng Nhơn', 95)
INSERT XAPHUONG VALUES(N'Xã Tân Hà', 95)
INSERT XAPHUONG VALUES(N'Xã Trà Tân', 95)
INSERT XAPHUONG VALUES(N'Xã Vũ Hoà', 95)

INSERT XAPHUONG VALUES(N'Thắng Hải', 96)
INSERT XAPHUONG VALUES(N'Thị trấn Tân Minh', 96)
INSERT XAPHUONG VALUES(N'Thị trấn Tân Nghĩa', 96)
INSERT XAPHUONG VALUES(N'Xã Sơn Mỹ', 96)
INSERT XAPHUONG VALUES(N'Xã Sông Phan', 96)
INSERT XAPHUONG VALUES(N'Xã Tân Đức', 96)
INSERT XAPHUONG VALUES(N'Xã Tân Hà', 96)
INSERT XAPHUONG VALUES(N'Xã Tân Phúc', 96)
INSERT XAPHUONG VALUES(N'Xã Tân Thắng', 96)
INSERT XAPHUONG VALUES(N'Xã Tân Xuân', 96)
INSERT XAPHUONG VALUES(N'Xã Thắng Hải', 96)

INSERT XAPHUONG VALUES(N'Thị trấn Ma Lâm', 97)
INSERT XAPHUONG VALUES(N'Thị trấn Phú Long', 97)
INSERT XAPHUONG VALUES(N'Xã Đa Mi', 97)
INSERT XAPHUONG VALUES(N'Xã Đông Giang', 97)
INSERT XAPHUONG VALUES(N'Xã Đông Tiến', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Chính', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Đức', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Hiệp', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Liêm', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Phú', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Thắng', 97)
INSERT XAPHUONG VALUES(N'Xã Hàm Trí', 97)
INSERT XAPHUONG VALUES(N'Xã Hồng Liêm', 97)
INSERT XAPHUONG VALUES(N'Xã Hồng Sơn', 97)
INSERT XAPHUONG VALUES(N'Xã La Dạ', 97)
INSERT XAPHUONG VALUES(N'Xã Thuận Hòa', 97)
INSERT XAPHUONG VALUES(N'Xã Thuận Minh', 97)

INSERT XAPHUONG VALUES(N'Thị trấn Thuận Nam', 98)
INSERT XAPHUONG VALUES(N'Xã Cà Ná', 98)
INSERT XAPHUONG VALUES(N'Xã Hàm Cần', 98)
INSERT XAPHUONG VALUES(N'Xã Hàm Cường', 98)
INSERT XAPHUONG VALUES(N'Xã Hàm Kiệm', 98)
INSERT XAPHUONG VALUES(N'Xã Hàm Minh', 98)
INSERT XAPHUONG VALUES(N'Xã Hàm Mỹ', 98)
INSERT XAPHUONG VALUES(N'Xã Hàm Thạnh', 98)
INSERT XAPHUONG VALUES(N'Xã Mương Mán', 98)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thạnh', 98)
INSERT XAPHUONG VALUES(N'Xã Nhị Hà', 98)
INSERT XAPHUONG VALUES(N'Xã Phước Diêm', 98)
INSERT XAPHUONG VALUES(N'Xã Phước Dinh', 98)
INSERT XAPHUONG VALUES(N'Xã Phước Hà', 98)
INSERT XAPHUONG VALUES(N'Xã Phước Minh', 98)
INSERT XAPHUONG VALUES(N'Xã Phước Nam', 98)
INSERT XAPHUONG VALUES(N'Xã Phước Ninh', 98)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 98)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 98)
INSERT XAPHUONG VALUES(N'Xã Tân Thuận', 98)
INSERT XAPHUONG VALUES(N'Xã Thuận Quí', 98)

INSERT XAPHUONG VALUES(N'Xã Long Hải', 99)
INSERT XAPHUONG VALUES(N'Xã Ngũ Phụng', 99)
INSERT XAPHUONG VALUES(N'Xã Tam Thanh', 99)

INSERT XAPHUONG VALUES(N'Thị trấn Lạc Tánh', 100)
INSERT XAPHUONG VALUES(N'Xã Bắc Ruộng', 100)
INSERT XAPHUONG VALUES(N'Xã Đồng Kho', 100)
INSERT XAPHUONG VALUES(N'Xã Đức Bình', 100)
INSERT XAPHUONG VALUES(N'Xã Đức Phú', 100)
INSERT XAPHUONG VALUES(N'Xã Đức Tân', 100)
INSERT XAPHUONG VALUES(N'Xã Đức Thuận', 100)
INSERT XAPHUONG VALUES(N'Xã Gia An', 100)
INSERT XAPHUONG VALUES(N'Xã Gia Huynh', 100)
INSERT XAPHUONG VALUES(N'Xã Huy Khiêm', 100)
INSERT XAPHUONG VALUES(N'Xã La Ngâu', 100)
INSERT XAPHUONG VALUES(N'Xã Măng Tố', 100)
INSERT XAPHUONG VALUES(N'Xã Nghị Đức', 100)
INSERT XAPHUONG VALUES(N'Xã Suối Kiết', 100)

INSERT XAPHUONG VALUES(N'Thị trấn Liên Hương', 101)
INSERT XAPHUONG VALUES(N'Thị trấn Phan Rí Cửa', 101)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh', 101)
INSERT XAPHUONG VALUES(N'Xã Chí Công', 101)
INSERT XAPHUONG VALUES(N'Xã Hòa Minh', 101)
INSERT XAPHUONG VALUES(N'Xã Hoà Phú', 101)
INSERT XAPHUONG VALUES(N'Xã Phan Dũng', 101)
INSERT XAPHUONG VALUES(N'Xã Phong Phú', 101)
INSERT XAPHUONG VALUES(N'Xã Phú Lạc', 101)
INSERT XAPHUONG VALUES(N'Xã Phước Thể', 101)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hảo', 101)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Tân', 101)

INSERT XAPHUONG VALUES(N'Phường Bình Hưng', 102)
INSERT XAPHUONG VALUES(N'Phường Đức Long', 102)
INSERT XAPHUONG VALUES(N'Phường Đức Nghĩa', 102)
INSERT XAPHUONG VALUES(N'Phường Đức Thắng', 102)
INSERT XAPHUONG VALUES(N'Phường Hàm Tiến', 102)
INSERT XAPHUONG VALUES(N'Phường Hưng Long', 102)
INSERT XAPHUONG VALUES(N'Phường Lạc Đạo', 102)
INSERT XAPHUONG VALUES(N'Phường Mũi Né', 102)
INSERT XAPHUONG VALUES(N'Phường Phú Hài', 102)
INSERT XAPHUONG VALUES(N'Phường Phú Tài', 102)
INSERT XAPHUONG VALUES(N'Phường Phú Thủy', 102)
INSERT XAPHUONG VALUES(N'Phường Phú Trinh', 102)
INSERT XAPHUONG VALUES(N'Phường Thanh Hải', 102)
INSERT XAPHUONG VALUES(N'Phường Xuân An', 102)
INSERT XAPHUONG VALUES(N'Xã Phong Nẫm', 102)
INSERT XAPHUONG VALUES(N'Xã Thiện Nghiệp', 102)
INSERT XAPHUONG VALUES(N'Xã Tiến Lợi', 102)
INSERT XAPHUONG VALUES(N'Xã Tiến Thành', 102)

INSERT XAPHUONG VALUES(N'Phường Bình Tân', 103)
INSERT XAPHUONG VALUES(N'Phường Phước Hội', 103)
INSERT XAPHUONG VALUES(N'Phường Phước Lộc', 103)
INSERT XAPHUONG VALUES(N'Phường Tân An', 103)
INSERT XAPHUONG VALUES(N'Phường Tân Thiện', 103)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 103)
INSERT XAPHUONG VALUES(N'Xã Tân Hải', 103)
INSERT XAPHUONG VALUES(N'Xã Tân Phước', 103)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 103)

INSERT XAPHUONG VALUES(N'Thị trấn Cái Nước', 104)
INSERT XAPHUONG VALUES(N'Xã Đông Hưng', 104)
INSERT XAPHUONG VALUES(N'Xã Đông Thới', 104)
INSERT XAPHUONG VALUES(N'Xã Hoà Mỹ', 104)
INSERT XAPHUONG VALUES(N'Xã Hưng Mỹ', 104)
INSERT XAPHUONG VALUES(N'Xã Lương Thế Trân', 104)
INSERT XAPHUONG VALUES(N'Xã Phú Hưng', 104)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 104)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng Đông', 104)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phú', 104)
INSERT XAPHUONG VALUES(N'Xã Trần Thới', 104)

INSERT XAPHUONG VALUES(N'Tân Duyệt', 105)
INSERT XAPHUONG VALUES(N'Thị trấn Đầm Dơi', 105)
INSERT XAPHUONG VALUES(N'Xã Ngọc Chánh', 105)
INSERT XAPHUONG VALUES(N'Xã Nguyễn Huân', 105)
INSERT XAPHUONG VALUES(N'Xã Quách Phẩm', 105)
INSERT XAPHUONG VALUES(N'Xã Quách Phẩm Bắc', 105)
INSERT XAPHUONG VALUES(N'Xã Tạ An Khương', 105)
INSERT XAPHUONG VALUES(N'Xã Tạ An Khương Đông', 105)
INSERT XAPHUONG VALUES(N'Xã Tạ An Khương Nam', 105)
INSERT XAPHUONG VALUES(N'Xã Tân Dân', 105)
INSERT XAPHUONG VALUES(N'Xã Tân Đức', 105)
INSERT XAPHUONG VALUES(N'Xã Tân Duyệt', 105)
INSERT XAPHUONG VALUES(N'Xã Tân Thuận', 105)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 105)
INSERT XAPHUONG VALUES(N'Xã Tân Trung', 105)
INSERT XAPHUONG VALUES(N'Xã Thanh Tùng', 105)
INSERT XAPHUONG VALUES(N'Xã Trần Phán', 105)

INSERT XAPHUONG VALUES(N'Thị trấn Năm Căn', 106)
INSERT XAPHUONG VALUES(N'Xã Đất Mới', 106)
INSERT XAPHUONG VALUES(N'Xã Hàm Rồng', 106)
INSERT XAPHUONG VALUES(N'Xã Hàng Vịnh', 106)
INSERT XAPHUONG VALUES(N'Xã Hiệp Tùng', 106)
INSERT XAPHUONG VALUES(N'Xã Lâm Hải', 106)
INSERT XAPHUONG VALUES(N'Xã Tam Giang', 106)
INSERT XAPHUONG VALUES(N'Xã Tam Giang Đông', 106)

INSERT XAPHUONG VALUES(N'Thị Trấn Rạch Gốc', 107)
INSERT XAPHUONG VALUES(N'Xã Đất Mũi', 107)
INSERT XAPHUONG VALUES(N'Xã Tam Giang Tây', 107)
INSERT XAPHUONG VALUES(N'Xã Tân ân', 107)
INSERT XAPHUONG VALUES(N'Xã Tân Ân Tây', 107)
INSERT XAPHUONG VALUES(N'Xã Viên An', 107)
INSERT XAPHUONG VALUES(N'Xã Viên An Đông', 107)

INSERT XAPHUONG VALUES(N'Thị trấn Cái Đôi Vàm', 108)
INSERT XAPHUONG VALUES(N'Xã Nguyễn Việt Khái', 108)
INSERT XAPHUONG VALUES(N'Xã Phú Mỹ', 108)
INSERT XAPHUONG VALUES(N'Xã Phú Tân', 108)
INSERT XAPHUONG VALUES(N'xã Phú Thuận', 108)
INSERT XAPHUONG VALUES(N'xã Rạch Chèo', 108)
INSERT XAPHUONG VALUES(N'Xã Tân Hải', 108)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng Tây', 108)
INSERT XAPHUONG VALUES(N'Xã Việt Thắng', 108)

INSERT XAPHUONG VALUES(N'Thị trấn Thới Bình', 109)
INSERT XAPHUONG VALUES(N'Xã Biển Bạch', 109)
INSERT XAPHUONG VALUES(N'Xã Biển Bạch Đông', 109)
INSERT XAPHUONG VALUES(N'Xã Hồ Thị Kỷ', 109)
INSERT XAPHUONG VALUES(N'Xã Tân Bằng', 109)
INSERT XAPHUONG VALUES(N'Xã Tân Lộc', 109)
INSERT XAPHUONG VALUES(N'Xã Tân Lộc Bắc', 109)
INSERT XAPHUONG VALUES(N'Xã Tân Lộc Đông', 109)
INSERT XAPHUONG VALUES(N'Xã Tân Phú', 109)
INSERT XAPHUONG VALUES(N'Xã Thới Bình', 109)
INSERT XAPHUONG VALUES(N'Xã Trí Lực', 109)
INSERT XAPHUONG VALUES(N'Xã Trí Phải', 109)

INSERT XAPHUONG VALUES(N'Thị trấn Sông Đốc', 110)
INSERT XAPHUONG VALUES(N'Thị trấn Trần Văn Thời', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Bình', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Bình Đông', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Bình Tây', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Bình Tây Bắc', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Hải', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Hưng', 110)
INSERT XAPHUONG VALUES(N'Xã Khánh Lộc', 110)
INSERT XAPHUONG VALUES(N'Xã Lợi An', 110)
INSERT XAPHUONG VALUES(N'Xã Phong Điền', 110)
INSERT XAPHUONG VALUES(N'Xã Phong Lạc', 110)
INSERT XAPHUONG VALUES(N'Xã Trần Hợi', 110)

INSERT XAPHUONG VALUES(N'Khánh Thuận', 111)
INSERT XAPHUONG VALUES(N'Thị trấn U Minh', 111)
INSERT XAPHUONG VALUES(N'Xã Khánh An', 111)
INSERT XAPHUONG VALUES(N'Xã Khánh Hòa', 111)
INSERT XAPHUONG VALUES(N'Xã Khánh Hội', 111)
INSERT XAPHUONG VALUES(N'Xã Khánh Lâm', 111)
INSERT XAPHUONG VALUES(N'Xã Khánh Tiến', 111)
INSERT XAPHUONG VALUES(N'Xã Nguyễn Phích', 111)

INSERT XAPHUONG VALUES(N'Phường 1', 112)
INSERT XAPHUONG VALUES(N'Phường 2', 112)
INSERT XAPHUONG VALUES(N'Phường 4', 112)
INSERT XAPHUONG VALUES(N'Phường 5', 112)
INSERT XAPHUONG VALUES(N'Phường 6', 112)
INSERT XAPHUONG VALUES(N'Phường 7', 112)
INSERT XAPHUONG VALUES(N'Phường 8', 112)
INSERT XAPHUONG VALUES(N'Phường 9', 112)
INSERT XAPHUONG VALUES(N'Phường Tân Thành', 112)
INSERT XAPHUONG VALUES(N'Tân Xuyên', 112)
INSERT XAPHUONG VALUES(N'Xã An Xuyên', 112)
INSERT XAPHUONG VALUES(N'Xã Định Bình', 112)
INSERT XAPHUONG VALUES(N'Xã Hòa Tân', 112)
INSERT XAPHUONG VALUES(N'Xã Hòa Thành', 112)
INSERT XAPHUONG VALUES(N'Xã Lý Văn Lâm', 112)
INSERT XAPHUONG VALUES(N'Xã Tắc Vân', 112)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 112)

INSERT XAPHUONG VALUES(N'Phường An Thới', 113)
INSERT XAPHUONG VALUES(N'Phường Bình Thủy', 113)
INSERT XAPHUONG VALUES(N'Phường Bùi Hữu Nghĩa', 113)
INSERT XAPHUONG VALUES(N'Phường Long Hòa', 113)
INSERT XAPHUONG VALUES(N'Phường Long Tuyền', 113)
INSERT XAPHUONG VALUES(N'Phường Thới An Đông', 113)
INSERT XAPHUONG VALUES(N'Phường Trà An', 113)
INSERT XAPHUONG VALUES(N'Phường Trà Nóc', 113)

INSERT XAPHUONG VALUES(N'Phường Ba Láng', 114)
INSERT XAPHUONG VALUES(N'Phường Hưng Phú', 114)
INSERT XAPHUONG VALUES(N'Phường Hưng Thạnh', 114)
INSERT XAPHUONG VALUES(N'Phường Lê Bình', 114)
INSERT XAPHUONG VALUES(N'Phường Phú Thứ', 114)
INSERT XAPHUONG VALUES(N'Phường Tân Phú', 114)
INSERT XAPHUONG VALUES(N'Phường Thường Thạnh', 114)

INSERT XAPHUONG VALUES(N'Phường An Bình', 115)
INSERT XAPHUONG VALUES(N'Phường An Cư', 115)
INSERT XAPHUONG VALUES(N'Phường An Hòa', 115)
INSERT XAPHUONG VALUES(N'Phường An Khánh', 115)
INSERT XAPHUONG VALUES(N'Phường An Nghiệp', 115)
INSERT XAPHUONG VALUES(N'Phường An Phú', 115)
INSERT XAPHUONG VALUES(N'Phường Cái Khế', 115)
INSERT XAPHUONG VALUES(N'Phường Hưng Lợi', 115)
INSERT XAPHUONG VALUES(N'Phường Tân An', 115)
INSERT XAPHUONG VALUES(N'Phường Thới Bình', 115)
INSERT XAPHUONG VALUES(N'Phường Xuân Khánh', 115)

INSERT XAPHUONG VALUES(N'Phường Châu Văn Liêm', 116)
INSERT XAPHUONG VALUES(N'Phường Long Hưng', 116)
INSERT XAPHUONG VALUES(N'Phường Phước Thới', 116)
INSERT XAPHUONG VALUES(N'Phường Thới An', 116)
INSERT XAPHUONG VALUES(N'Phường Thới Hoà', 116)
INSERT XAPHUONG VALUES(N'Phường Thới Long', 116)
INSERT XAPHUONG VALUES(N'Phường Trường Lạc', 116)

INSERT XAPHUONG VALUES(N'Phường Tân Hưng', 117)
INSERT XAPHUONG VALUES(N'Phường Tân Lộc', 117)
INSERT XAPHUONG VALUES(N'Phường Thạnh Hòa', 117)
INSERT XAPHUONG VALUES(N'Phường Thới Thuận', 117)
INSERT XAPHUONG VALUES(N'Phường Thốt Nốt', 117)
INSERT XAPHUONG VALUES(N'Phường Thuận An', 117)
INSERT XAPHUONG VALUES(N'Phường Thuận Hưng', 117)
INSERT XAPHUONG VALUES(N'Phường Trung Kiên', 117)
INSERT XAPHUONG VALUES(N'Phường Trung Nhứt', 117)

INSERT XAPHUONG VALUES(N'Thị trấn Cờ Đỏ', 118)
INSERT XAPHUONG VALUES(N'Xã Đông Hiệp', 118)
INSERT XAPHUONG VALUES(N'Xã Đông Thắng', 118)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phú', 118)
INSERT XAPHUONG VALUES(N'Xã Thới Đông', 118)
INSERT XAPHUONG VALUES(N'Xã Thới Hưng', 118)
INSERT XAPHUONG VALUES(N'Xã Thới Xuân', 118)
INSERT XAPHUONG VALUES(N'Xã Trung An', 118)
INSERT XAPHUONG VALUES(N'Xã Trung Hưng', 118)
INSERT XAPHUONG VALUES(N'Xã Trung Thạnh', 118)

INSERT XAPHUONG VALUES(N'Thị Trấn Phong Điền', 119)
INSERT XAPHUONG VALUES(N'Xã Giai Xuân', 119)
INSERT XAPHUONG VALUES(N'Xã Mỹ Khánh', 119)
INSERT XAPHUONG VALUES(N'Xã Nhơn ái', 119)
INSERT XAPHUONG VALUES(N'Xã Nhơn Nghĩa', 119)
INSERT XAPHUONG VALUES(N'Xã Tân Thới', 119)
INSERT XAPHUONG VALUES(N'Xã Trường Long', 119)

INSERT XAPHUONG VALUES(N'Thị Trấn Thới Lai', 120)
INSERT XAPHUONG VALUES(N'Xã Định Môn', 120)
INSERT XAPHUONG VALUES(N'Xã Đông Bình', 120)
INSERT XAPHUONG VALUES(N'Xã Đông Thuận', 120)
INSERT XAPHUONG VALUES(N'Xã Tân Thạnh', 120)
INSERT XAPHUONG VALUES(N'Xã Thới Tân', 120)
INSERT XAPHUONG VALUES(N'Xã Thới Thạnh', 120)
INSERT XAPHUONG VALUES(N'Xã Trường Thắng', 120)
INSERT XAPHUONG VALUES(N'Xã Trường Thành', 120)
INSERT XAPHUONG VALUES(N'Xã Trường Xuân', 120)
INSERT XAPHUONG VALUES(N'Xã Trường Xuân A', 120)
INSERT XAPHUONG VALUES(N'Xã Trường Xuân B', 120)
INSERT XAPHUONG VALUES(N'Xã Xuân Thắng', 120)

INSERT XAPHUONG VALUES(N'Thị trấn Thanh An', 121)
INSERT XAPHUONG VALUES(N'Thị trấn Vĩnh Thạnh', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh An', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh Lộc', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh Lợi', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh Mỹ', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh Qưới', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh Thắng', 121)
INSERT XAPHUONG VALUES(N'Xã Thạnh Tiến', 121)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Bình', 121)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Trinh', 121)

INSERT XAPHUONG VALUES(N'Thị trấn Bảo Lạc', 122)
INSERT XAPHUONG VALUES(N'Xã Bảo Toàn', 122)
INSERT XAPHUONG VALUES(N'Xã Cô Ba', 122)
INSERT XAPHUONG VALUES(N'Xã Cốc Pàng', 122)
INSERT XAPHUONG VALUES(N'Xã Đình Phùng', 122)
INSERT XAPHUONG VALUES(N'Xã Hồng An', 122)
INSERT XAPHUONG VALUES(N'Xã Hồng Trị', 122)
INSERT XAPHUONG VALUES(N'Xã Hưng Đạo', 122)
INSERT XAPHUONG VALUES(N'Xã Hưng Thịnh', 122)
INSERT XAPHUONG VALUES(N'Xã Huy Giáp', 122)
INSERT XAPHUONG VALUES(N'Xã Khánh Xuân', 122)
INSERT XAPHUONG VALUES(N'Xã Kim Cúc', 122)
INSERT XAPHUONG VALUES(N'Xã Phan Thanh', 122)
INSERT XAPHUONG VALUES(N'Xã Sơn Lập', 122)
INSERT XAPHUONG VALUES(N'Xã Sơn Lộ', 122)
INSERT XAPHUONG VALUES(N'Xã Thượng Hà', 122)
INSERT XAPHUONG VALUES(N'Xã Xuân Trường', 122)

INSERT XAPHUONG VALUES(N'Thị trấn Pác Miầu', 123)
INSERT XAPHUONG VALUES(N'Xã Đức Hạnh', 123)
INSERT XAPHUONG VALUES(N'Xã Lý Bôn', 123)
INSERT XAPHUONG VALUES(N'Xã Mông ân', 123)
INSERT XAPHUONG VALUES(N'Xã Nam Cao', 123)
INSERT XAPHUONG VALUES(N'Xã Nam Quang', 123)
INSERT XAPHUONG VALUES(N'Xã Quảng Lâm', 123)
INSERT XAPHUONG VALUES(N'Xã Tân Việt', 123)
INSERT XAPHUONG VALUES(N'Xã Thạch Lâm', 123)
INSERT XAPHUONG VALUES(N'Xã Thái Học', 123)
INSERT XAPHUONG VALUES(N'Xã Thái Sơn', 123)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Phong', 123)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Quang', 123)
INSERT XAPHUONG VALUES(N'Xã Yên Thổ', 123)

INSERT XAPHUONG VALUES(N'Xã An Lạc', 124)
INSERT XAPHUONG VALUES(N'Xã Cô Ngân', 124)
INSERT XAPHUONG VALUES(N'Xã Đồng Loan', 124)
INSERT XAPHUONG VALUES(N'Xã Đức Quang', 124)
INSERT XAPHUONG VALUES(N'Xã Kim Loan', 124)
INSERT XAPHUONG VALUES(N'Xã Lý Quốc', 124)
INSERT XAPHUONG VALUES(N'Xã Minh Long', 124)
INSERT XAPHUONG VALUES(N'Xã Quang Long', 124)
INSERT XAPHUONG VALUES(N'Xã Thắng Lợi', 124)
INSERT XAPHUONG VALUES(N'Xã Thanh Nhật', 124)
INSERT XAPHUONG VALUES(N'Xã Thị Hoa', 124)
INSERT XAPHUONG VALUES(N'Xã Thống Nhất', 124)
INSERT XAPHUONG VALUES(N'Xã Vinh Quý', 124)

INSERT XAPHUONG VALUES(N'Thị trấn Thông Nông', 125)
INSERT XAPHUONG VALUES(N'Thị Trấn Xuân Hoà', 125)
INSERT XAPHUONG VALUES(N'Xã Cải Viên', 125)
INSERT XAPHUONG VALUES(N'Xã Cần Nông', 125)
INSERT XAPHUONG VALUES(N'Xã Cần Yên', 125)
INSERT XAPHUONG VALUES(N'Xã Đa Thông', 125)
INSERT XAPHUONG VALUES(N'Xã Hạ Thôn', 125)
INSERT XAPHUONG VALUES(N'Xã Hồng Sỹ', 125)
INSERT XAPHUONG VALUES(N'Xã Kéo Yên', 125)
INSERT XAPHUONG VALUES(N'Xã Lũng Nặm', 125)
INSERT XAPHUONG VALUES(N'Xã Lương Can', 125)
INSERT XAPHUONG VALUES(N'Xã Lương Thông', 125)
INSERT XAPHUONG VALUES(N'Xã Mã Ba', 125)
INSERT XAPHUONG VALUES(N'Xã Nà Sác', 125)
INSERT XAPHUONG VALUES(N'Xã Ngọc Đào', 125)
INSERT XAPHUONG VALUES(N'Xã Ngọc Động', 125)
INSERT XAPHUONG VALUES(N'Xã Nội Thôn', 125)
INSERT XAPHUONG VALUES(N'Xã Quý Quân', 125)
INSERT XAPHUONG VALUES(N'Xã Sĩ Hai', 125)
INSERT XAPHUONG VALUES(N'Xã Sóc Hà', 125)
INSERT XAPHUONG VALUES(N'Xã Thanh Long', 125)
INSERT XAPHUONG VALUES(N'Xã Thượng Thôn', 125)
INSERT XAPHUONG VALUES(N'Xã Tổng Cọt', 125)
INSERT XAPHUONG VALUES(N'Xã Trường Hà', 125)
INSERT XAPHUONG VALUES(N'Xã Vân An', 125)
INSERT XAPHUONG VALUES(N'Xã Vần Dính', 125)
INSERT XAPHUONG VALUES(N'Xã Yên Sơn', 125)

INSERT XAPHUONG VALUES(N'Thị trấn Nước Hai', 126)
INSERT XAPHUONG VALUES(N'Xã Bạch Đằng', 126)
INSERT XAPHUONG VALUES(N'Xã Bế Triều', 126)
INSERT XAPHUONG VALUES(N'Xã Bình Dương', 126)
INSERT XAPHUONG VALUES(N'Xã Bình Long', 126)
INSERT XAPHUONG VALUES(N'Xã Công Trừng', 126)
INSERT XAPHUONG VALUES(N'Xã Đại Tiến', 126)
INSERT XAPHUONG VALUES(N'Xã Dân Chủ', 126)
INSERT XAPHUONG VALUES(N'Xã Đức Long', 126)
INSERT XAPHUONG VALUES(N'Xã Đức Xuân', 126)
INSERT XAPHUONG VALUES(N'Xã Hà Trì', 126)
INSERT XAPHUONG VALUES(N'Xã Hoàng Tung', 126)
INSERT XAPHUONG VALUES(N'Xã Hồng Nam', 126)
INSERT XAPHUONG VALUES(N'Xã Hồng Việt', 126)
INSERT XAPHUONG VALUES(N'Xã Lê Chung', 126)
INSERT XAPHUONG VALUES(N'Xã Nam Tuấn', 126)
INSERT XAPHUONG VALUES(N'Xã Ngũ Lão', 126)
INSERT XAPHUONG VALUES(N'Xã Nguyễn Huệ', 126)
INSERT XAPHUONG VALUES(N'Xã Quang Trung', 126)
INSERT XAPHUONG VALUES(N'Xã Trưng Vương', 126)
INSERT XAPHUONG VALUES(N'Xã Trương Lương', 126)

INSERT XAPHUONG VALUES(N'Thị trấn Nguyên Bình', 127)
INSERT XAPHUONG VALUES(N'Thị trấn Tĩnh Túc', 127)
INSERT XAPHUONG VALUES(N'Xã Bắc Hợp', 127)
INSERT XAPHUONG VALUES(N'Xã Ca Thành', 127)
INSERT XAPHUONG VALUES(N'Xã Hoa Thám', 127)
INSERT XAPHUONG VALUES(N'Xã Hưng Đạo', 127)
INSERT XAPHUONG VALUES(N'Xã Lang Môn', 127)
INSERT XAPHUONG VALUES(N'Xã Mai Long', 127)
INSERT XAPHUONG VALUES(N'Xã Minh Tâm', 127)
INSERT XAPHUONG VALUES(N'Xã Minh Thanh', 127)
INSERT XAPHUONG VALUES(N'Xã Phan Thanh', 127)
INSERT XAPHUONG VALUES(N'Xã Quang Thành', 127)
INSERT XAPHUONG VALUES(N'Xã Tam Kim', 127)
INSERT XAPHUONG VALUES(N'Xã Thái Học', 127)
INSERT XAPHUONG VALUES(N'Xã Thành Công', 127)
INSERT XAPHUONG VALUES(N'Xã Thể Dục', 127)
INSERT XAPHUONG VALUES(N'Xã Thịnh Vượng', 127)
INSERT XAPHUONG VALUES(N'Xã Triệu Nguyên', 127)
INSERT XAPHUONG VALUES(N'Xã Vũ Minh', 127)
INSERT XAPHUONG VALUES(N'Xã Vũ Nông', 127)
INSERT XAPHUONG VALUES(N'Xã Yên Lạc', 127)

INSERT XAPHUONG VALUES(N'Thị Trấn Hòa Thuận', 128)
INSERT XAPHUONG VALUES(N'Thị trấn Tà Lùng', 128)
INSERT XAPHUONG VALUES(N'Xã Cách Linh', 128)
INSERT XAPHUONG VALUES(N'Xã Đại Sơn', 128)
INSERT XAPHUONG VALUES(N'Xã Hồng Đại', 128)
INSERT XAPHUONG VALUES(N'Xã Lương Thiện', 128)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hưng', 128)
INSERT XAPHUONG VALUES(N'Xã Tiên Thành', 128)
INSERT XAPHUONG VALUES(N'Xã Triệu ẩu', 128)

INSERT XAPHUONG VALUES(N'Thị trấn Hoà Thuận', 129)
INSERT XAPHUONG VALUES(N'Thị trấn Quảng Uyên', 129)
INSERT XAPHUONG VALUES(N'Thị trấn Tà Lùng', 129)
INSERT XAPHUONG VALUES(N'Xã Bế Văn Đàn', 129)
INSERT XAPHUONG VALUES(N'Xã Cách Linh', 129)
INSERT XAPHUONG VALUES(N'Xã Cai Bộ', 129)
INSERT XAPHUONG VALUES(N'Xã Chí Thảo', 129)
INSERT XAPHUONG VALUES(N'Xã Đại Sơn', 129)
INSERT XAPHUONG VALUES(N'Xã Độc Lập', 129)
INSERT XAPHUONG VALUES(N'Xã Hạnh Phúc', 129)
INSERT XAPHUONG VALUES(N'Xã Hồng Quang', 129)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hưng', 129)
INSERT XAPHUONG VALUES(N'Xã Ngọc Động', 129)
INSERT XAPHUONG VALUES(N'Xã Phi Hải', 129)
INSERT XAPHUONG VALUES(N'Xã Phúc Sen', 129)
INSERT XAPHUONG VALUES(N'Xã Quảng Hưng', 129)
INSERT XAPHUONG VALUES(N'Xã Quốc Toản', 129)
INSERT XAPHUONG VALUES(N'Xã Tiên Thành', 129)
INSERT XAPHUONG VALUES(N'Xã Tự Do', 129)

INSERT XAPHUONG VALUES(N'Thị trấn Quảng Uyên', 130)
INSERT XAPHUONG VALUES(N'Xã Bình Lăng', 130)
INSERT XAPHUONG VALUES(N'Xã Cai Bộ', 130)
INSERT XAPHUONG VALUES(N'Xã Chí Thảo', 130)
INSERT XAPHUONG VALUES(N'Xã Đoài Khôn', 130)
INSERT XAPHUONG VALUES(N'Xã Hạnh Phúc', 130)
INSERT XAPHUONG VALUES(N'Xã Hoàng Hải', 130)
INSERT XAPHUONG VALUES(N'Xã Hồng Định', 130)
INSERT XAPHUONG VALUES(N'Xã Hồng Quang', 130)
INSERT XAPHUONG VALUES(N'Xã Ngọc Động', 130)
INSERT XAPHUONG VALUES(N'Xã Phi Hải', 130)
INSERT XAPHUONG VALUES(N'Xã Phúc Sen', 130)
INSERT XAPHUONG VALUES(N'Xã Quảng Hưng', 130)
INSERT XAPHUONG VALUES(N'Xã Quốc Dân', 130)
INSERT XAPHUONG VALUES(N'Xã Quốc Phong', 130)
INSERT XAPHUONG VALUES(N'Xã Tự Do', 130)

INSERT XAPHUONG VALUES(N'Thị trấn Đông Khê', 131)
INSERT XAPHUONG VALUES(N'Xã Canh Tân', 131)
INSERT XAPHUONG VALUES(N'Xã Danh Sỹ', 131)
INSERT XAPHUONG VALUES(N'Xã Đức Long', 131)
INSERT XAPHUONG VALUES(N'Xã Đức Thông', 131)
INSERT XAPHUONG VALUES(N'Xã Đức Xuân', 131)
INSERT XAPHUONG VALUES(N'Xã Kim Đồng', 131)
INSERT XAPHUONG VALUES(N'Xã Lê Lai', 131)
INSERT XAPHUONG VALUES(N'Xã Lê Lợi', 131)
INSERT XAPHUONG VALUES(N'Xã Minh Khai', 131)
INSERT XAPHUONG VALUES(N'Xã Quang Trọng', 131)
INSERT XAPHUONG VALUES(N'Xã Thái Cường', 131)
INSERT XAPHUONG VALUES(N'Xã Thị Ngân', 131)
INSERT XAPHUONG VALUES(N'Xã Thuỵ Hùng', 131)
INSERT XAPHUONG VALUES(N'Xã Trọng Con', 131)
INSERT XAPHUONG VALUES(N'Xã Vân Trình', 131)

INSERT XAPHUONG VALUES(N'Thị trấn Hùng Quốc', 133)
INSERT XAPHUONG VALUES(N'Thị trấn Trà Lĩnh', 133)
INSERT XAPHUONG VALUES(N'Thị trấn Trùng Khánh', 133)
INSERT XAPHUONG VALUES(N'Xã Cảnh Tiên', 133)
INSERT XAPHUONG VALUES(N'Xã Cao Chương', 133)
INSERT XAPHUONG VALUES(N'Xã Cao Thăng', 133)
INSERT XAPHUONG VALUES(N'Xã Chí Viễn', 133)
INSERT XAPHUONG VALUES(N'Xã Cô Mười', 133)
INSERT XAPHUONG VALUES(N'Xã Đàm Thuỷ', 133)
INSERT XAPHUONG VALUES(N'Xã Đình Minh', 133)
INSERT XAPHUONG VALUES(N'Xã Đình Phong', 133)
INSERT XAPHUONG VALUES(N'Xã Đoài Côn', 133)
INSERT XAPHUONG VALUES(N'Xã Đoài Dương', 133)
INSERT XAPHUONG VALUES(N'Xã Đức Hồng', 133)
INSERT XAPHUONG VALUES(N'Xã Khâm Thành', 133)
INSERT XAPHUONG VALUES(N'Xã Lăng Hiếu', 133)
INSERT XAPHUONG VALUES(N'Xã Lăng Yên', 133)
INSERT XAPHUONG VALUES(N'Xã Lưu Ngọc', 133)
INSERT XAPHUONG VALUES(N'Xã Ngọc Chung', 133)
INSERT XAPHUONG VALUES(N'Xã Ngọc Côn', 133)
INSERT XAPHUONG VALUES(N'Xã Ngọc Khê', 133)
INSERT XAPHUONG VALUES(N'Xã Phong Châu', 133)
INSERT XAPHUONG VALUES(N'Xã Phong Nậm', 133)
INSERT XAPHUONG VALUES(N'Xã Quang Hán', 133)
INSERT XAPHUONG VALUES(N'Xã Quang Trung', 133)
INSERT XAPHUONG VALUES(N'Xã Quang Vinh', 133)
INSERT XAPHUONG VALUES(N'Xã Thân Giáp', 133)
INSERT XAPHUONG VALUES(N'Xã Thông Hoè', 133)
INSERT XAPHUONG VALUES(N'Xã Tri Phương', 133)
INSERT XAPHUONG VALUES(N'Xã Trung Phúc', 133)
INSERT XAPHUONG VALUES(N'Xã Xuân Nội', 133)

INSERT XAPHUONG VALUES(N'Phường Hợp Giang', 134)
INSERT XAPHUONG VALUES(N'Phường Sông Bằng', 134)
INSERT XAPHUONG VALUES(N'Phường Sông Hiến', 134)
INSERT XAPHUONG VALUES(N'Phường Tân Giang', 134)
INSERT XAPHUONG VALUES(N'Xã Chu Trinh', 134)
INSERT XAPHUONG VALUES(N'Xã Đề Thám', 134)
INSERT XAPHUONG VALUES(N'Xã Duyệt Trung', 134)
INSERT XAPHUONG VALUES(N'Xã Hoà Chung', 134)
INSERT XAPHUONG VALUES(N'Xã Hưng Đạo', 134)
INSERT XAPHUONG VALUES(N'Xã Ngọc Xuân', 134)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Quang', 134)

INSERT XAPHUONG VALUES(N'Phường Hoà An', 135)
INSERT XAPHUONG VALUES(N'Phường Hoà Phát', 135)
INSERT XAPHUONG VALUES(N'Phường Hoà Thọ Đông', 135)
INSERT XAPHUONG VALUES(N'Phường Hoà Thọ Tây', 135)
INSERT XAPHUONG VALUES(N'Phường Hoà Xuân', 135)
INSERT XAPHUONG VALUES(N'Phường Khuê Trung', 135)
INSERT XAPHUONG VALUES(N'Hòa Phát', 135)

INSERT XAPHUONG VALUES(N'Phường Bình Hiên', 136)
INSERT XAPHUONG VALUES(N'Phường Bình Thuận', 136)
INSERT XAPHUONG VALUES(N'Phường Hải Châu I', 136)
INSERT XAPHUONG VALUES(N'Phường Hải Châu II', 136)
INSERT XAPHUONG VALUES(N'Phường Hoà Cường Bắc', 136)
INSERT XAPHUONG VALUES(N'Phường Hoà Cường Nam', 136)
INSERT XAPHUONG VALUES(N'Phường Hoà Thuận Đông', 136)
INSERT XAPHUONG VALUES(N'Phường Hoà Thuận Tây', 136)
INSERT XAPHUONG VALUES(N'Phường Nam Dương', 136)
INSERT XAPHUONG VALUES(N'Phường Phước Ninh', 136)
INSERT XAPHUONG VALUES(N'Phường Thạch Thang', 136)
INSERT XAPHUONG VALUES(N'Phường Thanh Bình', 136)
INSERT XAPHUONG VALUES(N'Phường Thuận Phước', 136)

INSERT XAPHUONG VALUES(N'Phường Hoà Hiệp Bắc', 137)
INSERT XAPHUONG VALUES(N'Phường Hoà Hiệp Nam', 137)
INSERT XAPHUONG VALUES(N'Phường Hoà Khánh Bắc', 137)
INSERT XAPHUONG VALUES(N'Phường Hoà Khánh Nam', 137)
INSERT XAPHUONG VALUES(N'Phường Hoà Minh', 137)

INSERT XAPHUONG VALUES(N'Phường Hoà Hải', 138)
INSERT XAPHUONG VALUES(N'Phường Hoà Quý', 138)
INSERT XAPHUONG VALUES(N'Phường Khuê Mỹ', 138)
INSERT XAPHUONG VALUES(N'Phường Mỹ An', 138)

INSERT XAPHUONG VALUES(N'Phường An Hải Bắc', 139)
INSERT XAPHUONG VALUES(N'Phường An Hải Đông', 139)
INSERT XAPHUONG VALUES(N'Phường An Hải Tây', 139)
INSERT XAPHUONG VALUES(N'Phường Mân Thái', 139)
INSERT XAPHUONG VALUES(N'Phường Nại Hiên Đông', 139)
INSERT XAPHUONG VALUES(N'Phường Phước Mỹ', 139)
INSERT XAPHUONG VALUES(N'Phường Thọ Quang', 139)

INSERT XAPHUONG VALUES(N'Phường An Khê', 140)
INSERT XAPHUONG VALUES(N'Phường Chính Gián', 140)
INSERT XAPHUONG VALUES(N'Phường Hoà Khê', 140)
INSERT XAPHUONG VALUES(N'Phường Tam Thuận', 140)
INSERT XAPHUONG VALUES(N'Phường Tân Chính', 140)
INSERT XAPHUONG VALUES(N'Phường Thạc Gián', 140)
INSERT XAPHUONG VALUES(N'Phường Thanh Khê Đông', 140)
INSERT XAPHUONG VALUES(N'Phường Thanh Khê Tây', 140)
INSERT XAPHUONG VALUES(N'Phường Vĩnh Trung', 140)
INSERT XAPHUONG VALUES(N'Phường Xuân Hà', 140)

INSERT XAPHUONG VALUES(N'Xã Hoà Bắc', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Châu', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Khương', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Liên', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Nhơn', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Ninh', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Phong', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Phú', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Phước', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Sơn', 141)
INSERT XAPHUONG VALUES(N'Xã Hoà Tiến', 141)

INSERT XAPHUONG VALUES(N'Xã Cuôr KNia', 142)
INSERT XAPHUONG VALUES(N'Xã Ea Bar', 142)
INSERT XAPHUONG VALUES(N'Xã Ea Huar', 142)
INSERT XAPHUONG VALUES(N'Xã Ea Nuôl', 142)
INSERT XAPHUONG VALUES(N'Xã Ea Wer', 142)
INSERT XAPHUONG VALUES(N'Xã Krông Na', 142)
INSERT XAPHUONG VALUES(N'Xã Tân Hoà', 142)

INSERT XAPHUONG VALUES(N'Xã Cư Ê Wi', 143)
INSERT XAPHUONG VALUES(N'Xã Dray Bhăng', 143)
INSERT XAPHUONG VALUES(N'Xã Ea Bhốc', 143)
INSERT XAPHUONG VALUES(N'Xã Ea BHốk', 143)
INSERT XAPHUONG VALUES(N'Xã Ea Hu', 143)
INSERT XAPHUONG VALUES(N'Xã Ea Ktur', 143)
INSERT XAPHUONG VALUES(N'Xã Ea Ning', 143)
INSERT XAPHUONG VALUES(N'Xã Ea Tiêu', 143)
INSERT XAPHUONG VALUES(N'Xã Hòa Hiệp', 143)

INSERT XAPHUONG VALUES(N'Thị trấn Ea Pốk', 144)
INSERT XAPHUONG VALUES(N'Thị trấn Quảng Phú', 144)
INSERT XAPHUONG VALUES(N'Xã Cư Dliê M-nông', 144)
INSERT XAPHUONG VALUES(N'Xã Cư M-gar', 144)
INSERT XAPHUONG VALUES(N'Xã Cư Suê', 144)
INSERT XAPHUONG VALUES(N'Xã Cuor Đăng', 144)
INSERT XAPHUONG VALUES(N'Xã Ea D-Rơng', 144)
INSERT XAPHUONG VALUES(N'Xã Ea H-Đinh', 144)
INSERT XAPHUONG VALUES(N'Xã Ea Kiết', 144)
INSERT XAPHUONG VALUES(N'Xã Ea KPam', 144)
INSERT XAPHUONG VALUES(N'Xã Ea M-DRóh', 144)
INSERT XAPHUONG VALUES(N'Xã Ea M''nang', 144)
INSERT XAPHUONG VALUES(N'Xã Ea Tar', 144)
INSERT XAPHUONG VALUES(N'Xã Ea Tul', 144)
INSERT XAPHUONG VALUES(N'Xã Eakuêh', 144)
INSERT XAPHUONG VALUES(N'Xã Quảng Hiệp', 144)
INSERT XAPHUONG VALUES(N'Xã Quảng Tiến', 144)

INSERT XAPHUONG VALUES(N'Thị trấn Ea Drăng', 145)
INSERT XAPHUONG VALUES(N'Xã Cư A mung', 145)
INSERT XAPHUONG VALUES(N'Xã Cư Mốt', 145)
INSERT XAPHUONG VALUES(N'Xã Dliê Yang', 145)
INSERT XAPHUONG VALUES(N'Xã Ea H''leo', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Hiao', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Khal', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Nam', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Ral', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Sol', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Tir', 145)
INSERT XAPHUONG VALUES(N'Xã Ea Wy', 145)

INSERT XAPHUONG VALUES(N'Thị trấn Ea Kar', 146)
INSERT XAPHUONG VALUES(N'Thị trấn Ea Knốp', 146)
INSERT XAPHUONG VALUES(N'Xã Cư Bông', 146)
INSERT XAPHUONG VALUES(N'Xã Cư ELang', 146)
INSERT XAPHUONG VALUES(N'Xã Cư Huê', 146)
INSERT XAPHUONG VALUES(N'Xã Cư Ni', 146)
INSERT XAPHUONG VALUES(N'Xã Cư Prông', 146)
INSERT XAPHUONG VALUES(N'Xã Cư Yang', 146)
INSERT XAPHUONG VALUES(N'Xã Ea Đar', 146)
INSERT XAPHUONG VALUES(N'Xã Ea Kmút', 146)
INSERT XAPHUONG VALUES(N'Xã Ea ô', 146)
INSERT XAPHUONG VALUES(N'Xã Ea Păl', 146)
INSERT XAPHUONG VALUES(N'Xã Ea Păn', 146)
INSERT XAPHUONG VALUES(N'Xã Ea Sô', 146)
INSERT XAPHUONG VALUES(N'Xã Ea Tih', 146)
INSERT XAPHUONG VALUES(N'Xã EaSar', 146)
INSERT XAPHUONG VALUES(N'Xã Xuân Phú', 146)

INSERT XAPHUONG VALUES(N'Thị trấn Ea Súp', 147)
INSERT XAPHUONG VALUES(N'Xã Cư KBang', 147)
INSERT XAPHUONG VALUES(N'Xã Cư M-Lan', 147)
INSERT XAPHUONG VALUES(N'Xã Ea Bung', 147)
INSERT XAPHUONG VALUES(N'Xã Ea Lê', 147)
INSERT XAPHUONG VALUES(N'Xã Ea Rốk', 147)
INSERT XAPHUONG VALUES(N'Xã Ia JLơi', 147)
INSERT XAPHUONG VALUES(N'Xã Ia Lốp', 147)
INSERT XAPHUONG VALUES(N'Xã Ia Rvê', 147)
INSERT XAPHUONG VALUES(N'Xã Ya Tờ Mốt', 147)

INSERT XAPHUONG VALUES(N'Thị trấn Buôn Trấp', 148)
INSERT XAPHUONG VALUES(N'Xã Băng A Drênh', 148)
INSERT XAPHUONG VALUES(N'Xã Bình Hòa', 148)
INSERT XAPHUONG VALUES(N'Xã Dray Sáp', 148)
INSERT XAPHUONG VALUES(N'Xã Dur KMăl', 148)
INSERT XAPHUONG VALUES(N'Xã Ea Bông', 148)
INSERT XAPHUONG VALUES(N'Xã Ea Na', 148)
INSERT XAPHUONG VALUES(N'Xã Quảng Điền', 148)

INSERT XAPHUONG VALUES(N'Thị trấn Krông Kmar', 149)
INSERT XAPHUONG VALUES(N'Xã Cư Drăm', 149)
INSERT XAPHUONG VALUES(N'Xã Cư KTy', 149)
INSERT XAPHUONG VALUES(N'Xã Cư Pui', 149)
INSERT XAPHUONG VALUES(N'Xã Dang Kang', 149)
INSERT XAPHUONG VALUES(N'Xã Ea Trul', 149)
INSERT XAPHUONG VALUES(N'Xã Hòa Lễ', 149)
INSERT XAPHUONG VALUES(N'Xã Hòa Phong', 149)
INSERT XAPHUONG VALUES(N'Xã Hòa Sơn', 149)
INSERT XAPHUONG VALUES(N'Xã Hòa Tân', 149)
INSERT XAPHUONG VALUES(N'Xã Hòa Thành', 149)
INSERT XAPHUONG VALUES(N'Xã Khuê Ngọc Điền', 149)
INSERT XAPHUONG VALUES(N'Xã Yang Mao', 149)
INSERT XAPHUONG VALUES(N'Xã Yang Reh', 149)

INSERT XAPHUONG VALUES(N'Xã Chư Kbô', 150)
INSERT XAPHUONG VALUES(N'Xã Cư Né', 150)
INSERT XAPHUONG VALUES(N'Xã Cư Pơng', 150)
INSERT XAPHUONG VALUES(N'Xã Ea Ngai', 150)
INSERT XAPHUONG VALUES(N'Xã Ea Sin', 150)
INSERT XAPHUONG VALUES(N'Xã Pơng Drang', 150)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 150)

INSERT XAPHUONG VALUES(N'Thị trấn Krông Năng', 151)
INSERT XAPHUONG VALUES(N'Xã Cư Klông', 151)
INSERT XAPHUONG VALUES(N'Xã ĐLiê Ya', 151)
INSERT XAPHUONG VALUES(N'Xã Ea Đah', 151)
INSERT XAPHUONG VALUES(N'Xã Ea Hồ', 151)
INSERT XAPHUONG VALUES(N'Xã Ea Puk', 151)
INSERT XAPHUONG VALUES(N'Xã Ea Tam', 151)
INSERT XAPHUONG VALUES(N'Xã Ea Tân', 151)
INSERT XAPHUONG VALUES(N'Xã Ea Tóh', 151)
INSERT XAPHUONG VALUES(N'Xã Phú Lộc', 151)
INSERT XAPHUONG VALUES(N'Xã Phú Xuân', 151)
INSERT XAPHUONG VALUES(N'Xã Tam Giang', 151)

INSERT XAPHUONG VALUES(N'Thị trấn Phước An', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Hiu', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Kênh', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Kly', 152)
INSERT XAPHUONG VALUES(N'Xã Ea KNuec', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Kuăng', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Phê', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Uy', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Yiêng', 152)
INSERT XAPHUONG VALUES(N'Xã Ea Yông', 152)
INSERT XAPHUONG VALUES(N'Xã Hòa An', 152)
INSERT XAPHUONG VALUES(N'Xã Hoà Đông', 152)
INSERT XAPHUONG VALUES(N'Xã Hòa Tiến', 152)
INSERT XAPHUONG VALUES(N'Xã KRông Búk', 152)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 152)
INSERT XAPHUONG VALUES(N'Xã Vụ Bổn', 152)

INSERT XAPHUONG VALUES(N'Thị trấn Liên Sơn', 153)
INSERT XAPHUONG VALUES(N'Xã Bông Krang', 153)
INSERT XAPHUONG VALUES(N'Xã Buôn Tría', 153)
INSERT XAPHUONG VALUES(N'Xã Buôn Triết', 153)
INSERT XAPHUONG VALUES(N'Xã Đắk Liêng', 153)
INSERT XAPHUONG VALUES(N'Xã Đắk Nuê', 153)
INSERT XAPHUONG VALUES(N'Xã Đắk Phơi', 153)
INSERT XAPHUONG VALUES(N'Xã Ea R-Bin', 153)
INSERT XAPHUONG VALUES(N'Xã Krông Nô', 153)
INSERT XAPHUONG VALUES(N'Xã Nam Ka', 153)
INSERT XAPHUONG VALUES(N'Xã Yang Tao', 153)

INSERT XAPHUONG VALUES(N'Thị trấn M-Đrắk', 154)
INSERT XAPHUONG VALUES(N'xã Cư San', 154)
INSERT XAPHUONG VALUES(N'Xã Cư K Róa', 154)
INSERT XAPHUONG VALUES(N'Xã Cư M-ta', 154)
INSERT XAPHUONG VALUES(N'Xã Cư Prao', 154)
INSERT XAPHUONG VALUES(N'Xã Ea H''MLay', 154)
INSERT XAPHUONG VALUES(N'Xã Ea Lai', 154)
INSERT XAPHUONG VALUES(N'Xã Ea M- Doal', 154)
INSERT XAPHUONG VALUES(N'Xã Ea Pil', 154)
INSERT XAPHUONG VALUES(N'Xã Ea Riêng', 154)
INSERT XAPHUONG VALUES(N'Xã Ea Trang', 154)
INSERT XAPHUONG VALUES(N'Xã KRông á', 154)
INSERT XAPHUONG VALUES(N'Xã Krông Jing', 154)

INSERT XAPHUONG VALUES(N'Phường Ea Tam', 155)
INSERT XAPHUONG VALUES(N'Phường Khánh Xuân', 155)
INSERT XAPHUONG VALUES(N'Phường Tân An', 155)
INSERT XAPHUONG VALUES(N'Phường Tân Hoà', 155)
INSERT XAPHUONG VALUES(N'Phường Tân Lập', 155)
INSERT XAPHUONG VALUES(N'Phường Tân Lợi', 155)
INSERT XAPHUONG VALUES(N'Phường Tân Thành', 155)
INSERT XAPHUONG VALUES(N'Phường Tân Tiến', 155)
INSERT XAPHUONG VALUES(N'Phường Thắng Lợi', 155)
INSERT XAPHUONG VALUES(N'Phường Thành Công', 155)
INSERT XAPHUONG VALUES(N'Phường Thành Nhất', 155)
INSERT XAPHUONG VALUES(N'Phường Thống Nhất', 155)
INSERT XAPHUONG VALUES(N'Phường Tự An', 155)
INSERT XAPHUONG VALUES(N'Xã Cư êBur', 155)
INSERT XAPHUONG VALUES(N'Xã Ea Kao', 155)
INSERT XAPHUONG VALUES(N'Xã Ea Tu', 155)
INSERT XAPHUONG VALUES(N'Xã Hòa Khánh', 155)
INSERT XAPHUONG VALUES(N'Xã Hòa Phú', 155)
INSERT XAPHUONG VALUES(N'Xã Hòa Thắng', 155)
INSERT XAPHUONG VALUES(N'Xã Hòa Thuận', 155)
INSERT XAPHUONG VALUES(N'Xã Hòa Xuân', 155)

INSERT XAPHUONG VALUES(N'Phường An Bình', 156)
INSERT XAPHUONG VALUES(N'Phường An Lạc', 156)
INSERT XAPHUONG VALUES(N'Phường Bình Tân', 156)
INSERT XAPHUONG VALUES(N'Phường Đạt Hiếu', 156)
INSERT XAPHUONG VALUES(N'Phường Đoàn Kết', 156)
INSERT XAPHUONG VALUES(N'Phường Thiện An', 156)
INSERT XAPHUONG VALUES(N'Phường Thống Nhất', 156)
INSERT XAPHUONG VALUES(N'Xã Bình Thuận', 156)
INSERT XAPHUONG VALUES(N'Xã Cư Bao', 156)
INSERT XAPHUONG VALUES(N'Xã Ea Blang', 156)
INSERT XAPHUONG VALUES(N'Xã Ea Drông', 156)
INSERT XAPHUONG VALUES(N'Xã Ea Siên', 156)

INSERT XAPHUONG VALUES(N'Thị trấn Ea T-Ling', 157)
INSERT XAPHUONG VALUES(N'Xã Cư Knia', 157)
INSERT XAPHUONG VALUES(N'Xã Đắk DRông', 157)
INSERT XAPHUONG VALUES(N'Xã Đắk Wil', 157)
INSERT XAPHUONG VALUES(N'Xã Ea Pô', 157)
INSERT XAPHUONG VALUES(N'Xã Nam Dong', 157)
INSERT XAPHUONG VALUES(N'Xã Tâm Thắng', 157)
INSERT XAPHUONG VALUES(N'Xã Trúc Sơn', 157)

INSERT XAPHUONG VALUES(N'Xã Đắk Ha', 158)
INSERT XAPHUONG VALUES(N'Xã Đắk Plao', 158)
INSERT XAPHUONG VALUES(N'Xã Đắk R Măng', 158)
INSERT XAPHUONG VALUES(N'Xã Đắk Som', 158)
INSERT XAPHUONG VALUES(N'Xã Quảng Hoà', 158)
INSERT XAPHUONG VALUES(N'Xã Quảng Khê', 158)
INSERT XAPHUONG VALUES(N'Xã Quảng Sơn', 158)

INSERT XAPHUONG VALUES(N'Thị trấn Đắk Mil', 159)
INSERT XAPHUONG VALUES(N'Xã Đắk Gằn', 159)
INSERT XAPHUONG VALUES(N'Xã Đắk Lao', 159)
INSERT XAPHUONG VALUES(N'Xã Đắk N Drót', 159)
INSERT XAPHUONG VALUES(N'Xã Đắk R-La', 159)
INSERT XAPHUONG VALUES(N'Xã Đắk Sắk', 159)
INSERT XAPHUONG VALUES(N'Xã Đức Mạnh', 159)
INSERT XAPHUONG VALUES(N'Xã Đức Minh', 159)
INSERT XAPHUONG VALUES(N'Xã Long Sơn', 159)
INSERT XAPHUONG VALUES(N'Xã Thuận An', 159)

INSERT XAPHUONG VALUES(N'Thị trấn Kiến Đức', 160)
INSERT XAPHUONG VALUES(N'Xã Đắk Ru', 160)
INSERT XAPHUONG VALUES(N'Xã Đắk Sin', 160)
INSERT XAPHUONG VALUES(N'Xã Đắk Wer', 160)
INSERT XAPHUONG VALUES(N'Xã Đạo Nghĩa', 160)
INSERT XAPHUONG VALUES(N'Xã Hưng Bình', 160)
INSERT XAPHUONG VALUES(N'Xã Kiến Thành', 160)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Thắng', 160)
INSERT XAPHUONG VALUES(N'Xã Nhân Cơ', 160)
INSERT XAPHUONG VALUES(N'Xã Nhân Đạo', 160)
INSERT XAPHUONG VALUES(N'Xã Quảng Tín', 160)

INSERT XAPHUONG VALUES(N'Nam Bình', 161)
INSERT XAPHUONG VALUES(N'Thị trấn Đức An', 161)
INSERT XAPHUONG VALUES(N'Xã Đăk Hoà', 161)
INSERT XAPHUONG VALUES(N'Xã Đắk Môl', 161)
INSERT XAPHUONG VALUES(N'Xã Đắk N''Dung', 161)
INSERT XAPHUONG VALUES(N'Xã Nâm N Jang', 161)
INSERT XAPHUONG VALUES(N'Xã Thuận Hà', 161)
INSERT XAPHUONG VALUES(N'Xã Thuận Hạnh', 161)
INSERT XAPHUONG VALUES(N'Xã Trường Xuân', 161)

INSERT XAPHUONG VALUES(N'Thị trấn Đắk Mâm', 162)
INSERT XAPHUONG VALUES(N'Xã Buôn Choah', 162)
INSERT XAPHUONG VALUES(N'Xã Đắk Drô', 162)
INSERT XAPHUONG VALUES(N'Xã Đắk Nang', 162)
INSERT XAPHUONG VALUES(N'Xã Đắk Sôr', 162)
INSERT XAPHUONG VALUES(N'Xã Đức Xuyên', 162)
INSERT XAPHUONG VALUES(N'Xã Nam Đà', 162)
INSERT XAPHUONG VALUES(N'Xã Nâm Đir', 162)
INSERT XAPHUONG VALUES(N'Xã Nâm N''Đir', 162)
INSERT XAPHUONG VALUES(N'Xã Nâm Nung', 162)
INSERT XAPHUONG VALUES(N'Xã Nam Xuân', 162)
INSERT XAPHUONG VALUES(N'Xã Quảng Phú', 162)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 162)

INSERT XAPHUONG VALUES(N'Xã Đắk Búk So', 163)
INSERT XAPHUONG VALUES(N'Xã Đăk Ngo', 163)
INSERT XAPHUONG VALUES(N'Xã Đắk R-Tíh', 163)
INSERT XAPHUONG VALUES(N'Xã Quảng Tâm', 163)
INSERT XAPHUONG VALUES(N'Xã Quảng Tân', 163)
INSERT XAPHUONG VALUES(N'Xã Quảng Trực', 163)

INSERT XAPHUONG VALUES(N'Phường Nghĩa Đức', 164)
INSERT XAPHUONG VALUES(N'Phường Nghĩa Phú', 164)
INSERT XAPHUONG VALUES(N'Phường Nghĩa Tân', 164)
INSERT XAPHUONG VALUES(N'Phường Nghĩa Thành', 164)
INSERT XAPHUONG VALUES(N'Phường Nghĩa Trung', 164)
INSERT XAPHUONG VALUES(N'Phường Quảng Thành', 164)
INSERT XAPHUONG VALUES(N'Xã Đắk Nia', 164)
INSERT XAPHUONG VALUES(N'Xã Đăk R Moan', 164)

INSERT XAPHUONG VALUES(N'Hẹ Muông', 165)
INSERT XAPHUONG VALUES(N'Pom Lót', 165)
INSERT XAPHUONG VALUES(N'Xã Hua Thanh', 165)
INSERT XAPHUONG VALUES(N'Xã Mường Lói', 165)
INSERT XAPHUONG VALUES(N'Xã Mường Nhà', 165)
INSERT XAPHUONG VALUES(N'Xã Mường Pồn', 165)
INSERT XAPHUONG VALUES(N'Xã Na Tông', 165)
INSERT XAPHUONG VALUES(N'Xã Na ư', 165)
INSERT XAPHUONG VALUES(N'Xã Noong Hẹt', 165)
INSERT XAPHUONG VALUES(N'Xã Noong Luống', 165)
INSERT XAPHUONG VALUES(N'Xã Núa Ngam', 165)
INSERT XAPHUONG VALUES(N'Xã Pa Thơm', 165)
INSERT XAPHUONG VALUES(N'Xã Phu Luông', 165)
INSERT XAPHUONG VALUES(N'Xã Sam Mứn', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh An', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh Chăn', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh Hưng', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh Luông', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh Nưa', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh Xương', 165)
INSERT XAPHUONG VALUES(N'Xã Thanh Yên', 165)

INSERT XAPHUONG VALUES(N'Nong U', 166)
INSERT XAPHUONG VALUES(N'Pú Hồng', 166)
INSERT XAPHUONG VALUES(N'Thị trấn Điện Biên Đông', 166)
INSERT XAPHUONG VALUES(N'Tìa Dình', 166)
INSERT XAPHUONG VALUES(N'Xã Chiềng Sơ', 166)
INSERT XAPHUONG VALUES(N'Xã Háng Lìa', 166)
INSERT XAPHUONG VALUES(N'Xã Keo Lôm', 166)
INSERT XAPHUONG VALUES(N'Xã Luân Giói', 166)
INSERT XAPHUONG VALUES(N'Xã Mường Luân', 166)
INSERT XAPHUONG VALUES(N'Xã Na Son', 166)
INSERT XAPHUONG VALUES(N'Xã Phì Nhừ', 166)
INSERT XAPHUONG VALUES(N'Xã Phình Giàng', 166)
INSERT XAPHUONG VALUES(N'Xã Pú Nhi', 166)
INSERT XAPHUONG VALUES(N'Xã Xa Dung', 166)

INSERT XAPHUONG VALUES(N'Thị Trấn Mường ảng', 167)
INSERT XAPHUONG VALUES(N'Xã Ẳng Cang', 167)
INSERT XAPHUONG VALUES(N'Xã ảng nưa', 167)
INSERT XAPHUONG VALUES(N'Xã ảng tở', 167)
INSERT XAPHUONG VALUES(N'Xã Búng Lao', 167)
INSERT XAPHUONG VALUES(N'Xã Mường Đăng', 167)
INSERT XAPHUONG VALUES(N'Xã Mường Lạn', 167)
INSERT XAPHUONG VALUES(N'Xã Nặm Lịch', 167)
INSERT XAPHUONG VALUES(N'Xã Nậm Lịch', 167)
INSERT XAPHUONG VALUES(N'Xã Ngối Cáy', 167)
INSERT XAPHUONG VALUES(N'Xã Xuân Lao', 167)

INSERT XAPHUONG VALUES(N'Huối Mí', 168)
INSERT XAPHUONG VALUES(N'Ma Thì Hồ', 168)
INSERT XAPHUONG VALUES(N'Na Sang', 168)
INSERT XAPHUONG VALUES(N'Nậm Nèn', 168)
INSERT XAPHUONG VALUES(N'Sa Lông', 168)
INSERT XAPHUONG VALUES(N'Thị trấn Mường Chà', 168)
INSERT XAPHUONG VALUES(N'Xã Hừa Ngài', 168)
INSERT XAPHUONG VALUES(N'Xã Huổi Lèng', 168)
INSERT XAPHUONG VALUES(N'Xã Mường Mươn', 168)
INSERT XAPHUONG VALUES(N'Xã Mường Tùng', 168)
INSERT XAPHUONG VALUES(N'Xã Pa Ham', 168)
INSERT XAPHUONG VALUES(N'Xã Xá Tổng', 168)

INSERT XAPHUONG VALUES(N'Xã Chung Chải', 169)
INSERT XAPHUONG VALUES(N'Xã Huổi Lếnh', 169)
INSERT XAPHUONG VALUES(N'Xã Leng Su Sìn', 169)
INSERT XAPHUONG VALUES(N'Xã Mường Nhé', 169)
INSERT XAPHUONG VALUES(N'Xã Mường Toong', 169)
INSERT XAPHUONG VALUES(N'Xã Nậm Kè', 169)
INSERT XAPHUONG VALUES(N'Xã Nậm Vì', 169)
INSERT XAPHUONG VALUES(N'Xã Pá Mỳ', 169)
INSERT XAPHUONG VALUES(N'Xã Quảng Lâm', 169)
INSERT XAPHUONG VALUES(N'Xã Sen Thượng', 169)
INSERT XAPHUONG VALUES(N'Xã Sín Thầu', 169)

INSERT XAPHUONG VALUES(N'Nậm Chua', 170)
INSERT XAPHUONG VALUES(N'Xã Chà Cang', 170)
INSERT XAPHUONG VALUES(N'Xã Chà Nưa', 170)
INSERT XAPHUONG VALUES(N'Xã Chà Tở', 170)
INSERT XAPHUONG VALUES(N'Xã Nà Bủng', 170)
INSERT XAPHUONG VALUES(N'Xã Na Cô Sa', 170)
INSERT XAPHUONG VALUES(N'Xã Nà Hỳ', 170)
INSERT XAPHUONG VALUES(N'Xã Nà Khoa', 170)
INSERT XAPHUONG VALUES(N'Xã Nậm Khăn', 170)
INSERT XAPHUONG VALUES(N'Xã Nậm Nhừ', 170)
INSERT XAPHUONG VALUES(N'Xã Nậm Tin', 170)
INSERT XAPHUONG VALUES(N'Xã Pa Tần', 170)
INSERT XAPHUONG VALUES(N'Xã Phìn Hồ', 170)
INSERT XAPHUONG VALUES(N'Xã Si Pa Phìn', 170)
INSERT XAPHUONG VALUES(N'Xã Vàng Đán', 170)

INSERT XAPHUONG VALUES(N'Thị trấn Tủa Chùa', 171)
INSERT XAPHUONG VALUES(N'Xã Huổi Só', 171)
INSERT XAPHUONG VALUES(N'Xã Lao Xả Phình', 171)
INSERT XAPHUONG VALUES(N'Xã Mường Báng', 171)
INSERT XAPHUONG VALUES(N'Xã Mường Đun', 171)
INSERT XAPHUONG VALUES(N'Xã Sáng Nhè', 171)
INSERT XAPHUONG VALUES(N'Xã Sính Phình', 171)
INSERT XAPHUONG VALUES(N'Xã Tả Phìn', 171)
INSERT XAPHUONG VALUES(N'Xã Tả Sìn Thàng', 171)
INSERT XAPHUONG VALUES(N'Xã Trung Thu', 171)
INSERT XAPHUONG VALUES(N'Xã Tủa Thàng', 171)
INSERT XAPHUONG VALUES(N'Xã Xín Chải', 171)

INSERT XAPHUONG VALUES(N'Pú Xi', 172)
INSERT XAPHUONG VALUES(N'Thị trấn Tuần Giáo', 172)
INSERT XAPHUONG VALUES(N'Xã Chiềng Đông', 172)
INSERT XAPHUONG VALUES(N'Xã Chiềng Sinh', 172)
INSERT XAPHUONG VALUES(N'Xã Mùn Chung', 172)
INSERT XAPHUONG VALUES(N'Xã Mường Khong', 172)
INSERT XAPHUONG VALUES(N'Xã Mường Mùn', 172)
INSERT XAPHUONG VALUES(N'Xã Mường Thín', 172)
INSERT XAPHUONG VALUES(N'Xã Nà Sáy', 172)
INSERT XAPHUONG VALUES(N'Xã Nà Tòng', 172)
INSERT XAPHUONG VALUES(N'Xã Phình Sáng', 172)
INSERT XAPHUONG VALUES(N'Xã Pú Nhung', 172)
INSERT XAPHUONG VALUES(N'Xã Quài Cang', 172)
INSERT XAPHUONG VALUES(N'Xã Quài Nưa', 172)
INSERT XAPHUONG VALUES(N'Xã Quài Tở', 172)
INSERT XAPHUONG VALUES(N'Xã Rạng Đông', 172)
INSERT XAPHUONG VALUES(N'Xã Ta Ma', 172)
INSERT XAPHUONG VALUES(N'Xã Tênh Phông', 172)
INSERT XAPHUONG VALUES(N'Xã Tỏa Tình', 172)

INSERT XAPHUONG VALUES(N'Phường Him Lam', 173)
INSERT XAPHUONG VALUES(N'Phường Mường Thanh', 173)
INSERT XAPHUONG VALUES(N'Phường Nam Thanh', 173)
INSERT XAPHUONG VALUES(N'Phường Noong Bua', 173)
INSERT XAPHUONG VALUES(N'Phường Tân Thanh', 173)
INSERT XAPHUONG VALUES(N'Phường Thanh Bình', 173)
INSERT XAPHUONG VALUES(N'Phường Thanh Trường', 173)
INSERT XAPHUONG VALUES(N'Xã Mường Phăng', 173)
INSERT XAPHUONG VALUES(N'Xã Nà Nhạn', 173)
INSERT XAPHUONG VALUES(N'Xã Nà Tấu', 173)
INSERT XAPHUONG VALUES(N'Xã Pá Khoang', 173)
INSERT XAPHUONG VALUES(N'Xã Tà Lèng', 173)
INSERT XAPHUONG VALUES(N'Xã Thanh Minh', 173)

INSERT XAPHUONG VALUES(N'Phường Na Lay', 174)
INSERT XAPHUONG VALUES(N'Phường Sông Đà', 174)
INSERT XAPHUONG VALUES(N'Xã Lay Nưa', 174)

INSERT XAPHUONG VALUES(N'Xã Bảo Bình', 175)
INSERT XAPHUONG VALUES(N'Xã Lâm San', 175)
INSERT XAPHUONG VALUES(N'Xã Long Giao', 175)
INSERT XAPHUONG VALUES(N'Xã Nhân Nghĩa', 175)
INSERT XAPHUONG VALUES(N'Xã Sông Nhạn', 175)
INSERT XAPHUONG VALUES(N'Xã Sông Ray', 175)
INSERT XAPHUONG VALUES(N'Xã Thừa Đức', 175)
INSERT XAPHUONG VALUES(N'Xã Xuân Bảo', 175)
INSERT XAPHUONG VALUES(N'Xã Xuân Đông', 175)
INSERT XAPHUONG VALUES(N'Xã Xuân Đường', 175)
INSERT XAPHUONG VALUES(N'Xã Xuân Mỹ', 175)
INSERT XAPHUONG VALUES(N'Xã Xuân Quế', 175)
INSERT XAPHUONG VALUES(N'Xã Xuân Tây', 175)

INSERT XAPHUONG VALUES(N'Thị trấn Định Quán', 176)
INSERT XAPHUONG VALUES(N'Xã Gia Canh', 176)
INSERT XAPHUONG VALUES(N'Xã La Ngà', 176)
INSERT XAPHUONG VALUES(N'Xã Ngọc Định', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Cường', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Hòa', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Lợi', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Ngọc', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Tân', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Túc', 176)
INSERT XAPHUONG VALUES(N'Xã Phú Vinh', 176)
INSERT XAPHUONG VALUES(N'Xã Suối Nho', 176)
INSERT XAPHUONG VALUES(N'Xã Thanh Sơn', 176)
INSERT XAPHUONG VALUES(N'Xã Túc Trưng', 176)

INSERT XAPHUONG VALUES(N'Thị trấn Long Thành', 177)
INSERT XAPHUONG VALUES(N'Xã An Phước', 177)
INSERT XAPHUONG VALUES(N'Xã Bàu Cạn', 177)
INSERT XAPHUONG VALUES(N'Xã Bình An', 177)
INSERT XAPHUONG VALUES(N'Xã Bình Sơn', 177)
INSERT XAPHUONG VALUES(N'Xã Cẩm Đường', 177)
INSERT XAPHUONG VALUES(N'Xã Lộc An', 177)
INSERT XAPHUONG VALUES(N'Xã Long An', 177)
INSERT XAPHUONG VALUES(N'Xã Long Đức', 177)
INSERT XAPHUONG VALUES(N'Xã Long Phước', 177)
INSERT XAPHUONG VALUES(N'Xã Phước Bình', 177)
INSERT XAPHUONG VALUES(N'Xã Phước Thái', 177)
INSERT XAPHUONG VALUES(N'Xã Suối Trầu', 177)
INSERT XAPHUONG VALUES(N'Xã Tam An', 177)
INSERT XAPHUONG VALUES(N'Xã Tân Hiệp', 177)

INSERT XAPHUONG VALUES(N'Xã Đại Phước', 178)
INSERT XAPHUONG VALUES(N'Xã Hiệp Phước', 178)
INSERT XAPHUONG VALUES(N'Xã Long Tân', 178)
INSERT XAPHUONG VALUES(N'Xã Long Thọ', 178)
INSERT XAPHUONG VALUES(N'Xã Phú Đông', 178)
INSERT XAPHUONG VALUES(N'Xã Phú Hội', 178)
INSERT XAPHUONG VALUES(N'Xã Phú Hữu', 178)
INSERT XAPHUONG VALUES(N'Xã Phú Thạnh', 178)
INSERT XAPHUONG VALUES(N'Xã Phước An', 178)
INSERT XAPHUONG VALUES(N'Xã Phước Khánh', 178)
INSERT XAPHUONG VALUES(N'Xã Phước Thiền', 178)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thanh', 178)

INSERT XAPHUONG VALUES(N'Đắc Lua', 179)
INSERT XAPHUONG VALUES(N'Thị trấn Tân Phú', 179)
INSERT XAPHUONG VALUES(N'Xã Dak Lua', 179)
INSERT XAPHUONG VALUES(N'Xã Nam Cát Tiên', 179)
INSERT XAPHUONG VALUES(N'Xã Núi Tượng', 179)
INSERT XAPHUONG VALUES(N'Xã Phú An', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Bình', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Điền', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Lâm', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Lập', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Lộc', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Sơn', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Thanh', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Thịnh', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Trung', 179)
INSERT XAPHUONG VALUES(N'Xã Phú Xuân', 179)
INSERT XAPHUONG VALUES(N'Xã Tà Lài', 179)
INSERT XAPHUONG VALUES(N'Xã Thanh Sơn', 179)
INSERT XAPHUONG VALUES(N'Xã Trà Cổ', 179)

INSERT XAPHUONG VALUES(N'Thị Trấn Dầu Giây', 180)
INSERT XAPHUONG VALUES(N'Xã Bàu Hàm 2', 180)
INSERT XAPHUONG VALUES(N'Xã Gia Kiệm', 180)
INSERT XAPHUONG VALUES(N'Xã Gia Tân 1', 180)
INSERT XAPHUONG VALUES(N'Xã Gia Tân 2', 180)
INSERT XAPHUONG VALUES(N'Xã Gia Tân 3', 180)
INSERT XAPHUONG VALUES(N'Xã Hưng Lộc', 180)
INSERT XAPHUONG VALUES(N'Xã Lộ 25', 180)
INSERT XAPHUONG VALUES(N'Xã Quang Trung', 180)
INSERT XAPHUONG VALUES(N'Xã Xuân Thạnh', 180)
INSERT XAPHUONG VALUES(N'Xã Xuân Thiện', 180)

INSERT XAPHUONG VALUES(N'Thị trấn Trảng Bom', 181)
INSERT XAPHUONG VALUES(N'Xã An Viễn', 181)
INSERT XAPHUONG VALUES(N'Xã Bắc Sơn', 181)
INSERT XAPHUONG VALUES(N'Xã Bàu Hàm', 181)
INSERT XAPHUONG VALUES(N'Xã Bình Minh', 181)
INSERT XAPHUONG VALUES(N'Xã Cây Gáo', 181)
INSERT XAPHUONG VALUES(N'Xã Đồi 61', 181)
INSERT XAPHUONG VALUES(N'Xã Đông Hoà', 181)
INSERT XAPHUONG VALUES(N'Xã Giang Điền', 181)
INSERT XAPHUONG VALUES(N'Xã Hố Nai 3', 181)
INSERT XAPHUONG VALUES(N'Xã Hưng Thịnh', 181)
INSERT XAPHUONG VALUES(N'Xã Quảng Tiến', 181)
INSERT XAPHUONG VALUES(N'Xã Sông Thao', 181)
INSERT XAPHUONG VALUES(N'Xã Sông Trầu', 181)
INSERT XAPHUONG VALUES(N'Xã Tây Hoà', 181)
INSERT XAPHUONG VALUES(N'Xã Thanh Bình', 181)
INSERT XAPHUONG VALUES(N'Xã Trung Hoà', 181)

INSERT XAPHUONG VALUES(N'Thị trấn Vĩnh An', 182)
INSERT XAPHUONG VALUES(N'Xã Bình Hòa', 182)
INSERT XAPHUONG VALUES(N'Xã Bình Lợi', 182)
INSERT XAPHUONG VALUES(N'Xã Hiếu Liêm', 182)
INSERT XAPHUONG VALUES(N'Xã Mã Đà', 182)
INSERT XAPHUONG VALUES(N'Xã Phú Lý', 182)
INSERT XAPHUONG VALUES(N'Xã Tân An', 182)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 182)
INSERT XAPHUONG VALUES(N'Xã Thạnh Phú', 182)
INSERT XAPHUONG VALUES(N'Xã Thiện Tân', 182)
INSERT XAPHUONG VALUES(N'Xã Trị An', 182)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Tân', 182)

INSERT XAPHUONG VALUES(N'Thị trấn Gia Ray', 183)
INSERT XAPHUONG VALUES(N'Xã Bảo Hoà', 183)
INSERT XAPHUONG VALUES(N'Xã Lang Minh', 183)
INSERT XAPHUONG VALUES(N'Xã Suối Cao', 183)
INSERT XAPHUONG VALUES(N'Xã Suối Cát', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Bắc', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Định', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Hiệp', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Hòa', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Hưng', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Phú', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Tâm', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Thành', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Thọ', 183)
INSERT XAPHUONG VALUES(N'Xã Xuân Trường', 183)

INSERT XAPHUONG VALUES(N'Phường An Bình', 184)
INSERT XAPHUONG VALUES(N'Phường An Hòa', 184)
INSERT XAPHUONG VALUES(N'Phường Bình Đa', 184)
INSERT XAPHUONG VALUES(N'Phường Bửu Hòa', 184)
INSERT XAPHUONG VALUES(N'Phường Bửu Long', 184)
INSERT XAPHUONG VALUES(N'Phường Hố Nai', 184)
INSERT XAPHUONG VALUES(N'Phường Hòa Bình', 184)
INSERT XAPHUONG VALUES(N'Phường Long Bình', 184)
INSERT XAPHUONG VALUES(N'Phường Long Bình Tân', 184)
INSERT XAPHUONG VALUES(N'Phường Phước Tân', 184)
INSERT XAPHUONG VALUES(N'Phường Quang Vinh', 184)
INSERT XAPHUONG VALUES(N'Phường Quyết Thắng', 184)
INSERT XAPHUONG VALUES(N'Phường Tam Hiệp', 184)
INSERT XAPHUONG VALUES(N'Phường Tam Hòa', 184)
INSERT XAPHUONG VALUES(N'Phường Tam Phước', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Biên', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Hạnh', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Hiệp', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Hòa', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Mai', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Phong', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Tiến', 184)
INSERT XAPHUONG VALUES(N'Phường Tân Vạn', 184)
INSERT XAPHUONG VALUES(N'Phường Thanh Bình', 184)
INSERT XAPHUONG VALUES(N'Phường Thống Nhất', 184)
INSERT XAPHUONG VALUES(N'Phường Trảng Dài', 184)
INSERT XAPHUONG VALUES(N'Phường Trung Dũng', 184)
INSERT XAPHUONG VALUES(N'Xã Hiệp Hòa', 184)
INSERT XAPHUONG VALUES(N'Xã Hóa An', 184)
INSERT XAPHUONG VALUES(N'Xã Long Hưng', 184)

INSERT XAPHUONG VALUES(N'Phường Bàu Sen', 185)
INSERT XAPHUONG VALUES(N'Phường Phú Bình', 185)
INSERT XAPHUONG VALUES(N'Phường Suối Tre', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân An', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân Bình', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân Hoà', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân Lập', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân Tân', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân Thanh', 185)
INSERT XAPHUONG VALUES(N'Phường Xuân Trung', 185)
INSERT XAPHUONG VALUES(N'Xã Bảo Quang', 185)
INSERT XAPHUONG VALUES(N'Xã Bảo Vinh', 185)
INSERT XAPHUONG VALUES(N'Xã Bàu Trâm', 185)
INSERT XAPHUONG VALUES(N'Xã Bình Lộc', 185)
INSERT XAPHUONG VALUES(N'Xã Hàng Gòn', 185)

INSERT XAPHUONG VALUES(N'Thị trấn Mỹ Thọ', 186)
INSERT XAPHUONG VALUES(N'Xã An Bình', 186)
INSERT XAPHUONG VALUES(N'Xã Ba Sao', 186)
INSERT XAPHUONG VALUES(N'Xã Bình Hàng Tây', 186)
INSERT XAPHUONG VALUES(N'Xã Bình Hàng Trung', 186)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh', 186)
INSERT XAPHUONG VALUES(N'Xã Gáo Giồng', 186)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hiệp', 186)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hội', 186)
INSERT XAPHUONG VALUES(N'Xã Mỹ Long', 186)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thọ', 186)
INSERT XAPHUONG VALUES(N'Xã Mỹ Xương', 186)
INSERT XAPHUONG VALUES(N'Xã Nhị Mỹ', 186)
INSERT XAPHUONG VALUES(N'Xã Phong Mỹ', 186)
INSERT XAPHUONG VALUES(N'Xã Phương Thịnh', 186)
INSERT XAPHUONG VALUES(N'Xã Phương Trà', 186)
INSERT XAPHUONG VALUES(N'Xã Tân Hội Trung', 186)
INSERT XAPHUONG VALUES(N'Xã Tân Nghĩa', 186)

INSERT XAPHUONG VALUES(N'Thị trấn Cái Tàu Hạ', 187)
INSERT XAPHUONG VALUES(N'Xã An Hiệp', 187)
INSERT XAPHUONG VALUES(N'Xã An Khánh', 187)
INSERT XAPHUONG VALUES(N'Xã An Nhơn', 187)
INSERT XAPHUONG VALUES(N'Xã An Phú Thuận', 187)
INSERT XAPHUONG VALUES(N'Xã Hòa Tân', 187)
INSERT XAPHUONG VALUES(N'Xã Phú Hựu', 187)
INSERT XAPHUONG VALUES(N'Xã Phú Long', 187)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 187)
INSERT XAPHUONG VALUES(N'Xã Tân Nhuận Đông', 187)
INSERT XAPHUONG VALUES(N'Xã Tân Phú', 187)
INSERT XAPHUONG VALUES(N'Xã Tân Phú Trung', 187)

INSERT XAPHUONG VALUES(N'Thị Trấn Thường Thới Tiền', 188)
INSERT XAPHUONG VALUES(N'Xã Long Khánh A', 188)
INSERT XAPHUONG VALUES(N'Xã Long Khánh B', 188)
INSERT XAPHUONG VALUES(N'Xã Long Thuận', 188)
INSERT XAPHUONG VALUES(N'Xã Phú Thuận A', 188)
INSERT XAPHUONG VALUES(N'Xã Phú Thuận B', 188)
INSERT XAPHUONG VALUES(N'Xã Thường Lạc', 188)
INSERT XAPHUONG VALUES(N'Xã Thường Phước 1', 188)
INSERT XAPHUONG VALUES(N'Xã Thường Phước 2', 188)
INSERT XAPHUONG VALUES(N'Xã Thường Thới Hậu A', 188)
INSERT XAPHUONG VALUES(N'Xã Thường Thới Hậu B', 188)

INSERT XAPHUONG VALUES(N'Thị trấn Lai Vung', 189)
INSERT XAPHUONG VALUES(N'Xã Định Hòa', 189)
INSERT XAPHUONG VALUES(N'Xã Hòa Long', 189)
INSERT XAPHUONG VALUES(N'Xã Hòa Thành', 189)
INSERT XAPHUONG VALUES(N'Xã Long Hậu', 189)
INSERT XAPHUONG VALUES(N'Xã Long Thắng', 189)
INSERT XAPHUONG VALUES(N'Xã Phong Hòa', 189)
INSERT XAPHUONG VALUES(N'Xã Tân Dương', 189)
INSERT XAPHUONG VALUES(N'Xã Tân Hòa', 189)
INSERT XAPHUONG VALUES(N'Xã Tân Phước', 189)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 189)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thới', 189)

INSERT XAPHUONG VALUES(N'Thị trấn Lấp Vò', 190)
INSERT XAPHUONG VALUES(N'Xã Bình Thành', 190)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh Trung', 190)
INSERT XAPHUONG VALUES(N'Xã Định An', 190)
INSERT XAPHUONG VALUES(N'Xã Định Yên', 190)
INSERT XAPHUONG VALUES(N'Xã Hội An Đông', 190)
INSERT XAPHUONG VALUES(N'Xã Long Hưng A', 190)
INSERT XAPHUONG VALUES(N'Xã Long Hưng B', 190)
INSERT XAPHUONG VALUES(N'Xã Mỹ An Hưng A', 190)
INSERT XAPHUONG VALUES(N'Xã Mỹ An Hưng B', 190)
INSERT XAPHUONG VALUES(N'Xã Tân Khánh Trung', 190)
INSERT XAPHUONG VALUES(N'Xã Tân Mỹ', 190)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Thạnh', 190)

INSERT XAPHUONG VALUES(N'Thị trấn Tràm Chim', 191)
INSERT XAPHUONG VALUES(N'Xã An Hòa', 191)
INSERT XAPHUONG VALUES(N'Xã An Long', 191)
INSERT XAPHUONG VALUES(N'Xã Hoà Bình', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Cường', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Đức', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Hiệp', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Ninh', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Thành A', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Thành B', 191)
INSERT XAPHUONG VALUES(N'Xã Phú Thọ', 191)
INSERT XAPHUONG VALUES(N'Xã Tân Công Sính', 191)

INSERT XAPHUONG VALUES(N'Thị trấn Sa Rài', 192)
INSERT XAPHUONG VALUES(N'Xã An Phước', 192)
INSERT XAPHUONG VALUES(N'Xã Bình Phú', 192)
INSERT XAPHUONG VALUES(N'Xã Tân Công Chí', 192)
INSERT XAPHUONG VALUES(N'Xã Tân Hộ Cơ', 192)
INSERT XAPHUONG VALUES(N'Xã Tân Phước', 192)
INSERT XAPHUONG VALUES(N'Xã Tân Thành A', 192)
INSERT XAPHUONG VALUES(N'Xã Tân Thành B', 192)
INSERT XAPHUONG VALUES(N'Xã Thông Bình', 192)

INSERT XAPHUONG VALUES(N'Thị trấn Thanh Bình', 193)
INSERT XAPHUONG VALUES(N'Xã An Phong', 193)
INSERT XAPHUONG VALUES(N'Xã Bình Tấn', 193)
INSERT XAPHUONG VALUES(N'Xã Bình Thành', 193)
INSERT XAPHUONG VALUES(N'Xã Phú Lợi', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Hòa', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Huề', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Long', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Mỹ', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Phú', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Quới', 193)
INSERT XAPHUONG VALUES(N'Xã Tân Thạnh', 193)

INSERT XAPHUONG VALUES(N'Thị trấn Mỹ An', 194)
INSERT XAPHUONG VALUES(N'Xã Đốc Binh Kiều', 194)
INSERT XAPHUONG VALUES(N'Xã Hưng Thạnh', 194)
INSERT XAPHUONG VALUES(N'Xã Láng Biển', 194)
INSERT XAPHUONG VALUES(N'Xã Mỹ An', 194)
INSERT XAPHUONG VALUES(N'Xã Mỹ Đông', 194)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hòa', 194)
INSERT XAPHUONG VALUES(N'Xã Mỹ Quý', 194)
INSERT XAPHUONG VALUES(N'Xã Phú Điền', 194)
INSERT XAPHUONG VALUES(N'Xã Tân Kiều', 194)
INSERT XAPHUONG VALUES(N'Xã Thạnh Lợi', 194)
INSERT XAPHUONG VALUES(N'Xã Thanh Mỹ', 194)
INSERT XAPHUONG VALUES(N'Xã Trường Xuân', 194)

INSERT XAPHUONG VALUES(N'Phường 1', 195)
INSERT XAPHUONG VALUES(N'Phường 2', 195)
INSERT XAPHUONG VALUES(N'Phường 3', 195)
INSERT XAPHUONG VALUES(N'Phường 4', 195)
INSERT XAPHUONG VALUES(N'Phường 6', 195)
INSERT XAPHUONG VALUES(N'Phường 11', 195)
INSERT XAPHUONG VALUES(N'Phường Hoà Thuận', 195)
INSERT XAPHUONG VALUES(N'Phường Mỹ Phú', 195)
INSERT XAPHUONG VALUES(N'Xã Hòa An', 195)
INSERT XAPHUONG VALUES(N'Xã Mỹ Ngãi', 195)
INSERT XAPHUONG VALUES(N'Xã Mỹ Tân', 195)
INSERT XAPHUONG VALUES(N'Xã Mỹ Trà', 195)
INSERT XAPHUONG VALUES(N'Xã Tân Thuận Đông', 195)
INSERT XAPHUONG VALUES(N'Xã Tân Thuận Tây', 195)
INSERT XAPHUONG VALUES(N'Xã Tịnh Thới', 195)

INSERT XAPHUONG VALUES(N'Phường An Bình A', 196)
INSERT XAPHUONG VALUES(N'Phường An Bình B', 196)
INSERT XAPHUONG VALUES(N'Phường An Lạc', 196)
INSERT XAPHUONG VALUES(N'Phường An Lộc', 196)
INSERT XAPHUONG VALUES(N'Phường An Thạnh', 196)
INSERT XAPHUONG VALUES(N'Xã Bình Thạnh', 196)
INSERT XAPHUONG VALUES(N'Xã Tân Hội', 196)

INSERT XAPHUONG VALUES(N'Phường 1', 197)
INSERT XAPHUONG VALUES(N'Phường 2', 197)
INSERT XAPHUONG VALUES(N'Phường 3', 197)
INSERT XAPHUONG VALUES(N'Phường 4', 197)
INSERT XAPHUONG VALUES(N'Phường An Hòa', 197)
INSERT XAPHUONG VALUES(N'Phường Tân Quy Đông', 197)
INSERT XAPHUONG VALUES(N'Xã Tân Khánh Đông', 197)
INSERT XAPHUONG VALUES(N'Xã Tân Phú Đông', 197)
INSERT XAPHUONG VALUES(N'Xã Tân Quy Tây', 197)

INSERT XAPHUONG VALUES(N'Ia Kreng', 198)
INSERT XAPHUONG VALUES(N'Thị trấn Phú Hòa', 198)
INSERT XAPHUONG VALUES(N'Xã Chư Đăng Ya', 198)
INSERT XAPHUONG VALUES(N'Xã Chư Jôr', 198)
INSERT XAPHUONG VALUES(N'Xã Đăk Tơ Ver', 198)
INSERT XAPHUONG VALUES(N'Xã Hà Tây', 198)
INSERT XAPHUONG VALUES(N'Xã Hòa Phú', 198)
INSERT XAPHUONG VALUES(N'Xã Ia Ka', 198)
INSERT XAPHUONG VALUES(N'Xã Ia Khươl', 198)
INSERT XAPHUONG VALUES(N'Xã Ia Ly', 198)
INSERT XAPHUONG VALUES(N'Xã Ia Mơ Nông', 198)
INSERT XAPHUONG VALUES(N'Xã Ia Nhin', 198)
INSERT XAPHUONG VALUES(N'Xã Ia Phí', 198)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Hòa', 198)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Hưng', 198)

INSERT XAPHUONG VALUES(N'Thị trấn Chư Prông', 199)
INSERT XAPHUONG VALUES(N'Xã Bàu Cạn', 199)
INSERT XAPHUONG VALUES(N'Xã Bình Giáo', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Bang', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Băng', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Boòng', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Drăng', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Ga', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Kly', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Lâu', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Me', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Mơ', 199)
INSERT XAPHUONG VALUES(N'Xã Ia O', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Phìn', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Pia', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Piơr', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Púch', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Tôr', 199)
INSERT XAPHUONG VALUES(N'Xã Ia Vê', 199)
INSERT XAPHUONG VALUES(N'Xã Thăng Hưng', 199)

INSERT XAPHUONG VALUES(N'Chư Don', 200)
INSERT XAPHUONG VALUES(N'Ia Blứ', 200)
INSERT XAPHUONG VALUES(N'Ia Dreng', 200)
INSERT XAPHUONG VALUES(N'Ia Hla', 200)
INSERT XAPHUONG VALUES(N'Ia Hrú', 200)
INSERT XAPHUONG VALUES(N'Ia Le', 200)
INSERT XAPHUONG VALUES(N'Ia Rong', 200)
INSERT XAPHUONG VALUES(N'Nhơn Hòa', 200)
INSERT XAPHUONG VALUES(N'Thị Trấn Nhơn Hoà', 200)
INSERT XAPHUONG VALUES(N'Xã Ia Dreng', 200)
INSERT XAPHUONG VALUES(N'Xã Ia Hla', 200)
INSERT XAPHUONG VALUES(N'Xã Ia Hrú', 200)
INSERT XAPHUONG VALUES(N'Xã Ia Le', 200)
INSERT XAPHUONG VALUES(N'Xã Ia Phang', 200)

INSERT XAPHUONG VALUES(N'Bar Măih', 201)
INSERT XAPHUONG VALUES(N'Ia Pal', 201)
INSERT XAPHUONG VALUES(N'Kông Htok', 201)
INSERT XAPHUONG VALUES(N'Thị trấn Chư Sê', 201)
INSERT XAPHUONG VALUES(N'Xã AL Bá', 201)
INSERT XAPHUONG VALUES(N'Xã AYun', 201)
INSERT XAPHUONG VALUES(N'Xã Bờ Ngoong', 201)
INSERT XAPHUONG VALUES(N'Xã Chư Pơng', 201)
INSERT XAPHUONG VALUES(N'Xã Dun', 201)
INSERT XAPHUONG VALUES(N'Xã H Bông', 201)
INSERT XAPHUONG VALUES(N'Xã Ia Blang', 201)
INSERT XAPHUONG VALUES(N'Xã Ia Glai', 201)
INSERT XAPHUONG VALUES(N'Xã Ia HLốp', 201)
INSERT XAPHUONG VALUES(N'Xã Ia Ko', 201)
INSERT XAPHUONG VALUES(N'Xã Ia Tiêm', 201)

INSERT XAPHUONG VALUES(N'HNol', 202)
INSERT XAPHUONG VALUES(N'Thị trấn Đăk Đoa', 202)
INSERT XAPHUONG VALUES(N'Xã A Dơk', 202)
INSERT XAPHUONG VALUES(N'Xã Đăk Krong', 202)
INSERT XAPHUONG VALUES(N'Xã Đăk Sơmei', 202)
INSERT XAPHUONG VALUES(N'Xã Glar', 202)
INSERT XAPHUONG VALUES(N'Xã H' Neng', 202)
INSERT XAPHUONG VALUES(N'Xã Hà Bầu', 202)
INSERT XAPHUONG VALUES(N'Xã Hà Đông', 202)
INSERT XAPHUONG VALUES(N'Xã Hải Yang', 202)
INSERT XAPHUONG VALUES(N'Xã Ia Băng', 202)
INSERT XAPHUONG VALUES(N'Xã Ia Pết', 202)
INSERT XAPHUONG VALUES(N'Xã K' Dang', 202)
INSERT XAPHUONG VALUES(N'Xã Kon Gang', 202)
INSERT XAPHUONG VALUES(N'Xã Nam Yang', 202)
INSERT XAPHUONG VALUES(N'Xã Tân Bình', 202)
INSERT XAPHUONG VALUES(N'Xã Trang', 202)

INSERT XAPHUONG VALUES(N'Xã An Thành', 203)
INSERT XAPHUONG VALUES(N'Xã Cư An', 203)
INSERT XAPHUONG VALUES(N'Xã Đak Pơ', 203)
INSERT XAPHUONG VALUES(N'Xã Hà Tam', 203)
INSERT XAPHUONG VALUES(N'Xã Phú An', 203)
INSERT XAPHUONG VALUES(N'Xã Tân An', 203)
INSERT XAPHUONG VALUES(N'Xã Ya Hội', 203)
INSERT XAPHUONG VALUES(N'Xã Yang Bắc', 203)

INSERT XAPHUONG VALUES(N'Thị trấn Chư Ty', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Din', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Dơk', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Dom', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Kla', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Krêl', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Kriêng', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Lang', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Nan', 204)
INSERT XAPHUONG VALUES(N'Xã Ia Pnôn', 204)

INSERT XAPHUONG VALUES(N'Ia Grăng', 205)
INSERT XAPHUONG VALUES(N'Thị trấn Ia Kha', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Bă', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Chia', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Dêr', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Hrung', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Khai', 205)
INSERT XAPHUONG VALUES(N'Xã Ia KRai', 205)
INSERT XAPHUONG VALUES(N'Xã Ia O', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Pếch', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Sao', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Tô', 205)
INSERT XAPHUONG VALUES(N'Xã Ia Yok', 205)

INSERT XAPHUONG VALUES(N'Xã Chư Mố', 206)
INSERT XAPHUONG VALUES(N'Xã Chư Răng', 206)
INSERT XAPHUONG VALUES(N'Xã Ia Broăi', 206)
INSERT XAPHUONG VALUES(N'Xã Ia KDăm', 206)
INSERT XAPHUONG VALUES(N'Xã Ia Ma Rơn', 206)
INSERT XAPHUONG VALUES(N'Xã Ia Trok', 206)
INSERT XAPHUONG VALUES(N'Xã Ia Tul', 206)
INSERT XAPHUONG VALUES(N'Xã Kim Tân', 206)
INSERT XAPHUONG VALUES(N'Xã Pờ Tó', 206)

INSERT XAPHUONG VALUES(N'Thị trấn KBang', 207)
INSERT XAPHUONG VALUES(N'Xã Đăk HLơ', 207)
INSERT XAPHUONG VALUES(N'Xã Đăk Roong', 207)
INSERT XAPHUONG VALUES(N'Xã Đăk Smar', 207)
INSERT XAPHUONG VALUES(N'Xã Đông', 207)
INSERT XAPHUONG VALUES(N'Xã Kon Pne', 207)
INSERT XAPHUONG VALUES(N'Xã Kông Lơng Khơng', 207)
INSERT XAPHUONG VALUES(N'Xã Kông Pla', 207)
INSERT XAPHUONG VALUES(N'Xã KRong', 207)
INSERT XAPHUONG VALUES(N'Xã Lơ Ku', 207)
INSERT XAPHUONG VALUES(N'Xã Nghĩa An', 207)
INSERT XAPHUONG VALUES(N'Xã Sơ Pai', 207)
INSERT XAPHUONG VALUES(N'Xã Sơn Lang', 207)
INSERT XAPHUONG VALUES(N'Xã Tơ Tung', 207)

INSERT XAPHUONG VALUES(N'Thị trấn Kông Chro', 208)
INSERT XAPHUONG VALUES(N'Xã An Trung', 208)
INSERT XAPHUONG VALUES(N'Xã Chơ Long', 208)
INSERT XAPHUONG VALUES(N'Xã Chư Krêy', 208)
INSERT XAPHUONG VALUES(N'Xã Đăk Kơ Ning', 208)
INSERT XAPHUONG VALUES(N'Xã Đăk Pling', 208)
INSERT XAPHUONG VALUES(N'Xã Đăk Pơ Pho', 208)
INSERT XAPHUONG VALUES(N'Xã Đăk Song', 208)
INSERT XAPHUONG VALUES(N'Xã Đăk Tơ Pang', 208)
INSERT XAPHUONG VALUES(N'Xã Kông Yang', 208)
INSERT XAPHUONG VALUES(N'Xã SRó', 208)
INSERT XAPHUONG VALUES(N'Xã Ya Ma', 208)
INSERT XAPHUONG VALUES(N'Xã Yang Nam', 208)
INSERT XAPHUONG VALUES(N'Xã Yang Trung', 208)

INSERT XAPHUONG VALUES(N'Thị trấn Phú Túc', 209)
INSERT XAPHUONG VALUES(N'Xã Chư Drăng', 209)
INSERT XAPHUONG VALUES(N'Xã Chư Gu', 209)
INSERT XAPHUONG VALUES(N'Xã Chư Ngọc', 209)
INSERT XAPHUONG VALUES(N'Xã Chư RCăm', 209)
INSERT XAPHUONG VALUES(N'Xã Đất Bằng', 209)
INSERT XAPHUONG VALUES(N'Xã Ia HDreh', 209)
INSERT XAPHUONG VALUES(N'Xã Ia Mláh', 209)
INSERT XAPHUONG VALUES(N'Xã Ia RMok', 209)
INSERT XAPHUONG VALUES(N'Xã Ia RSai', 209)
INSERT XAPHUONG VALUES(N'Xã Ia RSươm', 209)
INSERT XAPHUONG VALUES(N'Xã Krông Năng', 209)
INSERT XAPHUONG VALUES(N'Xã Phú Cần', 209)
INSERT XAPHUONG VALUES(N'Xã Uar', 209)

INSERT XAPHUONG VALUES(N'Thị trấn Kon Dơng', 210)
INSERT XAPHUONG VALUES(N'Xã Ayun', 210)
INSERT XAPHUONG VALUES(N'Xã Đăk Djrăng', 210)
INSERT XAPHUONG VALUES(N'Xã Đăk Jơ Ta', 210)
INSERT XAPHUONG VALUES(N'Xã Đăk Trôi', 210)
INSERT XAPHUONG VALUES(N'Xã Đăk Yă', 210)
INSERT XAPHUONG VALUES(N'Xã ĐăkTaLey', 210)
INSERT XAPHUONG VALUES(N'Xã Đê Ar', 210)
INSERT XAPHUONG VALUES(N'Xã Hra', 210)
INSERT XAPHUONG VALUES(N'Xã Kon Chiêng', 210)
INSERT XAPHUONG VALUES(N'Xã Kon Thụp', 210)
INSERT XAPHUONG VALUES(N'Xã Lơ Pang', 210)

INSERT XAPHUONG VALUES(N'Thị trấn Phú Thiện', 211)
INSERT XAPHUONG VALUES(N'Xã Ayun Hạ', 211)
INSERT XAPHUONG VALUES(N'Xã Chrôh Pơnan', 211)
INSERT XAPHUONG VALUES(N'Xã Chư A Thai', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Ake', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Hiao', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Ke', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Peng', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Piar', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Sol', 211)
INSERT XAPHUONG VALUES(N'Xã Ia Yeng', 211)

INSERT XAPHUONG VALUES(N'Phường Chi Lăng', 212)
INSERT XAPHUONG VALUES(N'Phường Diên Hồng', 212)
INSERT XAPHUONG VALUES(N'Phường Đống Đa', 212)
INSERT XAPHUONG VALUES(N'Phường Hoa Lư', 212)
INSERT XAPHUONG VALUES(N'Phường Hội Phú', 212)
INSERT XAPHUONG VALUES(N'Phường Hội Thương', 212)
INSERT XAPHUONG VALUES(N'Phường Ia Kring', 212)
INSERT XAPHUONG VALUES(N'Phường Phù Đổng', 212)
INSERT XAPHUONG VALUES(N'Phường Tây Sơn', 212)
INSERT XAPHUONG VALUES(N'Phường Thắng Lợi', 212)
INSERT XAPHUONG VALUES(N'Phường Thống Nhất', 212)
INSERT XAPHUONG VALUES(N'Phường Trà Bá', 212)
INSERT XAPHUONG VALUES(N'Phường Yên Đỗ', 212)
INSERT XAPHUONG VALUES(N'Phường Yên Thế', 212)
INSERT XAPHUONG VALUES(N'Xã An Phú', 212)
INSERT XAPHUONG VALUES(N'Xã Biển Hồ', 212)
INSERT XAPHUONG VALUES(N'Xã Chư á', 212)
INSERT XAPHUONG VALUES(N'Xã Chư HDrông', 212)
INSERT XAPHUONG VALUES(N'Xã Diên Phú', 212)
INSERT XAPHUONG VALUES(N'Xã Gào', 212)
INSERT XAPHUONG VALUES(N'Xã Ia Kênh', 212)
INSERT XAPHUONG VALUES(N'Xã Tân Sơn', 212)
INSERT XAPHUONG VALUES(N'Xã Trà Đa', 212)

INSERT XAPHUONG VALUES(N'Phường An Bình', 213)
INSERT XAPHUONG VALUES(N'Phường An Phú', 213)
INSERT XAPHUONG VALUES(N'Phường An Phước', 213)
INSERT XAPHUONG VALUES(N'Phường An Tân', 213)
INSERT XAPHUONG VALUES(N'Phường Ngô Mây', 213)
INSERT XAPHUONG VALUES(N'Phường Tây Sơn', 213)
INSERT XAPHUONG VALUES(N'Xã Cửu An', 213)
INSERT XAPHUONG VALUES(N'Xã Song An', 213)
INSERT XAPHUONG VALUES(N'Xã Thành An', 213)
INSERT XAPHUONG VALUES(N'Xã Tú An', 213)
INSERT XAPHUONG VALUES(N'Xã Xuân An', 213)

INSERT XAPHUONG VALUES(N'Phường Cheo Reo', 214)
INSERT XAPHUONG VALUES(N'Phường Đoàn Kết', 214)
INSERT XAPHUONG VALUES(N'Phường Hoà Bình', 214)
INSERT XAPHUONG VALUES(N'Phường Sông Bờ', 214)
INSERT XAPHUONG VALUES(N'Xã Chư Băh', 214)
INSERT XAPHUONG VALUES(N'Xã Ia RTô', 214)
INSERT XAPHUONG VALUES(N'Xã la RBol', 214)
INSERT XAPHUONG VALUES(N'Xã la Sao', 214)

INSERT XAPHUONG VALUES(N'Thị Trấn Yên Phú', 215)
INSERT XAPHUONG VALUES(N'Xã Đường âm', 215)
INSERT XAPHUONG VALUES(N'Xã Đường Hồng', 215)
INSERT XAPHUONG VALUES(N'Xã Giáp Trung', 215)
INSERT XAPHUONG VALUES(N'Xã Lạc Nông', 215)
INSERT XAPHUONG VALUES(N'Xã Minh Ngọc', 215)
INSERT XAPHUONG VALUES(N'Xã Minh Sơn', 215)
INSERT XAPHUONG VALUES(N'Xã Phiêng Luông', 215)
INSERT XAPHUONG VALUES(N'Xã Phú Nam', 215)
INSERT XAPHUONG VALUES(N'Xã Thượng Tân', 215)
INSERT XAPHUONG VALUES(N'Xã Yên Cường', 215)
INSERT XAPHUONG VALUES(N'Xã Yên Định', 215)
INSERT XAPHUONG VALUES(N'Xã Yên Phong', 215)

INSERT XAPHUONG VALUES(N'Thị trấn Việt Quang', 216)
INSERT XAPHUONG VALUES(N'Thị trấn Vĩnh Tuy', 216)
INSERT XAPHUONG VALUES(N'Xã Bằng Hành', 216)
INSERT XAPHUONG VALUES(N'Xã Đồng Tâm', 216)
INSERT XAPHUONG VALUES(N'Xã Đông Thành', 216)
INSERT XAPHUONG VALUES(N'Xã Đồng Tiến', 216)
INSERT XAPHUONG VALUES(N'Xã Đồng Yên', 216)
INSERT XAPHUONG VALUES(N'Xã Đức Xuân', 216)
INSERT XAPHUONG VALUES(N'Xã Hùng An', 216)
INSERT XAPHUONG VALUES(N'Xã Hữu Sản', 216)
INSERT XAPHUONG VALUES(N'Xã Kim Ngọc', 216)
INSERT XAPHUONG VALUES(N'Xã Liên Hiệp', 216)
INSERT XAPHUONG VALUES(N'Xã Quang Minh', 216)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 216)
INSERT XAPHUONG VALUES(N'Xã Tân Quang', 216)
INSERT XAPHUONG VALUES(N'Xã Tân Thành', 216)
INSERT XAPHUONG VALUES(N'Xã Thượng Bình', 216)
INSERT XAPHUONG VALUES(N'Xã Tiên Kiều', 216)
INSERT XAPHUONG VALUES(N'Xã Việt Hồng', 216)
INSERT XAPHUONG VALUES(N'Xã Việt Vinh', 216)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Hảo', 216)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Phúc', 216)
INSERT XAPHUONG VALUES(N'Xã Vô Điếm', 216)

INSERT XAPHUONG VALUES(N'Thị trấn Đồng Văn', 217)
INSERT XAPHUONG VALUES(N'Thị trấn Phó Bảng', 217)
INSERT XAPHUONG VALUES(N'Xã Hố Quáng Phìn', 217)
INSERT XAPHUONG VALUES(N'Xã Lũng Cú', 217)
INSERT XAPHUONG VALUES(N'Xã Lũng Phìn', 217)
INSERT XAPHUONG VALUES(N'Xã Lũng Táo', 217)
INSERT XAPHUONG VALUES(N'Xã Lũng Thầu', 217)
INSERT XAPHUONG VALUES(N'Xã Má Lé', 217)
INSERT XAPHUONG VALUES(N'Xã Phố Cáo', 217)
INSERT XAPHUONG VALUES(N'Xã Phố Là', 217)
INSERT XAPHUONG VALUES(N'Xã Sảng Tủng', 217)
INSERT XAPHUONG VALUES(N'Xã Sính Lủng', 217)
INSERT XAPHUONG VALUES(N'Xã Sủng Là', 217)
INSERT XAPHUONG VALUES(N'Xã Sủng Trái', 217)
INSERT XAPHUONG VALUES(N'Xã Tả Lủng', 217)
INSERT XAPHUONG VALUES(N'Xã Tả Phìn', 217)
INSERT XAPHUONG VALUES(N'Xã Thài Phìn Tủng', 217)
INSERT XAPHUONG VALUES(N'Xã Vần Chải', 217)
INSERT XAPHUONG VALUES(N'Xã Xà Phìn', 217)

INSERT XAPHUONG VALUES(N'Thị trấn Vinh Quang', 218)
INSERT XAPHUONG VALUES(N'Xã Bản Luốc', 218)
INSERT XAPHUONG VALUES(N'Xã Bản Máy', 218)
INSERT XAPHUONG VALUES(N'Xã Bản Nhùng', 218)
INSERT XAPHUONG VALUES(N'Xã Bản Péo', 218)
INSERT XAPHUONG VALUES(N'Xã Bản Phùng', 218)
INSERT XAPHUONG VALUES(N'Xã Chiến Phố', 218)
INSERT XAPHUONG VALUES(N'Xã Đản Ván', 218)
INSERT XAPHUONG VALUES(N'Xã Hồ Thầu', 218)
INSERT XAPHUONG VALUES(N'Xã Nậm Dịch', 218)
INSERT XAPHUONG VALUES(N'Xã Nậm Khòa', 218)
INSERT XAPHUONG VALUES(N'Xã Nam Sơn', 218)
INSERT XAPHUONG VALUES(N'Xã Nậm Tỵ', 218)
INSERT XAPHUONG VALUES(N'Xã Nàng Đôn', 218)
INSERT XAPHUONG VALUES(N'Xã Ngàm Đăng Vài', 218)
INSERT XAPHUONG VALUES(N'Xã Pố Lồ', 218)
INSERT XAPHUONG VALUES(N'Xã Pờ Ly Ngài', 218)
INSERT XAPHUONG VALUES(N'Xã Sán Xả Hồ', 218)
INSERT XAPHUONG VALUES(N'Xã Tả Sử Choóng', 218)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 218)
INSERT XAPHUONG VALUES(N'Xã Thàng Tín', 218)
INSERT XAPHUONG VALUES(N'Xã Thèn Chu Phìn', 218)
INSERT XAPHUONG VALUES(N'Xã Thông Nguyên', 218)
INSERT XAPHUONG VALUES(N'Xã Tụ Nhân', 218)
INSERT XAPHUONG VALUES(N'Xã Túng Sán', 218)

INSERT XAPHUONG VALUES(N'Thị trấn Mèo Vạc', 219)
INSERT XAPHUONG VALUES(N'Xã Cán Chu Phìn', 219)
INSERT XAPHUONG VALUES(N'Xã Giàng Chu Phìn', 219)
INSERT XAPHUONG VALUES(N'Xã Khâu Vai', 219)
INSERT XAPHUONG VALUES(N'Xã Lũng Chinh', 219)
INSERT XAPHUONG VALUES(N'Xã Lũng Pù', 219)
INSERT XAPHUONG VALUES(N'Xã Nậm Ban', 219)
INSERT XAPHUONG VALUES(N'Xã Niêm Sơn', 219)
INSERT XAPHUONG VALUES(N'Xã Niêm Tòng', 219)
INSERT XAPHUONG VALUES(N'Xã Pả Vi', 219)
INSERT XAPHUONG VALUES(N'Xã Pải Lủng', 219)
INSERT XAPHUONG VALUES(N'Xã Sơn Vĩ', 219)
INSERT XAPHUONG VALUES(N'Xã Sủng Máng', 219)
INSERT XAPHUONG VALUES(N'Xã Sủng Trà', 219)
INSERT XAPHUONG VALUES(N'Xã Tả Lủng', 219)
INSERT XAPHUONG VALUES(N'Xã Tát Ngà', 219)
INSERT XAPHUONG VALUES(N'Xã Thượng Phùng', 219)
INSERT XAPHUONG VALUES(N'Xã Xín Cái', 219)

INSERT XAPHUONG VALUES(N'Thị trấn Tam Sơn', 220)
INSERT XAPHUONG VALUES(N'Xã Bát Đại Sơn', 220)
INSERT XAPHUONG VALUES(N'Xã Cán Tỷ', 220)
INSERT XAPHUONG VALUES(N'Xã Cao Mã Pờ', 220)
INSERT XAPHUONG VALUES(N'Xã Đông Hà', 220)
INSERT XAPHUONG VALUES(N'Xã Lùng Tám', 220)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Thuận', 220)
INSERT XAPHUONG VALUES(N'Xã Quản Bạ', 220)
INSERT XAPHUONG VALUES(N'Xã Quyết Tiến', 220)
INSERT XAPHUONG VALUES(N'Xã Tả Ván', 220)
INSERT XAPHUONG VALUES(N'Xã Thái An', 220)
INSERT XAPHUONG VALUES(N'Xã Thanh Vân', 220)
INSERT XAPHUONG VALUES(N'Xã Tùng Vài', 220)

INSERT XAPHUONG VALUES(N'Thị Trấn Yên Bình', 221)
INSERT XAPHUONG VALUES(N'Xã Bản Rịa', 221)
INSERT XAPHUONG VALUES(N'Xã Bằng Lang', 221)
INSERT XAPHUONG VALUES(N'Xã Hương Sơn', 221)
INSERT XAPHUONG VALUES(N'Xã Nà Khương', 221)
INSERT XAPHUONG VALUES(N'Xã Tân Bắc', 221)
INSERT XAPHUONG VALUES(N'Xã Tân Nam', 221)
INSERT XAPHUONG VALUES(N'Xã Tân Trịnh', 221)
INSERT XAPHUONG VALUES(N'Xã Tiên Nguyên', 221)
INSERT XAPHUONG VALUES(N'Xã Tiên Yên', 221)
INSERT XAPHUONG VALUES(N'Xã Vĩ Thượng', 221)
INSERT XAPHUONG VALUES(N'Xã Xuân Giang', 221)
INSERT XAPHUONG VALUES(N'Xã Xuân Minh', 221)
INSERT XAPHUONG VALUES(N'Xã Yên Hà', 221)
INSERT XAPHUONG VALUES(N'Xã Yên Thành', 221)

INSERT XAPHUONG VALUES(N'Thị trấn Vị Xuyên', 222)
INSERT XAPHUONG VALUES(N'Thị trấn Việt Lâm', 222)
INSERT XAPHUONG VALUES(N'Xã Bạch Ngọc', 222)
INSERT XAPHUONG VALUES(N'Xã Cao Bồ', 222)
INSERT XAPHUONG VALUES(N'Xã Đạo Đức', 222)
INSERT XAPHUONG VALUES(N'Xã Kim Linh', 222)
INSERT XAPHUONG VALUES(N'Xã Kim Thạch', 222)
INSERT XAPHUONG VALUES(N'Xã Lao Chải', 222)
INSERT XAPHUONG VALUES(N'Xã Linh Hồ', 222)
INSERT XAPHUONG VALUES(N'Xã Minh Tân', 222)
INSERT XAPHUONG VALUES(N'Xã Ngọc Linh', 222)
INSERT XAPHUONG VALUES(N'Xã Ngọc Minh', 222)
INSERT XAPHUONG VALUES(N'Xã Phong Quang', 222)
INSERT XAPHUONG VALUES(N'Xã Phú Linh', 222)
INSERT XAPHUONG VALUES(N'Xã Phương Tiến', 222)
INSERT XAPHUONG VALUES(N'Xã Quảng Ngần', 222)
INSERT XAPHUONG VALUES(N'Xã Thanh Đức', 222)
INSERT XAPHUONG VALUES(N'Xã Thanh Thủy', 222)
INSERT XAPHUONG VALUES(N'Xã Thuận Hoà', 222)
INSERT XAPHUONG VALUES(N'Xã Thượng Sơn', 222)
INSERT XAPHUONG VALUES(N'Xã Trung Thành', 222)
INSERT XAPHUONG VALUES(N'Xã Tùng Bá', 222)
INSERT XAPHUONG VALUES(N'Xã Việt Lâm', 222)
INSERT XAPHUONG VALUES(N'Xã Xín Chải', 222)

INSERT XAPHUONG VALUES(N'Thị trấn Cốc Pài', 223)
INSERT XAPHUONG VALUES(N'Xã Bản Díu', 223)
INSERT XAPHUONG VALUES(N'Xã Bản Ngò', 223)
INSERT XAPHUONG VALUES(N'Xã Chế Là', 223)
INSERT XAPHUONG VALUES(N'Xã Chí Cà', 223)
INSERT XAPHUONG VALUES(N'Xã Cốc Rế', 223)
INSERT XAPHUONG VALUES(N'Xã Khuôn Lùng', 223)
INSERT XAPHUONG VALUES(N'Xã Nà Chì', 223)
INSERT XAPHUONG VALUES(N'Xã Nấm Dẩn', 223)
INSERT XAPHUONG VALUES(N'Xã Nàn Ma', 223)
INSERT XAPHUONG VALUES(N'Xã Nàn Xỉn', 223)
INSERT XAPHUONG VALUES(N'Xã Ngán Chiên', 223)
INSERT XAPHUONG VALUES(N'Xã Pà Vây Sử', 223)
INSERT XAPHUONG VALUES(N'Xã Quảng Nguyên', 223)
INSERT XAPHUONG VALUES(N'Xã Tả Nhìu', 223)
INSERT XAPHUONG VALUES(N'Xã Thèng Phàng', 223)
INSERT XAPHUONG VALUES(N'Xã Thu Tà', 223)
INSERT XAPHUONG VALUES(N'Xã Trung Thịnh', 223)
INSERT XAPHUONG VALUES(N'Xã Xín Mần', 223)

INSERT XAPHUONG VALUES(N'Thị trấn Yên Minh', 224)
INSERT XAPHUONG VALUES(N'Xã Bạch Đích', 224)
INSERT XAPHUONG VALUES(N'Xã Đông Minh', 224)
INSERT XAPHUONG VALUES(N'Xã Du Già', 224)
INSERT XAPHUONG VALUES(N'Xã Du Tiến', 224)
INSERT XAPHUONG VALUES(N'Xã Đường Thượng', 224)
INSERT XAPHUONG VALUES(N'Xã Hữu Vinh', 224)
INSERT XAPHUONG VALUES(N'Xã Lao Và Chải', 224)
INSERT XAPHUONG VALUES(N'Xã Lũng Hồ', 224)
INSERT XAPHUONG VALUES(N'Xã Mậu Duệ', 224)
INSERT XAPHUONG VALUES(N'Xã Mậu Long', 224)
INSERT XAPHUONG VALUES(N'Xã Na Khê', 224)
INSERT XAPHUONG VALUES(N'Xã Ngam La', 224)
INSERT XAPHUONG VALUES(N'Xã Ngọc Long', 224)
INSERT XAPHUONG VALUES(N'Xã Phú Lũng', 224)
INSERT XAPHUONG VALUES(N'Xã Sủng Thài', 224)
INSERT XAPHUONG VALUES(N'Xã Sủng Tráng', 224)
INSERT XAPHUONG VALUES(N'Xã Thắng Mố', 224)

INSERT XAPHUONG VALUES(N'Phường Minh Khai', 225)
INSERT XAPHUONG VALUES(N'Phường Ngọc Hà', 225)
INSERT XAPHUONG VALUES(N'Phường Nguyễn Trãi', 225)
INSERT XAPHUONG VALUES(N'Phường Quang Trung', 225)
INSERT XAPHUONG VALUES(N'Phường Trần Phú', 225)
INSERT XAPHUONG VALUES(N'Xã Ngọc Đường', 225)
INSERT XAPHUONG VALUES(N'Xã Phương Độ', 225)
INSERT XAPHUONG VALUES(N'Xã Phương Thiện', 225)

INSERT XAPHUONG VALUES(N'Thị trấn Bình Mỹ', 226)
INSERT XAPHUONG VALUES(N'Xã An Đổ', 226)
INSERT XAPHUONG VALUES(N'Xã An Lão', 226)
INSERT XAPHUONG VALUES(N'Xã An Mỹ', 226)
INSERT XAPHUONG VALUES(N'Xã An Ninh', 226)
INSERT XAPHUONG VALUES(N'Xã An Nội', 226)
INSERT XAPHUONG VALUES(N'Xã Bình Nghĩa', 226)
INSERT XAPHUONG VALUES(N'Xã Bồ Đề', 226)
INSERT XAPHUONG VALUES(N'Xã Bối Cầu', 226)
INSERT XAPHUONG VALUES(N'Xã Đồn Xá', 226)
INSERT XAPHUONG VALUES(N'Xã Đồng Du', 226)
INSERT XAPHUONG VALUES(N'Xã Hưng Công', 226)
INSERT XAPHUONG VALUES(N'Xã La Sơn', 226)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thọ', 226)
INSERT XAPHUONG VALUES(N'Xã Ngọc Lũ', 226)
INSERT XAPHUONG VALUES(N'Xã Tiêu Động', 226)
INSERT XAPHUONG VALUES(N'Xã Tràng An', 226)
INSERT XAPHUONG VALUES(N'Xã Trung Lương', 226)
INSERT XAPHUONG VALUES(N'Xã Vũ Bản', 226)

INSERT XAPHUONG VALUES(N'Ba Sao', 227)
INSERT XAPHUONG VALUES(N'Thị trấn Quế', 227)
INSERT XAPHUONG VALUES(N'Xã Đại Cương', 227)
INSERT XAPHUONG VALUES(N'Xã Đồng Hóa', 227)
INSERT XAPHUONG VALUES(N'Xã Hoàng Tây', 227)
INSERT XAPHUONG VALUES(N'Xã Khả Phong', 227)
INSERT XAPHUONG VALUES(N'Xã Lê Hồ', 227)
INSERT XAPHUONG VALUES(N'Xã Liên Sơn', 227)
INSERT XAPHUONG VALUES(N'Xã Ngọc Sơn', 227)
INSERT XAPHUONG VALUES(N'Xã Nguyễn úy', 227)
INSERT XAPHUONG VALUES(N'Xã Nhật Tân', 227)
INSERT XAPHUONG VALUES(N'Xã Nhật Tựu', 227)
INSERT XAPHUONG VALUES(N'Xã Tân Sơn', 227)
INSERT XAPHUONG VALUES(N'Xã Thanh Sơn', 227)
INSERT XAPHUONG VALUES(N'Xã Thi Sơn', 227)
INSERT XAPHUONG VALUES(N'Xã Thụy Lôi', 227)
INSERT XAPHUONG VALUES(N'Xã Tượng Lĩnh', 227)
INSERT XAPHUONG VALUES(N'Xã Văn Xá', 227)

INSERT XAPHUONG VALUES(N'Thị trấn Vĩnh Trụ', 228)
INSERT XAPHUONG VALUES(N'Xã Bắc Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Chân Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Chính Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Công Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Đạo Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Đồng Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Đức Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Hòa Hậu', 228)
INSERT XAPHUONG VALUES(N'Xã Hợp Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Nguyên Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Nhân Bình', 228)
INSERT XAPHUONG VALUES(N'Xã Nhân Chính', 228)
INSERT XAPHUONG VALUES(N'Xã Nhân Khang', 228)
INSERT XAPHUONG VALUES(N'Xã Nhân Mỹ', 228)
INSERT XAPHUONG VALUES(N'Xã Nhân Nghĩa', 228)
INSERT XAPHUONG VALUES(N'Xã Nhân Thịnh', 228)
INSERT XAPHUONG VALUES(N'Xã Phú Phúc', 228)
INSERT XAPHUONG VALUES(N'Xã Tiến Thắng', 228)
INSERT XAPHUONG VALUES(N'Xã Trần Hưng Đạo', 228)
INSERT XAPHUONG VALUES(N'Xã Văn Lý', 228)
INSERT XAPHUONG VALUES(N'Xã Xuân Khê', 228)

INSERT XAPHUONG VALUES(N'Thị trấn Kiện Khê', 229)
INSERT XAPHUONG VALUES(N'Thị trấn Tân Thanh', 229)
INSERT XAPHUONG VALUES(N'Xã Liêm Cần', 229)
INSERT XAPHUONG VALUES(N'Xã Liêm Phong', 229)
INSERT XAPHUONG VALUES(N'Xã Liêm Sơn', 229)
INSERT XAPHUONG VALUES(N'Xã Liêm Thuận', 229)
INSERT XAPHUONG VALUES(N'Xã Liêm Túc', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Hà', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Hải', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Hương', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Nghị', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Nguyên', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Phong', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Tâm', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Tân', 229)
INSERT XAPHUONG VALUES(N'Xã Thanh Thủy', 229)

INSERT XAPHUONG VALUES(N'Phường Hai Bà Trưng', 230)
INSERT XAPHUONG VALUES(N'Phường Lê Hồng Phong', 230)
INSERT XAPHUONG VALUES(N'Phường Minh Khai', 230)
INSERT XAPHUONG VALUES(N'Phường Quang Trung', 230)
INSERT XAPHUONG VALUES(N'Phường Trần Hưng Đạo', 230)
INSERT XAPHUONG VALUES(N'Phường. Lương Khánh Thiện', 230)
INSERT XAPHUONG VALUES(N'Kim Bình', 230)
INSERT XAPHUONG VALUES(N'Thanh Tuyền', 230)
INSERT XAPHUONG VALUES(N'Tiên Hiệp', 230)
INSERT XAPHUONG VALUES(N'Xã Châu Sơn', 230)
INSERT XAPHUONG VALUES(N'Xã Đinh Xá', 230)
INSERT XAPHUONG VALUES(N'Xã Định Xá', 230)
INSERT XAPHUONG VALUES(N'Xã Kim Bình', 230)
INSERT XAPHUONG VALUES(N'Xã Lam Hạ', 230)
INSERT XAPHUONG VALUES(N'Xã Liêm Chính', 230)
INSERT XAPHUONG VALUES(N'Xã Liêm Chung', 230)
INSERT XAPHUONG VALUES(N'Xã Liêm Tiết', 230)
INSERT XAPHUONG VALUES(N'Xã Liêm Tuyền', 230)
INSERT XAPHUONG VALUES(N'Xã Phù Vân', 230)
INSERT XAPHUONG VALUES(N'Xã Thanh Châu', 230)
INSERT XAPHUONG VALUES(N'Xã Tiên Hải', 230)
INSERT XAPHUONG VALUES(N'Xã Tiên Tân', 230)
INSERT XAPHUONG VALUES(N'Xã Trịnh Xá', 230)

INSERT XAPHUONG VALUES(N'Phường Bạch Thượng', 231)
INSERT XAPHUONG VALUES(N'Phường Châu Giang', 231)
INSERT XAPHUONG VALUES(N'Phường Duy Minh', 231)
INSERT XAPHUONG VALUES(N'Phường Hòa Mạc', 231)
INSERT XAPHUONG VALUES(N'Thị trấn Đồng Văn', 231)
INSERT XAPHUONG VALUES(N'Xã Châu Sơn', 231)
INSERT XAPHUONG VALUES(N'Xã Chuyên Ngoại', 231)
INSERT XAPHUONG VALUES(N'Xã Đọi Sơn', 231)
INSERT XAPHUONG VALUES(N'Xã Duy Hải', 231)
INSERT XAPHUONG VALUES(N'Xã Hoàng Đông', 231)
INSERT XAPHUONG VALUES(N'Xã Mộc Bắc', 231)
INSERT XAPHUONG VALUES(N'Xã Mộc Nam', 231)
INSERT XAPHUONG VALUES(N'Xã Tiên Ngoại', 231)
INSERT XAPHUONG VALUES(N'Xã Tiên Nội', 231)
INSERT XAPHUONG VALUES(N'Xã Tiền Phong', 231)
INSERT XAPHUONG VALUES(N'Xã Tiên Sơn', 231)
INSERT XAPHUONG VALUES(N'Xã Trác Văn', 231)
INSERT XAPHUONG VALUES(N'Xã Yên Bắc', 231)
INSERT XAPHUONG VALUES(N'Xã Yên Nam', 231)

INSERT XAPHUONG VALUES(N'Phường Cống Vị', 232)
INSERT XAPHUONG VALUES(N'Phường Điện Biên', 232)
INSERT XAPHUONG VALUES(N'Phường Đội Cấn', 232)
INSERT XAPHUONG VALUES(N'Phường Giảng Võ', 232)
INSERT XAPHUONG VALUES(N'Phường Kim Mã', 232)
INSERT XAPHUONG VALUES(N'Phường Liễu Giai', 232)
INSERT XAPHUONG VALUES(N'Phường Ngọc Hà', 232)
INSERT XAPHUONG VALUES(N'Phường Ngọc Khánh', 232)
INSERT XAPHUONG VALUES(N'Phường Phúc Xá', 232)
INSERT XAPHUONG VALUES(N'Phường Quán Thánh', 232)
INSERT XAPHUONG VALUES(N'Phường Thành Công', 232)
INSERT XAPHUONG VALUES(N'Phường Trúc Bạch', 232)
INSERT XAPHUONG VALUES(N'Phường Vĩnh Phúc', 232)
INSERT XAPHUONG VALUES(N'Phường. Nguyễn Trung Trực', 232)

INSERT XAPHUONG VALUES(N'Phường Cổ Nhuế 1', 233)
INSERT XAPHUONG VALUES(N'Phường Cổ Nhuế 2', 233)
INSERT XAPHUONG VALUES(N'Phường Đông Ngạc', 233)
INSERT XAPHUONG VALUES(N'Phường Đức Thắng', 233)
INSERT XAPHUONG VALUES(N'Phường Liên Mạc', 233)
INSERT XAPHUONG VALUES(N'Phường Minh Khai', 233)
INSERT XAPHUONG VALUES(N'Phường Phú Diễn', 233)
INSERT XAPHUONG VALUES(N'Phường Phúc Diễn', 233)
INSERT XAPHUONG VALUES(N'Phường Tây Tựu', 233)
INSERT XAPHUONG VALUES(N'Phường Thượng Cát', 233)
INSERT XAPHUONG VALUES(N'Phường Thụy Phương', 233)
INSERT XAPHUONG VALUES(N'Phường Xuân Đỉnh', 233)
INSERT XAPHUONG VALUES(N'Phường Xuân Tảo', 233)

INSERT XAPHUONG VALUES(N'Phường Dịch Vọng', 234)
INSERT XAPHUONG VALUES(N'Phường Dịch Vọng Hậu', 234)
INSERT XAPHUONG VALUES(N'Phường Mai Dịch', 234)
INSERT XAPHUONG VALUES(N'Phường Nghĩa Đô', 234)
INSERT XAPHUONG VALUES(N'Phường Nghĩa Tân', 234)
INSERT XAPHUONG VALUES(N'Phường Quan Hoa', 234)
INSERT XAPHUONG VALUES(N'Phường Trung Hoà', 234)
INSERT XAPHUONG VALUES(N'Phường Yên Hoà', 234)

INSERT XAPHUONG VALUES(N'Phường Cát Linh', 235)
INSERT XAPHUONG VALUES(N'Phường Hàng Bột', 235)
INSERT XAPHUONG VALUES(N'Phường Khâm Thiên', 235)
INSERT XAPHUONG VALUES(N'Phường Khương Thượng', 235)
INSERT XAPHUONG VALUES(N'Phường Kim Liên', 235)
INSERT XAPHUONG VALUES(N'Phường Láng Hạ', 235)
INSERT XAPHUONG VALUES(N'Phường Láng Thượng', 235)
INSERT XAPHUONG VALUES(N'Phường Nam Đồng', 235)
INSERT XAPHUONG VALUES(N'Phường Ngã Tư Sở', 235)
INSERT XAPHUONG VALUES(N'Phường ô Chợ Dừa', 235)
INSERT XAPHUONG VALUES(N'Phường Phương Liên', 235)
INSERT XAPHUONG VALUES(N'Phường Phương Mai', 235)
INSERT XAPHUONG VALUES(N'Phường Quang Trung', 235)
INSERT XAPHUONG VALUES(N'Phường Quốc Tử Giám', 235)
INSERT XAPHUONG VALUES(N'Phường Thịnh Quang', 235)
INSERT XAPHUONG VALUES(N'Phường Thổ Quan', 235)
INSERT XAPHUONG VALUES(N'Phường Trung Liệt', 235)
INSERT XAPHUONG VALUES(N'Phường Trung Phụng', 235)
INSERT XAPHUONG VALUES(N'Phường Trung Tự', 235)
INSERT XAPHUONG VALUES(N'Phường Văn Chương', 235)
INSERT XAPHUONG VALUES(N'Phường Văn Miếu', 235)

INSERT XAPHUONG VALUES(N'Phường Hà Cầu', 236)
INSERT XAPHUONG VALUES(N'Phường La Khê', 236)
INSERT XAPHUONG VALUES(N'Phường Mộ Lao', 236)
INSERT XAPHUONG VALUES(N'Phường Nguyễn Trãi', 236)
INSERT XAPHUONG VALUES(N'Phường Phú La', 236)
INSERT XAPHUONG VALUES(N'Phường Phúc La', 236)
INSERT XAPHUONG VALUES(N'Phường Quang Trung', 236)
INSERT XAPHUONG VALUES(N'Phường Vạn Phúc', 236)
INSERT XAPHUONG VALUES(N'Phường Văn Quán', 236)
INSERT XAPHUONG VALUES(N'Phường Yên Nghĩa', 236)
INSERT XAPHUONG VALUES(N'Phường Yết Kiêu', 236)
INSERT XAPHUONG VALUES(N'Xã Biên Giang', 236)
INSERT XAPHUONG VALUES(N'Xã Đồng Mai', 236)
INSERT XAPHUONG VALUES(N'Xã Dương Nội', 236)
INSERT XAPHUONG VALUES(N'Xã Kiến Hưng', 236)
INSERT XAPHUONG VALUES(N'Xã Phú Lãm', 236)
INSERT XAPHUONG VALUES(N'Xã Phú Lương', 236)

INSERT XAPHUONG VALUES(N'Phường Bạch Đằng', 237)
INSERT XAPHUONG VALUES(N'Phường Bách Khoa', 237)
INSERT XAPHUONG VALUES(N'Phường Bạch Mai', 237)
INSERT XAPHUONG VALUES(N'Phường Bùi Thị Xuân', 237)
INSERT XAPHUONG VALUES(N'Phường Cầu Dền', 237)
INSERT XAPHUONG VALUES(N'Phường Đống Mác', 237)
INSERT XAPHUONG VALUES(N'Phường Đồng Nhân', 237)
INSERT XAPHUONG VALUES(N'Phường Đồng Tâm', 237)
INSERT XAPHUONG VALUES(N'Phường Lê Đại Hành', 237)
INSERT XAPHUONG VALUES(N'Phường Minh Khai', 237)
INSERT XAPHUONG VALUES(N'Phường Ngô Thì Nhậm', 237)
INSERT XAPHUONG VALUES(N'Phường Nguyễn Du', 237)
INSERT XAPHUONG VALUES(N'Phường Phạm Đình Hổ', 237)
INSERT XAPHUONG VALUES(N'Phường Phố Huế', 237)
INSERT XAPHUONG VALUES(N'Phường Quỳnh Lôi', 237)
INSERT XAPHUONG VALUES(N'Phường Quỳnh Mai', 237)
INSERT XAPHUONG VALUES(N'Phường Thanh Lương', 237)
INSERT XAPHUONG VALUES(N'Phường Thanh Nhàn', 237)
INSERT XAPHUONG VALUES(N'Phường Trương Định', 237)
INSERT XAPHUONG VALUES(N'Phường Vĩnh Tuy', 237)

INSERT XAPHUONG VALUES(N'Phường Chương Dương', 238)
INSERT XAPHUONG VALUES(N'Phường Cửa Đông', 238)
INSERT XAPHUONG VALUES(N'Phường Cửa Nam', 238)
INSERT XAPHUONG VALUES(N'Phường Đồng Xuân', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Bạc', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Bài', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Bồ', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Bông', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Buồm', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Đào', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Gai', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Mã', 238)
INSERT XAPHUONG VALUES(N'Phường Hàng Trống', 238)
INSERT XAPHUONG VALUES(N'Phường Lý Thái Tổ', 238)
INSERT XAPHUONG VALUES(N'Phường Phan Chu Trinh', 238)
INSERT XAPHUONG VALUES(N'Phường Phúc Tân', 238)
INSERT XAPHUONG VALUES(N'Phường Trần Hưng Đạo', 238)
INSERT XAPHUONG VALUES(N'Phường Tràng Tiền', 238)

INSERT XAPHUONG VALUES(N'Phường Đại Kim', 239)
INSERT XAPHUONG VALUES(N'Phường Định Công', 239)
INSERT XAPHUONG VALUES(N'Phường Giáp Bát', 239)
INSERT XAPHUONG VALUES(N'Phường Hoàng Liệt', 239)
INSERT XAPHUONG VALUES(N'Phường Hoàng Văn Thụ', 239)
INSERT XAPHUONG VALUES(N'Phường Lĩnh Nam', 239)
INSERT XAPHUONG VALUES(N'Phường Mai Động', 239)
INSERT XAPHUONG VALUES(N'Phường Tân Mai', 239)
INSERT XAPHUONG VALUES(N'Phường Thanh Trì', 239)
INSERT XAPHUONG VALUES(N'Phường Thịnh Liệt', 239)
INSERT XAPHUONG VALUES(N'Phường Trần Phú', 239)
INSERT XAPHUONG VALUES(N'Phường Tương Mai', 239)
INSERT XAPHUONG VALUES(N'Phường Vĩnh Hưng', 239)
INSERT XAPHUONG VALUES(N'Phường Yên Sở', 239)

INSERT XAPHUONG VALUES(N'Phường Bồ Đề', 240)
INSERT XAPHUONG VALUES(N'Phường Cự Khối', 240)
INSERT XAPHUONG VALUES(N'Phường Đức Giang', 240)
INSERT XAPHUONG VALUES(N'Phường Gia Thuỵ', 240)
INSERT XAPHUONG VALUES(N'Phường Giang Biên', 240)
INSERT XAPHUONG VALUES(N'Phường Long Biên', 240)
INSERT XAPHUONG VALUES(N'Phường Ngọc Lâm', 240)
INSERT XAPHUONG VALUES(N'Phường Ngọc Thuỵ', 240)
INSERT XAPHUONG VALUES(N'Phường Phúc Đồng', 240)
INSERT XAPHUONG VALUES(N'Phường Phúc Lợi', 240)
INSERT XAPHUONG VALUES(N'Phường Sài Đồng', 240)
INSERT XAPHUONG VALUES(N'Phường Thạch Bàn', 240)
INSERT XAPHUONG VALUES(N'Phường Thượng Thanh', 240)
INSERT XAPHUONG VALUES(N'Phường Việt Hưng', 240)

INSERT XAPHUONG VALUES(N'Phường Cầu Diễn', 241)
INSERT XAPHUONG VALUES(N'Phường Đại Mỗ', 241)
INSERT XAPHUONG VALUES(N'Phường Mễ Trì', 241)
INSERT XAPHUONG VALUES(N'Phường Mỹ Đình 1', 241)
INSERT XAPHUONG VALUES(N'Phường Mỹ Đình 2', 241)
INSERT XAPHUONG VALUES(N'Phường Phú Đô', 241)
INSERT XAPHUONG VALUES(N'Phường Tây Mỗ', 241)
INSERT XAPHUONG VALUES(N'Phường Trung Văn', 241)
INSERT XAPHUONG VALUES(N'Phường Xuân Phương', 241)
INSERT XAPHUONG VALUES(N'Phường. Phương Canh', 241)

INSERT XAPHUONG VALUES(N'Phường Bưởi', 242)
INSERT XAPHUONG VALUES(N'Phường Nhật Tân', 242)
INSERT XAPHUONG VALUES(N'Phường Phú Thượng', 242)
INSERT XAPHUONG VALUES(N'Phường Quảng An', 242)
INSERT XAPHUONG VALUES(N'Phường Thuỵ Khuê', 242)
INSERT XAPHUONG VALUES(N'Phường Tứ Liên', 242)
INSERT XAPHUONG VALUES(N'Phường Xuân La', 242)
INSERT XAPHUONG VALUES(N'Phường Yên Phụ', 242)

INSERT XAPHUONG VALUES(N'Phường Hạ Đình', 243)
INSERT XAPHUONG VALUES(N'Phường Khương Đình', 243)
INSERT XAPHUONG VALUES(N'Phường Khương Mai', 243)
INSERT XAPHUONG VALUES(N'Phường Khương Trung', 243)
INSERT XAPHUONG VALUES(N'Phường Kim Giang', 243)
INSERT XAPHUONG VALUES(N'Phường Nhân Chính', 243)
INSERT XAPHUONG VALUES(N'Phường Phương Liệt', 243)
INSERT XAPHUONG VALUES(N'Phường Thanh Xuân Bắc', 243)
INSERT XAPHUONG VALUES(N'Phường Thanh Xuân Nam', 243)
INSERT XAPHUONG VALUES(N'Phường Thanh Xuân Trung', 243)
INSERT XAPHUONG VALUES(N'Phường Thượng Đình', 243)

INSERT XAPHUONG VALUES(N'Thị trấn Tây Đằng', 244)
INSERT XAPHUONG VALUES(N'Xã Ba Trại', 244)
INSERT XAPHUONG VALUES(N'Xã Ba Vì', 244)
INSERT XAPHUONG VALUES(N'Xã Cẩm Lĩnh', 244)
INSERT XAPHUONG VALUES(N'Xã Cam Thượng', 244)
INSERT XAPHUONG VALUES(N'Xã Châu Sơn', 244)
INSERT XAPHUONG VALUES(N'Xã Chu Minh', 244)
INSERT XAPHUONG VALUES(N'Xã Cổ Đô', 244)
INSERT XAPHUONG VALUES(N'Xã Đông Quang', 244)
INSERT XAPHUONG VALUES(N'Xã Đồng Thái', 244)
INSERT XAPHUONG VALUES(N'Xã Khánh Thượng', 244)
INSERT XAPHUONG VALUES(N'Xã Minh Châu', 244)
INSERT XAPHUONG VALUES(N'Xã Minh Quang', 244)
INSERT XAPHUONG VALUES(N'Xã Phong Vân', 244)
INSERT XAPHUONG VALUES(N'Xã Phú Châu', 244)
INSERT XAPHUONG VALUES(N'Xã Phú Cường', 244)
INSERT XAPHUONG VALUES(N'Xã Phú Đông', 244)
INSERT XAPHUONG VALUES(N'Xã Phú Phương', 244)
INSERT XAPHUONG VALUES(N'Xã Phú Sơn', 244)
INSERT XAPHUONG VALUES(N'Xã Sơn Đà', 244)
INSERT XAPHUONG VALUES(N'Xã Tản Hồng', 244)
INSERT XAPHUONG VALUES(N'Xã Tản Lĩnh', 244)
INSERT XAPHUONG VALUES(N'Xã Thái Hòa', 244)
INSERT XAPHUONG VALUES(N'Xã Thuần Mỹ', 244)
INSERT XAPHUONG VALUES(N'Xã Thụy An', 244)
INSERT XAPHUONG VALUES(N'Xã Tiên Phong', 244)
INSERT XAPHUONG VALUES(N'Xã Tòng Bạt', 244)
INSERT XAPHUONG VALUES(N'Xã Vân Hòa', 244)
INSERT XAPHUONG VALUES(N'Xã Vạn Thắng', 244)
INSERT XAPHUONG VALUES(N'Xã Vật Lại', 244)
INSERT XAPHUONG VALUES(N'Xã Yên Bài', 244)

INSERT XAPHUONG VALUES(N'Thị trấn Chúc Sơn', 245)
INSERT XAPHUONG VALUES(N'Thị trấn Xuân Mai', 245)
INSERT XAPHUONG VALUES(N'Xã Đại Yên', 245)
INSERT XAPHUONG VALUES(N'Xã Đồng Lạc', 245)
INSERT XAPHUONG VALUES(N'Xã Đồng Phú', 245)
INSERT XAPHUONG VALUES(N'Xã Đông Phương Yên', 245)
INSERT XAPHUONG VALUES(N'Xã Đông Sơn', 245)
INSERT XAPHUONG VALUES(N'Xã Hòa Chính', 245)
INSERT XAPHUONG VALUES(N'Xã Hoàng Diệu', 245)
INSERT XAPHUONG VALUES(N'Xã Hoàng Văn Thụ', 245)
INSERT XAPHUONG VALUES(N'Xã Hồng Phong', 245)
INSERT XAPHUONG VALUES(N'Xã Hợp Đồng', 245)
INSERT XAPHUONG VALUES(N'Xã Hữu Văn', 245)
INSERT XAPHUONG VALUES(N'Xã Lam Điền', 245)
INSERT XAPHUONG VALUES(N'Xã Mỹ Lương', 245)
INSERT XAPHUONG VALUES(N'Xã Nam Phương Tiến', 245)
INSERT XAPHUONG VALUES(N'Xã Ngọc Hòa', 245)
INSERT XAPHUONG VALUES(N'Xã Phú Nam An', 245)
INSERT XAPHUONG VALUES(N'Xã Phú Nghĩa', 245)
INSERT XAPHUONG VALUES(N'Xã Phụng Châu', 245)
INSERT XAPHUONG VALUES(N'Xã Quảng Bị', 245)
INSERT XAPHUONG VALUES(N'Xã Tân Tiến', 245)
INSERT XAPHUONG VALUES(N'Xã Thanh Bình', 245)
INSERT XAPHUONG VALUES(N'Xã Thượng Vực', 245)
INSERT XAPHUONG VALUES(N'Xã Thụy Hương', 245)
INSERT XAPHUONG VALUES(N'Xã Thủy Xuân Tiên', 245)
INSERT XAPHUONG VALUES(N'Xã Tiên Phương', 245)
INSERT XAPHUONG VALUES(N'Xã Tốt Động', 245)
INSERT XAPHUONG VALUES(N'Xã Trần Phú', 245)
INSERT XAPHUONG VALUES(N'Xã Trung Hòa', 245)
INSERT XAPHUONG VALUES(N'Xã Trường Yên', 245)
INSERT XAPHUONG VALUES(N'Xã Văn Võ', 245)

INSERT XAPHUONG VALUES(N'Thị trấn Phùng', 246)
INSERT XAPHUONG VALUES(N'Xã Đan Phượng', 246)
INSERT XAPHUONG VALUES(N'Xã Đồng Tháp', 246)
INSERT XAPHUONG VALUES(N'Xã Hạ Mỗ', 246)
INSERT XAPHUONG VALUES(N'Xã Hồng Hà', 246)
INSERT XAPHUONG VALUES(N'Xã Liên Hà', 246)
INSERT XAPHUONG VALUES(N'Xã Liên Hồng', 246)
INSERT XAPHUONG VALUES(N'Xã Liên Trung', 246)
INSERT XAPHUONG VALUES(N'Xã Phương Đình', 246)
INSERT XAPHUONG VALUES(N'Xã Song Phượng', 246)
INSERT XAPHUONG VALUES(N'Xã Tân Hội', 246)
INSERT XAPHUONG VALUES(N'Xã Tân Lập', 246)
INSERT XAPHUONG VALUES(N'Xã Thọ An', 246)
INSERT XAPHUONG VALUES(N'Xã Thọ Xuân', 246)
INSERT XAPHUONG VALUES(N'Xã Thượng Mỗ', 246)
INSERT XAPHUONG VALUES(N'Xã Trung Châu', 246)

INSERT XAPHUONG VALUES(N'Thị trấn Đông Anh', 247)
INSERT XAPHUONG VALUES(N'Xã Bắc Hồng', 247)
INSERT XAPHUONG VALUES(N'Xã Cổ Loa', 247)
INSERT XAPHUONG VALUES(N'Xã Đại Mạch', 247)
INSERT XAPHUONG VALUES(N'Xã Đông Hội', 247)
INSERT XAPHUONG VALUES(N'Xã Dục Tú', 247)
INSERT XAPHUONG VALUES(N'Xã Hải Bối', 247)
INSERT XAPHUONG VALUES(N'Xã Kim Chung', 247)
INSERT XAPHUONG VALUES(N'Xã Kim Nỗ', 247)
INSERT XAPHUONG VALUES(N'Xã Liên Hà', 247)
INSERT XAPHUONG VALUES(N'Xã Mai Lâm', 247)
INSERT XAPHUONG VALUES(N'Xã Nam Hồng', 247)
INSERT XAPHUONG VALUES(N'Xã Nguyên Khê', 247)
INSERT XAPHUONG VALUES(N'Xã Tàm Xá', 247)
INSERT XAPHUONG VALUES(N'Xã Tầm Xá', 247)
INSERT XAPHUONG VALUES(N'Xã Thuỵ Lâm', 247)
INSERT XAPHUONG VALUES(N'Xã Tiên Dương', 247)
INSERT XAPHUONG VALUES(N'Xã Uy Nỗ', 247)
INSERT XAPHUONG VALUES(N'Xã Vân Hà', 247)
INSERT XAPHUONG VALUES(N'Xã Vân Nội', 247)
INSERT XAPHUONG VALUES(N'Xã Việt Hùng', 247)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Ngọc', 247)
INSERT XAPHUONG VALUES(N'Xã Võng La', 247)
INSERT XAPHUONG VALUES(N'Xã Xuân Canh', 247)
INSERT XAPHUONG VALUES(N'Xã Xuân Nộn', 247)

INSERT XAPHUONG VALUES(N'Thị Trấn Trâu Quỳ', 248)
INSERT XAPHUONG VALUES(N'Thị trấn Yên Viên', 248)
INSERT XAPHUONG VALUES(N'Xã Bát Tràng', 248)
INSERT XAPHUONG VALUES(N'Xã Cổ Bi', 248)
INSERT XAPHUONG VALUES(N'Xã Đa Tốn', 248)
INSERT XAPHUONG VALUES(N'Xã Đặng Xá', 248)
INSERT XAPHUONG VALUES(N'Xã Đình Xuyên', 248)
INSERT XAPHUONG VALUES(N'Xã Đông Dư', 248)
INSERT XAPHUONG VALUES(N'Xã Dương Hà', 248)
INSERT XAPHUONG VALUES(N'Xã Dương Quang', 248)
INSERT XAPHUONG VALUES(N'Xã Dương Xá', 248)
INSERT XAPHUONG VALUES(N'Xã Kiêu Kỵ', 248)
INSERT XAPHUONG VALUES(N'Xã Kim Lan', 248)
INSERT XAPHUONG VALUES(N'Xã Kim Sơn', 248)
INSERT XAPHUONG VALUES(N'Xã Lệ Chi', 248)
INSERT XAPHUONG VALUES(N'Xã Ninh Hiệp', 248)
INSERT XAPHUONG VALUES(N'Xã Phù Đổng', 248)
INSERT XAPHUONG VALUES(N'Xã Phú Thị', 248)
INSERT XAPHUONG VALUES(N'Xã Trung Mầu', 248)
INSERT XAPHUONG VALUES(N'Xã Văn Đức', 248)
INSERT XAPHUONG VALUES(N'Xã Yên Thường', 248)
INSERT XAPHUONG VALUES(N'Xã Yên Viên', 248)

INSERT XAPHUONG VALUES(N'Thị trấn Trạm Trôi', 249)
INSERT XAPHUONG VALUES(N'Xã An Khánh', 249)
INSERT XAPHUONG VALUES(N'Xã An Thượng', 249)
INSERT XAPHUONG VALUES(N'Xã Cát Quế', 249)
INSERT XAPHUONG VALUES(N'Xã Đắc Sở', 249)
INSERT XAPHUONG VALUES(N'Xã Di Trạch', 249)
INSERT XAPHUONG VALUES(N'Xã Đông La', 249)
INSERT XAPHUONG VALUES(N'Xã Đức Giang', 249)
INSERT XAPHUONG VALUES(N'Xã Đức Thượng', 249)
INSERT XAPHUONG VALUES(N'Xã Dương Liễu', 249)
INSERT XAPHUONG VALUES(N'Xã Kim Chung', 249)
INSERT XAPHUONG VALUES(N'Xã La Phù', 249)
INSERT XAPHUONG VALUES(N'Xã Lại Yên', 249)
INSERT XAPHUONG VALUES(N'Xã Minh Khai', 249)
INSERT XAPHUONG VALUES(N'Xã Sơn Đồng', 249)
INSERT XAPHUONG VALUES(N'Xã Song Phương', 249)
INSERT XAPHUONG VALUES(N'Xã Tiền Yên', 249)
INSERT XAPHUONG VALUES(N'Xã Vân Canh', 249)
INSERT XAPHUONG VALUES(N'Xã Vân Côn', 249)
INSERT XAPHUONG VALUES(N'Xã Yên Sở', 249)

INSERT XAPHUONG VALUES(N'Thị trấn Chi Đông', 250)
INSERT XAPHUONG VALUES(N'Thị trấn Quang Minh', 250)
INSERT XAPHUONG VALUES(N'Xã Chu Phan', 250)
INSERT XAPHUONG VALUES(N'Xã Đại Thịnh', 250)
INSERT XAPHUONG VALUES(N'Xã Hoàng Kim', 250)
INSERT XAPHUONG VALUES(N'Xã Kim Hoa', 250)
INSERT XAPHUONG VALUES(N'Xã Liên Mạc', 250)
INSERT XAPHUONG VALUES(N'Xã Mê Linh', 250)
INSERT XAPHUONG VALUES(N'Xã Tam Đồng', 250)
INSERT XAPHUONG VALUES(N'Xã Thạch Đà', 250)
INSERT XAPHUONG VALUES(N'Xã Thanh Lâm', 250)
INSERT XAPHUONG VALUES(N'Xã Tiền Phong', 250)
INSERT XAPHUONG VALUES(N'Xã Tiến Thắng', 250)
INSERT XAPHUONG VALUES(N'Xã Tiến Thịnh', 250)
INSERT XAPHUONG VALUES(N'Xã Tráng Việt', 250)
INSERT XAPHUONG VALUES(N'Xã Tự Lập', 250)
INSERT XAPHUONG VALUES(N'Xã Văn Khê', 250)
INSERT XAPHUONG VALUES(N'Xã Vạn Yên', 250)

INSERT XAPHUONG VALUES(N'Thị trấn Đại Nghĩa', 251)
INSERT XAPHUONG VALUES(N'Xã An Mỹ', 251)
INSERT XAPHUONG VALUES(N'Xã An Phú', 251)
INSERT XAPHUONG VALUES(N'Xã An Tiến', 251)
INSERT XAPHUONG VALUES(N'Xã Bột Xuyên', 251)
INSERT XAPHUONG VALUES(N'Xã Đại Hưng', 251)
INSERT XAPHUONG VALUES(N'Xã Đốc Tín', 251)
INSERT XAPHUONG VALUES(N'Xã Đồng Tâm', 251)
INSERT XAPHUONG VALUES(N'Xã Hồng Sơn', 251)
INSERT XAPHUONG VALUES(N'Xã Hợp Thanh', 251)
INSERT XAPHUONG VALUES(N'Xã Hợp Tiến', 251)
INSERT XAPHUONG VALUES(N'Xã Hùng Tiến', 251)
INSERT XAPHUONG VALUES(N'Xã Hương Sơn', 251)
INSERT XAPHUONG VALUES(N'Xã Lê Thanh', 251)
INSERT XAPHUONG VALUES(N'Xã Mỹ Thành', 251)
INSERT XAPHUONG VALUES(N'Xã Phù Lưu Tế', 251)
INSERT XAPHUONG VALUES(N'Xã Phúc Lâm', 251)
INSERT XAPHUONG VALUES(N'Xã Phùng Xá', 251)
INSERT XAPHUONG VALUES(N'Xã Thượng Lâm', 251)
INSERT XAPHUONG VALUES(N'Xã Tuy Lai', 251)
INSERT XAPHUONG VALUES(N'Xã Vạn Kim', 251)
INSERT XAPHUONG VALUES(N'Xã Xuy Xá', 251)

INSERT XAPHUONG VALUES(N'Thị trấn Phú Minh', 252)
INSERT XAPHUONG VALUES(N'Thị trấn Phú Xuyên', 252)
INSERT XAPHUONG VALUES(N'Xã Bạch Hạ', 252)
INSERT XAPHUONG VALUES(N'Xã Châu Can', 252)
INSERT XAPHUONG VALUES(N'Xã Chuyên Mỹ', 252)
INSERT XAPHUONG VALUES(N'Xã Đại Thắng', 252)
INSERT XAPHUONG VALUES(N'Xã Đại Xuyên', 252)
INSERT XAPHUONG VALUES(N'Xã Hoàng Long', 252)
INSERT XAPHUONG VALUES(N'Xã Hồng Minh', 252)
INSERT XAPHUONG VALUES(N'Xã Hồng Thái', 252)
INSERT XAPHUONG VALUES(N'Xã Khai Thái', 252)
INSERT XAPHUONG VALUES(N'Xã Minh Tân', 252)
INSERT XAPHUONG VALUES(N'Xã Nam Phong', 252)
INSERT XAPHUONG VALUES(N'Xã Nam Tiến', 252)
INSERT XAPHUONG VALUES(N'Xã Nam Triều', 252)
INSERT XAPHUONG VALUES(N'Xã Phú Túc', 252)
INSERT XAPHUONG VALUES(N'Xã Phú Yên', 252)
INSERT XAPHUONG VALUES(N'Xã Phúc Tiến', 252)
INSERT XAPHUONG VALUES(N'Xã Phượng Dực', 252)
INSERT XAPHUONG VALUES(N'Xã Quang Lãng', 252)
INSERT XAPHUONG VALUES(N'Xã Quang Trung', 252)
INSERT XAPHUONG VALUES(N'Xã Sơn Hà', 252)
INSERT XAPHUONG VALUES(N'Xã Tân Dân', 252)
INSERT XAPHUONG VALUES(N'Xã Tri Thủy', 252)
INSERT XAPHUONG VALUES(N'Xã Tri Trung', 252)
INSERT XAPHUONG VALUES(N'Xã Văn Hoàng', 252)
INSERT XAPHUONG VALUES(N'Xã Vân Từ', 252)

INSERT XAPHUONG VALUES(N'Thị trấn Phúc Thọ', 253)
INSERT XAPHUONG VALUES(N'Xã Hát Môn', 253)
INSERT XAPHUONG VALUES(N'Xã Hiệp Thuận', 253)
INSERT XAPHUONG VALUES(N'Xã Liên Hiệp', 253)
INSERT XAPHUONG VALUES(N'Xã Long Xuyên', 253)
INSERT XAPHUONG VALUES(N'Xã Ngọc Tảo', 253)
INSERT XAPHUONG VALUES(N'Xã Phúc Hòa', 253)
INSERT XAPHUONG VALUES(N'Xã Phụng Thượng', 253)
INSERT XAPHUONG VALUES(N'Xã Phương Độ', 253)
INSERT XAPHUONG VALUES(N'Xã Sen Chiểu', 253)
INSERT XAPHUONG VALUES(N'Xã Sen Phương', 253)
INSERT XAPHUONG VALUES(N'Xã Tam Hiệp', 253)
INSERT XAPHUONG VALUES(N'Xã Tam Thuấn', 253)
INSERT XAPHUONG VALUES(N'Xã Thanh Đa', 253)
INSERT XAPHUONG VALUES(N'Xã Thọ Lộc', 253)
INSERT XAPHUONG VALUES(N'Xã Thượng Cốc', 253)
INSERT XAPHUONG VALUES(N'Xã Tích Giang', 253)
INSERT XAPHUONG VALUES(N'Xã Trạch Mỹ Lộc', 253)
INSERT XAPHUONG VALUES(N'Xã Vân Hà', 253)
INSERT XAPHUONG VALUES(N'Xã Vân Nam', 253)
INSERT XAPHUONG VALUES(N'Xã Vân Phúc', 253)
INSERT XAPHUONG VALUES(N'Xã Võng Xuyên', 253)
INSERT XAPHUONG VALUES(N'Xã Xuân Đình', 253)

INSERT XAPHUONG VALUES(N'Thị trấn Quốc Oai', 254)
INSERT XAPHUONG VALUES(N'Xã Cấn Hữu', 254)
INSERT XAPHUONG VALUES(N'Xã Cộng Hòa', 254)
INSERT XAPHUONG VALUES(N'Xã Đại Thành', 254)
INSERT XAPHUONG VALUES(N'Xã Đồng Quang', 254)
INSERT XAPHUONG VALUES(N'Xã Đông Xuân', 254)
INSERT XAPHUONG VALUES(N'Xã Đông Yên', 254)
INSERT XAPHUONG VALUES(N'Xã Hòa Thạch', 254)
INSERT XAPHUONG VALUES(N'Xã Liệp Tuyết', 254)
INSERT XAPHUONG VALUES(N'Xã Nghĩa Hương', 254)
INSERT XAPHUONG VALUES(N'Xã Ngọc Liệp', 254)
INSERT XAPHUONG VALUES(N'Xã Ngọc Mỹ', 254)
INSERT XAPHUONG VALUES(N'Xã Phú Cát', 254)
INSERT XAPHUONG VALUES(N'Xã Phú Mãn', 254)
INSERT XAPHUONG VALUES(N'Xã Phượng Cách', 254)
INSERT XAPHUONG VALUES(N'Xã Sài Sơn', 254)
INSERT XAPHUONG VALUES(N'Xã Tân Hòa', 254)
INSERT XAPHUONG VALUES(N'Xã Tân Phú', 254)
INSERT XAPHUONG VALUES(N'Xã Thạch Thán', 254)
INSERT XAPHUONG VALUES(N'Xã Tuyết Nghĩa', 254)
INSERT XAPHUONG VALUES(N'Xã Yên Sơn', 254)

INSERT XAPHUONG VALUES(N'Thị trấn Sóc Sơn', 255)
INSERT XAPHUONG VALUES(N'Xã Bắc Phú', 255)
INSERT XAPHUONG VALUES(N'Xã Bắc Sơn', 255)
INSERT XAPHUONG VALUES(N'Xã Đông Xuân', 255)
INSERT XAPHUONG VALUES(N'Xã Đức Hoà', 255)
INSERT XAPHUONG VALUES(N'Xã Hiền Ninh', 255)
INSERT XAPHUONG VALUES(N'Xã Hồng Kỳ', 255)
INSERT XAPHUONG VALUES(N'Xã Kim Lũ', 255)
INSERT XAPHUONG VALUES(N'Xã Mai Đình', 255)
INSERT XAPHUONG VALUES(N'Xã Minh Phú', 255)
INSERT XAPHUONG VALUES(N'Xã Minh Trí', 255)
INSERT XAPHUONG VALUES(N'Xã Nam Sơn', 255)
INSERT XAPHUONG VALUES(N'Xã Phú Cường', 255)
INSERT XAPHUONG VALUES(N'Xã Phù Linh', 255)
INSERT XAPHUONG VALUES(N'Xã Phù Lỗ', 255)
INSERT XAPHUONG VALUES(N'Xã Phú Minh', 255)
INSERT XAPHUONG VALUES(N'Xã Quang Tiến', 255)
INSERT XAPHUONG VALUES(N'Xã Tân Dân', 255)
INSERT XAPHUONG VALUES(N'Xã Tân Hưng', 255)
INSERT XAPHUONG VALUES(N'Xã Tân Minh', 255)
INSERT XAPHUONG VALUES(N'Xã Thanh Xuân', 255)
INSERT XAPHUONG VALUES(N'Xã Tiên Dược', 255)
INSERT XAPHUONG VALUES(N'Xã Trung Giã', 255)
INSERT XAPHUONG VALUES(N'Xã Việt Long', 255)
INSERT XAPHUONG VALUES(N'Xã Xuân Giang', 255)
INSERT XAPHUONG VALUES(N'Xã Xuân Thu', 255)

INSERT XAPHUONG VALUES(N'Thị trấn Liên Quan', 256)
INSERT XAPHUONG VALUES(N'Xã Bình Phú', 256)
INSERT XAPHUONG VALUES(N'Xã Bình Yên', 256)
INSERT XAPHUONG VALUES(N'Xã Cẩm Yên', 256)
INSERT XAPHUONG VALUES(N'Xã Cần Kiệm', 256)
INSERT XAPHUONG VALUES(N'Xã Canh Nậu', 256)
INSERT XAPHUONG VALUES(N'Xã Chàng Sơn', 256)
INSERT XAPHUONG VALUES(N'Xã Đại Đồng', 256)
INSERT XAPHUONG VALUES(N'Xã Dị Nậu', 256)
INSERT XAPHUONG VALUES(N'Xã Đồng Trúc', 256)
INSERT XAPHUONG VALUES(N'Xã Hạ Bằng', 256)
INSERT XAPHUONG VALUES(N'Xã Hương Ngải', 256)
INSERT XAPHUONG VALUES(N'Xã Hữu Bằng', 256)
INSERT XAPHUONG VALUES(N'Xã Kim Quan', 256)
INSERT XAPHUONG VALUES(N'Xã Lại Thượng', 256)
INSERT XAPHUONG VALUES(N'Xã Phú Kim', 256)
INSERT XAPHUONG VALUES(N'Xã Phùng Xá', 256)
INSERT XAPHUONG VALUES(N'Xã Tân Xã', 256)
INSERT XAPHUONG VALUES(N'Xã Thạch Hoà', 256)
INSERT XAPHUONG VALUES(N'Xã Thạch Xá', 256)
INSERT XAPHUONG VALUES(N'Xã Tiến Xuân', 256)
INSERT XAPHUONG VALUES(N'Xã Yên Bình', 256)
INSERT XAPHUONG VALUES(N'Xã Yên Trung', 256)

INSERT XAPHUONG VALUES(N'Thị trấn Kim Bài', 257)
INSERT XAPHUONG VALUES(N'Xã Bích Hòa', 257)
INSERT XAPHUONG VALUES(N'Xã Bình Minh', 257)
INSERT XAPHUONG VALUES(N'Xã Cao Dương', 257)
INSERT XAPHUONG VALUES(N'Xã Cao Viên', 257)
INSERT XAPHUONG VALUES(N'Xã Cự Khê', 257)
INSERT XAPHUONG VALUES(N'Xã Dân Hòa', 257)
INSERT XAPHUONG VALUES(N'Xã Đỗ Động', 257)
INSERT XAPHUONG VALUES(N'Xã Hồng Dương', 257)
INSERT XAPHUONG VALUES(N'Xã Kim An', 257)
INSERT XAPHUONG VALUES(N'Xã Kim Thư', 257)
INSERT XAPHUONG VALUES(N'Xã Liên Châu', 257)
INSERT XAPHUONG VALUES(N'Xã Mỹ Hưng', 257)
INSERT XAPHUONG VALUES(N'Xã Phương Trung', 257)
INSERT XAPHUONG VALUES(N'Xã Tam Hưng', 257)
INSERT XAPHUONG VALUES(N'Xã Tân Ước', 257)
INSERT XAPHUONG VALUES(N'Xã Thanh Cao', 257)
INSERT XAPHUONG VALUES(N'Xã Thanh Mai', 257)
INSERT XAPHUONG VALUES(N'Xã Thanh Thùy', 257)
INSERT XAPHUONG VALUES(N'Xã Thanh Văn', 257)
INSERT XAPHUONG VALUES(N'Xã Xuân Dương', 257)

INSERT XAPHUONG VALUES(N'Thị trấn Văn Điển', 258)
INSERT XAPHUONG VALUES(N'Xã Đại áng', 258)
INSERT XAPHUONG VALUES(N'Xã Đông Mỹ', 258)
INSERT XAPHUONG VALUES(N'Xã Duyên Hà', 258)
INSERT XAPHUONG VALUES(N'Xã Hữu Hoà', 258)
INSERT XAPHUONG VALUES(N'Xã Liên Ninh', 258)
INSERT XAPHUONG VALUES(N'Xã Ngọc Hồi', 258)
INSERT XAPHUONG VALUES(N'Xã Ngũ Hiệp', 258)
INSERT XAPHUONG VALUES(N'Xã Tả Thanh Oai', 258)
INSERT XAPHUONG VALUES(N'Xã Tam Hiệp', 258)
INSERT XAPHUONG VALUES(N'Xã Tân Triều', 258)
INSERT XAPHUONG VALUES(N'Xã Thanh Liệt', 258)
INSERT XAPHUONG VALUES(N'Xã Tứ Hiệp', 258)
INSERT XAPHUONG VALUES(N'Xã Vạn Phúc', 258)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Quỳnh', 258)
INSERT XAPHUONG VALUES(N'Xã Yên Mỹ', 258)

INSERT XAPHUONG VALUES(N'Thị trấn Thường Tín', 259)
INSERT XAPHUONG VALUES(N'Xã Chương Dương', 259)
INSERT XAPHUONG VALUES(N'Xã Dũng Tiến', 259)
INSERT XAPHUONG VALUES(N'Xã Duyên Thái', 259)
INSERT XAPHUONG VALUES(N'Xã Hà Hồi', 259)
INSERT XAPHUONG VALUES(N'Xã Hiền Giang', 259)
INSERT XAPHUONG VALUES(N'Xã Hòa Bình', 259)
INSERT XAPHUONG VALUES(N'Xã Hồng Vân', 259)
INSERT XAPHUONG VALUES(N'Xã Khánh Hà', 259)
INSERT XAPHUONG VALUES(N'Xã Lê Lợi', 259)
INSERT XAPHUONG VALUES(N'Xã Liên Phương', 259)
INSERT XAPHUONG VALUES(N'Xã Minh Cường', 259)
INSERT XAPHUONG VALUES(N'Xã Nghiêm Xuyên', 259)
INSERT XAPHUONG VALUES(N'Xã Nguyễn Trãi', 259)
INSERT XAPHUONG VALUES(N'Xã Nhị Khê', 259)
INSERT XAPHUONG VALUES(N'Xã Ninh Sở', 259)
INSERT XAPHUONG VALUES(N'Xã Quất Động', 259)
INSERT XAPHUONG VALUES(N'Xã Tân Minh', 259)
INSERT XAPHUONG VALUES(N'Xã Thắng Lợi', 259)
INSERT XAPHUONG VALUES(N'Xã Thống Nhất', 259)
INSERT XAPHUONG VALUES(N'Xã Thư Phú', 259)
INSERT XAPHUONG VALUES(N'Xã Tiền Phong', 259)
INSERT XAPHUONG VALUES(N'Xã Tô Hiệu', 259)
INSERT XAPHUONG VALUES(N'Xã Tự Nhiên', 259)
INSERT XAPHUONG VALUES(N'Xã Văn Bình', 259)
INSERT XAPHUONG VALUES(N'Xã Vạn Điểm', 259)
INSERT XAPHUONG VALUES(N'Xã Văn Phú', 259)
INSERT XAPHUONG VALUES(N'Xã Vân Tảo', 259)
INSERT XAPHUONG VALUES(N'Xã Văn Tự', 259)

INSERT XAPHUONG VALUES(N'Thị trấn Vân Đình', 260)
INSERT XAPHUONG VALUES(N'Xã Cao Thành', 260)
INSERT XAPHUONG VALUES(N'Xã Đại Cường', 260)
INSERT XAPHUONG VALUES(N'Xã Đại Hùng', 260)
INSERT XAPHUONG VALUES(N'Xã Đội Bình', 260)
INSERT XAPHUONG VALUES(N'Xã Đông Lỗ', 260)
INSERT XAPHUONG VALUES(N'Xã Đồng Tân', 260)
INSERT XAPHUONG VALUES(N'Xã Đồng Tiến', 260)
INSERT XAPHUONG VALUES(N'Xã Hòa Lâm', 260)
INSERT XAPHUONG VALUES(N'Xã Hòa Nam', 260)
INSERT XAPHUONG VALUES(N'Xã Hòa Phú', 260)
INSERT XAPHUONG VALUES(N'Xã Hoa Sơn', 260)
INSERT XAPHUONG VALUES(N'Xã Hòa Xá', 260)
INSERT XAPHUONG VALUES(N'Xã Hồng Quang', 260)
INSERT XAPHUONG VALUES(N'Xã Kim Đường', 260)
INSERT XAPHUONG VALUES(N'Xã Liên Bạt', 260)
INSERT XAPHUONG VALUES(N'Xã Lưu Hoàng', 260)
INSERT XAPHUONG VALUES(N'Xã Minh Đức', 260)
INSERT XAPHUONG VALUES(N'Xã Phù Lưu', 260)
INSERT XAPHUONG VALUES(N'Xã Phương Tú', 260)
INSERT XAPHUONG VALUES(N'Xã Quảng Phú Cầu', 260)
INSERT XAPHUONG VALUES(N'Xã Sơn Công', 260)
INSERT XAPHUONG VALUES(N'Xã Tảo Dương Văn', 260)
INSERT XAPHUONG VALUES(N'Xã Trầm Lộng', 260)
INSERT XAPHUONG VALUES(N'Xã Trung Tú', 260)
INSERT XAPHUONG VALUES(N'Xã Trường Thịnh', 260)
INSERT XAPHUONG VALUES(N'Xã Vạn Thái', 260)
INSERT XAPHUONG VALUES(N'Xã Viên An', 260)
INSERT XAPHUONG VALUES(N'Xã Viên Nội', 260)

INSERT XAPHUONG VALUES(N'Phường Lê Lợi', 261)
INSERT XAPHUONG VALUES(N'Phường Ngô Quyền', 261)
INSERT XAPHUONG VALUES(N'Phường Phú Thịnh', 261)
INSERT XAPHUONG VALUES(N'Phường Quang Trung', 261)
INSERT XAPHUONG VALUES(N'Phường Sơn Lộc', 261)
INSERT XAPHUONG VALUES(N'Phường Trung Hưng', 261)
INSERT XAPHUONG VALUES(N'Phường Trung Sơn Trầm', 261)
INSERT XAPHUONG VALUES(N'Phường Viên Sơn', 261)
INSERT XAPHUONG VALUES(N'Phường Xuân Khanh', 261)
INSERT XAPHUONG VALUES(N'Xã Cổ Đông', 261)
INSERT XAPHUONG VALUES(N'Xã Đường Lâm', 261)
INSERT XAPHUONG VALUES(N'Xã Kim Sơn', 261)
INSERT XAPHUONG VALUES(N'Xã Sơn Đông', 261)
INSERT XAPHUONG VALUES(N'Xã Thanh Mỹ', 261)
INSERT XAPHUONG VALUES(N'Xã Xuân Sơn', 261)

INSERT XAPHUONG VALUES(N'Phường An Khánh', 262)
INSERT XAPHUONG VALUES(N'Phường An Lợi Đông', 262)
INSERT XAPHUONG VALUES(N'Phường An Phú', 262)
INSERT XAPHUONG VALUES(N'Phường Bình Chiểu', 262)
INSERT XAPHUONG VALUES(N'Phường Bình Thọ', 262)
INSERT XAPHUONG VALUES(N'Phường Bình Trưng Đông', 262)
INSERT XAPHUONG VALUES(N'Phường Bình Trưng Tây', 262)
INSERT XAPHUONG VALUES(N'Phường Cát Lái', 262)
INSERT XAPHUONG VALUES(N'Phường Hiệp Bình Chánh', 262)
INSERT XAPHUONG VALUES(N'Phường Hiệp Bình Phước', 262)
INSERT XAPHUONG VALUES(N'Phường Hiệp Phú', 262)
INSERT XAPHUONG VALUES(N'Phường Linh Chiểu', 262)
INSERT XAPHUONG VALUES(N'Phường Linh Đông', 262)
INSERT XAPHUONG VALUES(N'Phường Linh Tây', 262)
INSERT XAPHUONG VALUES(N'Phường Linh Trung', 262)
INSERT XAPHUONG VALUES(N'Phường Linh Xuân', 262)
INSERT XAPHUONG VALUES(N'Phường Long Bình', 262)
INSERT XAPHUONG VALUES(N'Phường Long Phước', 262)
INSERT XAPHUONG VALUES(N'Phường Long Thạnh Mỹ', 262)
INSERT XAPHUONG VALUES(N'Phường Long Trường', 262)
INSERT XAPHUONG VALUES(N'Phường Phú Hữu', 262)
INSERT XAPHUONG VALUES(N'Phường Phước Bình', 262)
INSERT XAPHUONG VALUES(N'Phường Phước Long A', 262)
INSERT XAPHUONG VALUES(N'Phường Phước Long B', 262)
INSERT XAPHUONG VALUES(N'Phường Tam Bình', 262)
INSERT XAPHUONG VALUES(N'Phường Tam Phú', 262)
INSERT XAPHUONG VALUES(N'Phường Tân Phú', 262)
INSERT XAPHUONG VALUES(N'Phường Tăng Nhơn Phú A', 262)
INSERT XAPHUONG VALUES(N'Phường Tăng Nhơn Phú B', 262)
INSERT XAPHUONG VALUES(N'Phường Thạnh Mỹ Lợi', 262)
INSERT XAPHUONG VALUES(N'Phường Thảo Điền', 262)
INSERT XAPHUONG VALUES(N'Phường Thủ Thiêm', 262)
INSERT XAPHUONG VALUES(N'Phường Trường Thạnh', 262)
INSERT XAPHUONG VALUES(N'Phường Trường Thọ', 262)

INSERT XAPHUONG VALUES(N'Phường Bến Nghé', 263)
INSERT XAPHUONG VALUES(N'Phường Bến Thành', 263)
INSERT XAPHUONG VALUES(N'Phường Cầu Kho', 263)
INSERT XAPHUONG VALUES(N'Phường Cầu Ông Lãnh', 263)
INSERT XAPHUONG VALUES(N'Phường Cô Giang', 263)
INSERT XAPHUONG VALUES(N'Phường Đa Kao', 263)
INSERT XAPHUONG VALUES(N'Phường Nguyễn Cư Trinh', 263)
INSERT XAPHUONG VALUES(N'Phường Nguyễn Thái Bình', 263)
INSERT XAPHUONG VALUES(N'Phường Phạm Ngũ Lão', 263)
INSERT XAPHUONG VALUES(N'Phường Tân Định', 263)

INSERT XAPHUONG VALUES(N'Phường 01', 264)
INSERT XAPHUONG VALUES(N'Phường 02', 264)
INSERT XAPHUONG VALUES(N'Phường 03', 264)
INSERT XAPHUONG VALUES(N'Phường 04', 264)
INSERT XAPHUONG VALUES(N'Phường 05', 264)
INSERT XAPHUONG VALUES(N'Phường 09', 264)
INSERT XAPHUONG VALUES(N'Phường 10', 264)
INSERT XAPHUONG VALUES(N'Phường 11', 264)
INSERT XAPHUONG VALUES(N'Phường 12', 264)
INSERT XAPHUONG VALUES(N'Phường 13', 264)
INSERT XAPHUONG VALUES(N'Phường 14', 264)
INSERT XAPHUONG VALUES(N'Phường Võ Thị Sáu', 264)

INSERT XAPHUONG VALUES(N'Phường 01', 265)
INSERT XAPHUONG VALUES(N'Phường 02', 265)
INSERT XAPHUONG VALUES(N'Phường 03', 265)
INSERT XAPHUONG VALUES(N'Phường 04', 265)
INSERT XAPHUONG VALUES(N'Phường 06', 265)
INSERT XAPHUONG VALUES(N'Phường 08', 265)
INSERT XAPHUONG VALUES(N'Phường 09', 265)
INSERT XAPHUONG VALUES(N'Phường 10', 265)
INSERT XAPHUONG VALUES(N'Phường 13', 265)
INSERT XAPHUONG VALUES(N'Phường 14', 265)
INSERT XAPHUONG VALUES(N'Phường 15', 265)
INSERT XAPHUONG VALUES(N'Phường 16', 265)
INSERT XAPHUONG VALUES(N'Phường 18', 265)

INSERT XAPHUONG VALUES(N'Phường 01', 266)
INSERT XAPHUONG VALUES(N'Phường 02', 266)
INSERT XAPHUONG VALUES(N'Phường 03', 266)
INSERT XAPHUONG VALUES(N'Phường 04', 266)
INSERT XAPHUONG VALUES(N'Phường 05', 266)
INSERT XAPHUONG VALUES(N'Phường 06', 266)
INSERT XAPHUONG VALUES(N'Phường 07', 266)
INSERT XAPHUONG VALUES(N'Phường 08', 266)
INSERT XAPHUONG VALUES(N'Phường 09', 266)
INSERT XAPHUONG VALUES(N'Phường 10', 266)
INSERT XAPHUONG VALUES(N'Phường 11', 266)
INSERT XAPHUONG VALUES(N'Phường 12', 266)
INSERT XAPHUONG VALUES(N'Phường 13', 266)
INSERT XAPHUONG VALUES(N'Phường 14', 266)

INSERT XAPHUONG VALUES(N'Phường 01', 267)
INSERT XAPHUONG VALUES(N'Phường 02', 267)
INSERT XAPHUONG VALUES(N'Phường 03', 267)
INSERT XAPHUONG VALUES(N'Phường 04', 267)
INSERT XAPHUONG VALUES(N'Phường 05', 267)
INSERT XAPHUONG VALUES(N'Phường 06', 267)
INSERT XAPHUONG VALUES(N'Phường 07', 267)
INSERT XAPHUONG VALUES(N'Phường 08', 267)
INSERT XAPHUONG VALUES(N'Phường 09', 267)
INSERT XAPHUONG VALUES(N'Phường 10', 267)
INSERT XAPHUONG VALUES(N'Phường 11', 267)
INSERT XAPHUONG VALUES(N'Phường 12', 267)
INSERT XAPHUONG VALUES(N'Phường 13', 267)
INSERT XAPHUONG VALUES(N'Phường 14', 267)

INSERT XAPHUONG VALUES(N'Phường Bình Thuận', 268)
INSERT XAPHUONG VALUES(N'Phường Phú Mỹ', 268)
INSERT XAPHUONG VALUES(N'Phường Phú Thuận', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Hưng', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Kiểng', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Phong', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Phú', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Quy', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Thuận Đông', 268)
INSERT XAPHUONG VALUES(N'Phường Tân Thuận Tây', 268)

INSERT XAPHUONG VALUES(N'Phường 1', 269)
INSERT XAPHUONG VALUES(N'Phường 2', 269)
INSERT XAPHUONG VALUES(N'Phường 3', 269)
INSERT XAPHUONG VALUES(N'Phường 4', 269)
INSERT XAPHUONG VALUES(N'Phường 5', 269)
INSERT XAPHUONG VALUES(N'Phường 6', 269)
INSERT XAPHUONG VALUES(N'Phường 7', 269)
INSERT XAPHUONG VALUES(N'Phường 8', 269)
INSERT XAPHUONG VALUES(N'Phường 9', 269)
INSERT XAPHUONG VALUES(N'Phường 10', 269)
INSERT XAPHUONG VALUES(N'Phường 11', 269)
INSERT XAPHUONG VALUES(N'Phường 12', 269)
INSERT XAPHUONG VALUES(N'Phường 13', 269)
INSERT XAPHUONG VALUES(N'Phường 14', 269)
INSERT XAPHUONG VALUES(N'Phường 15', 269)
INSERT XAPHUONG VALUES(N'Phường 16', 269)

INSERT XAPHUONG VALUES(N'Phường 01', 270)
INSERT XAPHUONG VALUES(N'Phường 02', 270)
INSERT XAPHUONG VALUES(N'Phường 04', 270)
INSERT XAPHUONG VALUES(N'Phường 05', 270)
INSERT XAPHUONG VALUES(N'Phường 06', 270)
INSERT XAPHUONG VALUES(N'Phường 07', 270)
INSERT XAPHUONG VALUES(N'Phường 08', 270)
INSERT XAPHUONG VALUES(N'Phường 09', 270)
INSERT XAPHUONG VALUES(N'Phường 10', 270)
INSERT XAPHUONG VALUES(N'Phường 11', 270)
INSERT XAPHUONG VALUES(N'Phường 12', 270)
INSERT XAPHUONG VALUES(N'Phường 13', 270)
INSERT XAPHUONG VALUES(N'Phường 14', 270)
INSERT XAPHUONG VALUES(N'Phường 15', 270)

INSERT XAPHUONG VALUES(N'Phường 1', 271)
INSERT XAPHUONG VALUES(N'Phường 2', 271)
INSERT XAPHUONG VALUES(N'Phường 3', 271)
INSERT XAPHUONG VALUES(N'Phường 4', 271)
INSERT XAPHUONG VALUES(N'Phường 5', 271)
INSERT XAPHUONG VALUES(N'Phường 6', 271)
INSERT XAPHUONG VALUES(N'Phường 7', 271)
INSERT XAPHUONG VALUES(N'Phường 8', 271)
INSERT XAPHUONG VALUES(N'Phường 9', 271)
INSERT XAPHUONG VALUES(N'Phường 10', 271)
INSERT XAPHUONG VALUES(N'Phường 11', 271)
INSERT XAPHUONG VALUES(N'Phường 12', 271)
INSERT XAPHUONG VALUES(N'Phường 13', 271)
INSERT XAPHUONG VALUES(N'Phường 14', 271)
INSERT XAPHUONG VALUES(N'Phường 15', 271)
INSERT XAPHUONG VALUES(N'Phường 16', 271)

INSERT XAPHUONG VALUES(N'Phường An Phú Đông', 272)
INSERT XAPHUONG VALUES(N'Phường Đông Hưng Thuận', 272)
INSERT XAPHUONG VALUES(N'phường Hiệp Thành', 272)
INSERT XAPHUONG VALUES(N'phường Tân Chánh Hiệp', 272)
INSERT XAPHUONG VALUES(N'Phường Tân Hưng Thuận', 272)
INSERT XAPHUONG VALUES(N'Phường Tân Thới Hiệp', 272)
INSERT XAPHUONG VALUES(N'Phường Tân Thới Nhất', 272)
INSERT XAPHUONG VALUES(N'Phường Thạnh Lộc', 272)
INSERT XAPHUONG VALUES(N'Phường Thạnh Xuân', 272)
INSERT XAPHUONG VALUES(N'Phường Thới An', 272)
INSERT XAPHUONG VALUES(N'Phường Trung Mỹ Tây', 272)

INSERT XAPHUONG VALUES(N'Phường An Lạc', 273)
INSERT XAPHUONG VALUES(N'Phường An Lạc A', 273)
INSERT XAPHUONG VALUES(N'Phường Bình Hưng Hòa', 273)
INSERT XAPHUONG VALUES(N'Phường Bình Hưng Hòa A', 273)
INSERT XAPHUONG VALUES(N'Phường Bình Hưng Hòa B', 273)
INSERT XAPHUONG VALUES(N'Phường Bình Trị Đông', 273)
INSERT XAPHUONG VALUES(N'Phường Bình Trị Đông A', 273)
INSERT XAPHUONG VALUES(N'Phường Bình Trị Đông B', 273)
INSERT XAPHUONG VALUES(N'Phường Tân Tạo', 273)
INSERT XAPHUONG VALUES(N'Phường Tân Tạo A', 273)

INSERT XAPHUONG VALUES(N'Phường 1', 274)
INSERT XAPHUONG VALUES(N'Phường 2', 274)
INSERT XAPHUONG VALUES(N'Phường 3', 274)
INSERT XAPHUONG VALUES(N'Phường 5', 274)
INSERT XAPHUONG VALUES(N'Phường 6', 274)
INSERT XAPHUONG VALUES(N'Phường 7', 274)
INSERT XAPHUONG VALUES(N'Phường 11', 274)
INSERT XAPHUONG VALUES(N'Phường 12', 274)
INSERT XAPHUONG VALUES(N'Phường 13', 274)
INSERT XAPHUONG VALUES(N'Phường 14', 274)
INSERT XAPHUONG VALUES(N'Phường 15', 274)
INSERT XAPHUONG VALUES(N'Phường 17', 274)
INSERT XAPHUONG VALUES(N'Phường 19', 274)
INSERT XAPHUONG VALUES(N'Phường 21', 274)
INSERT XAPHUONG VALUES(N'Phường 22', 274)
INSERT XAPHUONG VALUES(N'Phường 24', 274)
INSERT XAPHUONG VALUES(N'Phường 25', 274)
INSERT XAPHUONG VALUES(N'Phường 26', 274)
INSERT XAPHUONG VALUES(N'Phường 27', 274)
INSERT XAPHUONG VALUES(N'Phường 28', 274)

INSERT XAPHUONG VALUES(N'Phường 1', 275)
INSERT XAPHUONG VALUES(N'Phường 3', 275)
INSERT XAPHUONG VALUES(N'Phường 4', 275)
INSERT XAPHUONG VALUES(N'Phường 5', 275)
INSERT XAPHUONG VALUES(N'Phường 6', 275)
INSERT XAPHUONG VALUES(N'Phường 7', 275)
INSERT XAPHUONG VALUES(N'Phường 8', 275)
INSERT XAPHUONG VALUES(N'Phường 9', 275)
INSERT XAPHUONG VALUES(N'Phường 10', 275)
INSERT XAPHUONG VALUES(N'Phường 11', 275)
INSERT XAPHUONG VALUES(N'Phường 12', 275)
INSERT XAPHUONG VALUES(N'Phường 13', 275)
INSERT XAPHUONG VALUES(N'Phường 14', 275)
INSERT XAPHUONG VALUES(N'Phường 15', 275)
INSERT XAPHUONG VALUES(N'Phường 16', 275)
INSERT XAPHUONG VALUES(N'Phường 17', 275)

INSERT XAPHUONG VALUES(N'Phường 01', 276)
INSERT XAPHUONG VALUES(N'Phường 02', 276)
INSERT XAPHUONG VALUES(N'Phường 03', 276)
INSERT XAPHUONG VALUES(N'Phường 04', 276)
INSERT XAPHUONG VALUES(N'Phường 05', 276)
INSERT XAPHUONG VALUES(N'Phường 07', 276)
INSERT XAPHUONG VALUES(N'Phường 08', 276)
INSERT XAPHUONG VALUES(N'Phường 09', 276)
INSERT XAPHUONG VALUES(N'Phường 10', 276)
INSERT XAPHUONG VALUES(N'Phường 11', 276)
INSERT XAPHUONG VALUES(N'Phường 13', 276)
INSERT XAPHUONG VALUES(N'Phường 15', 276)
INSERT XAPHUONG VALUES(N'Phường 17', 276)

INSERT XAPHUONG VALUES(N'Phường 1', 277)
INSERT XAPHUONG VALUES(N'Phường 2', 277)
INSERT XAPHUONG VALUES(N'Phường 3', 277)
INSERT XAPHUONG VALUES(N'Phường 4', 277)
INSERT XAPHUONG VALUES(N'Phường 5', 277)
INSERT XAPHUONG VALUES(N'Phường 6', 277)
INSERT XAPHUONG VALUES(N'Phường 7', 277)
INSERT XAPHUONG VALUES(N'Phường 8', 277)
INSERT XAPHUONG VALUES(N'Phường 9', 277)
INSERT XAPHUONG VALUES(N'Phường 10', 277)
INSERT XAPHUONG VALUES(N'Phường 11', 277)
INSERT XAPHUONG VALUES(N'Phường 12', 277)
INSERT XAPHUONG VALUES(N'Phường 13', 277)
INSERT XAPHUONG VALUES(N'Phường 14', 277)
INSERT XAPHUONG VALUES(N'Phường 15', 277)

INSERT XAPHUONG VALUES(N'Phường Hiệp Tân', 278)
INSERT XAPHUONG VALUES(N'Phường Hoà Thạnh', 278)
INSERT XAPHUONG VALUES(N'Phường Phú Thạnh', 278)
INSERT XAPHUONG VALUES(N'Phường Phú Thọ Hoà', 278)
INSERT XAPHUONG VALUES(N'Phường Phú Trung', 278)
INSERT XAPHUONG VALUES(N'Phường Sơn Kỳ', 278)
INSERT XAPHUONG VALUES(N'Phường Tân Quý', 278)
INSERT XAPHUONG VALUES(N'Phường Tân Sơn Nhì', 278)
INSERT XAPHUONG VALUES(N'Phường Tân Thành', 278)
INSERT XAPHUONG VALUES(N'Phường Tân Thới Hoà', 278)
INSERT XAPHUONG VALUES(N'Phường Tây Thạnh', 278)

INSERT XAPHUONG VALUES(N'Thị Trấn Tân Túc', 279)
INSERT XAPHUONG VALUES(N'Xã An Phú Tây', 279)
INSERT XAPHUONG VALUES(N'Xã Bình Chánh', 279)
INSERT XAPHUONG VALUES(N'Xã Bình Hưng', 279)
INSERT XAPHUONG VALUES(N'Xã Bình Lợi', 279)
INSERT XAPHUONG VALUES(N'Xã Đa Phước', 279)
INSERT XAPHUONG VALUES(N'Xã Hưng Long', 279)
INSERT XAPHUONG VALUES(N'Xã Lê Minh Xuân', 279)
INSERT XAPHUONG VALUES(N'Xã Phạm Văn Hai', 279)
INSERT XAPHUONG VALUES(N'Xã Phong Phú', 279)
INSERT XAPHUONG VALUES(N'Xã Quy Đức', 279)
INSERT XAPHUONG VALUES(N'Xã Tân Kiên', 279)
INSERT XAPHUONG VALUES(N'Xã Tân Nhựt', 279)
INSERT XAPHUONG VALUES(N'Xã Tân Quý Tây', 279)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Lộc A', 279)
INSERT XAPHUONG VALUES(N'Xã Vĩnh Lộc B', 279)

INSERT XAPHUONG VALUES(N'Thị Trấn Cần Thạnh', 280)
INSERT XAPHUONG VALUES(N'Xã An Thới Đông', 280)
INSERT XAPHUONG VALUES(N'Xã Bình Khánh', 280)
INSERT XAPHUONG VALUES(N'Xã Long Hoà', 280)
INSERT XAPHUONG VALUES(N'Xã Lý Nhơn', 280)
INSERT XAPHUONG VALUES(N'Xã Tam Thôn Hiệp', 280)
INSERT XAPHUONG VALUES(N'Xã Thạnh An', 280)

INSERT XAPHUONG VALUES(N'Thị Trấn Củ Chi', 281)
INSERT XAPHUONG VALUES(N'Xã An Nhơn Tây', 281)
INSERT XAPHUONG VALUES(N'Xã An Phú', 281)
INSERT XAPHUONG VALUES(N'Xã Bình Mỹ', 281)
INSERT XAPHUONG VALUES(N'Xã Hoà Phú', 281)
INSERT XAPHUONG VALUES(N'Xã Nhuận Đức', 281)
INSERT XAPHUONG VALUES(N'Xã Phạm Văn Cội', 281)
INSERT XAPHUONG VALUES(N'Xã Phú Hòa Đông', 281)
INSERT XAPHUONG VALUES(N'Xã Phú Mỹ Hưng', 281)
INSERT XAPHUONG VALUES(N'Xã Phước Hiệp', 281)
INSERT XAPHUONG VALUES(N'Xã Phước Thạnh', 281)
INSERT XAPHUONG VALUES(N'Xã Phước Vĩnh An', 281)
INSERT XAPHUONG VALUES(N'Xã Tân An Hội', 281)
INSERT XAPHUONG VALUES(N'Xã Tân Phú Trung', 281)
INSERT XAPHUONG VALUES(N'Xã Tân Thạnh Đông', 281)
INSERT XAPHUONG VALUES(N'Xã Tân Thạnh Tây', 281)
INSERT XAPHUONG VALUES(N'Xã Tân Thông Hội', 281)
INSERT XAPHUONG VALUES(N'Xã Thái Mỹ', 281)
INSERT XAPHUONG VALUES(N'Xã Trung An', 281)
INSERT XAPHUONG VALUES(N'Xã Trung Lập Hạ', 281)
INSERT XAPHUONG VALUES(N'Xã Trung Lập Thượng', 281)

INSERT XAPHUONG VALUES(N'Thị Trấn Hóc Môn', 282)
INSERT XAPHUONG VALUES(N'Xã Bà Điểm', 282)
INSERT XAPHUONG VALUES(N'Xã Đông Thạnh', 282)
INSERT XAPHUONG VALUES(N'Xã Nhị Bình', 282)
INSERT XAPHUONG VALUES(N'Xã Tân Hiệp', 282)
INSERT XAPHUONG VALUES(N'Xã Tân Thới Nhì', 282)
INSERT XAPHUONG VALUES(N'Xã Tân Xuân', 282)
INSERT XAPHUONG VALUES(N'Xã Thới Tam Thôn', 282)
INSERT XAPHUONG VALUES(N'Xã Trung Chánh', 282)
INSERT XAPHUONG VALUES(N'Xã Xuân Thới Đông', 282)
INSERT XAPHUONG VALUES(N'Xã Xuân Thới Sơn', 282)
INSERT XAPHUONG VALUES(N'Xã Xuân Thới Thượng', 282)

INSERT XAPHUONG VALUES(N'Thị Trấn Nhà Bè', 283)
INSERT XAPHUONG VALUES(N'Xã Hiệp Phước', 283)
INSERT XAPHUONG VALUES(N'Xã Long Thới', 283)
INSERT XAPHUONG VALUES(N'Xã Nhơn Đức', 283)
INSERT XAPHUONG VALUES(N'Xã Phú Xuân', 283)
INSERT XAPHUONG VALUES(N'Xã Phước Kiển', 283)
INSERT XAPHUONG VALUES(N'Xã Phước Lộc', 283)

--------------------------------------------------------------------------------






-- SELECT * FROM SANPHAM JOIN DONGIA ON SANPHAM.ID = DONGIA.ID_SP -- SHOW
select * from TAIKHOAN
select * from CHITIETHD
select * from SANPHAM
select * from DANHMUC
select * from CHITIETDANHMUC

exec sp_CKAcc 'tuhueson', 'tuhueson522001+-*/', N'Khách Hàng'
