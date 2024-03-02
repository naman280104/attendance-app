import 'package:flutter/material.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../presentation/screens/student_home.dart';


class StudentAuthenticationServices{
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email','profile','openid']);

  Future<void> handleSignIn(context) async {
    try {
      await _googleSignIn.signIn();
      // Get the GoogleSignInAccount object and send the token to the backend
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final String googleToken = googleAuth.accessToken!;
      print(googleToken);
      http.post(Uri(scheme:'http', host:'172.30.21.97',port: 3000 ,path: '/auth/teacher/login'), body: {'googleToken': googleToken});
    } catch (error) {
      print('Google Sign-In failed: $error');
      // Handle sign-in failure
    } finally {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>StudentHome()), (route) => false);
    }
  }
}



Function getAdvertisingId = () async {
    bool? isLimitAdTrackingEnabled;
    try {
      isLimitAdTrackingEnabled = await AdvertisingId.isLimitAdTrackingEnabled;
    } on PlatformException {
      isLimitAdTrackingEnabled = false;
    }
    print("isLimitAdTrackingEnabled is $isLimitAdTrackingEnabled");
    
    if(isLimitAdTrackingEnabled == true){
      print("Limit Ad Tracking is enabled"); //promt user to open it
      return true;
      } 
    
    String? advertisingId;
    try {
      advertisingId = await AdvertisingId.id(true);
    } on PlatformException {
      advertisingId = null;
    }

    print("advertising id is $advertisingId");      
};
