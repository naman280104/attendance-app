const { customAlphabet } = require('nanoid');


const createUniqueID = (n) => {
    const alphabet = '0123456789abcdef';
    const nanoid = customAlphabet(alphabet,n);
    const uuid = nanoid();
    return uuid;
};

const createClassroomCode = () =>{
    const alphabet = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const nanoid = customAlphabet(alphabet,7);
    const uuid = nanoid();
    return uuid;
}


module.exports = { createUniqueID, createClassroomCode};
