const Room = require('../models/roomModel')

exports.getAllRooms = async (req, res, next) => {
  let successMessage = req.flash('success');
  const allRooms = await Room.getAllrooms()
  res.render('room/room', {
    pageTitle: 'Room',
    path: '/room',
    allRooms: allRooms,
    successMessage: successMessage.length > 0 ? successMessage[0] : null,
    editing: false
  })
}

exports.addRoom = async (req, res, next) => {
  const maPhong = req.body.maPhong
  const tenPhong = req.body.tenPhong
  const dienTich = req.body.dienTich
  const soGiuong = req.body.soGiuong
  const giaThue = req.body.giaThue
  const loaiPhong = req.body.phongNamNu

  try {
    await Room.addRoom(maPhong,tenPhong,dienTich,soGiuong,giaThue,loaiPhong)
    req.flash('success', 'Thêm phòng thành công!')
    res.redirect('/room')
  } catch(err) {
    console.log(err)
  }
}

exports.deleteRoom = async (req, res, next) => {
  const maPhong = req.body.maPhong
  try {
    await Room.deleteRoom(maPhong)
    req.flash('success', 'Xóa phòng thành công!')
    res.redirect('/room')
  } catch(err) {
    console.log(err)
  }
}

exports.getEditRoom = async (req, res, next) => {
  const editmode = req.query.edit
  const maPhong = req.params.maPhong
  try {
    const editRoom = await Room.getRoom(maPhong)
    const allRooms = await Room.getAllrooms()
    res.render('room/room', {
      pageTitle: 'Edit Room',
      path: '/room',
      allRooms: allRooms,
      editRoom: editRoom[0],
      editing: editmode,
      successMessage: null
    })
  } catch(err) {
    console.log(err)
  }
}

exports.updateRoom = async(req, res, next) => {
  const maPhong = req.body.maPhong
  const tenPhong = req.body.tenPhong
  const dienTich = req.body.dienTich
  const soGiuong = req.body.soGiuong
  const giaThue = req.body.giaThue
  const loaiPhong = req.body.phongNamNu
  
  try {
    await Room.updateRoom(maPhong, tenPhong, dienTich, soGiuong, giaThue, loaiPhong)
    req.flash('success', 'Sửa thông tin phòng thành công')
    res.redirect('/room')
  } catch(err) {
    console.log(err)
  }
}