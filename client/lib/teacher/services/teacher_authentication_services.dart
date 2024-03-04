import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:attendance/teacher/presentation/screens/teacher_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


String hostIP = dotenv.env['HOST_IP']!;
int hostPort = int.parse(dotenv.env['HOST_PORT']!);
class TeacherAuthenticationServices{
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email','profile','openid']);
  Future<void> handleSignIn(context) async {
    try {
      await _googleSignIn.signIn();
      // Get the GoogleSignInAccount object and send the token to the backend
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final String googleToken = googleAuth.accessToken!;
      print(googleToken);
      var res = await http.post(Uri(scheme:'http', host: hostIP ,port: hostPort ,path: '/teacher/auth/login'), body: {'googleToken': googleToken});
      if(res.statusCode == 200){
        FlutterSecureStorageClass securestorage = FlutterSecureStorageClass();
        Map<String, dynamic> responseBody = json.decode(res.body);
        print(responseBody);
        await securestorage.writeSecureData("token", responseBody['token']);

        FlutterSecureStorageClass securestorage2 = FlutterSecureStorageClass();
        print("token is ${await securestorage2.readSecureData('token')}");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>TeacherHome(username: responseBody['name'])), (route) => false);
      } 
      else{
        print('Google Sign-In failed: ${res.body}');
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
    }
  }
}