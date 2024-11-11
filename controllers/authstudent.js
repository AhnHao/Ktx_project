const Student = require('../models/studentModel')
const { validationResult } = require('express-validator')

exports.getLogin = (req, res, next) => {
  let message = req.flash('error')
  if (message.length > 0) {
    message = message[0]
  } else {
    message = null
  }
  res.render('authstudent/login', {
    pageTitle: 'Login',
    path: '/loginstudent',
    errorMessage: message,
    oldInput: {
        MaSinhVien: '',
    },
    validationErrors: []
  })
}

exports.login = async (req, res, next) => {
  const MaSinhVien = req.body.MaSinhVien
  const errors = validationResult(req)

  if (!errors.isEmpty()) {
    return res.status(422).render('authstudent/login', {
      pageTitle: 'Login',
      path: '/loginstudent',
      errorMessage: errors.array()[0].msg,
      oldInput: {
        MaSinhVien: MaSinhVien,
      },
      validationErrors: errors.array()
    })
  }

  try {
    const student = await Student.findByMSSV(MaSinhVien)
    if (!student) {
      return res.status(422).render('authstudent/login', {
        pageTitle: 'Login',
        path: '/loginstudent',
        errorMessage: 'MSSV không tồn tại',
        oldInput: {
            MaSinhVien: MaSinhVien,
        },
        validationErrors: errors.array()
      })
    }

    // Tạo session khi đăng nhập thành công
    // req.session.isLoggedIn = true
    req.session.student = student;
    req.session.save(err => {
      if (err) {
        console.error('Session save error:', err);
      }
      // console.log('Student session:', req.session.student);
      res.redirect('/roominfo');
    });

  } catch (err) {
    console.log(err)
  }
}

exports.logout = (req, res, next) => {
  req.session.destroy(err => {
    console.log(err);
    res.redirect('/loginstudent');
  });
};