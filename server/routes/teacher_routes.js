const teacher_route = require('express')();


const teacher_controller = require('../controllers/teacher_controller');


teacher_route.get('/get-classrooms',teacher_controller.getTeacherClassrooms);
teacher_route.post('/create-classroom', teacher_controller.createClassroom);
teacher_route.delete('/delete-classroom', teacher_controller.deleteClassroom);
teacher_route.get('/get-classroom-info', teacher_controller.getClassroomInfo);
teacher_route.post('/edit-classroom-name', teacher_controller.editClassroomName);
teacher_route.post('/add-lecture', teacher_controller.addLecture);
// teacher_route.get('/get-classroom-students', teacher_controller.getClassroomStudents);
// teacher_route.get('/get-lecture-attendace', teacher_controller.getLectureAttendance);
// teacher_route.post('/add-attendace-by-email', teacher_controller.addAttendanceByEmail);
// teacher_route.post('/add-student-by-email', teacher_controller.addStudentByEmail);
// teacher_route.get('/get-student-info', teacher_controller.getStudentInfo);
// teacher_route.post('/remove-student', teacher_controller.removeStudent);



module.exports = teacher_route;