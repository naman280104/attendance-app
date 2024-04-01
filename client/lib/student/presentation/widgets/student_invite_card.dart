import 'package:attendance/assets/constants/colors.dart';
import 'package:attendance/student/services/student_classroom_services.dart';
import 'package:flutter/material.dart';

class StudentInviteCard extends StatefulWidget {
  final String inviteID, classroomName, classroomTeacher;
  final Function reloadCallback;
  const StudentInviteCard(
      {super.key,
      required this.inviteID,
      required this.classroomName,
      required this.classroomTeacher,
      required this.reloadCallback});

  @override
  State<StudentInviteCard> createState() => _StudentInviteCardState();
}

class _StudentInviteCardState extends State<StudentInviteCard> {
  Future<void> respondToInvite(String studentResponse) async {
    try {
      var resp = await StudentClassroomServices.respondToInvite(context, widget.inviteID, studentResponse);
      widget.reloadCallback();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['message'])));
    }
    catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: classroomInviteBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.classroomName,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
          ),
          Text(
            widget.classroomTeacher,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {respondToInvite('ACCEPT'); },
                  child: Text(
                    '     Accept     ',
                    style: TextStyle(color: Colors.green),
                  )),
              ElevatedButton(
                  onPressed: () {respondToInvite('DECLINE'); },
                  child: Text('     Decline     ',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
