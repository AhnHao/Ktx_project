const express = require('express');
const router = express.Router();
const EmployeesController = require('../controllers/employeesController'); 



router.get('/employees', EmployeesController.getAllEmployees); 
router.post('/add-employees', EmployeesController.addEmployee); 
router.post('/delete-employees', EmployeesController.deleteEmployee); 
router.get('/edit-employees/:maNhanVien', EmployeesController.getEditEmployee); 
router.post('/update-employees', EmployeesController.updateEmployee); 

module.exports = router;
