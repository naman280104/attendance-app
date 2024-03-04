import 'package:attendance/splash_screen.dart';
import 'package:attendance/student/presentation/screens/student_home.dart';
import 'package:attendance/teacher/presentation/screens/teacher_home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';


Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Attendance',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
