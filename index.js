const express = require('express');
const app = express();
const session = require('express-session');
const flash = require('connect-flash');
const path = require('path');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');

dotenv.config();

const PORT = process.env.PORT || 8080;

// Body parser middleware
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use(
  session({
    secret: 'your-secret-key',
    resave: false,
    saveUninitialized: true,
  })
);
app.use(flash());

app.set('view engine', 'ejs')
app.set('views', 'views')
const classRoute = require('./routes/class')
const authRoutes = require('./routes/auth')
const roomRoutes = require('./routes/room')
const studentRoutes = require('./routes/student')
const employeesRoutes = require('./routes/Employees')
const paymentRoutes = require('./routes/payment')
const rentalRoutes = require('./routes/rental')
const authstudentRoutes = require('./routes/authstudent')
const utilityRoutes = require('./routes/utility')
const dashboardRoutes = require('./routes/dashboard')

app.use(classRoute)
app.use(authRoutes)
app.use(roomRoutes)
app.use(studentRoutes)
app.use(employeesRoutes)
app.use(paymentRoutes)
app.use(rentalRoutes)
app.use(authstudentRoutes)
app.use(utilityRoutes)
app.use(dashboardRoutes)

app.listen(PORT, () => {
  console.log('App is running on port 8080');
});
