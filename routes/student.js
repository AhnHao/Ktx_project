const express = require('express');

const router = express.Router();

const studentController = require('../controllers/studentController');
const isAuth = require('../middleware/isAuth');

// Route để lấy danh sách sinh viên
router.get('/student', isAuth, studentController.getAllStudents);

// Route để thêm sinh viên
router.post('/add-student', isAuth, studentController.addStudent);

// Route để xóa sinh viên
router.post('/delete-student', isAuth, studentController.deleteStudent);

// Route để lấy thông tin sinh viên để sửa
router.get('/edit-student/:maSinhVien', isAuth, studentController.getEditStudent);

// Route để cập nhật thông tin sinh viên
router.post('/update-student', isAuth, studentController.updateStudent);

module.exports = router;
