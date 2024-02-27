import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/teacher/presentation/screens/teacher_home.dart';
import 'package:flutter/material.dart';

class TeacherSignIn extends StatelessWidget {
  const TeacherSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBg,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.2,),
            const Text('Teacher Login',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            SizedBox(height: MediaQuery.of(context).size.height*0.4,),
            SizedBox(
              width: 280,
              height: 60,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>TeacherHome()), (route) => false);
                },
                child: Row(
                  children: <Widget>[
                    Image.asset('lib/assets/images/google.png',height: 30,width: 30,),
                    Expanded(child: SizedBox(width: 1,)),
                    Text('Continue with google',style: TextStyle(fontSize: 20,color: primaryBlack),),
                  ],
                ),
              ),
            
            )
          ],
        ),
      ),
    );
  }
}