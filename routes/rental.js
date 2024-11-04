const express = require('express')

const router = express.Router()

const rentalController = require('../controllers/rentalController')
const isAuth = require('../middleware/isAuth')

router.get('/rental', isAuth, rentalController.getAllRentals)

router.post('/add-rental', isAuth, rentalController.addRental)

router.post('/delete-rental', isAuth, rentalController.deleteRental)

router.get('/edit-rental/:maHopDong', isAuth, rentalController.getEditRental)

router.post('/update-rental', isAuth, rentalController.updateRental)
// Tìm kiếm rental (cần xác thực)
router.get('/search-rental', isAuth, rentalController.searchRental)

module.exports = router