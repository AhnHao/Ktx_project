const express = require('express')

const router = express.Router()

const dashboardController = require('../controllers/dashboardController')
const isAuth = require('../middleware/isAuth')

router.get('/dashboard', isAuth, dashboardController.getDashboard)

module.exports = router