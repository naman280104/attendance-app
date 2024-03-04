const auth_route = require('express')();


const auth_teacher_controller = require('../controllers/auth_teacher_controller');
const auth_middleware = require('../middlewares/auth');


auth_route.post('/login',auth_teacher_controller.loginUser);
auth_route.post('/logout',auth_middleware.isTeacher,auth_teacher_controller.logoutUser);


module.exports = auth_route;
