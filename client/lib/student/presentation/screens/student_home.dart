import 'package:attendance/assets/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/student/presentation/widgets/student_classroom_card.dart';
import 'package:attendance/student/presentation/widgets/student_app_bar.dart';
import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class StudentHome extends StatefulWidget {
  final String username;
  const StudentHome({super.key,required this.username});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {

  final TextEditingController newClassroomName = TextEditingController(); 
  void deleteClassroomCallback(){}
  late final String username;
  late final List<dynamic> classrooms;

  
  @override
  void initState(){
    classrooms = [
      {'courseName': 'Classroom-1','instructorName':'Prof. A'},
      {'courseName': 'Classroom-2','instructorName':'Prof. B'}
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudentAppBar(username: widget.username,),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: classrooms.length,
          itemBuilder: (context,index){
            return StudentClassroomCard(
              courseName: classrooms[index]['courseName']!,
              instructorName: classrooms[index]['instructorName']!,
              deleteClassroomCallback: deleteClassroomCallback,
            );
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
                  style: TextButton.styleFrom(
                      backgroundColor: complementaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                  ),
                  onPressed: (){
                    print(newClassroomName.text);
                    Navigator.pop(context);
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

