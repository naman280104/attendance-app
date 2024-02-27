const auth_route = require('express')();


const auth_teacher_controller = require('../controllers/auth_teacher_controller');
const auth_middleware = require('../middlewares/auth');


auth_route.post('/login',auth_teacher_controller.loginUser);
// auth_route.get('/login',auth_middleware.isTeacher,auth_teacher_controller.getUser);
// auth_route.post('/profile',auth_middleware.isTeacher,auth_teacher_controller.completeProfile);
// auth_route.put('/profile',auth_middleware.isTeacher,auth_teacher_controller.updateProfile);
// auth_route.get('/profile',auth_middleware.isTeacher,auth_teacher_controller.getProfile);
// auth_route.post('/logout',auth_teacher_controller.logoutUser);



module.exports = auth_route;