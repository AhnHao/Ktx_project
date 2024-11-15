
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
-- Biểu đồ điện nước doanh thu
DELIMITER //

CREATE PROCEDURE GetDienNuocRevenueByMonth()
BEGIN
    SELECT 
        DATE_FORMAT(ThangNam, '%Y-%m') AS Thang,       -- Lấy tháng và năm dưới dạng 'YYYY-MM'
        SUM(SoTienDien) AS TongTienDien,               -- Tổng tiền điện trong tháng
        SUM(SoTienNuoc) AS TongTienNuoc,               -- Tổng tiền nước trong tháng
        SUM(SoTienDien + SoTienNuoc) AS TongDoanhThu,  -- Tổng doanh thu (điện + nước) trong tháng
        SUM(TienConLai) AS TongTienConLai              -- Tổng tiền còn lại chưa thanh toán
    FROM 
        DienNuoc
    WHERE 
        NgayDong IS NOT NULL                           -- Chỉ tính các bản ghi có NgayDong khác NULL
    GROUP BY 
        DATE_FORMAT(ThangNam, '%Y-%m')                 -- Nhóm theo tháng và năm đã định dạng
    ORDER BY 
        Thang;                                         -- Sắp xếp theo tháng
END //

DELIMITER ;


-- Hàm tạo ra mã điện nước tự động
DELIMITER //

CREATE FUNCTION GenerateMaDienNuoc()
RETURNS VARCHAR(10)
READS SQL DATA
BEGIN
    DECLARE newMaDienNuoc VARCHAR(10);
    DECLARE latestMaDienNuoc VARCHAR(10);
    
    -- Lấy mã hóa đơn điện nước mới nhất
    SELECT MaDienNuoc INTO latestMaDienNuoc 
    FROM DienNuoc 
    ORDER BY MaDienNuoc DESC 
    LIMIT 1;
    
    -- Nếu chưa có mã nào, bắt đầu với HD000001
    IF latestMaDienNuoc IS NULL THEN
        SET newMaDienNuoc = 'HD000001';
    ELSE
        -- Tăng mã lên 1 dựa trên phần số trong mã
        SET newMaDienNuoc = CONCAT('HD', LPAD(CAST(SUBSTRING(latestMaDienNuoc, 3) AS UNSIGNED) + 1, 6, '0'));
    END IF;
    
    -- Trả về mã hóa đơn mới
    RETURN newMaDienNuoc;
END //

DELIMITER ;
-- Thêm điện nước dựa vào mã điện nước được tạo tự động
DELIMITER //

CREATE PROCEDURE ThemDienNuoc(
    IN p_MaPhong VARCHAR(10),
    IN p_ThangNam DATE,
    IN p_SoTienDien FLOAT,
    IN p_SoTienNuoc FLOAT,
    IN p_TienConLai FLOAT,
    IN p_NgayDong DATE
)
BEGIN
    DECLARE newMaDienNuoc VARCHAR(10);
    
    -- Tạo mã điện nước mới sử dụng hàm GenerateMaDienNuoc
    SET newMaDienNuoc = GenerateMaDienNuoc();
    
    -- Thực hiện thêm dữ liệu vào bảng DienNuoc
    INSERT INTO DienNuoc (MaDienNuoc, MaPhong, ThangNam, SoTienDien, SoTienNuoc, TienConLai, NgayDong)
    VALUES (newMaDienNuoc, p_MaPhong, p_ThangNam, p_SoTienDien, p_SoTienNuoc, p_TienConLai, p_NgayDong);
END //

DELIMITER ;

-- Xoá điện nước
DELIMITER //

CREATE PROCEDURE XoaDienNuoc(
    IN p_MaDienNuoc VARCHAR(10)
)
BEGIN
    -- Xóa bản ghi trong bảng DienNuoc theo MaDienNuoc
    DELETE FROM DienNuoc WHERE MaDienNuoc = p_MaDienNuoc;
END //

DELIMITER ;

show triggers
-- Hàm tạo mã hợp đồng tự động
DELIMITER //
CREATE FUNCTION GenerateMaHopDong()
RETURNS VARCHAR(10)
READS SQL DATA
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

-- Tạo hợp đồng thuê phòng từ mã hợp đồng tự động generate ra bằng function
DELIMITER //
CREATE PROCEDURE TaoHopDongThuePhong(
    IN MaSinhVien VARCHAR(10),
    IN MaPhong VARCHAR(10),
    IN BatDau DATE,
    IN KetThuc DATE,
    IN Gia DECIMAL(10, 2)
)
BEGIN
    DECLARE newMaHopDong VARCHAR(10);

    -- Gọi hàm GenerateMaHopDong để tạo mã hợp đồng mới
    SET newMaHopDong = GenerateMaHopDong();

    -- Tạo hợp đồng mới với mã hợp đồng được tạo
    INSERT INTO ThuePhong (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia)
    VALUES (newMaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia);

    -- Trả về mã hợp đồng mới nếu cần
    SELECT newMaHopDong AS MaHopDongMoi;
END //

