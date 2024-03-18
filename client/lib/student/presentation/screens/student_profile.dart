import 'package:attendance/splash_screen.dart';
import 'package:attendance/student/services/student_authentication_services.dart';
import 'package:attendance/student/services/student_profile_services.dart';
import 'package:flutter/material.dart';

import '../../../assets/constants/colors.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({
    super.key,
  });

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController rollNumberController =
        TextEditingController(text: "");
    Map<String, dynamic> profileData = {};
    String email = '';
    print("hello");
    bool initial = true;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                StudentAuthenticationServices().logout(context);
                              },
                              child: Text('Logout')),
                        ],
                      ));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: StudentProfileServices.getProfileDetials(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No data available');
            } else {
              print("in profile student");
              if (initial) {
                profileData = snapshot.data!;
                nameController =
                    TextEditingController(text: profileData['name']);
                rollNumberController =
                    TextEditingController(text: profileData['roll_no']);
                email = profileData['email'];
                initial = false;
              }
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      controller: nameController,
                      onChanged: (value) {
                        nameController.text = value;
                        print(nameController.text);
                      },
                      readOnly: false,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.more_horiz),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      controller: rollNumberController,
                      onChanged: (value) {
                        rollNumberController.text = value;
                      },
                      readOnly: false,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      controller: TextEditingController()..text = email,
                      readOnly: true,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: complementaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    onPressed: () {
                      print("Submit");
                      Map<String, dynamic> profileDetails = {
                        "name": nameController.text,
                        "roll_no": rollNumberController.text
                      };

                      StudentProfileServices.updateProfileDetials(
                          profileDetails, context);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Text(
                        'Submit',
                        style: TextStyle(fontSize: 21, color: primaryBlack),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              );
            }
          }),
    );
  }
}
