import 'package:attendance/teacher/presentation/screens/teacher_lecture.dart';
import 'package:flutter/material.dart';

import '../../../assets/constants/colors.dart';

class TeacherLectureTile extends StatelessWidget {
  final String classroomID;
  final int lectureNo, noOfStudents;
  final Map<String, dynamic> lectureInfo;

  const TeacherLectureTile({
    super.key,
    required this.classroomID,
    required this.lectureNo,
    required this.noOfStudents,
    required this.lectureInfo,
  });

  @override


  Widget build(BuildContext context) {
    final String attendance = '${lectureInfo["lecture_attendance_count"]}/${noOfStudents}';

    return Container(
      margin: EdgeInsets.fromLTRB(35, 15, 35, 0),
      child: ElevatedButton(
        onPressed: () {
          // print('${lecture[0]} Pressed');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TeacherLecturePage(
                      classroomID: classroomID,
                      lectureNo: lectureNo,
                      lectureInfo: lectureInfo)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: lectureInfo["lecture_is_accepting"] ? Colors.green : Color(0xFFEEEEEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 13, 0, 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lecture ${lectureNo}', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: primaryBlack),),
              Text(attendance, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18,color: primaryBlack),),
            ],
          ),
        ),
      ),
    );
  }
}
