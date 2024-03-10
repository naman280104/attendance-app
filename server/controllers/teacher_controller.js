const Teacher = require('../models/teacher_model');
const Classroom = require('../models/classroom_model');
const Lecture = require('../models/lecture_model');
const {createUniqueID, createClassroomCode} = require('../services/uuid');


const beacon_id_length = 16; //16 hex digits

const createClassroom = async (req,res) => {
    // need to apply transactionssssssssss
    
    try{
        const {classroom_name} = req.body;
        if (!classroom_name) {
            return res.status(400).json({message: 'Classroom name is required'});
        }
        let available_classroom_code = null;
        let available_beacon_id = null;

        while(1) {
            const classroom_code = createClassroomCode();
            const beacon_id = createUniqueID(beacon_id_length);
            const is_classroom_code_taken = await Classroom.findOne({classroom_code: classroom_code});
            const is_beacon_id_taken = await Classroom.findOne({beacon_id: beacon_id});
            
            if(is_classroom_code_taken || is_beacon_id_taken){
                continue;
            }
            else{
                available_classroom_code = classroom_code;
                available_beacon_id = beacon_id;
                break;  
            }
        }
        const teacher = await Teacher.findOne({email: req.user.email});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        else{
            const classroom = await Classroom.create({
                classroom_code: available_classroom_code,
                classroom_name: classroom_name,
                beacon_id: available_beacon_id,
            });
            await classroom.save();
            console.log(classroom);
            classroom_created = true;
            teacher.classrooms.push(classroom);
            await teacher.save();
            res.status(200).json({message: 'Classroom created successfully'});
        }
    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
};


const getTeacherClassrooms = async (req,res) => {
    try {
        const teacher = await Teacher.findOne({email: req.user.email});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        const classroom_ids = teacher.classrooms;
        let classrooms=[];

        for(let i = 0; i < classroom_ids.length; i++){

            const classroom = await Classroom.findOne({_id: classroom_ids[i]});
            classrooms.push({
                classroom_name: classroom.classroom_name,
                no_of_students: Array.from(classroom.classroom_students.entries()).length,
                classroom_id: classroom._id,
            });
        };
        res.status(200).json({classrooms: classrooms});
    } catch (error) {
        console.log(error);
        res.status(500).json({message: 'Internal server error'});
    }
}


const deleteClassroom = async (req,res) => {
    try {
        const {classroom_id} = req.body;
        console.log(classroom_id);
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id is required'});
        }
        
        const teacher = await Teacher.findOne({email: req.user.email});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        
        let classroom_found = false;
        teacher.classrooms.forEach((classroom) => {
            if(classroom._id == classroom_id){
                classroom_found = true;
            }
        });
        console.log("classroom_found is ",classroom_found);

        if(!classroom_found){
            return res.status(400).json({message: 'Classroom does not belong to teacher'});
        }
        
        const classroom = await Classroom.findOne({_id: classroom_id});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        
        await Classroom.deleteOne({_id: classroom_id});
        await teacher.classrooms.pull(classroom_id); 
        await teacher.save();
        res.status(200).json({message: 'Classroom deleted successfully'});
    } catch (error) {
        console.log(error);
        res.status(500).json({message: 'Internal server error'});
    }
}


const getClassroomInfo = async (req,res) => {
    try {
        const {classroom_id} = req.query;
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id is required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        let classroom_found = false;
        teacher.classrooms.forEach((classroom) => {
            if(classroom._id == classroom_id){
                classroom_found = true;
            }
        });
        if(!classroom_found){
            return res.status(400).json({message: 'Classroom does not belong to teacher'});
        }

        const classroom = await Classroom.findOne({_id: classroom_id});

        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const no_of_students = Array.from(classroom.classroom_students.keys()).length;
        
        const classroom_lectures=[];

        // yet to test
        for(let i = 0; i < classroom.classroom_lectures.length; i++){
            const lecture = await Lecture.findOne({_id: classroom.classroom_lectures[i]});
            const lecture_to_push =  {
                lecture_id: lecture._id,
                lecture_attendance_count: lecture.attendance_count,
                lecture_code: lecture.lecture_code,
                lecture_is_accepting: lecture.is_accepting,
                lecture_date: lecture.createdAt,
            }
            classroom_lectures.push(lecture_to_push);
        }
        
        console.log("classroom_lectures are ",classroom_lectures);

        res
          .status(200)
          .json({
            classroom_name: classroom.classroom_name,
            classroom_code: classroom.classroom_code,
            beacon_id: classroom.beacon_id,
            no_of_students: no_of_students,
            classroom_lectures: classroom_lectures,
          });

    } catch (error) {
        console.log(error);
        res.status(500).json({message: 'Internal server error'});
    }
}


const editClassroomName = async (req,res) => {
    try{
        const {classroom_id, classroom_name} = req.body;
        if(!classroom_id || !classroom_name){
            return res.status(400).json({message: 'Classroom id and classroom name are required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        let classroom_found = false;
        teacher.classrooms.forEach((classroom) => {
            if(classroom._id == classroom_id){
                classroom_found = true;
            }
        });
        if(!classroom_found){
            return res.status(400).json({message: 'Classroom does not belong to teacher'});
        }
        const classroom = await Classroom.findOne({_id: classroom_id});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        } 
        await Classroom.updateOne({_id: classroom_id}, {classroom_name: classroom_name});
        res.status(200).json({message: 'Classroom name updated successfully'});
    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
};


const addLecture = async (req,res) => {
    try{
        const {classroom_id} = req.body;
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id and lecture name are required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        let classroom_found = false;
        teacher.classrooms.forEach((classroom) => {
            if(classroom._id == classroom_id){
                classroom_found = true;
            }
        });
        console.log("classroom_found is ",classroom_found);
        if(!classroom_found){
            return res.status(400).json({message: 'Classroom does not belong to teacher'});
        }
        const classroom = await Classroom.findOne({_id: classroom_id});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        let lecture_code_available = null;
        while(1){
            const lecture_code = createUniqueID(8);
            const is_lecture_code_taken = false;
            classroom.classroom_lectures.forEach((lecture) => {
                if(lecture.lecture_code == lecture_code){
                    is_lecture_code_taken = true;
                }
            });
            console.log("yes");
            if(!is_lecture_code_taken){
                lecture_code_available = lecture_code;
                break;
            }
        }
        console.log("lecture_code_available is ",lecture_code_available);
            

        const lecture = await Lecture.create({
            lecture_code: lecture_code_available,
        });
        await lecture.save();
        classroom.classroom_lectures.push(lecture);
        await classroom.save();
        res.status(200).json({message: 'Lecture added successfully', lecture_id: lecture._id, lecture_code: lecture.lecture_code, lecture_date: lecture.createdAt});
    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


module.exports = {createClassroom, getTeacherClassrooms, deleteClassroom, getClassroomInfo, editClassroomName, addLecture};