const Teacher = require('../models/teacher_model');
const { verifyGoogleToken } = require('../services/google_auth');
const { createToken, connectredis } = require('../services/jwt');

const loginUser = async (req, res) => {
    const { googleToken } = req.body;
    try {
        const userData = await verifyGoogleToken(googleToken);
        console.log(userData.email);
        const token = await createToken({ email: userData.email, role: 'teacher' });
        return res.status(200).send({ token: token, message: 'Login successful'});
    }
    catch (error) {
        return res.status(400).send({ message: 'Invalid token' });
    }
};

const getUser = async (req, res) => {

}

const completeProfile = async (req, res) => {

}

const updateProfile = async (req, res) => {

}

const getProfile = async (req, res) => {

}

const logoutUser = async (req, res) => {

}



module.exports = {loginUser, getUser, completeProfile, updateProfile, getProfile, logoutUser}