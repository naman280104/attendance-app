import 'dart:io';
import 'dart:typed_data';

import 'package:attendance/teacher/presentation/screens/teacher_course_students_list.dart';
import 'package:attendance/teacher/presentation/screens/teacher_new_lecture.dart';
import 'package:attendance/teacher/presentation/screens/teacher_quiz.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_classroom_app_bar.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_lecture_tile.dart';
import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:excel/excel.dart' as Excel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import '../../../assets/constants/colors.dart';

class TeacherClassroom extends StatefulWidget {
  final String classroomName;
  final String classroomID;
  final Function changeClassroomNameCallback;
  const TeacherClassroom({
    super.key,
    required this.classroomName,
    required this.classroomID,
    required this.changeClassroomNameCallback,
  });

  @override
  State<TeacherClassroom> createState() => _TeacherClassroomState();
}

class _TeacherClassroomState extends State<TeacherClassroom> {

  late String classroomCode, classroomName, beaconID;
  bool isGenerating = false;

  Future<Map<String, dynamic>> fetchClassroomInfo() {
    // return Future.delayed(Duration(seconds: 2), () { return {"1": "2"}; });
    return TeacherClassroomServices.getClassroomInfo(widget.classroomID, context);
  }

  void handleGenerateReport() async {
    if (isGenerating) return;
    try {
      isGenerating = true;
      var resp = await TeacherClassroomServices.getAttendanceReport(widget.classroomID, context);
      print(resp);

      var report = resp['attendance_report'];

      List<String> studentEmails = report.keys.toList();
      int n = studentEmails.length;

      if (n == 0) {
        throw('No students in the classroom yet!');
      }

      int noOfLec = report[studentEmails[0]]['attendance'].length;

      var excel = Excel.Excel.createExcel();
      var sheetObject = excel['Sheet1'];

      List<Excel.CellValue> columnHeaders = [
        Excel.TextCellValue('Name'),
        Excel.TextCellValue('Email'),
        Excel.TextCellValue('Roll No'),
        ...List.generate(noOfLec, (idx) => Excel.TextCellValue('Lecture ${idx+1}')),
        Excel.TextCellValue('Attendance Percentage'),
      ];

      sheetObject.appendRow(columnHeaders);

      for (int i=0; i<n; i++) {
        var attendanceInfo = report[studentEmails[i]];
        // print(attendanceInfo['attendance']);
        // print(attendanceInfo['attendance'].runtimeType);
        // continue;

        List<Excel.IntCellValue> attendanceList = List.generate(noOfLec, (idx) => Excel.IntCellValue(attendanceInfo['attendance'][idx] ? 1 : 0));

        int presentIn = attendanceList.where((item) => item.value==1).length;
        double attendancePercentage = 100.0 * presentIn / attendanceList.length;
        attendancePercentage = (attendancePercentage * 100).roundToDouble() / 100;

        List<Excel.CellValue> infoRow = [
          Excel.TextCellValue('${attendanceInfo['name']}'),
          Excel.TextCellValue('${studentEmails[i]}'),
          Excel.TextCellValue('${attendanceInfo['roll_no']}'),
          ...attendanceList,
          Excel.DoubleCellValue(attendancePercentage),
        ];
        print(infoRow);
        sheetObject.appendRow(infoRow);
      }

      var fileBytes = excel.save();

      String classroomNameWithoutSpaces = widget.classroomName.replaceAll(' ', '_');
      DateTime now = DateTime.now();
      String convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}_${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}";

      String outputFileName = '${classroomNameWithoutSpaces}_${convertedDateTime}';

      final pickedDirectory = await FlutterFileDialog.pickDirectory();

      if (pickedDirectory != null) {
        final filePath = await FlutterFileDialog.saveFileToDirectory(
          directory: pickedDirectory,
          data: Uint8List.fromList(fileBytes!),
          fileName: outputFileName,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          replace: true,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Excel file $outputFileName saved to ${filePath}')
          )
        );

      }
    }
    catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()),));
    }
    finally {
      isGenerating = false;
    }
  }

  void handleAddLecture() async {
    print('Add Lecture Button Pressed for Classroom $classroomName');

    try {
      var resp = await TeacherClassroomServices.addLecture(widget.classroomID, context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp["message"])));
      setState(() {});
    }
    catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()),));
    }
  }

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

  @override
  void initState() {
    classroomName = widget.classroomName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TeacherClassroomAppBar(classroomName: classroomName,classroomID: widget.classroomID, changeClassroomNameCallback: widget.changeClassroomNameCallback,),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder(
              future: fetchClassroomInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Classroom Code
                        Container(
                          decoration: BoxDecoration(
                              color: primaryWhite,
                              border: Border(
                                  bottom:
                                      BorderSide(color: primaryBlack, width: 1))),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(25, 15, 30, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Text('Classroom Code: ${snapshot.data!["classroom_code"]}')
                              ),
                              OutlinedButton(
                                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherQuiz(classroomID: widget.classroomID, classroomName: widget.classroomName)));},
                                child: Text("Quiz")
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15,bottom: 10),
                          child: ElevatedButton.icon(
                            onPressed: handleGenerateReport,
                            icon: Icon(Icons.file_download, color: Colors.green.shade800),
                            label: Text('Generate Attendance Report', style: TextStyle(color: Colors.green.shade800))
                          )
                        ),
                        // Add Lecture
                        ElevatedButton(
                          onPressed: handleAddLecture,
                          style: ElevatedButton.styleFrom(
                              elevation: 3,
                              backgroundColor: Color(0xFFEEEEEE),
                              shape: RoundedRectangleBorder(
                                // side: BorderSide(width: 1.5,color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.7,
                            padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                            child: Text(
                              'Add Lecture',
                              style: TextStyle(
                                  color: primaryBlack,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        // Lectures
                        ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!["classroom_lectures"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return TeacherLectureTile(
                              classroomID: widget.classroomID,
                              lectureNo: index+1,
                              noOfStudents: snapshot.data!["no_of_students"],
                              lectureInfo: snapshot.data!["classroom_lectures"][index]
                            );
                          },
                        ),
                        // End Space
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  );
                }
                return Placeholder();
              }),
        ),
      bottomNavigationBar: TextButton(
        onPressed: (){
          print('Students List Button Pressed for Classroom $classroomName');
          Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentList(classroomName: classroomName, classroomID: widget.classroomID)));
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
