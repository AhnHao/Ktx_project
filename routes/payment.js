const express = require('express');

const router = express.Router();

const paymentController = require('../controllers/paymentController');
const isAuth = require('../middleware/isAuth');

// Lấy tất cả thanh toán (cần xác thực)s
router.get('/payment', isAuth, paymentController.getAllPayments);

// Thêm thanh toán (cần xác thực)
router.post('/add-payment', isAuth, paymentController.addPayment);

// Xóa thanh toán theo hợp đồng (cần xác thực)
router.post('/delete-payment/:MaHopDong', isAuth, paymentController.deletePayment);

// Cập nhật thanh toán (cần xác thực)
router.post('/update-payment', isAuth, paymentController.updatePayment);

// Lấy thông tin thanh toán để chỉnh sửa (cần xác thực)
router.get('/edit-payment/:MaHopDong', isAuth, paymentController.editPayment);

// Tìm kiếm thanh toán (cần xác thực)

router.get('/payment/search', isAuth, paymentController.searchPayment);

module.exports = router;