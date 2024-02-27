import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter/material.dart';

class TeacherProfile extends StatelessWidget {
  const TeacherProfile({super.key});

  final String email = 'instructor@gmail.com';
  final String name = "Instructor1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.25,),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              controller: TextEditingController()..text = name,
              readOnly: true,
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              controller: TextEditingController()..text = email,
              readOnly: true,
            ),
          ),
          Expanded(child: SizedBox()),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: complementaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
            onPressed: (){

            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Text('Submit',style: TextStyle(fontSize: 21,color: primaryBlack),),
            ),
          ),
          SizedBox(height: 30,)
        ],
      ),
    );
  }
}