DELIMITER ;
-- Cập nhật hợp đồng thuê phòng
DELIMITER //

CREATE PROCEDURE UpdateRental(
    IN p_MaHopDong VARCHAR(50),
    IN p_MaSinhVien VARCHAR(50),
    IN p_MaPhong VARCHAR(50),
    IN p_BatDau DATE,
    IN p_KetThuc DATE,
    IN p_Gia DECIMAL(10, 2)
)
BEGIN
    UPDATE ThuePhong
    SET
        MaSinhVien = p_MaSinhVien,
        MaPhong = p_MaPhong,
        BatDau = p_BatDau,
        KetThuc = p_KetThuc,
        Gia = p_Gia
    WHERE
        MaHopDong = p_MaHopDong;
END //

DELIMITER ;
-- Xoá hợp đồng thuê phòng
DELIMITER //

CREATE PROCEDURE XoaHopDongThuePhong(
    IN p_MaHopDong VARCHAR(10)
)
BEGIN
    -- Xóa bản ghi trong bảng ThuePhong theo MaHopDong
    DELETE FROM ThuePhong WHERE MaHopDong = p_MaHopDong;
END //

DELIMITER ;

-- Trigger kiểm tra ngày bắt đầu thuê phòng phải nhỏ hơn ngày kết thúc thuê phòng
DELIMITER //

CREATE TRIGGER CheckDateBeforeInsertOrUpdate
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    -- Kiểm tra ngày bắt đầu phải nhỏ hơn ngày kết thúc
    IF NEW.BatDau >= NEW.KetThuc THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày bắt đầu phải nhỏ hơn ngày kết thúc.';
    END IF;
END //

DELIMITER ;

-- Kiểm tra số lượng người trong phòng trước khi thêm vào
DELIMITER //

CREATE TRIGGER CheckRoomOccupancyBeforeInsert
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE current_occupants INT;
    DECLARE room_capacity INT;

    -- Đếm số lượng sinh viên hiện đang thuê phòng trong khoảng thời gian thuê
    SELECT COUNT(tp.MaHopDong)
    INTO current_occupants
    FROM Phong p
    LEFT JOIN ThuePhong tp 
        ON p.MaPhong = tp.MaPhong
        AND (tp.KetThuc IS NULL OR tp.KetThuc >= CURDATE()) -- Kiểm tra hợp đồng còn hiệu lực
    WHERE p.MaPhong = NEW.MaPhong
    GROUP BY p.MaPhong;

    -- Lấy sức chứa của phòng từ bảng Phong
    SELECT SoGiuong
    INTO room_capacity
    FROM Phong
    WHERE MaPhong = NEW.MaPhong;

    -- Kiểm tra nếu số người thuê hiện tại đã đạt sức chứa tối đa của phòng
    IF current_occupants >= room_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phòng đã đạt sức chứa tối đa.';
    END IF;
END //

DELIMITER ;

-- kiểm tra sinh viên nữ chỉ được thuê loại phòng F ( dành cho nữ) 
DELIMITER //

CREATE TRIGGER CheckGenderCompatibilityBeforeInsert
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE gender_student CHAR(1);
    DECLARE gender_room CHAR(1);

    -- Lấy giới tính của sinh viên từ bảng SinhVien
    SELECT GioiTinh INTO gender_student
    FROM SinhVien
    WHERE MaSinhVien = NEW.MaSinhVien;

    -- Lấy giới tính của phòng từ bảng Phong
    SELECT PhongNam_Nu INTO gender_room
    FROM Phong
    WHERE MaPhong = NEW.MaPhong;

    -- Kiểm tra nếu giới tính sinh viên và giới tính phòng không phù hợp
    IF gender_student != gender_room THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sinh viên chỉ được thuê phòng phù hợp với giới tính của mình.';
    END IF;
END //

DELIMITER ;
-- Trigger kiểm tra hợp đồng còn hiệu lực 
DELIMITER //

CREATE TRIGGER CheckActiveContractBeforeInsert
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE active_contracts INT;

    -- Kiểm tra số lượng hợp đồng đang có hiệu lực của sinh viên
    SELECT COUNT(*)
    INTO active_contracts
    FROM ThuePhong
    WHERE MaSinhVien = NEW.MaSinhVien
      AND MaPhong = NEW.MaPhong
      AND (KetThuc IS NULL OR KetThuc >= NEW.BatDau);

    -- Nếu có hợp đồng đang có hiệu lực, chặn việc thêm hợp đồng mới
    IF active_contracts > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sinh viên đã có hợp đồng thuê phòng còn hiệu lực.';
    END IF;
END //

DELIMITER ;


show triggers;

-- Thanh toán quét mã QR nè dùng transaction
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

-- Truy vấn thanh toán dựa trên maHopDong
DELIMITER //

