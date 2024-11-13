
drop database ktx;
create database ktx;
use  ktx;

-- Bảng Phòng
CREATE TABLE Phong (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong VARCHAR(255) NOT NULL,
    DienTich FLOAT NOT NULL,
    SoGiuong INT NOT NULL,
    GiaThue FLOAT NOT NULL,
    PhongNam_Nu CHAR(1) NOT NULL -- 'M' cho Nam, 'F' cho Nữ
);


-- Bảng Lớp
CREATE TABLE Lop (
    MaLop VARCHAR(10) PRIMARY KEY,
    TenLop VARCHAR(255) NOT NULL
);

-- Bảng Sinh viên
CREATE TABLE SinhVien (
    MaSinhVien VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(255) NOT NULL,
    SoDienThoai VARCHAR(20),
    MaLop VARCHAR(10), 
    GioiTinh CHAR(1) NOT NULL, -- 'M' cho Nam, 'F' cho Nữ\
    FOREIGN KEY (MaLop) REFERENCES Lop(MaLop)
);


-- Bảng Nhân viên
CREATE TABLE NhanVien (
    MaNhanVien VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(255) NOT NULL,-- Mật khẩu
    SoDienThoai VARCHAR(12),
    GhiChu VARCHAR(255)
);


-- Bảng Thuê phòng
CREATE TABLE ThuePhong (
    MaHopDong VARCHAR(10) PRIMARY KEY,
    MaSinhVien VARCHAR(10),
    MaPhong VARCHAR(10),
    BatDau DATE NOT NULL,
    KetThuc DATE,
    Gia FLOAT,
    FOREIGN KEY (MaSinhVien) REFERENCES SinhVien(MaSinhVien),
    FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong)
);

-- Bảng TT_Thuê phòng
CREATE TABLE TT_ThuePhong (
    MaHopDong VARCHAR(10),
    ThangNam DATE,
    SoTien FLOAT NOT NULL,
    NgayThanhToan DATE,
    MaNhanVien VARCHAR(10), -- Thay đổi kiểu dữ liệu của MaNhanVien
    PRIMARY KEY (MaHopDong, MaNhanVien),
    FOREIGN KEY (MaHopDong) REFERENCES ThuePhong(MaHopDong) ON DELETE CASCADE,
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);

CREATE TABLE Admin (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- Khóa chính với id tự động tăng
    email VARCHAR(255) NOT NULL UNIQUE, -- Email không được trùng lặp
    password VARCHAR(255) NOT NULL,     -- Mật khẩu sẽ lưu mã hóa (hashed password)
    hoTen VARCHAR(255) NOT NULL,        -- Họ và tên
    diaChi TEXT,                        -- Địa chỉ
    soDienThoai VARCHAR(20)
);

-- Bảng Điện Nước
CREATE TABLE DienNuoc (
    MaDienNuoc VARCHAR(10) PRIMARY KEY,             -- Mã hóa đơn điện nước dạng HD000001
    MaPhong VARCHAR(10),                            -- Mã phòng
    ThangNam DATE,                                  -- Tháng và năm của hóa đơn
    SoTienDien FLOAT NOT NULL,                      -- Số tiền điện
    SoTienNuoc FLOAT NOT NULL,                      -- Số tiền nước
    TienConLai FLOAT NOT NULL,                      -- Số tiền còn lại chưa thanh toán
    NgayDong DATE,                                  -- Ngày đóng hóa đơn
    FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong) -- Khóa ngoại liên kết tới bảng Phòng
);
-- Function to generate next MaDienNuoc
DELIMITER //
CREATE FUNCTION GenerateMaDienNuoc()
RETURNS VARCHAR(10)
BEGIN
    DECLARE newMaDienNuoc VARCHAR(10);
    DECLARE latestMaDienNuoc VARCHAR(10);
    
    -- Get the latest ID
    SELECT MaDienNuoc INTO latestMaDienNuoc FROM DienNuoc ORDER BY MaDienNuoc DESC LIMIT 1;
    
    -- If there's no record yet, start with HD000001
    IF latestMaDienNuoc IS NULL THEN
        SET newMaDienNuoc = 'HD000001';
    ELSE
        -- Increment by 1 based on current numeric portion
        SET newMaDienNuoc = CONCAT('HD', LPAD(CAST(SUBSTRING(latestMaDienNuoc, 3) AS UNSIGNED) + 1, 6, '0'));
    END IF;
    
    RETURN newMaDienNuoc;
