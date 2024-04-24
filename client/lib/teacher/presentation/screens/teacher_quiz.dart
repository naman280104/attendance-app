import 'dart:io';

import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_quiz_tile.dart';
import 'package:attendance/teacher/services/teacher_broadcast_services.dart';
import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class TeacherQuiz extends StatefulWidget {
  final String classroomID, classroomName;
  const TeacherQuiz({super.key, required this.classroomID, required this.classroomName});

  @override
  State<TeacherQuiz> createState() => _TeacherQuizState();
}

class _TeacherQuizState extends State<TeacherQuiz> {

  int noOfQuizzes = 0;
  late final TeacherBroadcastServices broadcaster;

  void reloadCallback() {
    setState(() {});
  }

  Future<Map<String, dynamic>> fetchAllQuizzes() async {
    try {
      var resp = await TeacherClassroomServices.getAllQuizzes(widget.classroomID, context);
      print(resp);
      noOfQuizzes = resp['quizzes'].length;

      return resp;

    } catch (err) {
      rethrow;
    }
    // return Future.delayed(Duration(seconds: 2), () => ".....................future returned this");
  }


  void handleAddQuiz () async {
    TextEditingController controller = TextEditingController();
    TextEditingController noOfQuesController = TextEditingController();
    File? pickedFile;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Quiz Details"),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Quiz Name",
                    border: OutlineInputBorder()
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: noOfQuesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "No. of questions",
                    border: OutlineInputBorder()
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Select quiz pdf"),
                    IconButton(
                      onPressed: () async {
                        var filePath = await FlutterFileDialog.pickFile();
                        print(filePath);
                        if (filePath != null) {
                          pickedFile = File(filePath);
                          setState(() {});
                          print(pickedFile);
                        }
            
                      },
                      icon: Icon(Icons.attach_file)
                    )
                  ],
                ),
                SizedBox(height: 20),
                
                Text(pickedFile==null ? "No file selected" : "Selected File: ${pickedFile!.path.substring(pickedFile!.path.lastIndexOf('/') + 1)}")
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  var resp = await TeacherClassroomServices.addQuiz(widget.classroomID, controller.text, noOfQuesController.text, pickedFile!.path, context);
                  print(resp);
                  Navigator.pop(context);
                } catch (err) {
                  SnackBar sb = SnackBar(content: Text(err.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(sb);
                } finally {
                  setState(() {});
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      }
    );
  }


  @override
  void initState() {
    super.initState();
    broadcaster = TeacherBroadcastServices(() {});
  }

  @override
  void dispose() {
    broadcaster.handleStopBroadcast(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quizzes"),
        backgroundColor: classroomTileBg,
      ),
      body: FutureBuilder(
        future: fetchAllQuizzes(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                if (snapshot.hasData) {
                  print(snapshot.data);
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        
                        SizedBox(height: 10, width: MediaQuery.of(context).size.width,),

                        ElevatedButton(
                          onPressed: handleAddQuiz,
                          style: ElevatedButton.styleFrom(
                              elevation: 3,
                              backgroundColor: Color(0xFFEEEEEE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.7,
                            padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                            child: Text(
                              'Add Quiz',
                              style: TextStyle(
                                  color: primaryBlack,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!['quizzes'].length,
                          itemBuilder: (context, index) {
                            return TeacherQuizTile(
                              classroomID: widget.classroomID,
                              classroomName: widget.classroomName,
                              quizInfo: snapshot.data!['quizzes'][index],
                              broadcaster: broadcaster,
                              reloadCallback: reloadCallback
                            );
                          }
                        ),

                        SizedBox(height: 30,)
                      ],
                    ),
                  );
                }
                return Placeholder();
        }),
      ), 
    );
  }
}