// Code: Middleware to verify user token

const { verifyToken } = require('../services/jwt');

const isTeacher = async (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    const user = await verifyToken(token);
    if (!user) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    if (user.role !== 'teacher') {
        return res.status(403).json({ message: 'Forbidden' });
    }
    req.user = user;
    next();
};

const isStudent = async (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    const user = await verifyToken(token);
    if (!user) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    if (user.role !== 'student') {
        return res.status(403).json({ message: 'Forbidden' });
    }
    req.user = user;
    next();
};

module.exports = { isTeacher, isStudent };

