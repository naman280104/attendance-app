import 'package:attendance/student/presentation/screens/student_sign_in.dart';
import 'package:attendance/teacher/presentation/screens/teacher_sign_in.dart';
import 'package:flutter/material.dart';
import 'assets/constants/colors.dart';


class AskRole extends StatelessWidget {
  const AskRole({super.key});

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.27,
                    height: 1,
                    color: Colors.black,
                  ),
                ),
                Text(
                  ' CONTINUE AS ',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.27,
                    height: 1,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
             SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentSignIn()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                child: Text(
                  "Student", 
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                    )
                  ),
                ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherSignIn()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                child: Text(
                  "Teacher", 
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                    )
                  ),
                ),
            ),

        ],
      ),
    );
  }
}