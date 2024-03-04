const profile_route = require('express')();


const profile_student_controller = require('../controllers/profile_student_controller');


profile_route.get('',profile_student_controller.getProfile);
profile_route.put('/update',profile_student_controller.updateProfile);


module.exports = profile_route;