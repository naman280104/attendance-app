import 'package:flutter/material.dart';

import '../../../assets/constants/colors.dart';

class StudentList extends StatefulWidget {
  final String classroomName,courseCode;
  const StudentList({
    super.key,
    required this.classroomName,
    required this.courseCode
  });

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<dynamic> students = [
    ['ABC','Roll No.1','abc@abc.abc'],
    ['ABC','Roll No.2','abc@abc.abc'],
    ['ABC','Roll No.3','abc@abc.abc'],
    ['ABC','Roll No.4','abc@abc.abc'],
    ['ABC','Roll No.5','abc@abc.abc'],
    ['ABC','Roll No.6','abc@abc.abc'],
    ['ABC','Roll No.7','abc@abc.abc'],
    ['ABC','Roll No.8','abc@abc.abc'],
    ['ABC','Roll No.9','abc@abc.abc'],
    ['ABC','Roll No.10','abc@abc.abc'],
    ['ABC','Roll No.11','abc@abc.abc'],
    ['ABC','Roll No.12','abc@abc.abc'],
  ];

  @override
  Widget build(BuildContext context) {
    TextEditingController newStudentEmailController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text(widget.classroomName,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 24),),backgroundColor: classroomTileBg,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(alignment: Alignment.centerLeft,padding: EdgeInsets.fromLTRB(20, 15, 20, 5),child: const Text('Add Student',style: TextStyle(fontSize: 16),),),
            Container(
              margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: newStudentEmailController,
                onSubmitted: (val){
                  showDialog(context: context, builder: (context)=>AlertDialog(
                    title: Text('Add Student'),
                    content: Text('email: $val'),
                    actions: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text('Cancel',style: TextStyle(color: primaryBlack),)
                      ),
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                            print('Add student with email $val');
                            setState(() {});
                          },
                          child: Text('Add',style: TextStyle(color: Colors.green),)
                      ),
                    ],
                  ));
                  newStudentEmailController.clear();
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.add),
                  hintText: 'Student Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: primaryBlack))
                ),
              ),
            ),
            Container(alignment: Alignment.centerLeft,padding: EdgeInsets.fromLTRB(20, 10, 20, 10),child: const Text('Full List',style: TextStyle(fontSize: 16),),),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Roll No.')),
                  DataColumn(label: Text('Email')),
                ],
                rows: [
                  for(var i=0; i<students.length;i++) ...[
                    DataRow(
                      onLongPress: (){
                        showDialog(context: context, builder: (context)=>AlertDialog(
                          title: Text('Remove Student'),
                          content: Text(
                              'Student Name : ${students[i][0]}\n'
                              'Student Roll No : ${students[i][1]}\n'
                              'Student Email : ${students[i][2]}\n'
                          ),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel',style: TextStyle(color: primaryBlack),)
                            ),
                            TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  print('Remove student at index $i');
                                  setState(() {});
                                },
                                child: Text('Remove',style: TextStyle(color: Colors.red),)
                            ),
                          ],
                        ));
                      },
                      cells: [
                        DataCell(Text(students[i][0])),
                        DataCell(Text(students[i][1])),
                        DataCell(Text(students[i][2])),
                      ]
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}
