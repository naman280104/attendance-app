import 'package:attendance/ask_role.dart';
import 'dart:convert';
import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String hostIP = dotenv.env['HOST_IP']!;
int hostPort = int.parse(dotenv.env['HOST_PORT']!);


class TeacherClassroomServices {

  static Future<Map<String,dynamic>> createClassroom(String classroomName,context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AskRole()), (route) => false);
    }
    else{
      try{
        var response = await http.post(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/teacher/create_classroom'),
                body: {'classroom_name': classroomName},
            headers: {'Authorization': token});
        if(response.statusCode==200){
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        }
        else{
          return {"error" : "Error fetching details"};
        }
      }
      catch(err){
          return {"error" : "Error fetching details"};
      }
    }
    return {};
  }

  static Future<Map<String,dynamic>> getClassrooms(context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AskRole()), (route) => false);
    }
    else{
      try{
        var response = await http.get(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/teacher/get_classrooms'),
            headers: {'Authorization': token});
        if(response.statusCode==200){
          var responseBody = json.decode(response.body);
          print("get_classrooms");
          print(responseBody);
          return responseBody;
        }
        else{
          throw("Error fetching details");
          // return {"error" : "Error fetching details"};
        }
      }
      catch(err){
          throw("Error fetching details");
          // return {"error" : "Error fetching details"};
      }
    }
    return {};
  }
}
