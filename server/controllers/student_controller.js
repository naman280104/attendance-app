const Student = require('../models/student_model');
const Teacher = require('../models/teacher_model');
const Classroom = require('../models/classroom_model');
const Lecture = require('../models/lecture_model');
const Attendance = require('../models/attendance_model');

const getAllClassrooms = async (req,res) => {
    
    try{
        const {email} = req.user;
        console.log("in the get all classrooms", email);
        const student = await Student.findOne({email: email});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom_ids = student.classrooms;
        const classrooms = [];
        for(let i=0; i<classroom_ids.length; i++){
            const classroom = await Classroom.findById(classroom_ids[i]);
            if(classroom){
                const teacher = await Teacher.findById(classroom.teacher);
                if(teacher){   
                    classrooms.push({
                        classroom_name: classroom.classroom_name,
                        classroom_teacher: teacher.name,
                        classroom_id: classroom._id
                    });
                }
                else{
                    // teacher not found
                    // decide later
                }
            }
        }
        return res.status(200).json({classrooms: classrooms});
    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
};

const joinClassroomByCode = async (req,res) => {
    try{
        const {classroom_code} = req.body;
        const {email} = req.user;

        const classroom = await Classroom.findOne({classroom_code});

        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student = await Student.findOne({email: email});

        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())

        if(student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student already in classroom'});
        }

        classroom.classroom_students.set(student._id, []);
        await classroom.save();

        student.classrooms.push(classroom._id);
        await student.save();

        console.log('joined classroom successfully');
        return res.status(200).json({message: 'Classroom joined successfully!'});

    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}

const unenroll = async (req,res) => {
    try{
        const {classroom_id} = req.body;
        const {email} = req.user;
        console.log("in the unenroll", classroom_id, email);
        const classroom = await Classroom.findById(classroom_id);

        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student = await Student.findOne({email: email});

        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        console.log(student_ids, student._id);
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        classroom.classroom_students.delete(student._id);
        await classroom.save();

        student.classrooms = student.classrooms.filter(id => id != classroom_id);
        await student.save();
        console.log(student);
        return res.status(200).json({message: 'Unenrolled successfully!'});

    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}

const getMyAttendance = async (req,res) => {
    try{
        const {classroom_id} = req.query;
        const {email} = req.user;
        const student = await Student.findOne({email: email});

        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const classroom = await Classroom.findById(classroom_id);
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        
        return res.status(200).json({myAttendance: myAttendance});

    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}

module.exports = {getAllClassrooms, joinClassroomByCode, unenroll, getMyAttendance};
