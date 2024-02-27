import 'package:attendance/teacher/presentation/screens/teacher_lecture.dart';
import 'package:flutter/material.dart';

import '../../../assets/constants/colors.dart';

class TeacherLectureTile extends StatelessWidget {
  final List<dynamic> lecture;
  final String courseName,courseCode;
  const TeacherLectureTile({
    super.key,
    required this.lecture, required this.courseName,required this.courseCode
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(35, 15, 35, 0),
      child: ElevatedButton(
        onPressed: () {
          print('${lecture[0]} Pressed');
          Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherLecturePage(lecture: lecture,courseCode: courseCode,courseName: courseName,)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFEEEEEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 13, 0, 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lecture[0],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: primaryBlack),),
              Text(lecture[1],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18,color: primaryBlack),),
            ],
          ),
        ),
      ),
    );
  }
}
