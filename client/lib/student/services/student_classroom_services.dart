import 'package:attendance/ask_role.dart';
import 'dart:convert';
import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String hostIP = dotenv.env['HOST_IP']!;
int hostPort = int.parse(dotenv.env['HOST_PORT']!);

class StudentClassroomServices {
  static Future<Map<String, dynamic>> getAllClassrooms(context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if (token == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => AskRole()), (route) => false);
    } else {
      try {
        var response = await http.get(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/student/get-all-classrooms'),
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          // return {"error" : "Error fetching details"};
          throw ("Error fetching details");
        }
      } catch (err) {
        print(err);
        // return {"error" : "Error fetching details"};
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> joinClassroomByCode(context, String classroomCode) async {
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
                path: '/student/join-classroom-by-code'),
            body: {"classroom_code": classroomCode},
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> unenroll(context, String classroomID) async {
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
                path: '/student/unenroll'),
            body: {"classroom_id": classroomID},
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> getBeaconIdentifier(context, String classroomID) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if (token == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => AskRole()), (route) => false);
    } else {
      try {
        var response = await http.get(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/student/get-beacon-identifier',
                queryParameters: {'classroom_id': classroomID},
            ),
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> markLiveAttendance(context, String classroomID, String beaconUUID, String advID) async {
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
                path: '/student/mark-live-attendance'
            ),
            body: {"classroom_id": classroomID, 'beacon_UUID': beaconUUID, 'advertisement_id': advID},
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> getMyAttendance(context, String classroomID) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if (token == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => AskRole()), (route) => false);
    } else {
      try {
        var response = await http.get(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/student/get-my-attendance',
                queryParameters: {'classroom_id': classroomID},
            ),
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> getInvites(context) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if (token == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => AskRole()), (route) => false);
    } else {
      try {
        var response = await http.get(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/student/get-invites',
            ),
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> respondToInvite(context, String inviteID, String studentResponse) async {
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
                path: '/student/respond-to-invite'
            ),
            body: {'invite_id': inviteID, 'student_response': studentResponse},
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }
  
  static Future<Map<String, dynamic>> getQuiz(context, String classroomID, String beaconUUID, String advID) async {
    FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
    String? token = await secureStorage.readSecureData("token");
    if (token == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => AskRole()), (route) => false);
    } else {
      try {
        var response = await http.get(
            Uri(
                scheme: 'http',
                host: hostIP,
                port: hostPort,
                path: '/student/get-quiz',
                queryParameters: {
                  'classroom_id': classroomID,
                  'beacon_UUID': beaconUUID,
                  'advertisement_id': advID
                },
            ),
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          // print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<String, dynamic>> submitQuiz(context, String classroomID, String beaconUUID, List<int> studentResponse) async {
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
                path: '/student/submit-quiz'
            ),
            body: {"classroom_id": classroomID, 'beacon_UUID': beaconUUID, 'student_response': json.encode(studentResponse)},
            headers: {'Authorization': token});

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          print(responseBody);
          return responseBody;
        } else {
          throw (json.decode(response.body)["message"]);
        }
      } catch (err) {
        print(err);
        rethrow;
      }
    }
    return {};
  }

}
