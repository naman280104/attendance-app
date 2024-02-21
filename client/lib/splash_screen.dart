import 'package:attendance/ask_role.dart';
import 'package:flutter/material.dart';
import 'assets/constants/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});


  
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context) => const AskRole())));
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