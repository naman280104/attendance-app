const Student = require('../models/student_model');
const Teacher = require('../models/teacher_model');
const profile_student_controller = require('./profile_student_controller');
const profile_teacher_controller = require('./profile_teacher_controller');
const {verifyToken} = require('../services/jwt');

const getRole = async (req,res) =>{
    const token = req.header('Authorization');
    if (!token) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    const user = await verifyToken(token);
    if (!user) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    req.user = user;
    if(req.user.role==='student'){
        return profile_student_controller.getProfile(req,res);
    }
    else if(req.user.role==='teacher'){
        return profile_teacher_controller.getProfile(req,res);
    }
    else{
        return res.status(400).json({message: 'Error fetching role.'});
    }
} 

module.exports = {getRole};