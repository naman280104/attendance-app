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
  void deleteClassroomCallback(){}
  late final String username;
  late final List<dynamic> classrooms;
  @override
  void initState() {
    username = 'Student';
    classrooms = [
      {'courseName': 'Classroom-1','instructorName':'Prof. A'},
      {'courseName': 'Classroom-2','instructorName':'Prof. B'}
    ];
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: StudentAppBar(username: username,),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: classrooms.length,
          itemBuilder: (context,index){
            return StudentClassroomCard(classroomName: classrooms[index]['courseName']!, instructorName: classrooms[index]['instructorName']!,deleteClassroomCallback: deleteClassroomCallback,);
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
                controller: newClassroomName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Course Name",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: (){
                    print(newClassroomName.text);
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

