import 'dart:convert';
import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:attendance/assets/myprovider.dart';
import 'package:attendance/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/student_home.dart';
import 'package:http/http.dart' as http;


String hostIP = dotenv.env['HOST_IP']!;
int hostPort = int.parse(dotenv.env['HOST_PORT']!);

class StudentAuthenticationServices{
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email','profile','openid']);
  Future<void> handleSignIn(context) async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.signIn();
      // Get the GoogleSignInAccount object and send the token to the backend
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final String googleToken = googleAuth.accessToken!;
      print(googleToken);
      String advertisingId = await getAdvertisingId();
      var res = await http.post(Uri(
        scheme:'http',
        host: hostIP,
        port: hostPort,
        path: '/student/auth/login'),
        body: {'googleToken': googleToken, 'advertisingId':advertisingId});
      if(res.statusCode == 200){
        FlutterSecureStorageClass securestorage = FlutterSecureStorageClass();
        Map<String, dynamic> responseBody = json.decode(res.body);
        print(responseBody);
        await securestorage.writeSecureData("token", responseBody['token']);

        FlutterSecureStorageClass securestorage2 = FlutterSecureStorageClass();
        print("token is ${await securestorage2.readSecureData('token')}");
        Provider.of<MyProvider>(context, listen: false).setName(responseBody['name']);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>StudentHome()), (route) => false);
      } 
      else{
        print('Google Sign-In failed: ${res.body}');
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
    }
  }

  void logout(context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    await secureStorage.deleteAllSecureData();
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => const SplashScreen())),(route) => false);
    if(token!=null){
      await http.post(Uri(scheme:'http', host: hostIP ,port: hostPort ,path: '/student/auth/logout',), headers: {'Authorization': token});
    }
    await _googleSignIn.signOut();
  }
}



Function getAdvertisingId = () async {
    bool? isLimitAdTrackingEnabled;
    try {
      isLimitAdTrackingEnabled = await AdvertisingId.isLimitAdTrackingEnabled;String? advertisingId = await AdvertisingId.id(true);
      print(advertisingId);
    } on PlatformException {
      isLimitAdTrackingEnabled = false;
    }
    print("isLimitAdTrackingEnabled is $isLimitAdTrackingEnabled");
    
    if(isLimitAdTrackingEnabled == true){
      print("Limit Ad Tracking is enabled"); //promt user to open it
      throw Exception("Limit Ad Tracking is enabled");
      } 
    
    String? advertisingId;
    try {
      advertisingId = await AdvertisingId.id(true);
    } on PlatformException {
      throw Exception("Failed to get advertising id");
    }


    print("advertising id is $advertisingId");   
    return advertisingId;   
};