CREATE PROCEDURE get_payment_by_contract(IN contractID VARCHAR(10))
BEGIN
    SELECT 
        TT.MaHopDong,
        TT.ThangNam,
        TT.SoTien,
        TT.NgayThanhToan,
        TT.MaNhanVien
    FROM 
        TT_ThuePhong TT
    JOIN ThuePhong TP ON TT.MaHopDong = TP.MaHopDong
    JOIN SinhVien SV ON TP.MaSinhVien = SV.MaSinhVien
    JOIN NhanVien NV ON TT.MaNhanVien = NV.MaNhanVien
    WHERE 
        TT.MaHopDong = contractID;
END //

DELIMITER ; 

-- Cập nhật ngày thanh toán trong TT_ThuePhong
DELIMITER //

CREATE PROCEDURE CapNhatTT_ThuePhong (
    IN p_MaHopDong VARCHAR(10),
    IN p_ThangNam DATE,
    IN p_SoTien FLOAT,
    IN p_NgayThanhToan DATE,
    IN p_MaNhanVien VARCHAR(10)
)
BEGIN
    -- Bắt đầu giao dịch
    START TRANSACTION;
        -- Cập nhật thông tin thuê phòng
        UPDATE TT_ThuePhong
        SET SoTien = p_SoTien,
            ThangNam = p_ThangNam,
            NgayThanhToan = p_NgayThanhToan,
            MaNhanVien = p_MaNhanVien
        WHERE MaHopDong = p_MaHopDong;
    -- Commit giao dịch nếu không có lỗi
    COMMIT;
END //

DELIMITER ;

-- Thủ tục xóa bản ghi TT_ThuePhong
DELIMITER //

CREATE PROCEDURE delete_tt_thuephong(IN p_MaHopDong VARCHAR(10))
BEGIN
        DELETE FROM TT_ThuePhong WHERE MaHopDong = p_MaHopDong;
        DELETE FROM ThuePhong WHERE MaHopDong = p_MaHopDong;
END //

DELIMITER ;

-- Truy vấn thanh toán dựa trên MaSinhVien
DELIMITER //
CREATE PROCEDURE get_payment_by_student(IN studentID VARCHAR(10))
BEGIN
    SELECT 
        TT.MaHopDong,
        TT.ThangNam,
        TT.SoTien,
        TT.NgayThanhToan,
        TT.MaNhanVien
    FROM 
        TT_ThuePhong TT
    JOIN ThuePhong TP ON TT.MaHopDong = TP.MaHopDong
    JOIN SinhVien SV ON TP.MaSinhVien = SV.MaSinhVien
    JOIN NhanVien NV ON TT.MaNhanVien = NV.MaNhanVien
    WHERE 
        SV.MaSinhVien = studentID;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tao_tt_thuephong_khi_thuephong_moi
AFTER INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE SoTien FLOAT;
    DECLARE ThangNam DATE;

    -- Set default values
    SET ThangNam = NEW.BatDau; -- Default to the start date of the contract
    SET SoTien = NEW.Gia;      -- Set the payment amount to the rental price of the room

    -- Insert a record into TT_ThuePhong for the new contract
    INSERT INTO TT_ThuePhong (MaHopDong, ThangNam, SoTien, NgayThanhToan, MaNhanVien)
    VALUES (NEW.MaHopDong, ThangNam, SoTien, NULL, 'CB000001');
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
('M000002', 'B2111790', 'AA01101', '2023-09-01', '2024-03-01', 3900000),
('M000003', 'B2111795', 'AA01103', '2023-09-01', '2024-03-01', 2180000),
('M000004', 'B2111821', 'AA01104', '2023-09-01', '2024-03-01', 1900000),
('M000005', 'B2105612', 'CA01001', '2023-09-01', '2024-03-01', 2450000),
('M000006', 'B2111342', 'AA01102', '2023-09-01', '2024-03-01', 4700000);


-- Insert Data for TT_ThuePhong (Payment Details)

INSERT INTO TT_ThuePhong (MaHopDong, ThangNam, SoTien, NgayThanhToan, MaNhanVien)
VALUES
('M000002', '2023-11-01', 1900000, '2023-11-11', 'CB000001'),
('M000003', '2023-11-01', 3900000, '2023-11-12', 'CB000001'),
('M000004', '2023-11-01', 2180000, '2023-11-13', 'CB000001'),
('M000005', '2023-11-01', 1900000, '2023-11-14', 'CB000001'),
('M000006', '2023-11-01', 2450000, '2023-11-15', 'CB000001');

-- Insert Data into DienNuoc with Room Names Matching ThuePhong Table

INSERT INTO DienNuoc (MaDienNuoc, MaPhong, ThangNam, SoTienDien, SoTienNuoc, TienConLai, NgayDong)
VALUES
('HD000001', 'AA01101', '2023-11-01', 120000, 80000, 200000, NULL),
('HD000002', 'AA01102', '2023-11-01', 150000, 100000, 250000, NULL),
('HD000003', 'AA01103', '2023-11-01', 90000, 70000, 160000, NULL),
('HD000004', 'AA01104', '2023-11-01', 110000, 90000, 200000, NULL),
('HD000005', 'CA01001', '2023-11-01', 125000, 75000, 200000, NULL),
('HD000006', 'CA01002', '2023-11-01', 100000, 95000, 195000, NULL);




