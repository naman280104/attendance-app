const student_route = require('express')();


const student_controller = require('../controllers/student_controller');


student_route.get('/get-all-classrooms',student_controller.getAllClassrooms);
student_route.post('/join-classroom-by-code',student_controller.joinClassroomByCode);
student_route.post('/unenroll',student_controller.unenroll);
// student_route.get('/get-my-attendance',student_controller.getMyAttendance);
// student_route.get('/mark-attendance',student_controller.getstudentClassrooms);

module.exports = student_route;