END;
//
DELIMITER ;

-- Function to generate next MaHopDong
DELIMITER //
CREATE FUNCTION GenerateMaHopDong()
RETURNS VARCHAR(10)
BEGIN
    DECLARE newMaHopDong VARCHAR(10);
    DECLARE latestMaHopDong VARCHAR(10);
    
    SELECT MaHopDong INTO latestMaHopDong FROM ThuePhong ORDER BY MaHopDong DESC LIMIT 1;
    
    IF latestMaHopDong IS NULL THEN
        SET newMaHopDong = 'M000001';
    ELSE
        SET newMaHopDong = CONCAT('M', LPAD(CAST(SUBSTRING(latestMaHopDong, 2) AS UNSIGNED) + 1, 6, '0'));
    END IF;
    
    RETURN newMaHopDong;
END;
//
DELIMITER ;

-- Function kiểm tra số người trong phòng
DELIMITER //

CREATE FUNCTION SoNguoiTrongPhong(MaPhongInput VARCHAR(10))
RETURNS INT
BEGIN
    DECLARE SoNguoi INT;
    
    SELECT COUNT(DISTINCT ThuePhong.MaSinhVien) INTO SoNguoi
    FROM ThuePhong
    JOIN TT_ThuePhong ON ThuePhong.MaHopDong = TT_ThuePhong.MaHopDong
    WHERE ThuePhong.MaPhong = MaPhongInput AND TT_ThuePhong.NgayThanhToan IS NOT NULL;
    
    RETURN SoNguoi;
END;

DELIMITER ;

-- Procedure tạo hợp đồng thuê phòng
DELIMITER //

CREATE PROCEDURE TaoHopDongThuePhong(
    IN MaSinhVienInput VARCHAR(10),
    IN MaPhongInput VARCHAR(10),
    IN BatDauInput DATE,
    IN KetThucInput DATE,
    IN GiaInput FLOAT
)
BEGIN
    DECLARE SoNguoi INT;
    DECLARE SoGiuong INT;
    DECLARE GioiTinhSinhVien CHAR(1);
    DECLARE PhongNam_Nu CHAR(1);
    DECLARE MaHopDongGenerated VARCHAR(10);

    -- Generate contract code
    SET MaHopDongGenerated = GenerateMaHopDong();

    -- Lấy số người hiện tại trong phòng
    SET SoNguoi = SoNguoiTrongPhong(MaPhongInput);

    -- Lấy số giường của phòng
    SELECT SoGiuong, PhongNam_Nu INTO SoGiuong, PhongNam_Nu FROM Phong WHERE MaPhong = MaPhongInput;

    -- Lấy giới tính của sinh viên
    SELECT GioiTinh INTO GioiTinhSinhVien FROM SinhVien WHERE MaSinhVien = MaSinhVienInput;

    -- Kiểm tra phòng đã đủ chỗ chưa và sinh viên có đúng giới tính không
    IF SoNguoi < SoGiuong THEN
        IF (PhongNam_Nu = 'M' AND GioiTinhSinhVien = 'M') OR (PhongNam_Nu = 'F' AND GioiTinhSinhVien = 'F') THEN
            -- Tạo hợp đồng thuê phòng
            INSERT INTO ThuePhong (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia)
            VALUES (MaHopDongGenerated, MaSinhVienInput, MaPhongInput, BatDauInput, KetThucInput, GiaInput);

            -- Tạo bản ghi TT_ThuePhong với ngày thanh toán là NULL
            INSERT INTO TT_ThuePhong (MaHopDong, ThangNam, SoTien, NgayThanhToan, MaNhanVien)
            VALUES (MaHopDongGenerated, BatDauInput, GiaInput, NULL, NULL);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giới tính sinh viên không phù hợp với loại phòng.';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phòng đã đầy, không thể thêm người vào phòng này nữa.';
    END IF;
END //

DELIMITER ;

-- Trigger tạo hóa đơn điện nước khi phòng mới được sử dụng
DELIMITER //

