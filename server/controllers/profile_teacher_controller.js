const Teacher = require('../models/teacher_model');


const updateProfile = async (req, res) => {
    const {name} = req.body;
    const email = req.user.email;
    
    try{
        await Teacher.updateOne({email: email}, {name: name});
        res.status(200).json({message: 'Profile updated successfully.'});
    }
    catch(error){
        return res.status(400).json({message: 'Error updating profile.'});
    }
}   

const getProfile = async (req, res) => {
    const email = req.user.email;
    try{
        const teacher = await Teacher.findOne({email: email});
        console.log(teacher);
        return res.status(200).json({name: teacher.name, email: email, role: req.user.role});
    }
    catch(error){
        return res.status(400).json({message: 'Error fetching profile.'});
    }
}


module.exports = {updateProfile, getProfile}