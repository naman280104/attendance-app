const Teacher = require('../models/teacher_model');
const { verifyGoogleToken } = require('../services/google_auth');
const { createToken, connectredis } = require('../services/jwt');


const loginUser = async (req, res) => {
    const { googleToken,advertisingId } = req.body;
    try {
        const userData = await verifyGoogleToken(googleToken);
        console.log(userData, "ffff");
        const token = await createToken({ email: userData.email, role: 'teacher' });
        const mongoose = global.mongoose;
        const teacher = await Teacher.findOne({email: userData.email});
        console.log(teacher);
        if(teacher!=null){
            return res.status(200).send({ token: token, message: 'Login successful',email: userData.email, name: teacher.name,role: 'teacher'});
        }
        else{
            const teacher = await Teacher({email: userData.email, name: userData.name});
            await teacher.save();
            return res.status(200).send({ token: token, message: 'Login successful Account created', email: userData.email, name: teacher.name, role: 'teacher'});
        }
    }
    catch (error) {
        console.log(error);
        return res.status(400).send({ message: 'Error' });
    }
};

const logoutUser = async (req, res) => {
    
}



module.exports = {loginUser, logoutUser}