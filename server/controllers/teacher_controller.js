const Teacher = require('../models/teacher_model');
const Classroom = require('../models/classroom_model');
const Student = require('../models/student_model');
const Lecture = require('../models/lecture_model');
const Attendance = require('../models/attendance_model');
const Invite = require('../models/invite_model');
const Quiz = require('../models/quiz_model');

const {createUniqueID, createClassroomCode} = require('../services/uuid');

const mongoose = require("mongoose");

const BEACON_ID_LENGTH = 16; //16 hex digits
const LECTURE_CODE_LENGTH = 8; //8 hex digits
const QUIZ_CODE_LENGTH = 8; //8 hex digits

const createClassroom = async (req,res) => {
    const session = await global.mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_name} = req.body;
        if (!classroom_name) {
            return res.status(400).json({message: 'Classroom name is required'});
        }
        let available_classroom_code = null;
        let available_beacon_id = null;
        
        while(1) {
            const classroom_code = createClassroomCode();
            const beacon_id = createUniqueID(BEACON_ID_LENGTH);
            const is_classroom_code_taken = await Classroom.findOne({classroom_code: classroom_code}, null, {session: session});
            const is_beacon_id_taken = await Classroom.findOne({beacon_id: beacon_id}, null, {session: session});
            
            if(is_classroom_code_taken || is_beacon_id_taken){
                continue;
            }
            else{
                available_classroom_code = classroom_code;
                available_beacon_id = beacon_id;
                break;  
            }
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        else{
            const classroom = (await Classroom.create([{
                classroom_code: available_classroom_code,
                classroom_name: classroom_name,
                beacon_id: available_beacon_id,
                teacher: teacher._id,
            }], {session: session}))[0];
            await classroom.save({session: session});
            classroom_created = true;
            teacher.classrooms.push(classroom);
            await teacher.save({session: session});
            await session.commitTransaction();
            return res.status(200).json({message: 'Classroom created successfully'});
        }
    }
    catch(err){
        console.log(err);
        await session.abortTransaction();
        return res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
    
};


