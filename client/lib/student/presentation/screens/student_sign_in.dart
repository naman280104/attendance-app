import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/student/services/student_authentication_services.dart';
import 'package:flutter/material.dart';

class StudentSignIn extends StatelessWidget {
  const StudentSignIn({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBg,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.2,),
            const Text('Student Login',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            SizedBox(height: MediaQuery.of(context).size.height*0.4,),
            SizedBox(
              width: 280,
              height: 60,
              child: ElevatedButton(
                onPressed: (){
                  StudentAuthenticationServices().handleSignIn(context);
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