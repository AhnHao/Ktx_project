const express = require('express')

const router = express.Router()

const utilityController = require('../controllers/utilityController')
const isAuth = require('../middleware/isAuth')
router.get('/utility',isAuth,utilityController.getAllUtilities)

router.post('/add-utility',isAuth, utilityController.addUtility)

router.get('/edit-utility/:MaDienNuoc',isAuth, utilityController.getEditUtility)
router.post('/update-utility',isAuth, utilityController.updateUtility)

router.post('/delete-utility',isAuth, utilityController.deleteUtility)

router.post('/updatePaymentStatus', utilityController.updatePaymentStatus);

module.exports = router