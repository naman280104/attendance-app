import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/student/presentation/screens/student_quiz.dart';
import 'package:attendance/student/services/student_authentication_services.dart';
import 'package:attendance/student/services/student_broadcast_services.dart';
import 'package:attendance/student/services/student_classroom_services.dart';
import 'package:flutter/material.dart';

String formatDDMMYYYY(String date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';  
  return formattedDate;
}

class StudentClassroom extends StatefulWidget {
  final String classroomName, classroomID;

  const StudentClassroom({
    super.key,
    required this.classroomName,
    required this.classroomID
  });

  @override
  State<StudentClassroom> createState() => _StudentClassroomState();
}

class _StudentClassroomState extends State<StudentClassroom> with WidgetsBindingObserver {

  late final StudentBroadcastServices receiver;

  bool reFetchAttendance = true;
  Map<String, dynamic> attendanceInfo = {};
  String lastUUID = "";
  bool fullAttendanceView = false;

  void reloadCallback() {
    setState(() {});
  }

  Future<void> handleBeaconFound(String uuid) async {
    try{
      if (uuid != lastUUID) {
        lastUUID = uuid;
        String advID = await getAdvertisingId();
        var resp = await StudentClassroomServices.markLiveAttendance(context, widget.classroomID, uuid, advID);
        SnackBar sb = SnackBar(content: Text(resp['message']));
        ScaffoldMessenger.of(context).showSnackBar(sb);
        receiver.stopScan();
        setState(() {
          reFetchAttendance = true;
        });
      }
    }
    catch (err) {
      String errMsg = err.toString();
      SnackBar sb = SnackBar(content: Text(errMsg));
      ScaffoldMessenger.of(context).showSnackBar(sb);
      receiver.stopScan();
    }
  }

  void handleMarkAttendance() async {
    lastUUID = "";
    if (receiver.isScanning) {
      await receiver.stopScan();
    } else {
      try {
        var resp = await StudentClassroomServices.getBeaconIdentifier(context, widget.classroomID);
        await receiver.startScan(resp['beacon_id']);
      }
      catch (err) {
        // print(err);
        debugPrint(err.toString());
        SnackBar sb = SnackBar(content: Text(err.toString()));
        ScaffoldMessenger.of(context).showSnackBar(sb);
      }
    }
  }

  Future<Map<String, dynamic>> getMyAttendance() async {
    if (reFetchAttendance) {
      attendanceInfo = await StudentClassroomServices.getMyAttendance(context, widget.classroomID);
      reFetchAttendance = false;
    }
    return attendanceInfo;
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    receiver = StudentBroadcastServices(reloadCallback, handleBeaconFound);

  }

  @override
  void dispose() {
    receiver.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  Widget showMarkAttendanceView() {
    List<dynamic> attendance = attendanceInfo["attendance"];
    String lastAttendanceDate = "";
    for(int i=attendance.length-1; i>=0; i--) {
      if (attendance[i]["is_present"]) {
        lastAttendanceDate = attendanceInfo["attendance"][i]["date"];
      }
    }

    String formattedDate = "";
    if (lastAttendanceDate != "") formattedDate = formatDDMMYYYY(lastAttendanceDate);

    
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 20),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StudentQuizView(classroomID: widget.classroomID,)));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: complementaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  child: Text('Attempt Quiz',style: TextStyle(color: primaryBlack),)),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 20),
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
            ],
          ),
          
          formattedDate == ""
          ? 
          Text('No attendance marked.')
          :
          Text('Last Attendance on \n $formattedDate',textAlign: TextAlign.center,style: TextStyle(fontSize: 18),),
          
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
                print('Mark Attendance Button Pressed for Classroom ${widget.classroomName}');
                handleMarkAttendance();
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                width: MediaQuery.of(context).size.width*0.6,
                child: Center(
                  child: receiver.isScanning ? CircularProgressIndicator() : Text('Mark Attendance',style: TextStyle(fontSize: 21,color: primaryBlack))
                ),
              ),
            ),
          )
        ],
      );
  }


  Widget showFullAttendanceView() {
    List<dynamic> attendance = attendanceInfo["attendance"];

    return SingleChildScrollView(
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
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Attendance')),
                ],
                rows: [
                  for(var i=0; i<attendance.length;i++) ...[
                    DataRow(
                      cells: [
                        DataCell(Text('Lecture ${i+1}')),
                        DataCell(Text(formatDDMMYYYY(attendance[i]["date"]))),
                        DataCell(Text(attendance[i]["is_present"] ? "Present" : "Absent")),
                      ]
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.classroomName,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),),backgroundColor: classroomTileBg),
      body: FutureBuilder(
        future: getMyAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            print(snapshot.data);
            if (fullAttendanceView) {
              return showFullAttendanceView();
            }
            return showMarkAttendanceView();
          }
          return Placeholder();
        })
      );
  }
}
