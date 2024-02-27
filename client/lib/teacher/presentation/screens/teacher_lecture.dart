import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter/material.dart';

class TeacherLecturePage extends StatefulWidget {
  final String courseName,courseCode;
  final List<dynamic> lecture;

  const TeacherLecturePage({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.lecture
  });

  @override
  State<TeacherLecturePage> createState() => _TeacherLecturePageState();
}

class _TeacherLecturePageState extends State<TeacherLecturePage> {

  List<dynamic> attendance = [
    ['ABC','Roll No.1','abc@abc.abc'],
    ['ABC','Roll No.2','abc@abc.abc'],
    ['ABC','Roll No.3','abc@abc.abc'],
    ['ABC','Roll No.4','abc@abc.abc'],
    ['ABC','Roll No.5','abc@abc.abc'],
    ['ABC','Roll No.6','abc@abc.abc'],
    ['ABC','Roll No.7','abc@abc.abc'],
    ['ABC','Roll No.8','abc@abc.abc']
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.indigo,
        backgroundColor: classroomTileBg,
        title: Text(widget.lecture[0],style: TextStyle(fontSize: 24,color: primaryBlack,fontWeight: FontWeight.w700),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date of Lecture
            Container(
              decoration: BoxDecoration(
                  color: primaryWhite,
                  border: Border(bottom: BorderSide(color: primaryBlack,width: 1))
              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(25, 15, 30, 15),
              margin: EdgeInsets.only(bottom: 30),
              child: Text('Date: ${widget.lecture[2]}'),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Roll No.')),
                  DataColumn(label: Text('Email')),
                ],
                rows: [
                  for(var i=0; i<attendance.length;i++) ...[
                    DataRow(
                        cells: [
                          DataCell(Text(attendance[i][0])),
                          DataCell(Text(attendance[i][1])),
                          DataCell(Text(attendance[i][2])),
                        ]
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(height: 20,)
          ],
        )
      ),
    );
  }
}
