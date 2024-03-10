const profile_student_routes = require('express')();


const profile_student_controller = require('../controllers/profile_student_controller');


profile_student_routes.get('',profile_student_controller.getProfile);
profile_student_routes.post('/update',profile_student_controller.updateProfile);


module.exports = profile_student_routes;