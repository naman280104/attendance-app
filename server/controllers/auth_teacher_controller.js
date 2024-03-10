const Teacher = require('../models/teacher_model');
const { verifyGoogleToken } = require('../services/google_auth');
const { createToken, deleteToken } = require('../services/jwt');


const loginUser = async (req, res) => {
    const { googleToken } = req.body;
    try {
        const userData = await verifyGoogleToken(googleToken);
        console.log(userData, "ffff");
        const token = await createToken({ email: userData.email, role: 'teacher' });
        const mongoose = global.mongoose;
        const teacher = await Teacher.findOne({email: userData.email});
        console.log("teacher is ",teacher);
        if(teacher!=null){
            return res.status(200).json({ token: token, message: 'Login successful',email: userData.email, name: teacher.name,role: 'teacher'});
        }
        else{
            const teacher = await Teacher({email: userData.email, name: userData.name});
            await teacher.save();
            return res.status(200).json({ token: token, message: 'Login successful Account created', email: userData.email, name: teacher.name, role: 'teacher'});
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