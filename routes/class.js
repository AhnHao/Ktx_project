const express = require('express')

const router = express.Router()

const classController = require('../controllers/classController')
const isAuth = require('../middleware/isAuth')

router.get('/class', isAuth, classController.getAllClasses)
router.post('/add-class', isAuth, classController.addClass)
router.get('/edit-class/:maLop', isAuth, classController.getEditClass)
router.post('/update-class', isAuth, classController.updateClass)
router.post('/delete-class', isAuth, classController.deleteClass)

// Route tìm kiếm lớp
router.get('/search-class', classController.searchClass);
module.exports = router