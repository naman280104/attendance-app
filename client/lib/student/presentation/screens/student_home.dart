import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:attendance/student/presentation/screens/student_pdf_test.dart';
import 'package:attendance/student/presentation/widgets/student_invite_card.dart';
import 'package:attendance/student/services/student_classroom_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/student/presentation/widgets/student_classroom_card.dart';
import 'package:attendance/student/presentation/widgets/student_app_bar.dart';
import 'package:attendance/assets/constants/colors.dart';



class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {

  final TextEditingController newClassroomName = TextEditingController(); 
  
  void deleteClassroomCallback(){
    setState(() {});
  }

  void reloadCallback() {
    setState(() {});
  }

  late final String username;

  Future<Map<String, dynamic>> fetchStudentHomeData() async {
    Map<String, dynamic> result = {};
    result['INVITES'] = await StudentClassroomServices.getInvites(context);
    result['CLASSROOMS'] = await StudentClassroomServices.getAllClassrooms(context);
    return result;
  }


  void joinClassroomByCode(String classroomCode) async {
    try{
      Navigator.pop(context);
      var resp = await StudentClassroomServices.joinClassroomByCode(context, classroomCode);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp["message"])));
      setState(() {});
    }
    catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    }
    return;
  }

  
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
            future: fetchStudentHomeData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                var invites = snapshot.data?['INVITES']['invites'];
                var classrooms = snapshot.data?['CLASSROOMS']['classrooms'];
                return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    itemCount: invites.length + classrooms.length,
                    itemBuilder: (context, index) {
                      if (index < invites.length) {
                        return StudentInviteCard(
                          inviteID: invites[index]['invite_id'],
                          classroomName: invites[index]['classroom_name'],
                          classroomTeacher: invites[index]['classroom_teacher'],
                          reloadCallback: reloadCallback,
                        );
                      }
                      else {
                        int invLen = invites.length;
                        index -= invLen;
                        return StudentClassroomCard(
                          classroomName: classrooms[index]['classroom_name']!,
                          classroomTeacher: classrooms[index]['classroom_teacher']!,
                          classroomID: classrooms[index]['classroom_id']!,
                          deleteClassroomCallback: deleteClassroomCallback,
                        );
                      }
                    },
                  ),
                );
              }
              return Placeholder();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              title: Text('Classroom Code'),
              content: TextField(
                controller: newClassroomName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Classroom Code",
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
                  onPressed: () {
                    joinClassroomByCode(newClassroomName.text);
                  },
                  child: Text('Join',style: TextStyle(color: primaryBlack),)
                )
              ],
            )
          );
          print('Floating Action Button Pressed');
        },
        backgroundColor: primaryBlack,
        child: const Icon(
          CupertinoIcons.plus,
          size: 30,
          color: primaryWhite,
        )
      ),
    );
  }
}

