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
};

module.exports = Payment;
