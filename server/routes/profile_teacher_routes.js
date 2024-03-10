const profile_teacher_routes = require('express')();


const profile_teacher_controller = require('../controllers/profile_teacher_controller');


profile_teacher_routes.get('',profile_teacher_controller.getProfile);
profile_teacher_routes.post('/update',profile_teacher_controller.updateProfile);


module.exports = profile_teacher_routes;