CREATE TRIGGER tao_hoadon_diennuoc_khi_phong_moi_duoc_su_dung
AFTER INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE MaDienNuocMoi VARCHAR(10);

    -- Kiểm tra xem phòng này đã từng có sinh viên thuê chưa
    IF (SELECT COUNT(*) FROM ThuePhong WHERE MaPhong = NEW.MaPhong) = 1 THEN
        -- Nếu đây là sinh viên đầu tiên thuê phòng, sử dụng hàm GenerateMaDienNuoc để tạo mã điện nước mới
        SET MaDienNuocMoi = GenerateMaDienNuoc();

        -- Thêm bản ghi vào bảng DienNuoc với MaPhong từ hợp đồng thuê phòng mới
        INSERT INTO DienNuoc (MaDienNuoc, MaPhong, ChiSoDien, ChiSoNuoc, ThangNam, SoTienDien, SoTienNuoc)
        VALUES (MaDienNuocMoi, NEW.MaPhong, 0, 0, DATE_FORMAT(NOW(), '%Y-%m'), 0, 0);
    END IF;
END //

DELIMITER ;

-- Trigger xoá hóa đơn điện nước khi phòng không còn sử dụng
DELIMITER //

CREATE TRIGGER xoa_hoadon_diennuoc_khi_phong_khong_con_su_dung
AFTER DELETE ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE soHopDong INT;

    -- Kiểm tra xem phòng còn hợp đồng thuê nào không
    SET soHopDong = (SELECT COUNT(*) FROM ThuePhong WHERE MaPhong = OLD.MaPhong);

    -- Nếu không còn hợp đồng thuê nào, xoá tất cả các hoá đơn điện nước của phòng
    IF soHopDong = 0 THEN
        DELETE FROM DienNuoc WHERE MaPhong = OLD.MaPhong;
    END IF;
END //

DELIMITER ;

-- Procedure tạo hóa đơn điện nước mới
DELIMITER //

CREATE PROCEDURE TaoHoaDonDienNuocMoi(
    IN MaPhongInput VARCHAR(10),
    IN ThangNamInput DATE,
    IN SoTienDienInput FLOAT,
    IN SoTienNuocInput FLOAT
)
BEGIN
    DECLARE MaDienNuocMoi VARCHAR(10);
    DECLARE TienConLai FLOAT;
    
    -- Generate a new bill code for electricity and water based on the GenerateMaDienNuoc function
    SET MaDienNuocMoi = GenerateMaDienNuoc();

    -- Calculate TienConLai as the sum of SoTienDienInput and SoTienNuocInput
    SET TienConLai = SoTienDienInput + SoTienNuocInput;
    
    -- Insert the new bill record for the specified room and month
    INSERT INTO DienNuoc (MaDienNuoc, MaPhong, ThangNam, SoTienDien, SoTienNuoc, TienConLai, NgayDong)
    VALUES (MaDienNuocMoi, MaPhongInput, ThangNamInput, SoTienDienInput, SoTienNuocInput, TienConLai, NULL);
    
    -- Optional: Display a success message
    SELECT CONCAT('New bill created with MaDienNuoc: ', MaDienNuocMoi) AS Message;
END //

DELIMITER ;

-- Procedure chỉnh sữa hóa đơn điện nước
DELIMITER //

CREATE PROCEDURE ChinhSuaThanhToanDienNuoc(
    IN MaDienNuocInput VARCHAR(10),
    IN SoTienDienInput FLOAT,
    IN SoTienNuocInput FLOAT,
    IN TienConLaiInput FLOAT,
    IN NgayDongInput DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred during the transaction.';
    END;

    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM DienNuoc WHERE MaDienNuoc = MaDienNuocInput) THEN
        UPDATE DienNuoc
        SET SoTienDien = SoTienDienInput,
            SoTienNuoc = SoTienNuocInput,
            TienConLai = TienConLaiInput,
            NgayDong = NgayDongInput
        WHERE MaDienNuoc = MaDienNuocInput;
        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MaDienNuoc does not exist.';
    END IF;
END //

DELIMITER ;

--Thanh toán hóa đơn điện nước
DELIMITER //

CREATE PROCEDURE ThanhToanHoaDonDienNuoc(
    IN MaDienNuocInput VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred during the transaction.';
    END;

    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM DienNuoc WHERE MaDienNuoc = MaDienNuocInput) THEN
        UPDATE DienNuoc
        SET TienConLai = 0,
            NgayDong = NOW()
        WHERE MaDienNuoc = MaDienNuocInput;
        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MaDienNuoc does not exist.';
    END IF;
END //

DELIMITER ;







