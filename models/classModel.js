const db = require('../config/database')


const Class = {

    getAllClasses: async function () {
        const sql = 'SELECT * FROM lop'
        const [result] = await db.query(sql)
        return result
    },

    addClass: async function (maLop, tenLop) {
        const sql = 'INSERT INTO lop (maLop, tenLop) VALUES (?, ?)'
        const [result] =  await db.query(sql, [maLop, tenLop])
        return result
    },
    
    getClass: async function (maLop) {
        const sql = 'SELECT * FROM lop WHERE maLop = ?'
        const [result] = await db.query(sql, [maLop])
        return result
    },
    updateClass: async function (maLop, tenLop) {
        const sql = 'UPDATE lop SET tenLop = ? WHERE maLop = ?'
        const [result] = await db.query(sql, [tenLop, maLop])
        return result
    },
    deleteClass: async function (maLop) {
        const sql = 'DELETE FROM lop WHERE maLop = ?'
        const [result] = await db.query(sql, [maLop])
        return result
    },
    // Viết hàm tìm kiếm lớp sử dụng Like
    searchByClass: async function (searchMaLop, searchTenLop) {
        const sql = 'SELECT * FROM Lop WHERE MaLop LIKE ? AND TenLop LIKE ?';
        const [result] = await db.query(sql, [`%${searchMaLop}%`, `%${searchTenLop}%`]);
        return result
    },
    getClassName: async function (maLop) {
        const sql = 'SELECT TenLop FROM Lop WHERE MaLop = ?';
        const [result] = await db.query(sql, [maLop]);
        return result.length > 0 ? result[0].TenLop : null;
    }
    
}
module.exports = Class
