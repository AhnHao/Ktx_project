const mysql = require('mysql2/promise')
const dotnenv = require('dotenv')

dotnenv.config()

const pool = mysql.createPool({
  host: process.env.HOST,
  user: process.env.USER,
  password: process.env.PASSWORD,
  database: process.env.DATABASE
});

module.exports = pool;
 