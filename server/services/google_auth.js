const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');

const CLIENT_ID_ANDROID = process.env.GOOGLE_CLIENT_ID_ANDROID;
const CLIENT_ID_IOS = process.env.GOOGLE_CLIENT_ID_IOS;
const client_ANDROID = new OAuth2Client(CLIENT_ID_ANDROID);
const client_IOS = new OAuth2Client(CLIENT_ID_IOS);


const verifyGoogleToken = async (accessToken,CLIENT_ID) => {
    console.log(accessToken);
    const tokenInfoEndpoint = `https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=${accessToken}`;
    const userInfoEndpoint = `https://www.googleapis.com/oauth2/v3/userinfo?access_token=${accessToken}`;
 
    try {
        const responsetoken = await axios.get(tokenInfoEndpoint);
        const responseuser = await axios.get(userInfoEndpoint);
        const tokenInfo = responsetoken.data;
        console.log(tokenInfo);
        if (tokenInfo.aud === CLIENT_ID_ANDROID || tokenInfo.aud === CLIENT_ID_IOS) {  
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