const Class = require('../models/classModel');



exports.getAllClasses = async (req, res, next) => {
    let successMessage = req.flash('success');
    let errorMessage = req.flash('error');
    const allClasses = await Class.getAllClasses()
    res.render('class/class', {
        pageTitle: 'Class',
        path: '/class',
        allClasses: allClasses,
        successMessage: successMessage.length > 0 ? successMessage[0] : null,
        errorMessage: errorMessage.length > 0 ? errorMessage[0] : null,
        searchMaLopQuery: '',
        searchTenLopQuery: '',
        editing: false
    })
}
exports.addClass = async (req, res, next) => {
    const maLop = req.body.maLop
    const tenLop = req.body.tenLop
    try {
      await Class.addClass(maLop,tenLop)
      req.flash('success', 'Thêm phòng thành công!')
      res.redirect('/class')
    } catch(err) {
      console.log(err)
    }
}
exports.getEditClass = async (req, res, next) => {
    const editmode = req.query.edit
    const maLop = req.params.maLop
    try {
      const editClass = await Class.getClass(maLop)
      const allClasses = await Class.getAllClasses()
      res.render('class/class', {
        pageTitle: 'Edit Class',
        path: '/class',
        allClasses: allClasses,
        editClass: editClass[0],
        editing: editmode,
        successMessage: null,
        searchMaLopQuery: '',
        searchTenLopQuery: ''
        })
    }
    catch(err) {
        console.log(err)
    }
}
exports.updateClass = async (req, res, next) => {
    const maLop = req.body.maLop
    const tenLop = req.body.tenLop
    try {
      await Class.updateClass(maLop, tenLop)
      req.flash('success', 'Cập nhật lớp thành công!')
      res.redirect('/class')
    } catch(err) {
      console.log(err)
    }
}
exports.deleteClass = async (req, res, next) => {
    const maLop = req.body.maLop
    try {
      await Class.deleteClass(maLop)
      req.flash('success', 'Xóa lớp thành công!')
      res.redirect('/class')
    } catch(err) {
      req.flash('error', 'Không thể xóa lớp này khi đang có sinhvien!')
      res.redirect('/class')
    }
}
exports.searchClass = async (req, res, next) => {
    try {
        const searchMaLop = req.query.searchMaLop || '';
        const searchTenLop = req.query.searchTenLop || '';
        const searchResults = await Class.searchByClass(searchMaLop, searchTenLop);
        res.render('class/class', {
            pageTitle: 'Search Results',
            path: '/class',
            allClasses: searchResults,
            successMessage: null,
            editing: false,
            searchMaLopQuery: searchMaLop || '',
            searchTenLopQuery: searchTenLop || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Lỗi khi tìm kiếm lớp.');
    }
};

