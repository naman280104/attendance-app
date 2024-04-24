import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TeacherNewLecture extends StatefulWidget {
  final String classroomName, courseCode, lectureNumber;
  final String lectureID, lectureCode;
  final String lectureDate;
  const TeacherNewLecture(
      {super.key,
      required this.classroomName,
      required this.courseCode,
      required this.lectureNumber,
      required this.lectureID,
      required this.lectureCode,
      required this.lectureDate});

  @override
  State<TeacherNewLecture> createState() => _TeacherNewLectureState();
}

class _TeacherNewLectureState extends State<TeacherNewLecture> {
  var fullAttendanceView = false;
  List<dynamic> attendance = [
    ['ABC', 'Roll No.1', 'abc@abc.abc'],
    ['ABC', 'Roll No.2', 'abc@abc.abc'],
    ['ABC', 'Roll No.3', 'abc@abc.abc'],
    ['ABC', 'Roll No.4', 'abc@abc.abc'],
    ['ABC', 'Roll No.5', 'abc@abc.abc'],
    ['ABC', 'Roll No.6', 'abc@abc.abc'],
    ['ABC', 'Roll No.7', 'abc@abc.abc'],
    ['ABC', 'Roll No.8', 'abc@abc.abc'],
    ['ABC', 'Roll No.9', 'abc@abc.abc'],
  ];
  List<dynamic> proxies = [
    ['ABC', 'Roll No.10', 'abc@abc.abc'],
    ['ABC', 'Roll No.11', 'abc@abc.abc'],
  ];
  var broadcasting = false;
  TextEditingController manuallyEnteredEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {

    DateTime dateTime = DateTime.parse(widget.lectureDate);
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';  
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecture ${widget.lectureNumber}',style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
        backgroundColor: classroomTileBg,
      ),
      body:
      fullAttendanceView == false ?
      Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(15, 15, 0, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFEEEEEE),
                  ),
                  child: Text(
                    'Date: $formattedDate',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ),
                Expanded(child: SizedBox(width: 1,)),
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
                          )),
                      child: Text(
                        'Attendance View',
                        style: TextStyle(color: primaryBlack),
                      )
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  Text('Number of Students Present',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),),
                  Text(attendance.length.toString(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 30,color: Colors.green),),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  Text('Number of Proxies',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),),
                  Text(proxies.length.toString(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 30,color: Colors.red),),
                ],
              ),
            ),
            SizedBox(height: 0,),
            SizedBox(height: 0,),
          ],
        )
      :
      SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(15, 15, 0, 20),
                  child: TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Mark Attendance'),
                              content: TextField(
                                controller: manuallyEnteredEmail,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter Email Id",
                                ),
                              ),
                              actions: [
                                TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: complementaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        )
                                    ),
                                    onPressed: (){
                                      print(manuallyEnteredEmail.text);
                                      manuallyEnteredEmail.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Mark',style: TextStyle(color: primaryBlack),)
                                )
                              ],
                            )
                        );
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: complementaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      child: Text(
                        'Add Email',
                        style: TextStyle(color: primaryBlack),
                      )),
                ),
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
                          )),
                      child: Text(
                        'Broadcast View',
                        style: TextStyle(color: primaryBlack),
                      )),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Attendance')),
                ],
                rows: [
                  for (var i = 0; i < attendance.length; i++) ...[
                    DataRow(cells: [
                      DataCell(Text(attendance[i][0])),
                      DataCell(Text(attendance[i][1])),
                      DataCell(Text(attendance[i][2])),
                    ]),
                  ]
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 10, 0, 10),
              alignment: Alignment.centerLeft,
              child: Text('Proxies',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700),),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Attendance')),
                ],
                rows: [
                  for (var i = 0; i < proxies.length; i++) ...[
                    DataRow(cells: [
                      DataCell(Text(proxies[i][0])),
                      DataCell(Text(proxies[i][1])),
                      DataCell(Text(proxies[i][2])),
                    ]),
                  ]
                ],
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      bottomNavigationBar: fullAttendanceView == false ?
      TextButton(
        onPressed: (){
          if (!broadcasting) print('Broadcast Button Pressed for ${widget.classroomName}');
          else print('Stop Button Pressed for Classroom ${widget.classroomName}');
          setState(() {
            broadcasting = !broadcasting;
          });
        },
        style: TextButton.styleFrom(
            backgroundColor: broadcasting==false? complementaryColor:Colors.red,
            shape: LinearBorder()
        ),
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(broadcasting == false ?'Broadcast':'Stop',style: TextStyle(color: primaryBlack,fontSize: 20),)
        ),
      )
      :
      SizedBox(height: 0,)
    );
  }
}
