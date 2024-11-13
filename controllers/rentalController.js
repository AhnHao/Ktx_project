const Rental = require('../models/rentalModel')
const Room = require('../models/roomModel')
const Student = require('../models/studentModel');
const Employees = require('../models/EmployeesModel');
const e = require('express');
// const { search } = require('../routes/rental');

exports.getAllRentals = async (req, res, next) => {
    let successMessage = req.flash('success');
    let errorMessage = req.flash('error');
    const allRentals = await Rental.getAllRentals()
    const allRooms = await Room.getAllrooms()
    const allStudents = await Student.getAllStudents()
    const allEmployees = await Employees.getAllEmployees()
    res.render('rental/rental', {
        pageTitle: 'Rental',
        path: '/rental',
        allRentals: allRentals,
        allRooms: allRooms,
        allStudents: allStudents,
        allEmployees: allEmployees,
        searchMaHopDong: '',
        searchMaSinhVien: '',
        searchMaPhong: '',
        successMessage: successMessage.length > 0 ? successMessage[0] : null,
        errorMessage: errorMessage.length > 0 ? errorMessage[0] : null,
        editing: false
    })
}
exports.addRental = async (req, res, next) => {
    const MaSinhVien = req.body.maSinhVien
    const MaPhong = req.body.maPhong
    const BatDau = req.body.batDau
    const KetThuc = req.body.ketThuc
    const Gia = req.body.gia
    const MaNhanVien = req.body.MaNhanVien
    try {
        await Rental.addRental(MaSinhVien, MaPhong, BatDau, KetThuc, Gia, MaNhanVien)
        req.flash('success', 'Thêm rental thành công!')
        res.redirect('/rental')
    } catch (error) {
        console.error('Lỗi khi thêm rental:', error.sqlMessage)
        req.flash('error', error.sqlMessage)
        res.redirect('/rental')
    }
}
exports.deleteRental = async (req, res, next) => {
    const MaHopDong = req.body.maHopDong
    try {
        await Rental.deleteRental(MaHopDong)
        req.flash('success', 'Xóa rental thành công!')
        res.redirect('/rental')
    } catch (error) {
        console.error('Lỗi khi xóa rental:', error)
        req.flash('error', 'Lỗi khi xóa rental')
        res.redirect('/rental')
    }
}
exports.getEditRental = async (req, res, next) => {
    const MaHopDong = req.params.maHopDong
    const editMode = req.query.edit
    const allRentals = await Rental.getAllRentals()
    const allRooms = await Room.getAllrooms()
    const allStudents = await Student.getAllStudents()
    const getRental = await Rental.getRental(MaHopDong)
    res.render('rental/rental', {
        pageTitle: 'Edit Rental',
        path : '/rental',
        allRentals: allRentals,
        allRooms: allRooms,
        allStudents: allStudents,
        editRental: getRental[0],
        searchMaHopDong: '',
        searchMaSinhVien: '',
        searchMaPhong: '',
        editing: editMode,
        successMessage: null
    })
}
exports.updateRental = async (req, res, next) => {
    const MaHopDong = req.body.maHopDong
    const MaSinhVien = req.body.maSinhVien
    const MaPhong = req.body.maPhong
    const BatDau = req.body.batDau
    const KetThuc = req.body.ketThuc
    const Gia = req.body.gia
    try {
        await Rental.updateRental(MaHopDong, MaSinhVien, MaPhong, BatDau, KetThuc, Gia)
        req.flash('success', 'Cập nhật rental thành công!')
        res.redirect('/rental')
    } catch (error) {
        console.error('Lỗi khi cập nhật rental:', error)
        req.flash('error', 'Lỗi khi cập nhật rental')
        res.redirect('/rental')
    }
}
exports.searchRental = async (req, res, next) => {
    try{
        const searchMaHopDong = req.query.searchMaHopDong || ''
        const searchMaSinhVien = req.query.searchMaSinhVien || ''
        const searchMaPhong = req.query.searchMaPhong || ''
        const allRentals = await Rental.searchRental(searchMaHopDong, searchMaSinhVien, searchMaPhong)
        const allRooms = await Room.getAllrooms()
        const allStudents = await Student.getAllStudents()
        res.render('rental/rental', {
            pageTitle: 'Rental',
            path: '/rental',
            allRentals: allRentals,
            allRooms: allRooms,
            allStudents: allStudents,
            searchMaHopDong: searchMaHopDong,
            searchMaSinhVien: searchMaSinhVien,
            searchMaPhong: searchMaPhong,
            successMessage: null,
            editing: false
        })
    }catch (error) {
        console.error('Lỗi khi tìm kiếm rental:', error)
        req.flash('error', 'Lỗi khi tìm kiếm rental')
        res.redirect('/rental')
    }
}
