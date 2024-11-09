const db = require('../config/database')

const Room = {
  getAllrooms: async function () {
    const sql = 'SELECT p.*, (p.SoGiuong - COUNT(tp.MaHopDong)) AS GiuongConLai FROM phong p LEFT JOIN thuephong tp ON p.MaPhong = tp.MaPhong GROUP BY p.MaPhong'
    const [result] = await db.query(sql)
    return result
  },

  getRoom: async function (maPhong) {
    const sql = 'SELECT p.*, (p.SoGiuong - COUNT(tp.MaHopDong)) AS GiuongConLai FROM phong p LEFT JOIN thuephong tp ON p.MaPhong = tp.MaPhong WHERE p.MaPhong = ? GROUP BY p.MaPhong'
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

  checkRoom: async function (maPhong) {
    const sql = 'SELECT * FROM thuephong WHERE maPhong = ?'
    const [result] = await db.query(sql, [maPhong])
    return result
  },

  searchRoom: async function (maPhong, tenPhong) {
    const sql = 'SELECT p.*, (p.SoGiuong - COUNT(tp.MaHopDong)) AS GiuongConLai FROM phong p LEFT JOIN thuephong tp ON p.MaPhong = tp.MaPhong WHERE p.MaPhong LIKE ? AND p.TenPhong LIKE ? GROUP BY p.MaPhong'
    const [result] = await db.query(sql, [`%${maPhong}%`, `%${tenPhong}%`])
    return result
  }
}

module.exports = Room
