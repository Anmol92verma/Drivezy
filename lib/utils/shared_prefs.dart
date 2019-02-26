import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {

  static final SharedPrefs _instance = new SharedPrefs._internal();
  factory SharedPrefs(){
    return _instance;
  }

  SharedPrefs._internal();


  Future<bool> clear() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.clear();
  }

}