INSERT INTO Phong (MaPhong, TenPhong, DienTich, SoGiuong, GiaThue, PhongNam_Nu)
VALUES
('AA01101', 'Phòng 101', 30.00, 8, 190000, 'M'),
('AA01102', 'Phòng 102', 30.00, 4, 390000, 'F'),
('AA01103', 'Phòng 103', 30.00, 7, 218000, 'M'),
('AA01104', 'Phòng 104', 30.00, 8, 190000, 'F'),
('AA01105', 'Phòng 105', 30.00, 8, 190000, 'F'),
('AA05001', 'Phòng 001', 30.00, 8, 245000, 'M'),
('AA05002', 'Phòng 002', 30.00, 4, 470000, 'F'),
('AA05003', 'Phòng 003', 30.00, 7, 380000, 'M'),
('AA05004', 'Phòng 004', 30.00, 7, 380000, 'F'),
('AA05005', 'Phòng 005', 30.00, 7, 245000, 'M'),
('BA02101', 'Phòng 101', 30.00, 4, 218000, 'M'),
('BA02102', 'Phòng 102', 30.00, 4, 218000, 'M'),
('BA02103', 'Phòng 103', 30.00, 4, 218000, 'F'),
('BA02104', 'Phòng 104', 30.00, 4, 218000, 'F'),
('BA02105', 'Phòng 105', 30.00, 4, 218000, 'M'),
('BA01101', 'Phòng 101', 30.00, 10, 120000, 'M'),
('BA01102', 'Phòng 102', 30.00, 10, 120000, 'F'),
('BA01103', 'Phòng 103', 30.00, 10, 120000, 'M'),
('BA01002', 'Phòng 002', 30.00, 6, 250000, 'M'),
('BA01003', 'Phòng 003', 30.00, 6, 250000, 'F'),
('BA01004', 'Phòng 004', 30.00, 6, 250000, 'F'),
('BA01005', 'Phòng 005', 30.00, 6, 250000, 'M'),
('BA01001', 'Phòng 001', 30.00, 5, 300000, 'M'),
('CA01001', 'Phòng 001', 30.00, 4, 350000, 'M'),
('CA01002', 'Phòng 002', 30.00, 4, 350000, 'M'),
('CA01003', 'Phòng 003', 30.00, 4, 350000, 'F'),
('CA01004', 'Phòng 004', 30.00, 4, 350000, 'F'),
('CA01005', 'Phòng 005', 30.00, 4, 350000, 'M');

-- Thêm dữ liệu vào bảng Lop

INSERT INTO Lop (MaLop, TenLop)
VALUES
('HG21V7A1', 'Công Nghệ Thông Tin'),
('DI21V7A1', 'Công Nghệ Thông Tin'),
('DI2195A1', 'Hệ Thống Thông Tin'),
('DI2196A1', 'Kỹ Thuật Phần Mền'),
('DI21T9A1', 'Mạng Máy Tính Và Truyền Thông Dữ Liệu'),
('DI21Y1A1', 'Tin Học Ứng Dụng'),
('DI21Z6A1', 'Khoa Học Máy Tính');

-- Thêm dữ liệu vào bảng SinhVien
INSERT INTO SinhVien (MaSinhVien, HoTen, SoDienThoai, MaLop, GioiTinh)
VALUES
('B2111890', 'Dương Quốc Lợi', '0912345678', 'HG21V7A1', 'M'),
('B2105553', 'Nguyễn Bình Nguyên', '0987654321', 'DI21V7A1', 'M'),
('B2111790', 'Võ Phương Duy', '0987654321', 'DI2195A1', 'M'),
('B2111795', 'Trần Anh Hào', '0987345345', 'DI2196A1', 'M'),
('B2111821', 'Phạm Ngọc Thi', '0987567456', 'DI21T9A1', 'F'),
('B2105612', 'Nguyễn Trinh Huy', '0987654999', 'DI21Y1A1', 'M'),
('B2111342', 'Liẽu Như Yên', '0987999999', 'DI21Z6A1', 'F'),
('B2111891', 'Lê Văn Anh', '0912345679', 'HG21V7A1', 'M'),
('B2105554', 'Trần Thị Bình', '0987654322', 'DI21V7A1', 'F'),
('B2111791', 'Nguyễn Văn Chung', '0987654323', 'DI2195A1', 'M'),
('B2111796', 'Phạm Thị Dung', '0987345346', 'DI2196A1', 'F'),
('B2111822', 'Hoàng Văn Tiến', '0987567457', 'DI21T9A1', 'M'),
('B2105613', 'Vũ Thị Phúc', '0987654990', 'DI21Y1A1', 'F'),
('B2111343', 'Đặng Văn Giang', '0987999990', 'DI21Z6A1', 'M');

