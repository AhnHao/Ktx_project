const express = require('express')
const { body } = require('express-validator')
const Student = require('../models/studentModel')

const router = express.Router()

const authstudentController = require('../controllers/authstudent')

router.get('/loginstudent', authstudentController.getLogin)

router.post(
    '/loginstudent',
    [
      body('MaSinhVien')
        .notEmpty().withMessage('MSSV không được để trống')
        .matches(/^[A-Za-z]\d{7}$/).withMessage('MSSV phải bắt đầu bằng một chữ cái, theo sau là 7 chữ số')
    ],
    authstudentController.login
  );

router.post('/logoutstudent', authstudentController.logout)

module.exports = router
