const db = require('../config/database');

const Student = {
  // Lấy tất cả sinh viên
  getAllStudents: async function () {
    const sql = 'SELECT * FROM SinhVien'; // Giả sử bảng sinh viên là SinhVien
    const [result] = await db.query(sql);
    return result;
  },

  // Lấy thông tin sinh viên theo mã sinh viên
  getStudent: async function (maSinhVien) {
    const sql = 'SELECT * FROM SinhVien WHERE MaSinhVien = ?';
    const [result] = await db.query(sql, [maSinhVien]);
    return result;
  },

  // Thêm sinh viên
  addStudent: async function (maSinhVien, hoTen, soDienThoai, maLop, gioiTinh) {
    const sql = 'INSERT INTO SinhVien (MaSinhVien, HoTen, SoDienThoai, MaLop, GioiTinh) VALUES (?, ?, ?, ?, ?)';
    const [result] = await db.query(sql, [
      maSinhVien,
      hoTen,
      soDienThoai,
      maLop,
      gioiTinh
    ]);
    return result;
  },

  // Cập nhật thông tin sinh viên
  updateStudent: async function (maSinhVien, hoTen, soDienThoai, maLop, gioiTinh) {
    const sql = 'UPDATE SinhVien SET HoTen = ?, SoDienThoai = ?, MaLop = ?, GioiTinh = ? WHERE MaSinhVien = ?';
    const [result] = await db.query(sql, [hoTen, soDienThoai, maLop, gioiTinh, maSinhVien]);
    return result;
  },

  // Xóa sinh viên
  deleteStudent: async function (maSinhVien) {
    const sql = 'DELETE FROM SinhVien WHERE MaSinhVien = ?';
    const [result] = await db.query(sql, [maSinhVien]);
    return result;
  },

  checkStudent: async function (maSinhVien) {
    const sql = 'SELECT * FROM thuephong WHERE maSinhVien = ?'
    const [result] = await db.query(sql, [maSinhVien])
    return result
  }
};

module.exports = Student;
