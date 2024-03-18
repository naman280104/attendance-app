import 'package:attendance/teacher/services/teacher_classroom_services.dart';
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
  // List<dynamic> students = [
  //   ['ABC', 'Roll No.1', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.2', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.3', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.4', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.5', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.6', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.7', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.8', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.9', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.10', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.11', 'abc@abc.abc'],
  //   ['ABC', 'Roll No.12', 'abc@abc.abc'],
  // ];

  Future<Map<String, dynamic>> fetchClassroomStudents() {
    return TeacherClassroomServices.getClassroomStudents(
        widget.classroomID, context);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController newStudentEmailController = TextEditingController();
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
                print("................................");
                print(snapshot.data);

                List<dynamic> students = snapshot.data?['students'];

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                        child: const Text(
                          'Add Student',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextField(
                          controller: newStudentEmailController,
                          onSubmitted: (val) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Add Student'),
                                      content: Text('email: $val'),
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
                                              Navigator.pop(context);
                                              print(
                                                  'Add student with email $val');
                                              setState(() {});
                                            },
                                            child: Text(
                                              'Add',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            )),
                                      ],
                                    ));
                            newStudentEmailController.clear();
                          },
                          decoration: InputDecoration(
                              suffixIcon: Icon(Icons.add),
                              hintText: 'Student Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: primaryBlack))),
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
                                                        Navigator.pop(context);
                                                        print(
                                                            'Remove student at index $i');
                                                        setState(() {});
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
