import 'dart:io';
import 'dart:typed_data';

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


  static Future<String> editClassroomName(String classroomID, String classroomName,context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AskRole()), (route) => false);
    }
    else{
      print(classroomID);
      try{
        var response = await http.post(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/teacher/edit-classroom-name'),
            headers: {'Authorization': token},
            body: {'classroom_id': classroomID, 'classroom_name': classroomName}
          );
            
        if(response.statusCode==200){
          var responseBody = json.decode(response.body);
          print("edit-classroom-name");
          print(responseBody);
          return "Changed Successfully!";
        }
        else{
          return "Error in changing";
        }
      }
      catch(err){
        print(err);
          return "Error in deleting $err";
      }
    }
    return "";
  }


  static Future<Map<String,dynamic>> addLecture(String classroomID, context) async {
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
                path: '/teacher/add-lecture'
            ),
            body: {'classroom_id': classroomID},
            headers: {'Authorization': token}
          );
          
        var responseBody = json.decode(response.body);
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String, dynamic>> liveAttendance(
      String classroomID, String lectureID, String action, context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if (token == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => AskRole()), (route) => false);
    } else {
      try {
        var response = await http.post(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/teacher/live-attendance'),
            body: {
              'classroom_id': classroomID,
              "lecture_id": lectureID,
              "action": action
            },
            headers: {
              'Authorization': token
            });

        var responseBody = json.decode(response.body);

        if (response.statusCode == 200) {
          print(responseBody);
          return responseBody;
        } else {
          throw (responseBody["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> getClassroomStudents(String classroomID, context) async {
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
                  path: '/teacher/get-classroom-students',
                  queryParameters: {'classroom_id': classroomID}
              ),
              headers: {'Authorization': token},
            );
        var responseBody = json.decode(response.body);

        if(response.statusCode==200){
          return responseBody;
        }
        else{
          throw(responseBody['message']);
        }
      }
      catch(err){
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> getLectureAttendance(String classroomID, String lectureID, context) async {
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
                  path: '/teacher/get-lecture-attendance',
                  queryParameters: {'classroom_id': classroomID, 'lecture_id': lectureID}
              ),
              headers: {'Authorization': token},
            );
        var responseBody = json.decode(response.body);

        if(response.statusCode==200){
          return responseBody;
        }
        else{
          throw(responseBody['message']);
        }
      }
      catch(err){
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> sendInvites(String classroomID, List<String> studentEmails, context) async {
    print(studentEmails);
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
                path: '/teacher/send-invites'
            ),
            body: {'classroom_id': classroomID, 'student_emails': jsonEncode(studentEmails)},
            headers: {'Authorization': token}
          );
          
        var responseBody = json.decode(response.body);
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> addAttendanceByEmail(String classroomID, String lectureID, String studentEmail, context) async {
    // print(studentEmails);
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
                path: '/teacher/add-attendance-by-email'
            ),
            body: {'classroom_id': classroomID, 'lecture_id': lectureID, 'student_email': studentEmail},
            headers: {'Authorization': token}
          );
          
        var responseBody = json.decode(response.body);
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> removeStudent(String classroomID, String studentEmail, context) async {
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
                path: '/teacher/remove-student'
            ),
            body: {'classroom_id': classroomID, 'student_email': studentEmail},
            headers: {'Authorization': token}
          );
          
        var responseBody = json.decode(response.body);
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> getAttendanceReport(String classroomID, context) async {
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
                  path: '/teacher/get-attendance-report',
                  queryParameters: {'classroom_id': classroomID}
              ),
              headers: {'Authorization': token},
            );
        var responseBody = json.decode(response.body);

        if(response.statusCode==200){
          return responseBody;
        }
        else{
          throw(responseBody['message']);
        }
      }
      catch(err){
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> addQuiz(String classroomID, String quizName, String noOfQues, String filePath, context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if(token==null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AskRole()), (route) => false);
    }
    else{
      try{
        var request = http.MultipartRequest(
          'POST',
          Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/teacher/add-quiz'
            ),
        );

        request.headers.addAll({
          'Authorization': token,
          'Content-Encoding': 'application/gzip'
          });

        request.fields.addAll({
          'classroom_id': classroomID,
          'quiz_name': quizName,
          'no_of_questions': noOfQues,
        });
        request.files.add(await http.MultipartFile.fromPath("file", filePath));
        var response = await request.send();
          
        var responseBody = json.decode(await response.stream.bytesToString());
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> getAllQuizzes(String classroomID, context) async {
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
                  path: '/teacher/get-all-quizzes',
                  queryParameters: {'classroom_id': classroomID}
              ),
              headers: {'Authorization': token},
            );
        var responseBody = json.decode(response.body);

        if(response.statusCode==200){
          return responseBody;
        }
        else{
          throw(responseBody['message']);
        }
      }
      catch(err){
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> removeQuiz(String classroomID, String quizID, context) async {
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
                path: '/teacher/remove-quiz'
            ),
            body: {'classroom_id': classroomID, 'quiz_id': quizID},
            headers: {'Authorization': token}
          );
          
        var responseBody = json.decode(response.body);
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> changeQuizState(String classroomID, String quizID, String action, context) async {
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
                path: '/teacher/change-quiz-state'
            ),
            body: {'classroom_id': classroomID, 'quiz_id': quizID, 'action': action},
            headers: {'Authorization': token}
          );
          
        var responseBody = json.decode(response.body);
        
        if(response.statusCode==200){
          print(responseBody);
          return responseBody;
        }
        else{
          throw(responseBody["message"]);
        }
      }
      catch(err){
        print(err);
        rethrow;
      }
    }
    return {};
  }


  static Future<Map<String,dynamic>> getQuizResponses(String classroomID, String quizID, context) async {
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
                  path: '/teacher/get-quiz-responses',
                  queryParameters: {'classroom_id': classroomID, 'quiz_id':quizID}
              ),
              headers: {'Authorization': token},
            );
        var responseBody = json.decode(response.body);

        if(response.statusCode==200){
          return responseBody;
        }
        else{
          throw(responseBody['message']);
        }
      }
      catch(err){
        rethrow;
      }
    }
    return {};
  }

}
