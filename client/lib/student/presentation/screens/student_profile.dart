import 'package:flutter/material.dart';

import '../../../assets/constants/colors.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});
  final String email = 'student@gmail.com';
  final String name = "Student1";
  final String rollNumber = 'rollNumber';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.2,),
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
                prefixIcon: Icon(Icons.more_horiz),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              controller: TextEditingController()..text = rollNumber,
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
