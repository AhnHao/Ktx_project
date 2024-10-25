const express = require('express')
const { body } = require('express-validator')
const Admin = require('../models/adminModel')

const router = express.Router()

const authController = require('../controllers/auth')

router.get('/', authController.getLogin)

router.post(
  '/login',
  [
    body('email')
      .isEmail()
      .withMessage('Vui lòng nhập email hợp lệ')
      .normalizeEmail(),
    body('password', 'Vui lòng nhập mật khẩu hợp lệ')
      .isLength({ min: 6 })
      .trim()
  ],
  authController.login
)

router.get('/register', authController.getRegister)

router.post(
  '/register',
  [
    body('email')
      .isEmail()
      .withMessage('Vui lòng nhập email hợp lệ')
      .custom(async email => {
        const admin = await Admin.findByEmail(email)
        if (admin) {
          throw new Error('Email đã tồn tại, vui lòng chọn email khác')
        }
      })
      .normalizeEmail(),
    body('password', 'Vui lòng nhập mật khẩu ít nhất 6 ký tự')
      .isLength({ min: 6 })
      .trim(),
    body('confirmPassword')
      .custom((value, { req }) => {
        if (value !== req.body.password) {
          throw new Error('Mật khẩu nhập lại không đúng')
        }
        return true
      })
      .trim(),
    body('name')
      .isLength({ min: 1 })
      .withMessage('Vui lòng không bỏ trống họ tên')
      .trim(),
    body('address')
      .isLength({ min: 1 })
      .withMessage('vui lòng không bỏ trống địa chỉ')
      .trim(),
    body('phone')
      .isMobilePhone('vi-VN')
      .withMessage('Vui lòng nhập số điện thoại hợp lệ tại Việt Nam')
      .trim()
  ],
  authController.register
)

router.post('/logout', authController.logout)

module.exports = router
