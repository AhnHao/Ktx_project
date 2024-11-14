const db = require('../config/database')

const Rental = {
    getAllRentals: async function () {
        const sql = 'SELECT * FROM thuephong'
        const [result] = await db.query(sql)
        return result
    },
    addRental: async function ( MaSinhVien, MaPhong, BatDau, KetThuc, Gia) {
        const sql = 'CALL TaoHopDongThuePhong(?, ?, ?, ?, ?)'
        await db.query(sql, [ MaSinhVien, MaPhong, BatDau, KetThuc, Gia])
    },
    deleteRental: async function (MaHopDong) {
        const sql = 'CALL XoaHopDongThuePhong(?)'
        await db.query(sql, [MaHopDong])
    },
    getRental: async function (MaHopDong) {
        const sql = 'SELECT * FROM thuephong WHERE MaHopDong = ?'
        const [result] = await db.query(sql, [MaHopDong])
        return result
    },
    updateRental: async function (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia) {
        const sql = 'CALL UpdateRental(?, ?, ?, ?, ?, ?)';
        const [result] = await db.query(sql, [MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia]);
        return result;
    },
    searchRental: async function (searchMaHopDong,searchMaSinhVien,searchMaPhong) {
        const sql = 'SELECT * FROM thuephong WHERE MaHopDong LIKE ? AND MaSinhVien LIKE ? AND MaPhong LIKE ?'
        const [result] = await db.query(sql, [`%${searchMaHopDong}%`, `%${searchMaSinhVien}%`, `%${searchMaPhong}%`])
        return result
    },
    getRentalByMSSV: async function (MaSinhVien){
        const sql = 'SELECT * FROM thuephong WHERE MaSinhVien = ?'
        const [result] = await db.query(sql, [MaSinhVien])
        return result
    },
    
}
module.exports = Rental