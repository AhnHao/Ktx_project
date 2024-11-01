const Employees = require('../models/EmployeesModel');

exports.getAllEmployees = async (req, res, next) => {
  let successMessage = req.flash('success');
  try {
    const allEmployees = await Employees.getAllEmployees();
    res.render('employees/employees', {
      pageTitle: 'Nhân Viên',
      path: '/employees',
      allEmployees: allEmployees,
      successMessage: successMessage.length > 0 ? successMessage[0] : null,
      editing: false
    });
  } catch (err) {
    console.log(err);
  }
};

exports.addEmployee = async (req, res, next) => {
  const maNhanVien = req.body.maNhanVien;
  const hoTen = req.body.hoTen;
  const soDienThoai = req.body.soDienThoai;
  const ghiChu = req.body.ghiChu;

  try {
    await Employees.addEmployee(maNhanVien, hoTen, soDienThoai, ghiChu);
    req.flash('success', 'Thêm nhân viên thành công!');
    res.redirect('/employees');
  } catch (err) {
    console.log(err);
  }
};

exports.deleteEmployee = async (req, res, next) => {
  const maNhanVien = req.body.maNhanVien;
  try {
    await Employees.deleteEmployee(maNhanVien);
    req.flash('success', 'Xóa nhân viên thành công!');
    res.redirect('/employees');
  } catch (err) {
    console.log(err);
  }
};

exports.getEditEmployee = async (req, res, next) => {
  const editMode = req.query.edit;
  const maNhanVien = req.params.maNhanVien;
  try {
    const editEmployee = await Employees.getEmployee(maNhanVien);
    const allEmployees = await Employees.getAllEmployees();
    res.render('employees/employees', {
      pageTitle: 'Sửa Nhân Viên',
      path: '/employees',
      allEmployees: allEmployees,
      editEmployee: editEmployee[0],
      editing: editMode,
      successMessage: null
    });
  } catch (err) {
    console.log(err);
  }
};

exports.updateEmployee = async (req, res, next) => {
  const maNhanVien = req.body.maNhanVien;
  const hoTen = req.body.hoTen;
  const soDienThoai = req.body.soDienThoai;
  const ghiChu = req.body.ghiChu;

  try {
    await Employees.updateEmployee(maNhanVien, hoTen, soDienThoai, ghiChu);
    req.flash('success', 'Cập nhật thông tin nhân viên thành công!');
    res.redirect('/employees');
  } catch (err) {
    console.log(err);
  }
};