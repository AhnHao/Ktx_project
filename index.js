const express = require('express')
const session = require('express-session')
const flash = require('connect-flash')
const path = require('path')
const bodyParser = require('body-parser')
const dotenv = require('dotenv')

dotenv.config()

const PORT = process.env.PORT || 8080

const app = express()

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.use(express.static(path.join(__dirname, 'public')))
app.use(
  session({
    secret: 'my secrect',
    resave: false,
    saveUninitialized: true
  })
)
app.use(flash())

app.set('view engine', 'ejs')
app.set('views', 'views')

const authRoutes = require('./routes/auth')
const roomRoutes = require('./routes/room')
const studentRoutes = require('./routes/student')
const employeesRoutes = require('./routes/Employees')
const paymentRoutes = require('./routes/payment')

app.use(authRoutes)
app.use(roomRoutes)
app.use(studentRoutes)
app.use(employeesRoutes)
app.use(paymentRoutes)

app.listen(PORT, () => {
  console.log('App is running on port 8080')
})