INSERT INTO NhanVien (MaNhanVien, HoTen, SoDienThoai, GhiChu)
VALUES
-- Ban Quản Lý Ký Túc Xá
('CB000001', 'Phạm Văn D', '0909123456', 'Quản lý toàn bộ ký túc xá'),
('CB000002', 'Nguyễn Thị E', '0909988776', 'Quản lý khu A'),
('CB000003', 'Trần Văn F', '0912345678', 'Quản lý khu B'),

-- Nhân Viên Hành Chính
('CB000004', 'Hoàng Thị G', '0912345679', 'Xử lý tài chính và thanh toán'),

-- Nhân Viên Kỹ Thuật
('CB000006', 'Trần Văn I', '0914567891', 'Bảo trì hệ thống điện nước'),
('CB000007', 'Võ Thị J', '0915678902', 'Theo dõi và cung cấp vật tư'),

-- Giáo Viên Quản Lý Khu Vực
('CB000008', 'Đặng Văn K', '0916789013', 'Giám sát sinh viên'),
('CB000009', 'Trương Thị L', '0917890124', 'Giám sát sinh viên'),

-- Nhân Viên An Ninh
('CB000010', 'Đỗ Văn M', '0918901235', 'Bảo vệ toàn bộ ký túc xá'),
('CB000011', 'Lý Thị N', '0919012346', 'Giám sát ca bảo vệ'),

-- Nhân Viên Dịch Vụ
('CB000012', 'Phạm Thị O', '0920123457', 'Quản lý dịch vụ căng tin'),
('CB000013', 'Ngô Văn P', '0921234568', 'Đảm bảo vệ sinh khu vực công cộng'),

-- Cố Vấn Sinh Viên
('CB000014', 'Phan Thị Q', '0922345679', 'Tư vấn và hỗ trợ sinh viên');


-- Insert Data for ThuePhong with 6-Month Contracts and No Deposit Field

INSERT INTO ThuePhong (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia)
VALUES
('M000001', 'B2111890', 'AA01101', '2023-09-01', '2024-03-01', 1900000),
('M000002', 'B2105553', 'AA01101', '2023-09-01', '2024-03-01', 1900000),
('M000003', 'B2111790', 'AA01102', '2023-09-01', '2024-03-01', 3900000),
('M000004', 'B2111795', 'AA01103', '2023-09-01', '2024-03-01', 2180000),
('M000005', 'B2111821', 'AA01104', '2023-09-01', '2024-03-01', 1900000),
('M000006', 'B2105612', 'CA01001', '2023-09-01', '2024-03-01', 2450000),
('M000007', 'B2111342', 'CA01002', '2023-09-01', '2024-03-01', 4700000);

-- Insert Data for TT_ThuePhong (Payment Details)

INSERT INTO TT_ThuePhong (MaHopDong, ThangNam, SoTien, NgayThanhToan, MaNhanVien)
VALUES
('M000001', '2023-11-01', 1900000, '2023-11-10', 'CB000001'),
('M000002', '2023-11-01', 1900000, '2023-11-11', 'CB000001'),
('M000003', '2023-11-01', 3900000, '2023-11-12', 'CB000001'),
('M000004', '2023-11-01', 2180000, '2023-11-13', 'CB000001'),
('M000005', '2023-11-01', 1900000, '2023-11-14', 'CB000001'),
('M000006', '2023-11-01', 2450000, '2023-11-15', 'CB000001'),
('M000007', '2023-11-01', 4700000, '2023-11-16', 'CB000001');


-- Insert Data into DienNuoc with Room Names Matching ThuePhong Table

INSERT INTO DienNuoc (MaDienNuoc, MaPhong, ThangNam, SoTienDien, SoTienNuoc, TienConLai, NgayDong)
VALUES
('HD000001', 'AA01101', '2023-11-01', 120000, 80000, 200000, NULL),
('HD000002', 'AA01102', '2023-11-01', 150000, 100000, 250000, NULL),
('HD000003', 'AA01103', '2023-11-01', 90000, 70000, 160000, NULL),
('HD000004', 'AA01104', '2023-11-01', 110000, 90000, 200000, NULL),
('HD000006', 'CA01001', '2023-11-01', 125000, 75000, 200000, NULL),
('HD000007', 'CA01002', '2023-11-01', 100000, 95000, 195000, NULL);


