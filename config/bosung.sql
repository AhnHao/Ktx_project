
-- Add a trigger to generate 'MaHopDong' based on 'ID'
DELIMITER //

CREATE TRIGGER trg_generate_mahopdong
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    IF NEW.MaHopDong IS NULL THEN
        SET NEW.MaHopDong = CONCAT('M', LPAD(NEW.ID + 1, 6, '0'));
    END IF;
END //

DELIMITER ;

-- Bảng TT_Thuê phòng
CREATE TABLE TT_ThuePhong (
    MaHopDong VARCHAR(10),
    ThangNam DATE,
    SoTien FLOAT NOT NULL,
    NgayThanhToan DATE,
    MaNhanVien VARCHAR(10), -- Thay đổi kiểu dữ liệu của MaNhanVien
    PRIMARY KEY (MaHopDong, MaNhanVien),
    FOREIGN KEY (MaHopDong) REFERENCES ThuePhong(MaHopDong),
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

-- Kiểm tra tình trạng thanh toán của sinh viên
DELIMITER //
CREATE FUNCTION check_student_payment_status(MSV VARCHAR(10))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE payment_status BOOLEAN;

    -- Check if any contract associated with the student has been fully paid
    SELECT 
        CASE 
            WHEN COUNT(TT.NgayThanhToan) > 0 THEN TRUE
            ELSE FALSE
        END INTO payment_status
    FROM 
        TT_ThuePhong TT
    JOIN ThuePhong TP ON TT.MaHopDong = TP.MaHopDong
    WHERE 
        TP.MaSinhVien = MSV
        AND TT.NgayThanhToan IS NOT NULL;  -- Condition for fully paid

    RETURN payment_status;
END //

DELIMITER ;


-- Kiểm tra thanh toán của sinh viên trước khi đăng ký phòng (Trigger)
DELIMITER //

CREATE TRIGGER trg_check_payment_before_insert
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    IF check_student_payment_status(NEW.MaSinhVien) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Sinh viên đã thanh toán một phòng, không thể đăng ký thêm phòng khác';
    END IF;
END //

DELIMITER ;

-- Xóa đăng ký phòng khác của sinh viên sau khi thanh toán
DELIMITER //

CREATE TRIGGER trg_remove_other_rooms_after_payment
AFTER UPDATE ON TT_ThuePhong
FOR EACH ROW
BEGIN
    DECLARE tmp_MaHopDong VARCHAR(10);
    SET tmp_MaHopDong = NEW.MaHopDong;
    -- Kiểm tra tình trạng thanh toán của sinh viên
    IF check_student_payment_status(tmp_MaHopDong) THEN
        -- Xóa các phòng khác mà sinh viên đã gửi yêu cầu nhưng chưa thanh toán
        DELETE FROM ThuePhong 
        WHERE MaSinhVien = (SELECT MaSinhVien FROM ThuePhong WHERE MaHopDong = tmp_MaHopDong)
        AND MaHopDong <> tmp_MaHopDong
        AND MaHopDong IN (SELECT MaHopDong FROM TT_ThuePhong WHERE NgayThanhToan IS NULL);
    END IF;
END //

DELIMITER ;


-- Đếm số sinh viên trong phòng

DELIMITER //
CREATE FUNCTION count_students_in_room(roomID VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT COUNT(*) INTO count
    FROM ThuePhong TP
    JOIN TT_ThuePhong TT ON TP.MaHopDong = TT.MaHopDong
    WHERE TP.MaPhong = roomID AND TT.NgayThanhToan IS NOT NULL;
    RETURN count;
END //
DELIMITER ;

-- Kiểm tra số lượng sinh viên trong phòng trước khi đăng ký

DELIMITER //
CREATE TRIGGER trg_check_room_capacity_before_insert
BEFORE INSERT ON ThuePhong
FOR EACH ROW
BEGIN
    DECLARE roomCapacity INT;
    DECLARE currentOccupancy INT;

    SELECT SoGiuong INTO roomCapacity FROM Phong WHERE MaPhong = NEW.MaPhong;
    SET currentOccupancy = count_students_in_room(NEW.MaPhong);

    IF currentOccupancy >= roomCapacity THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Phòng đã đầy, không thể đăng ký thêm.';
    END IF;
END //

DELIMITER ;

-- Tự động tăng MaHopDong cho TT_ThuePhong

DELIMITER //

CREATE PROCEDURE generate_new_mahopdong(OUT newMaHopDong VARCHAR(10))
BEGIN
    DECLARE maxMaHopDong VARCHAR(10);
    DECLARE newId INT;

    -- Lấy mã hợp đồng lớn nhất hiện tại
    SELECT MAX(MaHopDong) INTO maxMaHopDong FROM ThuePhong;

    -- Nếu chưa có mã hợp đồng nào, bắt đầu từ 'M000001'
    IF maxMaHopDong IS NULL THEN
        SET newMaHopDong = 'M000001';
    ELSE
        -- Lấy phần số từ mã hợp đồng lớn nhất, chuyển thành số nguyên, sau đó tăng lên 1
        SET newId = CAST(SUBSTRING(maxMaHopDong, 2) AS UNSIGNED) + 1;
        -- Format mã hợp đồng mới với tiền tố 'M' và điền đủ 6 chữ số
        SET newMaHopDong = CONCAT('M', LPAD(newId, 6, '0'));
    END IF;
END //

DELIMITER ;


-- Thêm bản ghi mới vào TT_ThuePhong
DELIMITER //

CREATE PROCEDURE add_tt_thuephong(
    IN thangNam DATE,
    IN soTien FLOAT,
    IN ngayThanhToan DATE,
    IN maNhanVien VARCHAR(10)
)
BEGIN
    DECLARE newMaHopDong VARCHAR(10);
    -- Gọi hàm generate_new_mahopdong để tạo mã hợp đồng mới
    CALL generate_new_mahopdong(newMaHopDong);
    START TRANSACTION;
    INSERT INTO TT_ThuePhong (MaHopDong, ThangNam, SoTien, NgayThanhToan, MaNhanVien)
    VALUES (newMaHopDong, thangNam, soTien, ngayThanhToan, maNhanVien);
    COMMIT;   
END //

DELIMITER ;


-- Trigger: Cập nhật ngày thanh toán trong TT_ThuePhong
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

-- Trigger: Kiểm tra hợp đồng trùng lặp khi thêm mới
DELIMITER //

CREATE TRIGGER trg_check_duplicate_before_insert
BEFORE INSERT ON TT_ThuePhong
FOR EACH ROW
BEGIN
    -- Nếu mã hợp đồng đã tồn tại thì không cho phép thêm
    IF EXISTS (SELECT 1 FROM TT_ThuePhong WHERE MaHopDong = NEW.MaHopDong) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hợp đồng đã tồn tại, không thể thêm mới.';
    END IF;
END //

DELIMITER ;


-- Thủ tục xóa bản ghi TT_ThuePhong
DELIMITER //

CREATE PROCEDURE delete_tt_thuephong(IN p_MaHopDong VARCHAR(10))
BEGIN
    START TRANSACTION;
        DELETE FROM TT_ThuePhong WHERE MaHopDong = p_MaHopDong;
        DELETE FROM TT_ThuePhong WHERE MaHopDong = p_MaHopDong;
    COMMIT;
END //

DELIMITER ;

