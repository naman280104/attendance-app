const { customAlphabet } = require('nanoid');


const createUniqueID = (n) => {
    const alphabet = '0123456789abcdef';
    const nanoid = customAlphabet(alphabet,n);
    const uuid = nanoid();
    return uuid;
};


module.exports = { createUniqueID };
