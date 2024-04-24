import 'dart:ffi';

import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/student/presentation/widgets/stdent_pdf_display.dart';
import 'package:attendance/student/services/student_broadcast_services.dart';
import 'package:attendance/student/services/student_classroom_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:flutter/widgets.dart';

class StudentQuizView extends StatefulWidget {
  final String classroomID;
  const StudentQuizView({super.key, required this.classroomID});

  @override
  State<StudentQuizView> createState() => _StudentQuizViewState();
}

class _StudentQuizViewState extends State<StudentQuizView> with WidgetsBindingObserver {

  late final StudentBroadcastServices receiver;
  int warnings = 0;
  int selectedIndex = 0;
  late List<int> selectedOptions;

  bool reFetchQuiz = true;
  bool quizBeaconAvailable = false;
  String lastUUID = "";
  Map<String, dynamic> resp = {};


  void reloadCallback() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    receiver = StudentBroadcastServices(reloadCallback, handleBeaconFound);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> handleBeaconFound(String uuid) async {
    try {
      if (uuid != lastUUID) {
        lastUUID = uuid;
        String advID = "adv_id_placeholder";
        
        resp = await StudentClassroomServices.getQuiz(
        context, widget.classroomID, uuid, advID);

        receiver.stopScan();
        setState(() {
          quizBeaconAvailable = true;
          reFetchQuiz = true;
        });
      }
    } catch (err) {
      String errMsg = err.toString();
      print("handle found..................");
      print(errMsg);
      SnackBar sb = SnackBar(content: Text(errMsg));
      ScaffoldMessenger.of(context).showSnackBar(sb);
      receiver.stopScan();
    }
  }

  void handleAttemptQuiz() async {
    print("attempt button");
    lastUUID = "";

    if (receiver.isScanning) {
      await receiver.stopScan();
    } else {
      try {
        print("........................");
        var resp = await StudentClassroomServices.getBeaconIdentifier(
            context, widget.classroomID);
        print(resp);
        await receiver.startScan(resp['beacon_id']);

      } catch (err) {
        SnackBar sb = SnackBar(content: Text(err.toString()));
        ScaffoldMessenger.of(context).showSnackBar(sb);
      }
    }
  }

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Are you sure you want to leave this quiz?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Stay'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget quizAvailableView() { 
    print(resp['no_of_questions']);
    List<int> pdfData = [];
    resp["data"].forEach((element) => pdfData.add(element));

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog();
      },
      child: Column(
        children: [
          PDFDisplay(
            // path: pathPDF,
            data: Uint8List.fromList(pdfData)
          ),

          MarkAnswer(
            classroomID: widget.classroomID,
            beaconUUID: lastUUID,
            noOfQues: resp['no_of_questions']
          ),

          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: quizBeaconAvailable
              ? quizAvailableView()
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 60,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: complementaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        onPressed: handleAttemptQuiz,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Center(
                              child: receiver.isScanning
                                  ? CircularProgressIndicator()
                                  : Text('Attempt Quiz',
                                      style: TextStyle(
                                          fontSize: 21, color: primaryBlack))),
                        ),
                      ),
                    ),

                    Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text("Once the quiz starts, you will receive 2 warnings if notification panel is opened or if you switch apps. On 3rd warning, the quiz will auto-submit.",
                            style: TextStyle(color: Colors.red),
                          ),
                    ),

                    
                ],
              )),
    );
  }
}


class MarkAnswer extends StatefulWidget {
  final String classroomID, beaconUUID;
  final int noOfQues;
  const MarkAnswer({
    super.key,
    required this.classroomID,
    required this.beaconUUID,
    required this.noOfQues
  });

  @override
  State<MarkAnswer> createState() => _MarkAnswerState();
}

class _MarkAnswerState extends State<MarkAnswer> with WidgetsBindingObserver {

  late List<int> selectedOptions;
  int selectedIndex = 0;
  int warnings = 0;


    void handleSubmit() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit the quiz?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Yes'),
              onPressed: () async {
                await submit(false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> submit(bool autoSubmitted) async {
    try {
      var resp = await StudentClassroomServices.submitQuiz(context, widget.classroomID, widget.beaconUUID, selectedOptions);
      print(resp);

      Navigator.of(context).pop();

      SnackBar sb = SnackBar(content: Text(autoSubmitted ? "Quiz Auto-Submitted" : resp['message']));
      ScaffoldMessenger.of(context).showSnackBar(sb);


    } catch (err) {
      SnackBar sb = SnackBar(content: Text(err.toString()));
      ScaffoldMessenger.of(context).showSnackBar(sb);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addObserver(this);
    selectedOptions = List.generate(widget.noOfQues, (index) => -1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      setState(() {
        warnings++;
      });
      if (warnings == 3) {
        submit(true);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        if(warnings > 0) Text("Warnings: $warnings"),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Text("Mark your answers", style: TextStyle(fontSize: 18)),
        ),
        //horizontal slider
        SizedBox(
          height: 50,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.noOfQues + 1,
              itemBuilder: (context, index) {
                if (index == widget.noOfQues) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: (index == selectedIndex)
                                ? complementaryColor
                                : null),
                        onPressed: handleSubmit,
                        child: Text("SUBMIT")),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: (index == selectedIndex)
                              ? complementaryColor
                              : null),
                      onPressed: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Text("Q${index + 1}")),
                );
              }),
        ),

        SizedBox(
          height: 20,
        ),

        // option selector
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return Flexible(
                flex: 1,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        backgroundColor:
                            (selectedOptions[selectedIndex] == index + 1)
                                ? complementaryColor
                                : null),
                    onPressed: () {
                      // 4 options available per ques
                      if (index >= 4) {
                        selectedOptions[selectedIndex] =
                            -1; // to unmark or unselect options for a question
                      } else {
                        selectedOptions[selectedIndex] = index + 1;
                      }

                      setState(() {});
                    },
                    child: (index == 4)
                        ? Text("Unmark")
                        : Text("Option ${index + 1}")),
              );
            })),
      ],
    );
  }
}
