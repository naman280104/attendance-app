import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter/material.dart';

class StudentClassroom extends StatefulWidget {
  final String courseName;

  const StudentClassroom({
    super.key,
    required this.courseName
  });

  @override
  State<StudentClassroom> createState() => _StudentClassroomState();
}

class _StudentClassroomState extends State<StudentClassroom> {

  String lastAttendanceDate = 'YYYY/MM/DD';
  bool fullAttendanceView = false;
  List<dynamic> attendance = [
    ['Lecture 1','2024-02-25','Present'],
    ['Lecture 2','2024-02-26','Absent'],
    ['Lecture 3','2024-02-27','Present']
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),),backgroundColor: classroomTileBg),
      body:
          fullAttendanceView == false ?
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.fromLTRB(0, 15, 15, 20),
            child: TextButton(
              onPressed: () {
                setState(() {
                  fullAttendanceView = true;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFEEEEEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
              ),
              child: Text('View Attendance',style: TextStyle(color: primaryBlack),)),
          ),
          Text('Last Attendance on \n $lastAttendanceDate',textAlign: TextAlign.center,style: TextStyle(fontSize: 18),),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: complementaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
              ),
              onPressed: (){
                print('Mark Attendance Button Pressed for course ${widget.courseName}');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Text('Mark Attendance',style: TextStyle(fontSize: 21,color: primaryBlack),),
              ),
            ),
          )
        ],
      ) :
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.fromLTRB(0, 15, 15, 20),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      fullAttendanceView = false;
                    });
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                  ),
                  child: Text('Mark Attendance',style: TextStyle(color: primaryBlack),)),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Lecture')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Attendance')),
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
        ),
      ),
    );
  }
}