const getTeacherClassrooms = async (req,res) => {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        const classroom_ids = teacher.classrooms;
        let classrooms=[];

        for(let i = 0; i < classroom_ids.length; i++){
            const classroom = await Classroom.findById(classroom_ids[i], null, {session: session});
            classrooms.push({
                classroom_name: classroom.classroom_name,
                no_of_students: Array.from(classroom.classroom_students.entries()).length,
                classroom_id: classroom._id,
            });
        };
        await session.commitTransaction();
        res.status(200).json({classrooms: classrooms});
    } catch (error) {
        console.log(error);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const deleteClassroom = async (req,res) => {
    
    const session = await global.mongoose.startSession();
    try {
        session.startTransaction();
        const {classroom_id} = req.body;
        console.log(classroom_id);
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id is required'});
        }
        
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        await Classroom.deleteOne({_id: classroom_id}, {session: session});
        console.log(teacher.classrooms);
        teacher.classrooms.pull(classroom_id); 
        console.log(teacher.classrooms);
        await teacher.save({session: session});
        await session.commitTransaction();
        res.status(200).json({message: 'Classroom deleted successfully'});
    } catch (error) {
        console.log(error);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const getClassroomInfo = async (req,res) => {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
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

        const classroom = await Classroom.findById(classroom_id, null, {session: session});

        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const no_of_students = Array.from(classroom.classroom_students.keys()).length;
        
        const classroom_lectures=[];

        // yet to test
        const one_hr_in_ms = 60 * 60 * 1000;
        for(let i = 0; i < classroom.classroom_lectures.length; i++){
            const lecture = await Lecture.findById(classroom.classroom_lectures[i], null, {session: session});
            const timediff = new Date() - lecture.createdAt;
            if(lecture.is_accepting && (timediff >=  one_hr_in_ms)){
                lecture.is_accepting = false;
                lecture.is_accepting_live = false;
                await lecture.save({session: session}); 
            }
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
        await session.commitTransaction();
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
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const editClassroomName = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id, classroom_name} = req.body;
        if(!classroom_id || !classroom_name){
            return res.status(400).json({message: 'Classroom id and classroom name are required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        } 
        await Classroom.updateOne({_id: classroom_id}, {classroom_name: classroom_name}, {session: session});
        await session.commitTransaction();
        res.status(200).json({message: 'Classroom name updated successfully'});
    }
    catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
};


const addLecture = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id} = req.body;
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id and lecture name are required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        let lecture_code_available = null;
        while(1){
            const lecture_code = createUniqueID(LECTURE_CODE_LENGTH);
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
            
        const lecture = (await Lecture.create([{
            lecture_code: lecture_code_available,
        }], { session: session }))[0];
        await lecture.save({session: session});
        classroom.classroom_lectures.push(lecture);
        await classroom.save({session: session});
        console.log("classroom lecture are is ",classroom.classroom_lectures);
        await session.commitTransaction();
        res.status(200).json({message: 'Lecture added successfully', lecture_id: lecture._id, lecture_code: lecture.lecture_code, lecture_date: lecture.createdAt});
    }
    catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const liveAttendance = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {action, classroom_id, lecture_id} = req.body;
        if(!action || !classroom_id || !lecture_id){
            return res.status(400).json({message: 'Action, classroom id and lecture id are required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        let lecture_found = false;
        classroom.classroom_lectures.forEach((lecture) => {
            if(lecture == lecture_id){
                lecture_found = true;
            }
        });
        if(!lecture_found){
            return res.status(400).json({message: 'Lecture does not belong to classroom'});
        }
        const lecture = await Lecture.findById(lecture_id, null, {session: session});
        if(!lecture){
            return res.status(404).json({message: 'Lecture not found'});
        }
        if(!lecture.is_accepting){
            return res.status(404).json({message: "Lecture not accepting attendance"});
        }

        if(action == 'START'){
            await Lecture.updateOne({_id: lecture_id}, {is_accepting_live: true}, {session: session});
            const beacon_UUID = classroom.beacon_id + createUniqueID(32 - BEACON_ID_LENGTH - LECTURE_CODE_LENGTH) + lecture.lecture_code;
            console.log("beacon_UUID is ",beacon_UUID);
            await session.commitTransaction();
            return res.status(200).json({message: "Lecture started",beacon_UUID : beacon_UUID});
        }
        else if(action == 'STOP'){
            await Lecture.updateOne({_id: lecture_id}, {is_accepting_live: false});
            await session.commitTransaction();
            return res.status(200).json({message: "Lecture stopped",});
        }
        return res.status(500).json({message: "Illegal action"});
    }
    catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally {
        await session.endSession();
    }
}


const getLectureAttendance = async (req,res) => {

    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const {classroom_id, lecture_id} = req.query;
        if(!classroom_id || !lecture_id){
            return res.status(400).json({message: 'Classroom id and lecture id are required'});
        }
        
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
        if(!teacher){
            return res.status(404).json({message: 'Teacher not found'});
        }
        
        let classroom_found = false;
        teacher.classrooms.forEach((classroom) => {
            if(classroom._id.toString() == classroom_id){
                classroom_found = true;
            }
        });

        if(!classroom_found){
            return res.status(400).json({message: 'Classroom does not belong to teacher'});
        }

        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        
        let lecture_found = false;
        classroom.classroom_lectures.forEach((lecture) => {
            if(lecture.toString() == lecture_id){
                lecture_found = true;
            }
        });

        if(!lecture_found){
            return res.status(400).json({message: 'Lecture does not belong to classroom'});
        }
        
        const lecture = await Lecture.findById(lecture_id, null, {session: session});
        if(!lecture){
            return res.status(404).json({message: 'Lecture not found'});
        }
        
        const student_ids = Array.from(classroom.classroom_students.keys());
        
        let lecture_attendance = [];
        for(let i = 0; i < student_ids.length; i++){
            const student_attendance = classroom.classroom_students.get(student_ids[i]);
            for(let j = 0; j < student_attendance.length; j++){
                if(student_attendance[j].lecture_id == lecture_id){
                    const student = await Student.findById(student_ids[i], null, {session: session});
                    lecture_attendance.push({
                        student_name: student.name,
                        student_email: student.email,
                    student_roll_no: student.roll_no,
                    });
                    break; 
                }
            }
            
        }
        await session.commitTransaction();
        return res.status(200).json({lecture_attendance: lecture_attendance, date: lecture.createdAt});
    }
    catch(err){
        console.log(err);
        await session.abortTransaction();
        return res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const getClassroomStudents = async (req,res) => {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const {classroom_id} = req.query;
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id is required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        const student_ids = Array.from(classroom.classroom_students.keys());
        let students = [];
        for(let i = 0; i < student_ids.length; i++){
            const student = await Student.findById(student_ids[i], null, {session: session});
            students.push({
                student_name: student.name,
                student_email: student.email,
                student_roll_no: student.roll_no,
                student_advertisement_id: student.advertisement_id,
            });
        }
        await session.commitTransaction();
        return res.status(200).json({students: students});
    } catch (error) {
        console.log(error);
        await session.abortTransaction();
        return res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const sendInvites = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        let {classroom_id, student_emails} = req.body;
        console.log(student_emails);
        student_emails = JSON.parse(student_emails);
        console.log(student_emails);
        console.log(typeof student_emails);
        if(!classroom_id || !student_emails){
            return res.status(400).json({message: 'Classroom id and student emails are required'});
        }

        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        
        let count_student_not_found = 0;
        let count_already_in_class = 0;
        for(let i = 0; i < student_emails.length; i++){
            const student = await Student.findOne({email: student_emails[i]}, null, {session: session});
            if(!student){
                count_student_not_found++;
                continue;
            }
            const student_id = student._id;
            if(classroom.classroom_students.get(student_id)){
                count_already_in_class++;
                continue;
            }
            const invite_present = await Invite.findOne({classroom_id: classroom_id, student_id: student_id}, null, {session: session});
            if(invite_present){
                continue;
            }
            const invite = (await Invite.create([{
                classroom_id: classroom_id,
                student_id: student_id,
            }]),{ session: session })[0];
            console.log(invite);
            await invite.save({session: session});
        }
        let count_invites_sent = student_emails.length - count_student_not_found - count_already_in_class;
        await session.commitTransaction();
        return res.status(200).json({message: 'Invites sent successfully', count_student_not_found: count_student_not_found, count_already_in_class: count_already_in_class, count_invites_sent: count_invites_sent});
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const addAttendanceByEmail = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id, student_email, lecture_id} = req.body;
        console.log(classroom_id, student_email, lecture_id);
        if(!classroom_id || !student_email || !lecture_id){
            return res.status(400).json({message: 'Classroom id, student email and lecture id are required'});
        }

        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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

        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const lecture = await Lecture.findById(lecture_id, null, {session: session});
        if(!lecture){
            return res.status(404).json({message: 'Lecture not found'});
        }

        let lecture_in_classroom = false;
        classroom.classroom_lectures.forEach((lecture) => {
            if(lecture == lecture_id){
                lecture_in_classroom = true;
            }
        });

        if(!lecture_in_classroom){
            return res.status(400).json({message: 'Lecture does not belong to classroom'});
        }

        const student = await Student.findOne({email: student_email}, null, {session: session});

        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }


        const attendance_present = await Attendance.findOne({student_id: student._id, lecture_id: lecture_id}, null, {session: session});
        console.log(attendance_present);
        if(attendance_present){
            return res.status(400).json({message: 'Attendance already marked'});
        }

        const attendance = (await Attendance.create([{
            advertisement_id: 'MARKED_MANUALLY',
            student_id: student._id,
            lecture_id: lecture._id,
            marked_manually: true,
        }],{session: session}))[0];
        await attendance.save({session: session});

        lecture.attendance_count++;
        await lecture.save({session: session});
        
        const updatedClassroom = await Classroom.findOneAndUpdate(
            { _id: classroom._id, [`classroom_students.${student._id}`] : { $exists: true } },
            { $push: { [`classroom_students.${student._id}`]: {attendance_id: attendance._id, lecture_id: lecture._id} } },
            {session: session}
        );
        console.log(updatedClassroom);
        await session.commitTransaction();
        return res.status(200).json({message: 'Attendance marked successfully'});
        
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const removeStudent = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id, student_email} = req.body;
        console.log(classroom_id, student_email);    
        if(!classroom_id || !student_email){
            return res.status(400).json({message: 'Classroom id and student email are required'});
        }

        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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

        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student = await Student.findOne({email: student_email}, null, {session: session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const student_id = student._id;
        const student_in_classroom = classroom.classroom_students.get(student_id);
        if(!student_in_classroom){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        classroom.classroom_students.delete(student._id);
        await classroom.save({session: session});
        student.classrooms = student.classrooms.filter(id => id != classroom_id);
        await student.save({session: session});
        console.log(student);
        await session.commitTransaction();
        return res.status(200).json({message: 'Student removed successfully'});
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const getAttendanceReport = async (req, res) => {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const { classroom_id } = req.query;

        if (!classroom_id) {
        return res.status(400).json({ message: "Classroom id is required" });
        }

        const teacher = await Teacher.findOne({ email: req.user.email }, null, { session: session });
        if (!teacher) {
        return res.status(404).json({ message: "Teacher not found" });
        }

        let classroom_found = false;
        teacher.classrooms.forEach((classroom) => {
        if (classroom._id == classroom_id) {
            classroom_found = true;
        }
        });

        if (!classroom_found) {
        return res.status(400).json({ message: "Classroom does not belong to teacher" });
        }

        const classroom = await Classroom.findById(classroom_id, null, { session: session });
        if (!classroom) {
        return res.status(404).json({ message: "Classroom not found" });
        }

        const student_ids = Array.from(classroom.classroom_students.keys());

        let attendance_report = {};

        const all_lectures = classroom.classroom_lectures;

        for (let i = 0; i < student_ids.length; i++) {
        const student_attendance = classroom.classroom_students.get(student_ids[i]);

        let student_attendance_for_all_lectures = Array.from(
            { length: all_lectures.length },
            () => false
        );

        for (let j = 0; j < all_lectures.length; j++) {
            for (let k = 0; k < student_attendance.length; k++) {
            if (student_attendance[k].lecture_id.toString() ==all_lectures[j].toString()) {
                student_attendance_for_all_lectures[j] = true;
                break;
            }
            }
        }

        const student = await Student.findById(student_ids[i], null, { session: session });
        attendance_report[student.email] = {
            name: student.name,
            roll_no: student.roll_no,
            attendance: student_attendance_for_all_lectures,
        };
        }

        console.log(attendance_report);
        await session.commitTransaction();
        return res.status(200).json({ attendance_report: attendance_report });
    } catch (err) {
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({ message: "Internal server error" });
    }
    finally {
        await session.endSession();
    }
};


const addQuiz = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        console.log(req);

        const {classroom_id, quiz_name, no_of_questions} = req.body;
        const quiz_file = req.file;
        if(!classroom_id || !quiz_file || !quiz_name || !no_of_questions){
            return res.status(400).json({message: 'Classroom id, quiz_file, no_of_questions and quiz_name  are required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        let quiz_code_available = null;
        while(1){
            const quiz_code = createUniqueID(QUIZ_CODE_LENGTH);
            const is_quiz_code_taken = false;
            classroom.classroom_quizzes.forEach((quiz) => {
                if(quiz.quiz_code == quiz_code){
                    is_quiz_code_taken = true;
                }
            });
            console.log("yes");
            if(!is_quiz_code_taken){
                quiz_code_available = quiz_code;
                break;
            }
        }
        console.log("quiz_code_available is ",quiz_code_available);
        console.log(parseInt(no_of_questions));
        const quiz = (await Quiz.create([{
            quiz_code: quiz_code_available,
            file_name: quiz_file.filename,
            file_id: quiz_file.id,
            no_of_questions: parseInt(no_of_questions),
            quiz_name: quiz_name
        }], {session: session}))[0];
        await quiz.save({session: session});
        classroom.classroom_quizzes.push(quiz);
        console.log("classroom is ",classroom.classroom_quizzes);
        await classroom.save({session: session});
        await session.commitTransaction();
        res.status(200).json({message: 'quiz added successfully', quiz_id: quiz._id, quiz_code: quiz.quiz_code, quiz_date: quiz.createdAt});
    }
    catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const removeQuiz = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        
        // const mongoose = global.mongoose;
        session.startTransaction();

        const {classroom_id, quiz_id} = req.body;
        console.log(classroom_id, quiz_id);
        if(!classroom_id || !quiz_id){
            return res.status(400).json({message: 'Classroom id and quiz id are required'});
        }

        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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

        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const quiz = await Quiz.findById(quiz_id, null, {session: session});
        if(!quiz){
            return res.status(404).json({message: 'Quiz not found'});
        }

        const quiz_in_classroom = classroom.classroom_quizzes.find((quiz) => quiz._id.toString() == quiz_id);
        if(!quiz_in_classroom){
            return res.status(400).json({message: 'Quiz not in classroom'});
        }

        classroom.classroom_quizzes = classroom.classroom_quizzes.filter((quiz) => quiz._id != quiz_id);
        const conn = mongoose.connection; // Get the Mongoose connection object
        const gfs = new mongoose.mongo.GridFSBucket(conn.db, { bucketName: "uploads" }); // Initialize GridFS stream
        const mongoid = new mongoose.Types.ObjectId(quiz.file_id);
        await gfs.delete(mongoid);
        await classroom.save({session: session});
        await Quiz.deleteOne({_id: quiz_id}, {session: session});
        await session.commitTransaction();
        return res.status(200).json({message: 'Quiz removed successfully'});
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }

}


const changeQuizState = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id, quiz_id, action} = req.body;
        console.log(classroom_id, quiz_id);
        if(!classroom_id || !quiz_id){
            return res.status(400).json({message: 'Classroom id and quiz id are required'});
        }

        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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

        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const quiz = await Quiz.findById(quiz_id, null, {session: session});
        if(!quiz){
            return res.status(404).json({message: 'Quiz not found'});
        }

        const quiz_in_classroom = classroom.classroom_quizzes.find((quiz) => quiz._id.toString() == quiz_id);
        if(!quiz_in_classroom){
            return res.status(400).json({message: 'Quiz not in classroom'});
        }

        if(action == 'START'){
            await Quiz.updateOne({_id: quiz_id}, {is_accepting: true}, {session: session});
            await session.commitTransaction();
            return res.status(200).json({message: 'Quiz started successfully'});
        }
        else if(action == 'STOP'){
            await Quiz.updateOne({_id: quiz_id}, {is_accepting: false}, {session: session});
            await session.commitTransaction();
            return res.status(200).json({message: 'Quiz stopped successfully'});
        }
        else{
            await session.abortTransaction();
            return res.status(400).json({message: 'Illegal action'});
        }
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const getAllQuizzes = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id} = req.query;
        if(!classroom_id){
            return res.status(400).json({message: 'Classroom id is required'});
        }

        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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

        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        let quizzes = [];
        for(let i = 0; i < classroom.classroom_quizzes.length; i++){
            const quiz = await Quiz.findById(classroom.classroom_quizzes[i], null, {session: session});
            const beacon_UUID = classroom.beacon_id + createUniqueID(32 - BEACON_ID_LENGTH - QUIZ_CODE_LENGTH) + quiz.quiz_code;
            quizzes.push({
                quiz_id: quiz._id,
                quiz_name: quiz.quiz_name,
                file_name: quiz.file_name,
                file_id: quiz.file_id,
                quiz_code: quiz.quiz_code,
                quiz_date: quiz.createdAt,
                is_accepting: quiz.is_accepting,
                beacon_UUID: beacon_UUID,
                no_of_questions: quiz.no_of_questions,
            });
        }
        console.log(quizzes);
        await session.commitTransaction();
        return res.status(200).json({quizzes: quizzes});
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const getQuizResponses = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id,quiz_id} = req.query;
        if(!classroom_id || !quiz_id){
            return res.status(400).json({message: 'Quiz id and classroom Id is required'});
        }
        const teacher = await Teacher.findOne({email: req.user.email}, null, {session: session});
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
        const classroom = await Classroom.findById(classroom_id, null, {session: session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }
        // check  if quiz_id is in classroom_found.classroom_quizzes
        let quiz_found = false;
        classroom.classroom_quizzes.forEach((quiz) => {
            if(quiz == quiz_id){
                quiz_found = true;
            }
        });
        if(!quiz_found){
            return res.status(400).json({message: 'Quiz does not belong to classroom'});
        }
        const quiz = await Quiz.findById(quiz_id, null, {session: session});
        if(!quiz){
            return res.status(404).json({message: 'Quiz not found'});
        }

        const student_ids = Array.from(quiz.student_responses.keys());

        let response_report = {};

        for(let i=0; i<student_ids.length; i++){
            const student = await Student.findById(student_ids[i], null, {session: session});
            response_report[student.email] = {
                name: student.name,
                roll_no: student.roll_no,
                response: quiz.student_responses.get(student_ids[i]),
            };
        }
    

        console.log(response_report);
        await session.commitTransaction();
        return res.status(200).json({ quiz_responses: response_report, no_of_questions: quiz.no_of_questions });
        
    } catch(err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


module.exports = {
    createClassroom,
    getTeacherClassrooms,
    deleteClassroom,
    getClassroomInfo,
    editClassroomName,
    addLecture,
    liveAttendance,
    getLectureAttendance,
    getClassroomStudents,
    sendInvites,
    addAttendanceByEmail,
    removeStudent,
    getAttendanceReport,
    addQuiz,
    removeQuiz,
    changeQuizState,
    getAllQuizzes,
    getQuizResponses
};
