const Admin = require('../models/adminModel')
const bcrypt = require('bcryptjs')
const { validationResult } = require('express-validator')

exports.getLogin = (req, res, next) => {
  let message = req.flash('error')
  if (message.length > 0) {
    message = message[0]
  } else {
    message = null
  }
  res.render('auth/login', {
    pageTitle: 'Login',
    path: '/login',
    errorMessage: message,
    oldInput: {
      email: '',
      password: ''
    },
    validationErrors: []
  })
}

exports.login = async (req, res, next) => {
  const email = req.body.email
  const password = req.body.password
  const errors = validationResult(req)

  if (!errors.isEmpty()) {
    return res.status(422).render('auth/login', {
      pageTitle: 'Login',
      path: '/login',
      errorMessage: errors.array()[0].msg,
      oldInput: {
        email: email,
        password: password
      },
      validationErrors: errors.array()
    })
  }

  try {
    const admin = await Admin.findByEmail(email)
    if (!admin) {
      return res.status(422).render('auth/login', {
        pageTitle: 'Login',
        path: '/login',
        errorMessage: 'Tài khoản không tồn tại',
        oldInput: {
          email: email,
          password: password
        },
        validationErrors: errors.array()
      })
    }

    const isMatch = await bcrypt.compare(password, admin.password)
    if (!isMatch) {
      return res.status(422).render('auth/login', {
        pageTitle: 'Login',
        path: '/login',
        errorMessage: 'Mật khẩu không chính xác',
        oldInput: { email: email, password: password },
        validationErrors: []
      })
    }

    // Tạo session khi đăng nhập thành công
    req.session.isLoggedIn = true
    req.session.admin = admin
    return req.session.save(err => {
      res.redirect('/room')
    })
  } catch (err) {
    console.log(err)
  }
}

exports.getRegister = (req, res, next) => {
  let message = req.flash('error')
  if (message.length > 0) {
    message = message[0]
  } else {
    message = null
  }

  res.render('auth/register', {
    pageTitle: 'Register',
    path: '/register',
    errorMessage: message,
    oldInput: {
      email: '',
      password: '',
      confirmPassword: '',
      name: '',
      address: '',
      phone: ''
    },
    validationErrors: []
  })
}

exports.register = async (req, res, next) => {
  const email = req.body.email
  const password = req.body.password
  const confirmPassword = req.body.confirmPassword
  const name = req.body.name
  const address = req.body.address
  const phone = req.body.phone
  const errors = validationResult(req)

  if (!errors.isEmpty()) {
    return res.status(422).render('auth/register', {
      pageTitle: 'Register',
      path: '/register',
      errorMessage: errors.array()[0].msg,
      oldInput: {
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
        address: address,
        phone: phone
      },
      validationErrors: errors.array()
    })
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 12)
    await Admin.addAdmin(email, hashedPassword, name, address, phone)
    req.flash('success', 'Đăng ký thành công!')
    res.status(201).redirect('/')
  } catch (err) {
    console.log(err)
    const error = new Error(err)
    error.httpStatusCode = 500
    return next(err)
  }
}

exports.logout = (req, res, next) => {
  req.session.destroy(err => {
    console.log(err);
    res.redirect('/');
  });
};