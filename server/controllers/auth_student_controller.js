const Student = require('../models/student_model');
const { verifyGoogleToken } = require('../services/google_auth');
const { createToken, deleteToken } = require('../services/jwt');

const loginUser = async (req, res) => {
    const { googleToken,advertisingId } = req.body;
    try {
        const userData = await verifyGoogleToken(googleToken);
        console.log(userData);
        const token = await createToken({ email: userData.email, role: 'student' });
        const mongoose = global.mongoose;
        const student = await Student.findOne({email: userData.email});
        console.log("student is",student);
        if(student!=null){
            return res.status(200).json({ token: token, message: 'Login successful',email: student.email, name: student.name, roll_no: "", role: 'student'});
        }
        else{
            const student = await Student({email: userData.email,advertisement_id: advertisingId, name: userData.name,});
            await student.save();
            return res.status(200).json({ token: token, message: 'Login successful Account created', email: student.email, name: student.name, roll_no: "", role: 'student'});
        }
    }
    catch (error) {
        console.log(error);
        return res.status(400).json({ message: 'Error' });
    }
};


const logoutUser = async (req, res) => {
    try{
        console.log(req.header('Authorization'));
        await deleteToken(req.header('Authorization'));
    }
    catch(err){
        console.log(err);   
    }
}



module.exports = {loginUser, logoutUser}
