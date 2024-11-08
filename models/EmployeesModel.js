const db = require('../config/database');

const Employees = {
  // Lấy tất cả nhân viên
  getAllEmployees: async function () {
    const sql = 'SELECT * FROM NhanVien'; // Giả sử bảng nhân viên là NhanVien
    const [result] = await db.query(sql);
    return result;
  },

  // Lấy thông tin nhân viên theo mã nhân viên
  getEmployee: async function (maNhanVien) {
    const sql = 'SELECT * FROM NhanVien WHERE MaNhanVien = ?';
    const [result] = await db.query(sql, [maNhanVien]);
    return result;
  },

  // Thêm nhân viên
  addEmployee: async function (maNhanVien, hoTen, soDienThoai, ghiChu) {
    const sql = 'INSERT INTO NhanVien (MaNhanVien, HoTen, SoDienThoai, GhiChu) VALUES (?, ?, ?, ?)';
    const [result] = await db.query(sql, [maNhanVien, hoTen, soDienThoai, ghiChu]);
    return result;
  },

  // Cập nhật thông tin nhân viên
  updateEmployee: async function (maNhanVien, hoTen, soDienThoai, ghiChu) {
    const sql = 'UPDATE NhanVien SET HoTen = ?, SoDienThoai = ?, GhiChu = ? WHERE MaNhanVien = ?';
    const [result] = await db.query(sql, [hoTen, soDienThoai, ghiChu, maNhanVien]);
    return result;
  },

  // Xóa nhân viên
  deleteEmployee: async function (maNhanVien) {
    const sql = 'DELETE FROM NhanVien WHERE MaNhanVien = ?';
    const [result] = await db.query(sql, [maNhanVien]);
    return result;
  },

  checkEmployee: async function (maNhanVien) {
    const sql = 'SELECT * FROM tt_thuephong WHERE maNhanVien = ?'
    const [result] = await db.query(sql, [maNhanVien])
    return result
  }
};

module.exports = Employees;
