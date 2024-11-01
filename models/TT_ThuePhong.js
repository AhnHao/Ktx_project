const db = require('../config/database');

const TT_ThuePhong = {
  // Truy vấn thanh toán của một sinh viên cụ thể
  getStudentPaymentById: async function (studentID) {
    try {
      const sql = 'CALL get_payment_by_student(?)';
      const [result] = await db.query(sql, [studentID]);
      return result[0];
    } catch (error) {
      console.error('Error fetching student payment:', error);
      throw error;
    }
  },

  // Truy vấn tất cả các thanh toán theo hợp đồng
  getPaymentsByContractId: async function (contractID) {
    try {
      const sql = 'CALL get_payment_by_contract(?)';
      const [result] = await db.query(sql, [contractID]);
      return result[0];
    } catch (error) {
      console.error('Error fetching contract payments:', error);
      throw error;
    }
  },

  // Truy vấn tất cả các thanh toán
  getAllPayments: async function () {
    try {
      const sql = 'SELECT * FROM TT_ThuePhong';
      const [result] = await db.query(sql);
      return result;
    } catch (error) {
      console.error('Error fetching all payments:', error);
      throw error;
    }
  },

  // Kiểm tra tình trạng thanh toán của sinh viên
  checkStudentPaymentStatusById: async function (studentID) {
    try {
      const sql = 'CALL check_student_payment_status(?)';
      const [result] = await db.query(sql, [studentID]);
      return result[0];
    } catch (error) {
      console.error('Error checking student payment status:', error);
      throw error;
    }
  },

  // Thêm bản ghi mới vào TT_ThuePhong
  addPaymentRecord: async function (contractID, thangNam, soTien, ngayThanhToan, maNhanVien) {
    try {
      const sql = 'CALL add_tt_thuephong(?, ?, ?, ?, ?)';
      const [result] = await db.query(sql, [
        contractID,
        thangNam,
        parseInt(soTien),
        ngayThanhToan ? ngayThanhToan : null,
        maNhanVien,
      ]);
      return result;
    } catch (error) {
      console.error('Error adding new payment record:', error);
      throw error;
    }
  },

  // Chỉnh sửa thông tin trong TT_ThuePhong
  updatePaymentRecord: async function (contractID, thangNam, soTien, ngayThanhToan, maNhanVien) {
    try {
      const sql = 'CALL CapNhatTT_ThuePhong(?, ?, ?, ?, ?)';
      const [result] = await db.query(sql, [
        contractID,
        thangNam,
        parseInt(soTien),
        ngayThanhToan ? ngayThanhToan : null,
        maNhanVien
      ]);
      console.log('Update successful', result); // Log success message
    } catch (error) {
      console.error('Error updating payment:', error);
      throw error;
    }
  },
  // Xóa bản ghi trong TT_ThuePhong
  deletePaymentRecord: async function (contractID) {
    try {
      const sql = 'CALL delete_tt_thuephong(?)';
      const [result] = await db.query(sql, [contractID]);
      return result[0];
    } catch (error) {
      console.error('Error deleting payment record:', error);
      throw error;
    }
  },

  // Lấy thông tin thanh toán theo mã hợp đồng
  getPaymentById: async function (contractID) {
    try {
      const sql = 'SELECT * FROM TT_ThuePhong WHERE MaHopDong = ?';
      const [result] = await db.query(sql, [contractID]);
      return result[0];
    } catch (error) {
      console.error('Error fetching payment by MaHopDong:', error);
      throw error;
    }
  },
};

module.exports = TT_ThuePhong;