const Student = require('../models/student_model');
const Teacher = require('../models/teacher_model');
const Classroom = require('../models/classroom_model');
const Lecture = require('../models/lecture_model');
const Attendance = require('../models/attendance_model');
const Invite = require('../models/invite_model');
const Quiz = require('../models/quiz_model');


const mongoose = require("mongoose");


const BEACON_ID_LENGTH = 16; //16 hex digits
const LECTURE_CODE_LENGTH = 8; //8 hex digits
const QUIZ_CODE_LENGTH = 8; //8 hex digits

const getAllClassrooms = async (req,res) => {
    try{
        const {email} = req.user;
        console.log("in the get all classrooms", email);
        const session = await mongoose.startSession();
        session.startTransaction();
        const student = await Student.findOne({email: email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom_ids = student.classrooms;
        const classrooms = [];
        for(let i=0; i<classroom_ids.length; i++){
            const classroom = await Classroom.findById(classroom_ids[i], null, {session});
            if(classroom){
                const teacher = await Teacher.findById(classroom.teacher, null, {session});
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
    const session = await mongoose.startSession();
    try{
        const {classroom_code} = req.body;
        const {email} = req.user;
        session.startTransaction();
        const classroom = await Classroom.findOne({classroom_code}, null, {session});

        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student = await Student.findOne({email: email}, null, {session});

        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())

        if(student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student already in classroom'});
        }

        classroom.classroom_students.set(student._id, []);
        await classroom.save({session});

        student.classrooms.push(classroom._id);
        await student.save({session});

        console.log('joined classroom successfully');
        await session.commitTransaction();
        return res.status(200).json({message: 'Classroom joined successfully!'});
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


const unenroll = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        const {classroom_id} = req.body;
        const {email} = req.user;
        console.log("in the unenroll", classroom_id, email);
        session.startTransaction();
        const classroom = await Classroom.findById(classroom_id, null, {session});

        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student = await Student.findOne({email: email}, null, {session});

        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        console.log(student_ids, student._id);
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        classroom.classroom_students.delete(student._id);
        await classroom.save({session});

        student.classrooms = student.classrooms.filter(id => id != classroom_id);
        await student.save({session});
        console.log(student);
        await session.commitTransaction();
        return res.status(200).json({message: 'Unenrolled successfully!'});

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



const getBeaconIdentifier = async (req, res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id} = req.query;
        const student = await Student.findOne({email: req.user.email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom = await Classroom.findById(classroom_id, null, {session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }
        await session.commitTransaction();
        return res.status(200).json({beacon_id: classroom.beacon_id});
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


const markLiveAttendance = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        const {classroom_id, beacon_UUID, advertisement_id} = req.body;
        session.startTransaction();
        console.log(classroom_id, beacon_UUID, advertisement_id);
        if(!classroom_id || !beacon_UUID || !advertisement_id){
            return res.status(400).json({message: 'classroom id, adv id and beacon uuid are required'});
        }
        const student = await Student.findOne({email: req.user.email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom = await Classroom.findById(classroom_id, null, {session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        // console.log(student_ids, student._id);
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        const un_formatted_UUID = beacon_UUID.replace(/-/g, '');
        const received_lecture_code = un_formatted_UUID.slice(-1 * LECTURE_CODE_LENGTH);
        const received_classroom_beacon_id = un_formatted_UUID.slice(0,BEACON_ID_LENGTH);
        
        // console.log(received_classroom_beacon_id.length ,classroom.beacon_id.length);
        // console.log(received_classroom_beacon_id == classroom.beacon_id);

        if(received_classroom_beacon_id != classroom.beacon_id){
            // console.log("not equal")
            return res.status(400).json({message: 'Wrong Beacon UUID'});
        }

        let lecture_found = false;
        console.log(received_lecture_code)

        for(let i=0; i<classroom.classroom_lectures.length; i++){
            const lecture = await Lecture.findById(classroom.classroom_lectures[i], null, {session});
            console.log(i, lecture.lecture_code)
            if(lecture.lecture_code == received_lecture_code){
                lecture_found = true;
                if(!(lecture.is_accepting_live & lecture.is_accepting)){
                    return res.status(400).json({message: 'Lecture not accepting attendance'});
                }
                
                const student_attendance = classroom.classroom_students.get(student._id);
                for(let j=0; j<student_attendance.length; j++){
                    const attendance = await Attendance.findById(student_attendance[j]["attendance_id"], null, {session});
                    if(attendance.lecture_id.toString() == lecture._id.toString()){
                        console.log("alreadyyyyyyyyyyyyyyyyy")
                        return res.status(400).json({message: 'Attendance already marked'});
                    }
                }

                const attendance = (await Attendance.create([{
                    advertisement_id: advertisement_id,
                    student_id: student._id,
                    lecture_id: lecture._id,
                }], {session: session}))[0];

                await attendance.save({session: session});

                lecture.attendance_count++;
                await lecture.save({session: session});
                
                const updatedClassroom = await Classroom.findOneAndUpdate(
                    { _id: classroom._id, [`classroom_students.${student._id}`] : { $exists: true } },
                    { $push: { [`classroom_students.${student._id}`]: {attendance_id: attendance._id, lecture_id: lecture._id} } },
                    { session: session }
                );

                console.log(updatedClassroom);
                await session.commitTransaction();
                return res.status(200).json({message: 'Attendance marked successfully'});
            }
        }
        
        if(!lecture_found){
            await session.abortTransaction();
            return res.status(400).json({message: 'Wrong Beacon UUID'});
        }
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


const getMyAttendance = async (req,res) => {
    const session = await mongoose.startSession();
    const {classroom_id} = req.query;
    try{
        session.startTransaction();
        const student = await Student.findOne({email: req.user.email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const classroom = await Classroom.findById(classroom_id, null, {session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys());
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }
        console.log(classroom.classroom_students);
        console.log(classroom.classroom_lectures);
        const student_attendance = classroom.classroom_students.get(student._id);
        const classroom_lectures = classroom.classroom_lectures;
        const attendance_of_student = [];

        for(let i=0; i<classroom_lectures.length; i++){
            let is_present = false;
            const lecture = await Lecture.findById(classroom_lectures[i].toString(), null, {session});

            for(let j=0; j<student_attendance.length; j++){
                if(classroom_lectures[i].toString()==student_attendance[j]["lecture_id"]) {
                    is_present = true;
                    break;
                }
            }
            attendance_of_student.push({
                date: lecture.createdAt,
                is_present: is_present,
            });
        }
        await session.commitTransaction();
        return res.status(200).json({attendance: attendance_of_student});
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


const getInvites = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {email} = req.user;
        const student = await Student.findOne({email: email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const invites_data = await Invite.find({student_id: student._id}, null, {session}); 
        const invites=[];
        for(let i=0; i<invites_data.length; i++){
            const invite = invites_data[i];
            const classroom = await Classroom.findById(invite.classroom_id, null, {session});
            if(!classroom){
                await Invite.findByIdAndDelete(invite._id, {session});
                continue;
            }
            const teacher = await Teacher.findById(classroom.teacher, null, {session});
            if(!teacher){
                continue;
            }
            invites.push({
                invite_id: invite._id,
                classroom_name: classroom.classroom_name,
                classroom_teacher: teacher.name,
            });
        }
        await session.commitTransaction();
        return res.status(200).json({invites: invites});
    } catch (err){
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const respondToInvite = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {invite_id, student_response} = req.body;
        if(!invite_id || !student_response){
            return res.status(400).json({message: 'invite_id and student_response are required'});
        }

        const {email} = req.user;
        const student = await Student.findOne({email: email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const invite = await Invite.findById(invite_id, null, {session});
        if(!invite){
            return res.status(404).json({message: 'Invite not found'});
        }
        
        if(student_response == 'ACCEPT'){
            const classroom_id = invite.classroom_id;
            const classroom = await Classroom.findById(classroom_id, null, {session});
            if(!classroom){
                await Invite.findByIdAndDelete(invite_id, {session});
                return res.status(404).json({message: 'Classroom not found'});
            }
            
            const student_ids = Array.from(classroom.classroom_students.keys());
            if(student_ids.includes(student._id.toString())){
                await Invite.findByIdAndDelete(invite_id, {session});
                return res.status(400).json({message: 'Student already in classroom'});
            }


            classroom.classroom_students.set(student._id, []);
            await classroom.save({session: session});
            student.classrooms.push(classroom._id);
            await student.save({session: session});

            await Invite.findByIdAndDelete(invite_id, {session});
            await session.commitTransaction();
            return res.status(200).json({message: 'Invite accepted successfully!'});
        }
        else if(student_response == 'DECLINE'){
            await Invite.findByIdAndDelete(invite_id, {session});
            await session.commitTransaction();
            return res.status(200).json({message: 'Invite declined successfully!'});
        }
        else{
            await session.abortTransaction();
            return res.status(400).json({message: 'Invalid response'});
        }



    } catch(err) {
        console.log(err);
        await session.abortTransaction();
        res.status(500).json({message: 'Internal server error'});
    }
    finally{
        await session.endSession();
    }
}


const getQuiz = async (req,res) => {
    try{
        const {classroom_id, beacon_UUID, advertisement_id} = req.query;
        console.log(classroom_id, beacon_UUID, advertisement_id);
        if(!classroom_id || !beacon_UUID || !advertisement_id){
            return res.status(400).json({message: 'classroom id, adv id and beacon uuid are required'});
        }
        const student = await Student.findOne({email: req.user.email});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom = await Classroom.findById(classroom_id);
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        // console.log(student_ids, student._id);
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        const un_formatted_UUID = beacon_UUID.replace(/-/g, '');
        const received_quiz_code = un_formatted_UUID.slice(-1 * QUIZ_CODE_LENGTH);
        const received_classroom_beacon_id = un_formatted_UUID.slice(0,BEACON_ID_LENGTH);
        
        // console.log(received_classroom_beacon_id.length ,classroom.beacon_id.length);
        // console.log(received_classroom_beacon_id == classroom.beacon_id);

        if(received_classroom_beacon_id != classroom.beacon_id){
            // console.log("not equal")
            return res.status(400).json({message: 'Wrong Beacon UUID'});
        }

        let quiz_found = false;
        console.log(received_quiz_code);

        for(let i=0; i<classroom.classroom_quizzes.length; i++){
            const quiz = await Quiz.findById(classroom.classroom_quizzes[i]);
            console.log(i, quiz.quiz_code);
            if(quiz.quiz_code == received_quiz_code){
                quiz_found = true;
                if(!(quiz.is_accepting)){
                    return res.status(400).json({message: 'Quiz not accepting responses'});
                }
                
                const mongoose = global.mongoose;
                const conn = mongoose.connection; // Get the Mongoose connection object
                const gfs = new mongoose.mongo.GridFSBucket(conn.db, { bucketName: "uploads" }); // Initialize GridFS stream
                const mongoid = new mongoose.Types.ObjectId(quiz.file_id);
                const downloadStream = gfs.openDownloadStream(mongoid);
                let fileBuffer = Buffer.alloc(0);

                downloadStream.on('data', (chunk) => {
                    fileBuffer = Buffer.concat([fileBuffer, chunk]);
                });

                downloadStream.on('error', (err) => {
                    console.error('Error downloading file:', err);
                    return res.status(500).json({ error: 'Internal server error' });
                });

                downloadStream.on('end', () => {
                    const data = Array.from(fileBuffer); // Convert buffer to array of bytes
                    res.status(200).json({ data: data, no_of_questions: quiz.no_of_questions}); // Send byte array as response
                    delete data;
                });
                delete fileBuffer;
                return;
            }
        }
        
        if(!quiz_found){
            return res.status(400).json({message: 'Wrong Beacon UUID'});
        }

    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


const submitQuiz = async (req,res) => {
    const session = await mongoose.startSession();
    try{
        session.startTransaction();
        const {classroom_id, beacon_UUID} = req.body;
        let student_response = JSON.parse(req.body.student_response);
        console.log(classroom_id, beacon_UUID, student_response);
        if(!classroom_id || !beacon_UUID || !student_response){
            return res.status(400).json({message: 'classroom id, quiz code and student response are required'});
        }
        const student = await Student.findOne({email: req.user.email}, null, {session});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom = await Classroom.findById(classroom_id, null, {session});
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        // console.log(student_ids, student._id);
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        let quiz_found = false;
        const quiz_code = beacon_UUID.slice(-1 * QUIZ_CODE_LENGTH);
        console.log(quiz_code);
        for(let i=0; i<classroom.classroom_quizzes.length; i++){
            const quiz = await Quiz.findById(classroom.classroom_quizzes[i], null, {session});
            console.log(i, quiz.quiz_code);
            if(quiz.quiz_code == quiz_code){
                quiz_found = true;
                if(!(quiz.is_accepting)){
                    return res.status(400).json({message: 'Quiz not accepting responses'});
                }
                
                const student_ids = Array.from(quiz.student_responses.keys())
                // console.log(student_ids, student._id);
                if(student_ids.includes(student._id.toString())){
                    return res.status(400).json({message: 'Already responded'});
                }
                quiz.student_responses.set(student._id, student_response);                
                await quiz.save({session: session});
                await session.commitTransaction();
                return res.status(200).json({message: 'Quiz submitted successfully'});
            }
        }
        
        if(!quiz_found){
            await session.abortTransaction();
            return res.status(400).json({message: 'Wrong Quiz Code'});
        }

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




module.exports = {
    getAllClassrooms,
    joinClassroomByCode,
    unenroll,
    getMyAttendance,
    markLiveAttendance,
    getBeaconIdentifier,
    getInvites,
    respondToInvite,
    getQuiz,
    submitQuiz
};

