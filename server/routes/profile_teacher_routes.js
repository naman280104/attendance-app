const profile_route = require('express')();


const profile_teacher_controller = require('../controllers/profile_teacher_controller');


profile_route.get('',profile_teacher_controller.getProfile);
profile_route.put('/update',profile_teacher_controller.updateProfile);


module.exports = profile_route;