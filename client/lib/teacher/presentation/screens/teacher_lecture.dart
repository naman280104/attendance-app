import 'package:attendance/teacher/presentation/screens/teacher_lecture_page_accepting.dart';
import 'package:attendance/teacher/presentation/screens/teacher_lecture_page_not_accepting.dart';
import 'package:flutter/material.dart';

class TeacherLecturePage extends StatelessWidget {
  final String classroomID;
  final int lectureNo;
  final Map<String, dynamic> lectureInfo;

  const TeacherLecturePage({
    super.key,
    required this.classroomID,
    required this.lectureNo,
    required this.lectureInfo
  });
  
  @override
  Widget build(BuildContext context) {
    if (lectureInfo["lecture_is_accepting"]) {
      return LecturePageWhenAccepting(classroomID: classroomID, lectureNo: lectureNo, lectureInfo: lectureInfo);
    }
    return LecturePageWhenNotAccepting(classroomID: classroomID, lectureNo: lectureNo, lectureInfo: lectureInfo);
  }
}
