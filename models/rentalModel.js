const db = require('../config/database')

const Rental = {
    getAllRentals: async function () {
        const sql = 'SELECT * FROM thuephong'
        const [result] = await db.query(sql)
        return result
    },
    addRental: async function (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, TienDatCoc, GiaThueThucTe) {
        const sql = 'INSERT INTO thuephong (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, TienDatCoc, GiaThueThucTe) VALUES (?, ?, ?, ?, ?, ?, ?)'
        await db.query(sql, [MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, TienDatCoc, GiaThueThucTe])
    },
    deleteRental: async function (MaHopDong) {
        const sql = 'DELETE FROM thuephong WHERE MaHopDong = ?'
        await db.query(sql, [MaHopDong])
    },
    getRental: async function (MaHopDong) {
        const sql = 'SELECT * FROM thuephong WHERE MaHopDong = ?'
        const [result] = await db.query(sql, [MaHopDong])
        return result
    },
    updateRental: async function (MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, TienDatCoc, GiaThueThucTe) {
        const sql = 'UPDATE thuephong SET MaSinhVien = ?, MaPhong = ?, BatDau = ?, KetThuc = ?, TienDatCoc = ?, GiaThueThucTe = ? WHERE MaHopDong = ?'
        const[result] = await db.query(sql, [MaSinhVien, MaPhong, BatDau, KetThuc, TienDatCoc, GiaThueThucTe, MaHopDong])
        return result
    },
    searchRental: async function (searchMaHopDong,searchMaSinhVien,searchMaPhong) {
        const sql = 'SELECT * FROM thuephong WHERE MaHopDong LIKE ? AND MaSinhVien LIKE ? AND MaPhong LIKE ?'
        const [result] = await db.query(sql, [`%${searchMaHopDong}%`, `%${searchMaSinhVien}%`, `%${searchMaPhong}%`])
        return result
    }
}
module.exports = Rental