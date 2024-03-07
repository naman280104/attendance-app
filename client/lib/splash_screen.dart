import 'dart:convert';
import 'package:attendance/ask_role.dart';
import 'package:attendance/assets/myprovider.dart';
import 'package:attendance/student/presentation/screens/student_home.dart';
import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:attendance/teacher/presentation/screens/teacher_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'assets/constants/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


String hostIP = dotenv.env['HOST_IP']!;
int hostPort = int.parse(dotenv.env['HOST_PORT']!);

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () async {
      FlutterSecureStorageClass secureStorage = FlutterSecureStorageClass();
      String? token = await secureStorage.readSecureData('token');
      print("token is $token");
      print("token is ${await secureStorage.readSecureData('token')}");
      bool isvalid = false;
      if(token !=null){
        try{
          var response = await http.get(Uri(scheme:'http', host: hostIP ,port: hostPort ,path: '/auth/verify'), headers: {'Authorization': token});
          if(response.statusCode == 200){
            var responseBody = json.decode(response.body);
            print(responseBody);
            String role = responseBody['role'];
            String username = responseBody['name'] ;
            if(role == 'teacher'){
              isvalid = true;
              Provider.of<MyProvider>(context, listen: false).setName(username);
              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => TeacherHome())),(route) => false);
            }
            else if(role == 'student'){
              isvalid = true;
              Provider.of<MyProvider>(context, listen: false).setName(username);
              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => StudentHome())),(route) => false);
            }
          }
        }
        catch(err){
          print(err);
        }
      }
      if(!isvalid){
        await secureStorage.deleteAllSecureData();
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: ((context) => const AskRole())),(route) => false);
      }
    });
    return Scaffold(
      backgroundColor: initialBg,
      body: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Text(
                'ATTENDANCE',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Image.asset('lib/assets/images/canvas.png'),
            Expanded(child: SizedBox()),
          ]
        ),
    );
  }
}
