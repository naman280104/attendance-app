import 'package:attendance/teacher/presentation/screens/teacher_course_students_list.dart';
import 'package:attendance/teacher/presentation/screens/teacher_new_lecture.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_lecture_tile.dart';
import 'package:flutter/material.dart';

import '../../../assets/constants/colors.dart';

class TeacherClassroom extends StatefulWidget {
  final String courseCode;
  final String courseName;

  const TeacherClassroom({
    super.key,
    required this.courseCode, required this.courseName
  });

  @override
  State<TeacherClassroom> createState() => _TeacherClassroomState();
}

class _TeacherClassroomState extends State<TeacherClassroom> {

  List<dynamic> lectures = [
    ['Lecture-1','48/79','YYYY-MM-DD'],
    ['Lecture-2','57/79','YYYY-MM-DD'],
    ['Lecture-3','45/79','YYYY-MM-DD'],
    ['Lecture-4','48/79','YYYY-MM-DD'],
    ['Lecture-5','57/79','YYYY-MM-DD'],
    ['Lecture-6','45/79','YYYY-MM-DD'],
    ['Lecture-7','48/79','YYYY-MM-DD'],
    ['Lecture-8','57/79','YYYY-MM-DD'],
    ['Lecture-9','45/79','YYYY-MM-DD'],
    ['Lecture-10','48/79','YYYY-MM-DD'],
  ];

  var courseName = "";

  @override
  void initState() {
    courseName = widget.courseName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextField(
        controller: TextEditingController()..text = courseName,
        autocorrect: false,
        onSubmitted: (val){
          setState(() {
            courseName = val;
          });
        },
        style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.edit),
          border: InputBorder.none,
        ),
      ),backgroundColor: classroomTileBg,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Course Code
            Container(
              decoration: BoxDecoration(
                color: primaryWhite,
                border: Border(bottom: BorderSide(color: primaryBlack,width: 1))
              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(25, 15, 30, 15),
              margin: EdgeInsets.only(bottom: 30),
              child: Text('Classroom Code: ${widget.courseCode}'),
            ),
            // Add Lecture
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherNewLecture(courseName: courseName, courseCode: widget.courseCode, lectureNumber: (lectures.length).toString())));
              },
              style: ElevatedButton.styleFrom(
                elevation: 3,
                backgroundColor: Color(0xFFEEEEEE),
                shape: RoundedRectangleBorder(
                  // side: BorderSide(width: 1.5,color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                )
              ),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*0.7,
                padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                child: Text('Add Lecture',style: TextStyle(color: primaryBlack,fontSize: 20,fontWeight: FontWeight.w600),),
              ),
            ),
            // Lectures
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: lectures.length,
              itemBuilder: (BuildContext context, int index) {
                return TeacherLectureTile(lecture: lectures[index],courseName: courseName,courseCode: widget.courseCode,);
              },
            ),
            // End Space
            SizedBox(height: 20,)
          ],
        ),
      ),
      bottomNavigationBar: TextButton(
        onPressed: (){
          print('Students List Button Pressed for Course $courseName');
          Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentList(courseName: courseName, courseCode: widget.courseCode)));
        },
        style: TextButton.styleFrom(
          backgroundColor: complementaryColor,
          shape: LinearBorder()
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Text('Student List',style: TextStyle(color: primaryBlack,fontSize: 20),)
        ),
      )
    );
  }
}
