const Student = require('../models/studentModel');

exports.getAllStudents = async (req, res, next) => {
  let successMessage = req.flash('success');
  const allStudents = await Student.getAllStudents();
  res.render('student/student', {
    pageTitle: 'Danh Sách Sinh Viên',
    path: '/student',
    allStudents: allStudents,
    successMessage: successMessage.length > 0 ? successMessage[0] : null,
    editing: false
  });
}

exports.addStudent = async (req, res, next) => {
  const maSinhVien = req.body.maSinhVien;
  const hoTen = req.body.hoTen;
  const soDienThoai = req.body.soDienThoai; // Thay đổi từ 'sdt' thành 'soDienThoai'
  const maLop = req.body.maLop; // Mã lớp
  const gioiTinh = req.body.gioiTinh; // Giới tính

  try {
    await Student.addStudent(maSinhVien, hoTen, soDienThoai, maLop, gioiTinh); // Sửa cho đúng thông số
    req.flash('success', 'Thêm sinh viên thành công!');
    res.redirect('/student');
  } catch(err) {
    console.log(err);
  }
}

exports.deleteStudent = async (req, res, next) => {
  const maSinhVien = req.body.maSinhVien;
  try {
    await Student.deleteStudent(maSinhVien);
    req.flash('success', 'Xóa sinh viên thành công!');
    res.redirect('/student');
  } catch(err) {
    console.log(err);
  }
}

exports.getEditStudent = async (req, res, next) => {
  const editMode = req.query.edit;
  const maSinhVien = req.params.maSinhVien;
  try {
    const editStudent = await Student.getStudent(maSinhVien);
    const allStudents = await Student.getAllStudents();
    res.render('student/student', {
      pageTitle: 'Chỉnh Sửa Thông Tin Sinh Viên',
      path: '/student',
      allStudents: allStudents,
      editStudent: editStudent[0],
      editing: editMode,
      successMessage: null
    });
  } catch(err) {
    console.log(err);
  }
}

exports.updateStudent = async (req, res, next) => {
  const maSinhVien = req.body.maSinhVien;
  const hoTen = req.body.hoTen;
  const soDienThoai = req.body.soDienThoai; // Thay đổi từ 'sdt' thành 'soDienThoai'
  const maLop = req.body.maLop; // Mã lớp
  const gioiTinh = req.body.gioiTinh; // Giới tính

  try {
    await Student.updateStudent(maSinhVien, hoTen, soDienThoai, maLop, gioiTinh); // Sửa cho đúng thông số
    req.flash('success', 'Cập nhật thông tin sinh viên thành công!');
    res.redirect('/student');
  } catch(err) {
    console.log(err);
  }
}
