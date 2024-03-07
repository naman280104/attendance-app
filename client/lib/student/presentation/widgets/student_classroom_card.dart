import 'package:flutter/material.dart';
import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter_awesome_bottom_sheet/flutter_awesome_bottom_sheet.dart';

import '../screens/student_classroom.dart';


class StudentClassroomCard extends StatelessWidget {
  final String classroomName, instructorName;
  final Function deleteClassroomCallback;

  const StudentClassroomCard({super.key,required this.classroomName,required this.instructorName,required this.deleteClassroomCallback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentClassroom(classroomName: classroomName,)));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        padding: const EdgeInsets.fromLTRB(20, 10, 5, 20),
        height: 150,
        decoration: BoxDecoration(
          color: classroomTileBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(classroomName,style: const TextStyle(fontSize: 30,fontWeight: FontWeight.w500),),
                IconButton(
                    onPressed: (){
                      _showDeleteClassroomOption(context);
                    },
                    icon: const Icon(Icons.more_vert,size: 30,color: primaryBlack,)
                ),
              ],
            ),
            Text(instructorName,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  void _showDeleteClassroomOption(context){
    showModalBottomSheet(context: context, 
    builder:(context)=>SizedBox(
      height: 70,
      width: double.infinity,
      child: TextButton(
        onPressed: (){
          deleteClassroomCallback();
          print("delete classroom");
        },
        child: Text("Unenroll",style: TextStyle(fontSize: 22,color: primaryBlack),),
      ),
    ));
  }
}
