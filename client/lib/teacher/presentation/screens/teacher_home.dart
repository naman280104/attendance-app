import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_classroom_card.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_app_bar.dart';
import 'package:attendance/assets/constants/colors.dart';



class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {

  final TextEditingController newClassroomCode = TextEditingController(); 
  void deleteClassroomCallback(){}
  late final String username;
  late final List<dynamic> classrooms;
  @override
  void initState() {
    username = 'Teacher';
    classrooms = [
      {'courseName': 'Classroom-1','numberOfStudents':'20'},
      {'courseName': 'Classroom-2','numberOfStudents':'30'}
    ];
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: TeacherAppBar(username: username,),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: classrooms.length,
          itemBuilder: (context,index){
            return TeacherClassroomCard(classroomName: classrooms[index]['courseName']!, numberOfStudents: classrooms[index]['numberOfStudents']!,deleteClassroomCallback: deleteClassroomCallback,);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              title: Text('Course Code'),
              content: TextField(
                controller: newClassroomCode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Course Code",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: (){
                    print(newClassroomCode.text);
                    Navigator.pop(context);
                  },
                  child: Text('Confirm')
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

