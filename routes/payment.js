const express = require('express');
const router = express.Router();

const paymentController = require('../controllers/paymentController');
const isAuth = require('../middleware/isAuth');

// Get all payments
router.get('/', isAuth, paymentController.getAllPayments);

// Add payment
router.post('/add-payment', isAuth, paymentController.addPayment);

// Delete payment
router.post('/delete-payment/:MaHopDong', isAuth, paymentController.deletePayment);

// Update payment
router.post('/update-payment', isAuth, paymentController.updatePayment);

// Edit payment
router.get('/edit-payment/:MaHopDong', isAuth, paymentController.editPayment);

// Search payment
router.get('/search', isAuth, paymentController.searchPayment);

module.exports = router;
