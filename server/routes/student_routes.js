const student_route = require('express')();


const student_controller = require('../controllers/student_controller');


student_route.get('/get-invites',student_controller.getInvites);
student_route.post('/respond-to-invite',student_controller.respondToInvite);
student_route.get('/get-all-classrooms',student_controller.getAllClassrooms);
student_route.post('/join-classroom-by-code',student_controller.joinClassroomByCode);
student_route.post('/unenroll',student_controller.unenroll);
student_route.get('/get-beacon-identifier',student_controller.getBeaconIdentifier);
student_route.post('/mark-live-attendance',student_controller.markLiveAttendance);
student_route.get('/get-my-attendance',student_controller.getMyAttendance);
student_route.get('/get-quiz',student_controller.getQuiz);
student_route.post('/submit-quiz',student_controller.submitQuiz);

module.exports = student_route;
