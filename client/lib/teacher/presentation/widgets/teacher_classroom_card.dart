import 'package:attendance/teacher/presentation/screens/teacher_classroom.dart';
import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:flutter/material.dart';
import 'package:attendance/assets/constants/colors.dart';
import 'package:flutter_awesome_bottom_sheet/flutter_awesome_bottom_sheet.dart';

class TeacherClassroomCard extends StatelessWidget {
  final String classroomName, numberOfStudents, classroomID;
  final Function deleteClassroomCallback;
  final Function changeClassroomNameCallback;
  const TeacherClassroomCard(
      {super.key,
      required this.classroomName,
      required this.numberOfStudents,
      required this.classroomID,
      required this.deleteClassroomCallback,
      required this.changeClassroomNameCallback});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherClassroom(
                      classroomName: classroomName,
                      classroomID: classroomID,
                      changeClassroomNameCallback: changeClassroomNameCallback,
                    )));
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
                Text(
                  classroomName,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w500),
                ),
                IconButton(
                    onPressed: () {
                      _showDeleteClassroomOption(context);
                    },
                    icon: const Icon(
                      Icons.more_vert,
                      size: 30,
                      color: primaryBlack,
                    )),
              ],
            ),
            Text(
              '$numberOfStudents Students',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteClassroomOption(context) {
    AwesomeBottomSheet().show(
      context: context,
      title: const Text(
        "Delete",
        style: TextStyle(color: primaryBlack),
      ),
      color: CustomSheetColor(
        mainColor: const Color(0xFFEEEEEE),
        accentColor: const Color(0xFFEEEEEE),
        iconColor: primaryBlack,
      ),
      positive: AwesomeSheetAction(
        onPressed: () async {
          await TeacherClassroomServices.deleteClassroom(classroomID, context);
          deleteClassroomCallback();
          Navigator.of(context).pop();
        },
        title: 'YES',
        color: primaryBlack,
      ),
      negative: AwesomeSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        title: 'NO',
        color: primaryBlack,
      ),
      description: const Text(
        "Do you want to Delete this classroom?",
        style: TextStyle(color: primaryBlack),
      ),
    );
  }
}
