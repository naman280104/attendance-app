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
                path: '/teacher/create-classroom'
            ),
            body: {'classroom_name': classroomName},
            headers: {'Authorization': token}
          );
          
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
                path: '/teacher/get-classrooms'),
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

  static Future<String> deleteClassroom(String classroomID, context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AskRole()), (route) => false);
    }
    else{
      print(classroomID);
      try{
        var response = await http.delete(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/teacher/delete-classroom'),
            headers: {'Authorization': token},
            body: {'classroom_id': classroomID}
          );
            
        if(response.statusCode==200){
          var responseBody = json.decode(response.body);
          print("delete-classroom");
          print(responseBody);
          return "Deleted Successfully!";
        }
        else{
          return "Error in deleting";
        }
      }
      catch(err){
        print(err);
          return "Error in deleting $err";
      }
    }
    return "";
  }

    static Future<Map<String,dynamic>> getClassroomInfo(String classroomID, context) async {
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
                  path: '/teacher/get-classroom-info',
                  queryParameters: {'classroom_id': classroomID}
              ),
              headers: {'Authorization': token},
            );
        if(response.statusCode==200){
          var responseBody = json.decode(response.body);
          print("get-classroom-info");
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
