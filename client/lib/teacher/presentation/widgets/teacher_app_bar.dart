import 'package:attendance/teacher/presentation/screens/teacher_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/assets/constants/colors.dart';

class TeacherAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String username;
  const TeacherAppBar({super.key, required this.username});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text('Hi $username',style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w500),),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherProfile()));
              },
              icon: const Icon(CupertinoIcons.person_crop_circle,size: 40,color: primaryBlack,),)
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(10), child: Container(height: 1,color: Colors.black,),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
