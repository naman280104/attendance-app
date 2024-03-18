const express = require('express');
require('dotenv').config();


const app = express();
const PORT= process.env.PORT;


app.use(require('cors')());

// for parsing application/json
app.use(express.json());

// for parsing application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: true })); 

const http = require('http').Server(app);

const auth_middleware = require('./middlewares/auth');
const { getRole } = require('./controllers/get_role');
const {connectredis} = require('./services/jwt');

app.use('/auth/verify',getRole);
app.use('/teacher/auth', require('./routes/auth_teacher_routes'));
app.use('/student/auth', require('./routes/auth_student_routes'));
app.use('/teacher/profile',auth_middleware.isTeacher, require('./routes/profile_teacher_routes'));
app.use('/student/profile',auth_middleware.isStudent, require('./routes/profile_student_routes'));
app.use('/teacher',auth_middleware.isTeacher, require('./routes/teacher_routes'));
app.use('/student',auth_middleware.isStudent, require('./routes/student_routes'));

app.listen(PORT, async () => {
    console.log('Server is running on port',PORT);
    require('./services/db');
    await connectredis();
});

app.get('/', (req, res) => {
    console.log('Hello World');
    console.log(req);
    console.log();
    console.log();
    res.json('Hello World');

});
