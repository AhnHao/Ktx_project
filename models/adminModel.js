const db = require('../config/database')

const Admin = {

  findByEmail: async function (email) {
    const sql = 'SELECT * FROM admin where email = ?'
    const [result] = await db.query(sql, [email])
    return result.length > 0 ? result[0] : null
  },

  addAdmin: async function (email, password, name, address, phone) {
    const sql = 'INSERT INTO admin (email, password, hoTen, diaChi, soDienThoai) VALUES (?,?,?,?,?)'
    const [result] = await db.query(sql, [email, password, name, address, phone])
    return result
  }
}

module.exports = Admin