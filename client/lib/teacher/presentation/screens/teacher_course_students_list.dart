import 'package:attendance/teacher/services/teacher_classroom_services.dart';
import 'package:excel/excel.dart' as Excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../assets/constants/colors.dart';

class StudentList extends StatefulWidget {
  final String classroomName, classroomID;
  const StudentList(
      {super.key, required this.classroomName, required this.classroomID});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {

  Future<Map<String, dynamic>> fetchClassroomStudents() {
    return TeacherClassroomServices.getClassroomStudents(widget.classroomID, context);
  }

  Future<void> handleRemoveStudent(String studentEmail) async {
    try {
      var resp = await TeacherClassroomServices.removeStudent(widget.classroomID, studentEmail, context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['message'])));
    }
    catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()),));
    }
    finally {
      setState(() {});
    }
  }

  void handleAddExcel() async {

    try{
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
        withData: true,
      );
      
      List<String> studentEmails = [];

      if (pickedFile != null) {
        var bytes = pickedFile.files.single.bytes!.toList();
        var excel = Excel.Excel.decodeBytes(bytes);
        var table = excel.tables[excel.tables.keys.first];

        for (var row in table!.rows) {
          print('....................');
          print(row);
          String email = row[0]!.value.toString();
          studentEmails.add(email);
        }
      }

      print(studentEmails);

      var resp = await TeacherClassroomServices.sendInvites(widget.classroomID, studentEmails, context);
      print(resp);

      int countAlreadyInClass = resp['count_already_in_class'];
      // int countStudentNotFound = resp['count_student_not_found'];
      int countInvitesSent = resp['count_invites_sent'];


      Widget inviteResult = Column(
        children: [
          Text('${countInvitesSent} invites sent.'),
          Text('${countAlreadyInClass} students already in class.'),
        ],
      );
      var snackBar = SnackBar(content: inviteResult);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (err) {
      print(err);
      var snackBar = SnackBar(content: Text(err.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.classroomName,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
          ),
          backgroundColor: classroomTileBg,
        ),
        body: FutureBuilder(
            future: fetchClassroomStudents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.hasData) {
                // print("................................");
                // print(snapshot.data);

                List<dynamic> students = snapshot.data?['students'];

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            child: const Text(
                              'Add Students',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.fromLTRB(0, 10, 40, 0),
                            icon: Icon(Icons.file_upload),
                            onPressed: handleAddExcel,
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                        child: const Text(
                          'Add students by uploading an excel sheet with student emails.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: const Text(
                          'Full List',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: double.infinity),
                          child: DataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Roll No.')),
                              DataColumn(label: Text('Email')),
                            ],
                            rows: [
                              for (var i = 0; i < students.length; i++) ...[
                                DataRow(
                                    onLongPress: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text('Remove Student'),
                                                content: Text(
                                                    'Student Name : ${students[i]["student_name"]}\n'
                                                    'Student Roll No : ${students[i]["student_roll_no"]}\n'
                                                    'Student Email : ${students[i]["student_email"]}\n'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color: primaryBlack),
                                                      )),
                                                  TextButton(
                                                      onPressed: () {
                                                        print('remove..................');
                                                        Navigator.pop(context);
                                                        handleRemoveStudent(students[i]["student_email"]);
                                                      },
                                                      child: Text(
                                                        'Remove',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )),
                                                ],
                                              ));
                                    },
                                    cells: [
                                      DataCell(SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        child: Text(students[i]["student_name"], overflow: TextOverflow.ellipsis))
                                      ),
                                      DataCell(ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.2),
                                        child: Text(students[i]["student_roll_no"], overflow: TextOverflow.ellipsis))
                                      ),
                                      DataCell(SizedBox(
                                        // width: MediaQuery.of(context).size.width * 0.3,
                                        child: Text(students[i]["student_email"], overflow: TextOverflow.ellipsis))
                                      ),
                                    ]
                                  ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                );
              }

              return Placeholder();
            }));
  }
}
