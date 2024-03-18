const Student = require('../models/student_model');


const updateProfile = async (req, res) => {
    const {name, roll_no} = req.body;
    const email = req.user.email;
    console.log(email);
    try{
        await Student.updateOne({email: email}, {name: name, roll_no: roll_no});
        res.status(200).json({message: 'Profile updated successfully.'});
    }
    catch(error){
        return res.status(400).json({message: 'Error updating profile.'});
    }
}   

const getProfile = async (req, res) => {
    const email = req.user.email;
    try{
        console.log(email); 
        const student = await Student.findOne({email: email});
        console.log(student);
        return res.status(200).json({email: email,name: student.name, roll_no: student.roll_no,role: req.user.role,});
    }
    catch(error){
        return res.status(400).json({message: 'Error fetching profile.'});
    }
}

module.exports = {updateProfile, getProfile};