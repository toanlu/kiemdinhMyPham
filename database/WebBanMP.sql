USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name='WEBBANMP')
BEGIN
        DROP DATABASE WEBBANMP
END
CREATE DATABASE WEBBANMP
GO
USE WEBBANMP
GO

-- tạo bảng
-- GR ADMIN(00): CONTROL ALL
-- GR NHÂN VIÊN(01): HỖ TRỢ KHÁCH HÀNG XỬ LÝ ĐƠN HÀNG
-- GR KHÁCH HÀNG(02): NGƯỜI DÙNG
CREATE TABLE GRTK (
    ID INT IDENTITY NOT NULL,
    TEN NVARCHAR(50), -- TÊN GR
    CODEGR CHAR(2),
    CONSTRAINT PK_GR PRIMARY KEY (ID) 
)
CREATE TABLE TAIKHOAN (
    ID VARCHAR(15) NOT NULL, -- CREATE AUTO
    USERNAME VARCHAR(50), -- CHECK USERNAME THEO GROUP
    PW VARBINARY(50), -- MÃ HÓA + salt
    ID_GR INT REFERENCES GRTK(ID),
    CONSTRAINT PK_TK PRIMARY KEY (ID)
)
CREATE TABLE THONGTINTAIKHOAN (
    ID VARCHAR(20) NOT NULL, -- CREATE AUTO
    HOTEN NVARCHAR(50), -- HỌ TÊN
    NGSINH DATE, -- NGÀY SINH
    GTINH BIT, -- 1: NAM, 0: NỮ, NULL: CHƯA BIẾT(QUY VỀ 0)
    NGTAO DATE, -- NGÀY TẠO
    EMAIL VARCHAR(50), -- ĐỊA CHỈ EMAIL
    SDT VARCHAR(11), -- SDT
    DCHI NVARCHAR(50), -- ĐỊA CHỈ NHÀ / ĐỊA CHỈ GIAO
    ID_TAIKHOAN VARCHAR(15) REFERENCES TAIKHOAN(ID),
    CONSTRAINT PK_TTTK PRIMARY KEY (ID)
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
CREATE TABLE LOAISP ( -- _________________________________
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
CREATE TABLE SANPHAM ( -- _________________________________
    ID VARCHAR(5) NOT NULL, -- CREATE AUTO
    TENSP NVARCHAR(MAX), -- TÊN SẢN PHẨM
    MOTA NVARCHAR(MAX), -- MÔ TẢ
    SOLUONG INT, -- SỐ LƯỢNG TỒN KHO
    -- DONGIA FLOAT, -- ĐƠN GIÁ
    NSX NVARCHAR(30), -- NHÀ SẢN XUẤT
    HINHANH VARCHAR(50),
    ID_LOAI VARCHAR(6) REFERENCES LOAISP(ID),
    CONSTRAINT PK_SP PRIMARY KEY (ID)
)
CREATE TABLE SALE (
    ID INT IDENTITY NOT NULL,
    GIATRI FLOAT, -- GIÁ TRỊ SALE
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT SALE LẤY NGÀY GẦN NHẤT
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
    ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID),
    CONSTRAINT PK_HD PRIMARY KEY (ID)
)
CREATE TABLE CHITIETHD (
    ID INT IDENTITY NOT NULL,
    ID_HD VARCHAR(10) REFERENCES HOADON(ID),
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
    CONSTRAINT PK_CTHD PRIMARY KEY (ID, ID_HD) 
)
CREATE TABLE PHIEUNHAP (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    NGTAO DATE, -- NGÀY TẠO PHIẾU NHẬP
    DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ)
    ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID),
    CONSTRAINT PK_PN PRIMARY KEY (ID)
)
CREATE TABLE CHITIETPN (
    ID INT IDENTITY NOT NULL,
    ID_PN VARCHAR(10) REFERENCES PHIEUNHAP(ID),
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
    CONSTRAINT PK_CTPN PRIMARY KEY (ID, ID_PN) 
)
CREATE TABLE THONGKETRUYCAP (
    ID INT IDENTITY NOT NULL,
    ISONL BIT, -- KIỂM TRA CÒN ONL - DEFAULT: 1(ON)
    NGGHI DATETIME, -- NGÀY GHI NHẬN
    NGOFF DATETIME, -- KHI NGƯỜI DÙNG KẾT THÚC PHIÊN
    CONSTRAINT PK_TKTC PRIMARY KEY (ID)   
)
GO

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

ALTER TABLE SALE
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


-- SELECT * FROM SANPHAM JOIN DONGIA ON SANPHAM.ID = DONGIA.ID_SP -- SHOW
select * from TAIKHOAN
select * from CHITIETHD
select * from SANPHAM
select * from DANHMUC
select * from CHITIETDANHMUC

exec sp_CKAcc 'tuhueson', 'tuhueson522001+-*/', N'Khách Hàng'