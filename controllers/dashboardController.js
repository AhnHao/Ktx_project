const Room = require('../models/roomModel')
const Rental = require('../models/rentalModel')
const Payment = require('../models/paymentModel')
const Utility = require('../models/utilityModel')
exports.getDashboard =  async (req, res, next) => {
    let errorMessage = req.flash('error')
    let successMessage = req.flash('success')
    const totalRooms = await Room.getTotalRoom()
    const totalRentals = await Rental.getTotalRental()
    // Danh thu phòng trọ
    const totalRevenue = await Payment.getTotalRevenue()
    // Doanh thu điện nước
    const totalUtility = await Utility.getTotalUtility()
    const totalRevenueByMonth = await Utility.getUtilityRevenueByMonth()
    res.render('dashboard/dashboard', {
        pageTitle: 'Dashboard',
        path : '/dashboard',
        totalRooms: totalRooms,
        totalRentals: totalRentals,
        totalRevenue: totalRevenue,
        totalUtility: totalUtility,
        totalRevenueByMonth: totalRevenueByMonth,
        errorMessage: errorMessage[0],
        successMessage: successMessage[0]
    })
}
