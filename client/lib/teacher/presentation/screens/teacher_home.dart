import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:attendance/teacher/services/teacher_profile_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_classroom_card.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_app_bar.dart';
import 'package:attendance/assets/constants/colors.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({
    super.key,
  });

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final TextEditingController newClassroomCode = TextEditingController();
  void addClassroomCallback() {
    setState(() {});
  }
  void deleteClassroomCallback() {
    setState(() {});
  }
  void changeClassroomNameCallback() {
    setState(() {});
  }

  @override
  void initState() {
    // classrooms = [
    //   {'classroomName': 'Course1','numberOfStudents':'79','courseCode':'axhyeds'},
    //   {'classroomName': 'Course2','numberOfStudents':'79','courseCode':'jdhydki'}
    // ];
    super.initState();
  }

  Future<Map<String, dynamic>> fetchClassrooms() {
    return TeacherClassroomServices.getClassrooms(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TeacherAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
            future: fetchClassrooms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                print(snapshot.data);
                var classrooms = snapshot.data?["classrooms"];
                print(classrooms);
                return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    itemCount: classrooms.length,
                    itemBuilder: (context, index) {
                      return TeacherClassroomCard(
                        classroomName: classrooms[index]['classroom_name']!,
                        numberOfStudents:
                            classrooms[index]['no_of_students']!.toString(),
                        classroomID:
                            classrooms[index]['classroom_id']!.toString(),
                        deleteClassroomCallback: deleteClassroomCallback,
                        changeClassroomNameCallback: changeClassroomNameCallback,
                      );
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
                      title: Text('Classroom Name'),
                      content: TextField(
                        controller: newClassroomCode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter Classroom Name",
                        ),
                      ),
                      actions: [
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: complementaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            onPressed: () async {
                              Navigator.pop(context);
                              await TeacherClassroomServices.createClassroom(
                                  newClassroomCode.text, context);
                              print(newClassroomCode.text);
                              addClassroomCallback();
                            }, 
                            child: Text(
                              'Add Classroom',
                              style: TextStyle(color: primaryBlack),
                            ))
                      ],
                    ));
            print('Floating Action Button Pressed');
          },
          backgroundColor: primaryBlack,
          child: const Icon(
            CupertinoIcons.plus,
            size: 30,
            color: primaryWhite,
          )),
    );
  }
}
