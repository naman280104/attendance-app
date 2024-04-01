import 'dart:io';
import 'dart:async';
import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/teacher/services/teacher_broadcast_services.dart';
import 'package:flutter/widgets.dart';



class LecturePageWhenAccepting extends StatefulWidget {

  final String classroomID;
  final int lectureNo;
  final Map<String, dynamic> lectureInfo;

  const LecturePageWhenAccepting({
    super.key,
    required this.classroomID,
    required this.lectureNo,
    required this.lectureInfo
  });

  @override
  State<LecturePageWhenAccepting> createState() => _LecturePageWhenAcceptingState();
}

class _LecturePageWhenAcceptingState extends State<LecturePageWhenAccepting> {

  void reloadCallback() {
    setState(() {});
  }

  void startBroadcast() async {
    try {
      var resp = await TeacherClassroomServices.liveAttendance(
          widget.classroomID, widget.lectureInfo["lecture_id"], "START", context);
      print(resp);
      await broadcaster.handleStartBroadcast(context, resp['beacon_UUID']);
    }
    catch (err) {
      print(err);
      const snackBar =
          SnackBar(content: Text("Couldn't start the broadcast..."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void stopBroadcast() async {
    try{
      var resp = await TeacherClassroomServices.liveAttendance(
          widget.classroomID, widget.lectureInfo["lecture_id"], "STOP", context);
      print(resp);
      await broadcaster.handleStopBroadcast(context);
    }
    catch (err) {
      print(err);
      const snackBar = SnackBar(content: Text("Couldn't stop the broadcast..."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  late final TeacherBroadcastServices broadcaster;

  var fullAttendanceView = false;

  List<dynamic> attendance = [];
  List<dynamic> proxies = [];

  var broadcasting = false;
  TextEditingController manuallyEnteredEmail = TextEditingController();

  Future<void> markAttendanceByEmail(String student_email) async {
    try {
      String lectureID = widget.lectureInfo['lecture_id'];
      var resp = await TeacherClassroomServices.addAttendanceByEmail(widget.classroomID, lectureID, student_email, context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['message'])));
    }
    catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    }
    finally {
      setState(() {});
    }
  }

  Future<Map<String, dynamic>> fetchLectureAttendance() {
    return TeacherClassroomServices.getLectureAttendance(widget.classroomID, widget.lectureInfo['lecture_id'], context);
  }

  @override
  void initState() {
    super.initState();
    print(widget.classroomID);
    print(widget.lectureInfo);

    broadcaster = TeacherBroadcastServices(reloadCallback);
  }

  @override
  void dispose() {
    broadcaster.dispose();
    super.dispose();
  }


  Widget showBroadcastView() {
    DateTime dateTime = DateTime.parse(widget.lectureInfo["lecture_date"]);
    print(dateTime);
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';

    return Column(
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
            Expanded(
                child: SizedBox(
              width: 1,
            )),
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
                  )),
            ),
          ],
        ),
        Container(
          child: Visibility(
            visible:
                (broadcaster.isTransmissionSupported != BeaconStatus.supported),
            child: TextButton(
              onPressed: () {
                broadcaster.checkBTsupported(reloadCallback);
              },
              child: Text(
                "Your phone's Bluetooth is off. Turn on the Blutooth and tap here.",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            children: [
              Text(
                'Number of Students Present',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
              ),
              Text(
                attendance.length.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Colors.green),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            children: [
              Text(
                'Number of Proxies',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
              ),
              Text(
                proxies.length.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0,
        ),
        SizedBox(
          height: 0,
        ),
      ],
    );
  }

  Widget showFullAttendanceView() {
    return SingleChildScrollView(
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          )),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        markAttendanceByEmail(manuallyEnteredEmail.text);
                                        manuallyEnteredEmail.clear();
                                      },
                                      child: Text(
                                        'Mark',
                                        style: TextStyle(color: primaryBlack),
                                      ))
                                ],
                              ));
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
            // width: MediaQuery.of(context).size.width * 0.95,
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
                        child: Text(attendance[i]["student_name"],
                            overflow: TextOverflow.ellipsis))),
                    DataCell(SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(attendance[i]["student_roll_no"],
                            overflow: TextOverflow.ellipsis))),
                    DataCell(SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Text(attendance[i]["student_email"],
                            overflow: TextOverflow.ellipsis))),
                  ]),
                ]
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          proxies.isNotEmpty
              ? Container(
                  margin: EdgeInsets.fromLTRB(25, 10, 0, 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Proxies',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                )
              : Container(),
          proxies.isNotEmpty
              ? Container(
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
                      for (var i = 0; i < proxies.length; i++) ...[
                        DataRow(cells: [
                          DataCell(SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(proxies[i]["student_name"],
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Text(proxies[i]["student_roll_no"],
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Text(proxies[i]["student_email"],
                                  overflow: TextOverflow.ellipsis))),
                        ]),
                      ]
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Lecture ${widget.lectureNo}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
          ),
          backgroundColor: classroomTileBg,
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: FutureBuilder(
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
                    attendance.sort((a, b) => a['student_name'].compareTo(b['student_name']));
                    print("............................................");
                    print(attendance);
              
                    if (fullAttendanceView) {
                      return showFullAttendanceView();
                    }
                      // return Placeholder();
                    return showBroadcastView();
                  }
              
                  return Placeholder();
                }
              ),
            ),
          ),
        ),

        bottomNavigationBar: TextButton(
                onPressed: () {
                  broadcaster.isAdvertising ? stopBroadcast() : startBroadcast();
                },
                style: TextButton.styleFrom(
                    backgroundColor:
                        broadcaster.isAdvertising ? Colors.red : complementaryColor,
                    shape: LinearBorder()),
                child: Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Text(
                      broadcaster.isAdvertising ? 'Stop' : 'Broadcast',
                      style: TextStyle(color: primaryBlack, fontSize: 20),
                    )),
              )
      );
  }
}
