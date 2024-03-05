import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_classroom_card.dart';
import 'package:attendance/teacher/presentation/widgets/teacher_app_bar.dart';
import 'package:attendance/assets/constants/colors.dart';



class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key,});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {

  final TextEditingController newClassroomCode = TextEditingController(); 
  void deleteClassroomCallback(){}
  late final List<dynamic> classrooms;
  @override
  void initState() {
    classrooms = [
      {'courseName': 'Course1','numberOfStudents':'79','courseCode':'axhyeds'},
      {'courseName': 'Course2','numberOfStudents':'79','courseCode':'jdhydki'}
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: TeacherAppBar(),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: classrooms.length,
          itemBuilder: (context,index){
            return TeacherClassroomCard(courseName: classrooms[index]['courseName']!, numberOfStudents: classrooms[index]['numberOfStudents']!,courseCode: classrooms[index]['courseCode'],deleteClassroomCallback: deleteClassroomCallback,);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              title: Text('Course Name'),
              content: TextField(
                controller: newClassroomCode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Course Name",
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
                  onPressed: (){
                    print(newClassroomCode.text);
                    Navigator.pop(context);
                  },
                  child: Text('Add Course',style: TextStyle(color: primaryBlack),)
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

