const db = require('../config/database');

const Payment = {
  // ...existing code...

  getPaymentByContractCode: async function (MaHopDong) {
    const sql = 'SELECT * FROM TT_ThuePhong WHERE MaHopDong = ?';
    const [rows] = await db.query(sql, [MaHopDong]);
    return rows;
  },

  getPaymentByStudentId: async function (MaSoSinhVien) {
    const sql = `
      SELECT tt.*
      FROM TT_ThuePhong tt
      JOIN ThuePhong tp ON tt.MaHopDong = tp.MaHopDong
      WHERE tp.MaSinhVien = ?
    `;
    const [rows] = await db.query(sql, [MaSoSinhVien]);
    return rows;
  },

  // ...existing code...
  getTotalRevenue: async function () {
    const sql = 'SELECT SUM(SoTien) AS totalRevenue FROM TT_ThuePhong WHERE NgayThanhToan IS NOT NULL';
    const [result] = await db.query(sql);
    return result[0].totalRevenue;
  },
  getTotalStudentsWithPayment: async function () {
    const sql = `
      SELECT COUNT(DISTINCT tp.MaSinhVien) AS totalStudents
      FROM TT_ThuePhong tt
      JOIN ThuePhong tp ON tt.MaHopDong = tp.MaHopDong
      WHERE tt.NgayThanhToan IS NOT NULL
    `;
    const [rows] = await db.query(sql);
    return rows[0]?.totalStudents || 0;
  }, 
  getRoomPayment: async function () {
    const sql = `
    SELECT 
    tp.MaPhong, 
    ttp.MaHopDong, 
    ttp.ThangNam, 
    ttp.SoTien, 
    ttp.NgayThanhToan, 
    ttp.MaNhanVien
FROM 
    TT_ThuePhong ttp
JOIN 
    ThuePhong tp ON ttp.MaHopDong = tp.MaHopDong
WHERE 
    ttp.NgayThanhToan IS NOT NULL;
    `;
    const [rows] = await db.query(sql);
    return rows;
  }
};

module.exports = Payment;
