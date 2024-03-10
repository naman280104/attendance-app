
import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:flutter/material.dart';

class TeacherClassroomAppBar extends StatefulWidget  implements PreferredSizeWidget {
  final String classroomName;
  final String classroomID;
  final Function changeClassroomNameCallback; 
  const TeacherClassroomAppBar({super.key, required this.classroomName, required this.classroomID, required this.changeClassroomNameCallback});

  @override
  State<TeacherClassroomAppBar> createState() => _TeacherClassroomAppBarState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TeacherClassroomAppBarState extends State<TeacherClassroomAppBar> {
  
  TextEditingController classroomNameController = TextEditingController(); 
  
  @override
  void initState(){
    super.initState();
    classroomNameController.text = widget.classroomName;
  }
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: classroomNameController,
        autocorrect: false,
        onChanged: (value) {
          setState(() {
            classroomNameController.text = value;
          });
        },
        onSubmitted: (val) async {
          await TeacherClassroomServices.editClassroomName(widget.classroomID, classroomNameController.text, context);
          widget.changeClassroomNameCallback();
        },
        
        style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.edit),
          border: InputBorder.none,
        ),
      ),backgroundColor: classroomTileBg,);
  }

}