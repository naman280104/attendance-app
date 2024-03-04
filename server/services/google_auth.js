const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');

const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const client = new OAuth2Client(CLIENT_ID);


const verifyGoogleToken = async (accessToken) => {
    console.log(accessToken);
    const tokenInfoEndpoint = `https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=${accessToken}`;
    const userInfoEndpoint = `https://www.googleapis.com/oauth2/v3/userinfo?access_token=${accessToken}`;
 
    try {
        const responsetoken = await axios.get(tokenInfoEndpoint);
        const responseuser = await axios.get(userInfoEndpoint);
        const tokenInfo = responsetoken.data;
        console.log(tokenInfo);
        if (tokenInfo.aud === CLIENT_ID) {  
            return responseuser.data;
        } 
        else {
            console.log('Access token is not valid for your client.');
            throw new Error('Access token is not valid for your client.');
        }
    } 
    catch (error) {
        console.error('Error verifying access token:', error.message);
        throw new Error('Error verifying access token');
    }
}



module.exports = { verifyGoogleToken };