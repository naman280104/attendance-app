const auth_route = require('express')();


const auth_student_controller = require('../controllers/auth_student_controller');
const auth_middleware = require('../middlewares/auth');


auth_route.post('/login',auth_student_controller.loginUser);
auth_route.post('/logout',auth_middleware.isStudent,auth_student_controller.logoutUser);


module.exports = auth_route;
