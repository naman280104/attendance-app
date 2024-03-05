import 'package:attendance/assets/myprovider.dart';
import 'package:attendance/student/presentation/screens/student_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance/assets/constants/colors.dart';
import 'package:provider/provider.dart';

class StudentAppBar extends StatelessWidget implements PreferredSizeWidget{
  const StudentAppBar({super.key});

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Consumer<MyProvider>(
        builder: (context,myProvider,child) => Text('Hi ${myProvider.name}',style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w500),)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentProfile()));
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
