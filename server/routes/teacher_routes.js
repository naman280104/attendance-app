const teacher_route = require('express')();


const teacher_controller = require('../controllers/teacher_controller');

const multer = require('multer');
const {GridFsStorage} = require('multer-gridfs-storage');
const { MONGODB_URI } = process.env;

const storage = new GridFsStorage({
    url: MONGODB_URI,
    options: { useNewUrlParser: true, useUnifiedTopology: true },
    file: (req, file) => {
      return {
        filename: file.originalname,
        bucketName: 'uploads' // Specify the bucket name
      };
    }
  });
const upload = multer({ storage });

teacher_route.get('/get-classrooms', teacher_controller.getTeacherClassrooms);
teacher_route.post('/create-classroom', teacher_controller.createClassroom);
teacher_route.delete('/delete-classroom', teacher_controller.deleteClassroom);
teacher_route.get('/get-classroom-info', teacher_controller.getClassroomInfo);
teacher_route.post('/edit-classroom-name', teacher_controller.editClassroomName);
teacher_route.post('/add-lecture', teacher_controller.addLecture);
teacher_route.post('/live-attendance', teacher_controller.liveAttendance);
teacher_route.get('/get-lecture-attendance', teacher_controller.getLectureAttendance);
teacher_route.get('/get-classroom-students', teacher_controller.getClassroomStudents);
teacher_route.post('/send-invites',teacher_controller.sendInvites);
teacher_route.post('/add-attendance-by-email', teacher_controller.addAttendanceByEmail);
teacher_route.post('/remove-student', teacher_controller.removeStudent);
teacher_route.get('/get-attendance-report', teacher_controller.getAttendanceReport);
teacher_route.post('/add-quiz', upload.single("file"), teacher_controller.addQuiz);
teacher_route.get('/get-all-quizzes', teacher_controller.getAllQuizzes);
teacher_route.post('/remove-quiz', teacher_controller.removeQuiz);
teacher_route.post('/change-quiz-state', teacher_controller.changeQuizState);
teacher_route.get('/get-quiz-responses', teacher_controller.getQuizResponses);


module.exports = teacher_route;