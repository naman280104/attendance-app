import 'dart:typed_data';

import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/teacher/services/teacher_broadcast_services.dart';
import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:excel/excel.dart' as Excel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class TeacherQuizTile extends StatefulWidget {

  final String classroomID, classroomName;
  final Map<String, dynamic> quizInfo;
  final Function reloadCallback;
  final TeacherBroadcastServices broadcaster;

  const TeacherQuizTile({
    super.key,
    required this.classroomID,
    required this.classroomName,
    required this.quizInfo,
    required this.broadcaster,
    required this.reloadCallback,
  });

  @override
  State<TeacherQuizTile> createState() => _TeacherQuizTileState();
}

class _TeacherQuizTileState extends State<TeacherQuizTile> {

  bool isBroadcasting = false;
  bool isAccepting = false;

  void handleDeleteQuiz() async {
    try {
      String quizID = widget.quizInfo['quiz_id'];
      var resp = await TeacherClassroomServices.removeQuiz(widget.classroomID, quizID, context);

      widget.reloadCallback();

      SnackBar sb = SnackBar(content: Text(resp['message']));
      ScaffoldMessenger.of(context).showSnackBar(sb);
    } catch (err) {
      SnackBar sb = SnackBar(content: Text(err.toString()));
      ScaffoldMessenger.of(context).showSnackBar(sb);
    }
  }

  void handleChangeAccepting(bool value) async {
    String action = value ? 'START' : 'STOP';
    try {
      String quizID = widget.quizInfo['quiz_id'];
      var resp = await TeacherClassroomServices.changeQuizState(widget.classroomID, quizID, action, context);
      setState(() {
        isAccepting = value;
      });      

      SnackBar sb = SnackBar(content: Text(resp['message']));
      ScaffoldMessenger.of(context).showSnackBar(sb);
    } catch (err) {
      SnackBar sb = SnackBar(content: Text(err.toString()));
      ScaffoldMessenger.of(context).showSnackBar(sb);
    }
  }

  void handleDownloadResponses() async {
    try {
      var resp = await TeacherClassroomServices.getQuizResponses(widget.classroomID, widget.quizInfo['quiz_id'], context);

      var responses = resp['quiz_responses'];
      int noOfQues = resp['no_of_questions'];

      List<String> studentEmails = responses.keys.toList();
      int n = studentEmails.length;


      var excel = Excel.Excel.createExcel();
      var sheetObject = excel['Sheet1'];

      List<Excel.CellValue> columnHeaders = [
        Excel.TextCellValue('Name'),
        Excel.TextCellValue('Email'),
        Excel.TextCellValue('Roll No'),
        ...List.generate(noOfQues, (idx) => Excel.TextCellValue('Ques ${idx+1}')),
      ];

      sheetObject.appendRow(columnHeaders);

      print("..........test1");

      for (int i=0; i<n; i++) {
        var studentResponse = responses[studentEmails[i]];
        print(studentResponse);
        // print(attendanceInfo['attendance']);
        // print(attendanceInfo['attendance'].runtimeType);
        // continue;

        List<Excel.IntCellValue> attendanceList = List.generate(noOfQues, (idx) => Excel.IntCellValue(studentResponse['response'][idx]));

        List<Excel.CellValue> infoRow = [
          Excel.TextCellValue('${studentResponse['name']}'),
          Excel.TextCellValue('${studentEmails[i]}'),
          Excel.TextCellValue('${studentResponse['roll_no']}'),
          ...attendanceList,
        ];
        print(infoRow);
        sheetObject.appendRow(infoRow);
      }
      print("..........test2");

      var fileBytes = excel.save();

      String classroomNameWithoutSpaces = widget.classroomName.replaceAll(' ', '_');
      DateTime now = DateTime.now();
      String convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}_${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}";

      String outputFileName = '${classroomNameWithoutSpaces}_${widget.quizInfo['quiz_name']}_${convertedDateTime}';

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

    } catch (err) {
      SnackBar sb = SnackBar(content: Text(err.toString()));
      ScaffoldMessenger.of(context).showSnackBar(sb);
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.quizInfo);
    isAccepting = widget.quizInfo['is_accepting'];
    isBroadcasting = widget.broadcaster.isAdvertising;
  }

  @override
  Widget build(BuildContext context) {
    print("...................$isBroadcasting");
    return Container(
      margin: EdgeInsets.fromLTRB(35, 15, 35, 0),
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlack),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(widget.quizInfo['quiz_name']),
              ),
              PopupMenuButton<int>(
                padding: EdgeInsets.all(0),
                onSelected: (value) {
                  if (value == 0) {
                    handleDownloadResponses();
                  } else if (value == 1) {
                    // Delete Quiz
                    handleDeleteQuiz();
                  }
                },
                itemBuilder: (BuildContext context) {
                  // Define the menu items for the PopupMenuButton
                  return <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text("Download Responses"),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text("Delete Quiz"),
                    ),
                  ];
                },
              )
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text("Quiz ${widget.quizInfo['file_name']}"),
          ),

          Row(
            children: [
              Text("  Broadcast: "),
              // CupertinoSwitch(value: value, onChanged: onChanged)
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  splashRadius: 20,
                  value: isBroadcasting,
                  inactiveThumbColor: Colors.grey[600],
                  activeColor: Colors.green,
                  onChanged: (bool value) async {
                    String uuidToSet = widget.quizInfo['beacon_UUID'];
                    try {
                      if (value) {
                        await widget.broadcaster.handleStartBroadcast(context, uuidToSet);
                      } else {
                        await widget.broadcaster.handleStopBroadcast(context);
                      }
                      setState(() {
                        isBroadcasting = 
                          (widget.broadcaster.isAdvertising) && 
                          (widget.broadcaster.uuidBeingAdvertised == widget.quizInfo['beacon_UUID']);
                      });
                    } catch (err) {
                      print(err);
                    }
                  }
                ),
              )
            ],
          ),

          Row(
            children: [
              Text("  Accepting: "),
              // CupertinoSwitch(value: value, onChanged: onChanged)
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  splashRadius: 20,
                  value: isAccepting,
                  inactiveThumbColor: Colors.grey[600],
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    handleChangeAccepting(value);
                  }
                ),
              )
            ],
          )



        ],
      ),
    );
  }
}