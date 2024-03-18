import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:flutter/material.dart';
import 'package:attendance/assets/constants/colors.dart';


class LecturePageWhenNotAccepting extends StatefulWidget {

  final String classroomID;
  final int lectureNo;
  final Map<String, dynamic> lectureInfo;

  const LecturePageWhenNotAccepting({
    super.key,
    required this.classroomID,
    required this.lectureNo,
    required this.lectureInfo
  });

  @override
  State<LecturePageWhenNotAccepting> createState() => _LecturePageWhenNotAcceptingState();
}

class _LecturePageWhenNotAcceptingState extends State<LecturePageWhenNotAccepting> {

  List<dynamic> attendance = [];

  Future<Map<String, dynamic>> fetchLectureAttendance() {
    return TeacherClassroomServices.getLectureAttendance(widget.classroomID, widget.lectureInfo['lecture_id'], context);
  }

  @override
  Widget build(BuildContext context) {

    final DateTime dateTime = DateTime.parse(widget.lectureInfo["lecture_date"]);
    final String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';  
    

    print(widget.lectureInfo);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.indigo,
        backgroundColor: classroomTileBg,
        title: Text('Lecture ${widget.lectureNo}',style: TextStyle(fontSize: 24,color: primaryBlack,fontWeight: FontWeight.w700),),
      ),
      body: FutureBuilder(
            future: fetchLectureAttendance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.hasData) {
                attendance = snapshot.data?['lecture_attendance'];
                attendance.sort(
                    (a, b) => a['student_name'].compareTo(b['student_name']));
                print("............................................");
                print(attendance);

                return SingleChildScrollView(
                    child: Column(
                  children: [
                    // Date of Lecture
                    Container(
                      decoration: BoxDecoration(
                          color: primaryWhite,
                          border: Border(
                              bottom:
                                  BorderSide(color: primaryBlack, width: 1))),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(25, 15, 30, 15),
                      margin: EdgeInsets.only(bottom: 30),
                      child: Text('Date: ${formattedDate}'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: DataTable(
                        columnSpacing: 15,
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Roll No.')),
                          DataColumn(label: Text('Email')),
                        ],
                        rows: [
                          for (var i = 0; i < attendance.length; i++) ...[
                            DataRow(cells: [
                              DataCell(SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  child: Text(attendance[i]["student_name"], overflow: TextOverflow.ellipsis))),
                              DataCell(SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: Text(attendance[i]["student_roll_no"], overflow: TextOverflow.ellipsis))),
                              DataCell(SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: Text(attendance[i]["student_email"], overflow: TextOverflow.ellipsis))),
                            ]),
                          ]
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "This lecture is no longer accepting attendance.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ));
              }

              return Placeholder();
            }));
  }

}