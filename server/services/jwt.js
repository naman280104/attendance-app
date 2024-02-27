var redis = require('redis');
var JWTR =  require('jwt-redis').default;
var redisClient = redis.createClient();
var jwtr = new JWTR(redisClient);

const { JWT_SECRET } = process.env;

const connectredis = async () => {
    try{
        await redisClient.connect();
    }
    catch(err){
        console.log("redis connection error");
        console.log(err);
        return false;
    }
}
const createToken = async(id) => {
    await connectredis();
    const token = await jwtr.sign(id,JWT_SECRET,{
        expiresIn: "15 days"
    }); 
    console.log(token);
    return token;
}

const verifyToken = async (token) => {
    await connectredis();
    try{
        const userVar = await jwtr.verify(token,JWT_SECRET);
        return userVar;
    }
    catch(err){
        console.log(err);  
        return false;
    }
}

const deleteToken = async (token) => {
    await connectredis();
    try{
        await jwtr.verify(token,JWT_SECRET).then(async(res)=>{
            await jwtr.destroy(res.jti,JWT_SECRET);
        }).catch((err)=>{
            return "wrong token";
        });
    }
    catch(err){
        throw err;
    }
}

module.exports = {createToken, verifyToken, deleteToken, connectredis};