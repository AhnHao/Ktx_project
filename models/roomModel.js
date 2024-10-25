const db = require('../config/database')

const Room = {
  getAllrooms: async function () {
    const sql = 'SELECT * FROM phong'
    const [result] = await db.query(sql)
    return result
  },

  getRoom: async function (maPhong) {
    const sql = 'SELECT * FROM phong where MaPhong = ?'
    const [result] = await db.query(sql,[maPhong])
    return result
  },

  addRoom: async function (maPhong, tenPhong, dienTich, soGiuong, giaThue, loaiPhong) {
    const sql =
      'INSERT INTO phong (MaPhong, TenPhong, DienTich, SoGiuong, GiaThue, PhongNam_Nu) VALUES (?,?,?,?,?,?)'
    const [result] = await db.query(sql, [
      maPhong,
      tenPhong,
      dienTich,
      soGiuong,
      giaThue,
      loaiPhong
    ])
    return result
  },

  deleteRoom: async function (maPhong) {
    const sql = 'DELETE FROM phong WHERE MaPhong = ?'
    const [result] = await db.query(sql, [maPhong])
    return result
  },

  updateRoom: async function (maPhong, tenPhong, dienTich, soGiuong, giaThue, loaiPhong) {
    const sql = 'UPDATE phong SET TenPhong = ?, DienTich = ?, SoGiuong = ?, GiaThue = ?, PhongNam_Nu = ? WHERE MaPhong = ?'
    const [result] = await db.query(sql, [tenPhong, dienTich, soGiuong, giaThue, loaiPhong, maPhong])
    return result
  },
}

module.exports = Room
