const TT_ThuePhong = require('../models/TT_ThuePhong');

exports.getAllPayments = async (req, res) => {
  try {
    const allPayments = await TT_ThuePhong.getAllPayments();
    res.render('payment/payment', {
      pageTitle: 'Tất cả thanh toán',
      allPayments,
      editing: false,
      path: '/payment',
      searchPayment: null,
      successMessage: req.flash('successMessage'),
      errorMessage: req.flash('errorMessage'),
    });
  } catch (error) {
    console.error("Lỗi khi lấy danh sách thanh toán:", error);
    res.status(500).send('Lỗi hệ thống');
  }
};

exports.addPayment = async (req, res) => {
  const {ThangNam, SoTien, NgayThanhToan, MaNhanVien } = req.body;
  try {
    console.log(ThangNam, SoTien, NgayThanhToan, MaNhanVien);
    
    await TT_ThuePhong.addPaymentRecord(ThangNam, SoTien, NgayThanhToan, MaNhanVien);
    req.flash('successMessage', 'Thêm thanh toán thành công!');
    res.redirect('/payment');
  } catch (error) {
    console.error('Lỗi khi thêm thanh toán:', error);
    req.flash('errorMessage', 'Lỗi khi thêm thanh toán');
    res.redirect('/payment');
  }
};

exports.deletePayment = async (req, res) => {
  const { MaHopDong } = req.params;
  try {
    await TT_ThuePhong.deletePaymentRecord(MaHopDong);
    req.flash('successMessage', 'Xóa thanh toán thành công!');
    res.redirect('/payment');
  } catch (error) {
    console.error("Lỗi khi xóa thanh toán:", error);
    req.flash('errorMessage', 'Lỗi khi xóa thanh toán');
    res.redirect('/payment');
  }
};

exports.updatePayment = async (req, res) => {
  const { MDH, ThangNam, SoTien, NgayThanhToan, MaNhanVien } = req.body;
  try {
    await TT_ThuePhong.updatePaymentRecord(MDH, ThangNam, SoTien, NgayThanhToan, MaNhanVien);
    req.flash('successMessage', 'Cập nhật thanh toán thành công!');
    res.redirect('/payment');
  } catch (error) {
    console.error("Lỗi khi cập nhật thanh toán:", error);
    req.flash('errorMessage', 'Lỗi khi cập nhật thanh toán');
    res.redirect('/payment');
  }
};

exports.editPayment = async (req, res) => {
  const editing = req.query.edit === 'true';
  const { MaHopDong } = req.params;
  try {
    const editTT_ThuePhong = await TT_ThuePhong.getPaymentById(MaHopDong);
    if (!editTT_ThuePhong) {
      req.flash('errorMessage', 'Không tìm thấy thông tin thanh toán');
      return res.redirect('/payment');
    }
    
    const allPayments = await TT_ThuePhong.getAllPayments();
    res.render('payment/payment', {
      pageTitle: 'Chỉnh sửa thanh toán',
      allPayments,
      editTT_ThuePhong,
      editing,
      path: '/payment',
      searchPayment: null,
      successMessage: req.flash('successMessage'),
      errorMessage: req.flash('errorMessage'),
    });
  } catch (error) {
    console.error("Lỗi khi chỉnh sửa thanh toán:", error);
    req.flash('errorMessage', 'Lỗi khi chỉnh sửa thanh toán');
    res.redirect('/payment');
  }
};

exports.searchPayment = async (req, res) => {
  const { MaHopDongSearch, MaSoSinhVien } = req.query;
  let allPayments = [];
  let errorMessage = '';
  try {
    if (MaHopDongSearch) {
      allPayments = await TT_ThuePhong.getPaymentsByContractId(MaHopDongSearch);
    } else if (MaSoSinhVien) {
      allPayments = await TT_ThuePhong.getStudentPaymentById(MaSoSinhVien);
    } else {
      errorMessage = 'Vui lòng nhập Mã Hợp Đồng hoặc Mã Số Sinh Viên để tìm kiếm.';
    }
    res.render('payment/payment', {
      pageTitle: 'Payment',
      path: '/payment',
      allPayments: allPayments,
      searchPayment: { MaHopDongSearch, MaSoSinhVien },
      successMessage: '',
      errorMessage: errorMessage,
      editing: false,
    });
    req.flash('successMessage', 'Tìm kiếm thanh toán thành công!');
  } catch (error) {
    console.error("Lỗi khi tìm kiếm thanh toán:", error);
    req.flash('errorMessage', 'Lỗi khi tìm kiếm thanh toán');
    res.redirect('/payment');
  }
};