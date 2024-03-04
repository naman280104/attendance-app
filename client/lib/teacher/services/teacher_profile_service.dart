
import 'dart:convert';
import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:attendance/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendance/ask_role.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';



String hostIP = dotenv.env['HOST_IP']!;
int hostPort = int.parse(dotenv.env['HOST_PORT']!);

class TeacherProfileService{
  
  static Future<Map<String,dynamic>> getProfileDetials(context) async {

    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => const AskRole())),(route) => false);
    }
    else{
      // logic for fetch profile details
      try{
        var response = await http.get(Uri(scheme:'http', host: hostIP ,port: hostPort ,path: '/teacher/profile'), headers: {'Authorization': token});
        if(response.statusCode == 200){
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        }
        else{
          return {"error":"Error fetching detials"};
        }
      }
      catch(err){
        return {"error":"Error fetching detials"};
      }
    }
    return{};
  } 

  static Future<String> updateProfileDetials(Map<String,dynamic> profileDetails,context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => const AskRole())),(route) => false);
    }
    else{
      // logic for fetch profile details
      print("update details");
      try{
        var response = await http.put(Uri(scheme:'http', host: hostIP ,port: hostPort ,path: '/teacher/profile/update'), headers: {'Authorization': token},body: profileDetails);
          var responseBody = json.decode(response.body);
        if(response.statusCode == 200){
          print(responseBody);
          return responseBody['message'];
        }
        else{
          return responseBody['error'];
        }
      }
      catch(err){
        return "Error updating detials";
      }
    }
    return "";
  } 

  static void logout(context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    await secureStorage.deleteAllSecureData();
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => const SplashScreen())),(route) => false);
    if(token!=null){
      await http.post(Uri(scheme:'http', host: hostIP ,port: hostPort ,path: '/teacher/auth/logout',), headers: {'Authorization': token});
    }
  }
}