const Student = require('../models/student_model');
const Teacher = require('../models/teacher_model');
const Classroom = require('../models/classroom_model');
const Lecture = require('../models/lecture_model');
const Attendance = require('../models/attendance_model');
const Invite = require('../models/invite_model');


const BEACON_ID_LENGTH = 16; //16 hex digits
const LECTURE_CODE_LENGTH = 8; //8 hex digits

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



const getAttendanceBeaconIdentifier = async (req, res) => {
    try{
        const {classroom_id} = req.query;
        const student = await Student.findOne({email: req.user.email});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const classroom = await Classroom.findById(classroom_id);
        if(!classroom){
            return res.status(404).json({message: 'Classroom not found'});
        }

        const student_ids = Array.from(classroom.classroom_students.keys())
        if(!student_ids.includes(student._id.toString())){
            return res.status(400).json({message: 'Student not in classroom'});
        }

        return res.status(200).json({beacon_id: classroom.beacon_id});
    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


const markLiveAttendance = async (req,res) => {
    try{
        const {classroom_id, beacon_UUID, advertisement_id} = req.body;
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
            const lecture = await Lecture.findById(classroom.classroom_lectures[i]);
            console.log(i, lecture.lecture_code)
            if(lecture.lecture_code == received_lecture_code){
                lecture_found = true;
                if(!(lecture.is_accepting_live & lecture.is_accepting)){
                    return res.status(400).json({message: 'Lecture not accepting attendance'});
                }
                
                const student_attendance = classroom.classroom_students.get(student._id);
                for(let j=0; j<student_attendance.length; j++){
                    const attendance = await Attendance.findById(student_attendance[j]["attendance_id"]);
                    if(attendance.lecture_id.toString() == lecture._id.toString()){
                        console.log("alreadyyyyyyyyyyyyyyyyy")
                        return res.status(400).json({message: 'Attendance already marked'});
                    }
                }

                const attendance = new Attendance({
                    advertisement_id: advertisement_id,
                    student_id: student._id,
                    lecture_id: lecture._id,
                });

                await attendance.save();

                lecture.attendance_count++;
                await lecture.save();
                
                const updatedClassroom = await Classroom.findOneAndUpdate(
                    { _id: classroom._id, [`classroom_students.${student._id}`] : { $exists: true } },
                    { $push: { [`classroom_students.${student._id}`]: {attendance_id: attendance._id, lecture_id: lecture._id} } },
                  );

                console.log(updatedClassroom);

                return res.status(200).json({message: 'Attendance marked successfully'});
            }
        }
        
        if(!lecture_found){
            return res.status(400).json({message: 'Wrong Beacon UUID'});
        }

    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


const getMyAttendance = async (req,res) => {
    const {classroom_id} = req.query;
    try{
        const student = await Student.findOne({email: req.user.email});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }

        const classroom = await Classroom.findById(classroom_id);
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
            const lecture = await Lecture.findById(classroom_lectures[i].toString());

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

        return res.status(200).json({attendance: attendance_of_student});
    }
    catch(err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


const getInvites = async (req,res) => {
    try{
        const {email} = req.user;
        const student = await Student.findOne({email: email});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const invites_data = await Invite.find({student_id: student._id}); 
        const invites=[];
        for(let i=0; i<invites_data.length; i++){
            const invite = invites_data[i];
            const classroom = await Classroom.findById(invite.classroom_id);
            if(!classroom){
                await Invite.findByIdAndDelete(invite._id);
                continue;
            }
            const teacher = await Teacher.findById(classroom.teacher);
            if(!teacher){
                continue;
            }
            invites.push({
                invite_id: invite._id,
                classroom_name: classroom.classroom_name,
                classroom_teacher: teacher.name,
            });
        }
        return res.status(200).json({invites: invites});

    } catch (err){
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


const respondToInvite = async (req,res) => {
    try{
        const {invite_id, student_response} = req.body;
        if(!invite_id || !student_response){
            return res.status(400).json({message: 'invite_id and student_response are required'});
        }

        const {email} = req.user;
        const student = await Student.findOne({email: email});
        if(!student){
            return res.status(404).json({message: 'Student not found'});
        }
        
        const invite = await Invite.findById(invite_id);
        if(!invite){
            return res.status(404).json({message: 'Invite not found'});
        }
        
        if(student_response == 'ACCEPT'){
            const classroom_id = invite.classroom_id;
            const classroom = await Classroom.findById(classroom_id);
            if(!classroom){
                await Invite.findByIdAndDelete(invite_id);
                return res.status(404).json({message: 'Classroom not found'});
            }
            
            const student_ids = Array.from(classroom.classroom_students.keys());
            if(student_ids.includes(student._id.toString())){
                await Invite.findByIdAndDelete(invite_id);
                return res.status(400).json({message: 'Student already in classroom'});
            }


            classroom.classroom_students.set(student._id, []);
            await classroom.save();
            
            student.classrooms.push(classroom._id);
            await student.save();

            await Invite.findByIdAndDelete(invite_id);

            return res.status(200).json({message: 'Invite accepted successfully!'});
        }
        else if(student_response == 'DECLINE'){
            await Invite.findByIdAndDelete(invite_id);
            return res.status(200).json({message: 'Invite declined successfully!'});
        }
        else{
            return res.status(400).json({message: 'Invalid response'});
        }



    } catch(err) {
        console.log(err);
        res.status(500).json({message: 'Internal server error'});
    }
}


module.exports = {getAllClassrooms, joinClassroomByCode, unenroll, getMyAttendance, markLiveAttendance, getAttendanceBeaconIdentifier, getInvites, respondToInvite};
