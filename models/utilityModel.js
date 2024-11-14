const db = require('../config/database')

const Utility = {
  
    getAllUtilities: async function () {
        const sql = 'SELECT * FROM diennuoc'
        const [result] = await db.query(sql)
        return result
    },
    addUtility: async function ( maPhong, thangNam, soTienDien, soTienNuoc, tienConLai, ngayDong) {
        const sql = 'CALL ThemDienNuoc(?, ?, ?, ?, ?, ?)'
        await db.query(sql, [ maPhong, thangNam, soTienDien, soTienNuoc, tienConLai, ngayDong])
    },
    getUtilityByMaPhong: async function (maPhong) {
        const sql = 'SELECT * FROM diennuoc WHERE MaPhong = ?'
        const [result] = await db.query(sql, [maPhong])
        return result
    },
    getUtilityByMaDienNuoc: async function (maDienNuoc) {
        const sql = 'SELECT * FROM diennuoc WHERE MaDienNuoc = ?'
        const [result] = await db.query(sql, [maDienNuoc])
        return result
    },
    updateUtility: async function (maDienNuoc, maPhong, thangNam, soTienDien, soTienNuoc, tienConLai, ngayDong) {
        const sql = 'UPDATE diennuoc SET MaPhong = ?, ThangNam = ?, SoTienDien = ?, SoTienNuoc = ?, TienConLai = ?, NgayDong = ? WHERE MaDienNuoc = ?'
        await db.query(sql, [maPhong, thangNam, soTienDien, soTienNuoc, tienConLai, ngayDong, maDienNuoc])
    },
    deleteUtility: async function (maDienNuoc) {
        const sql = 'CALL XoaDienNuoc(?)'
        await db.query(sql, [maDienNuoc])
    },
    updatePaymentStatus: async function (maDienNuoc) {
        const sql = 'CALL ThanhToanHoaDonDienNuoc(?)';
        const [result] = await db.query(sql, [maDienNuoc]);
        return result;
    },
    getTotalUtility: async function () {
    const sql = 'SELECT SUM(SoTienDien + SoTienNuoc) AS totalUtility FROM diennuoc WHERE NgayDong IS NOT NULL'
    const [result] = await db.query(sql)
    return result[0].totalUtility
    },
    // Tính danh thu diện nước mỗi tháng
    getUtilityRevenueByMonth: async function () {
        const sql = 'CALL GetDienNuocRevenueByMonth()'
        const [result] = await db.query(sql)
        return result[0]
    },
}

module.exports = Utility
