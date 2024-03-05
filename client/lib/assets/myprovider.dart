import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyProvider extends ChangeNotifier{

  String _name="";


  void setName(String name){
    _name = name;
    notifyListeners();
  }

  String get name => _name;

}