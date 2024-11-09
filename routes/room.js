const express = require('express')

const router = express.Router()

const roomController = require('../controllers/roomController')
const isAuth = require('../middleware/isAuth')

router.get('/room', isAuth, roomController.getAllRooms)

router.post('/search-room', isAuth, roomController.searchRoom)

router.post('/add-room', isAuth, roomController.addRoom)

router.post('/delete-room', isAuth, roomController.deleteRoom)

router.get('/edit-room/:maPhong', isAuth, roomController.getEditRoom)

router.post('/update-room', isAuth, roomController.updateRoom)

module.exports = router