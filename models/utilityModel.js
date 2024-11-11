const db = require('../config/database')

const Utility = {
  

    getUtilityByMaPhong: async function (maPhong) {
        const sql = 'SELECT * FROM diennuoc WHERE MaPhong = ?'
        const [result] = await db.query(sql, [maPhong])
        return result
    }

}

module.exports = Utility
