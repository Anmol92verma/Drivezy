import 'package:drivezy_app/ui/auth/AuthScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:countdown/countdown.dart';
import 'dart:async';

class SplashPage extends StatefulWidget{



  @override
  State<StatefulWidget> createState() {
    return new SplashPageState();
  }

}

class SplashPageState extends State<SplashPage>{

  int val = 3;
  CountDown cd;

  @override
  void initState() {
    super.initState();
    countdown();
  }

  void countdown(){
    print("countdown() called");
    cd = new CountDown(new Duration(seconds: 4));
    StreamSubscription sub = cd.stream.listen(null);
    sub.onDone(() {
      print("Done");
      setState(() {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
        type: MaterialType.transparency,
        child: Container(child: new Center(child:
        new Text("Drivezy\nYour Travel Companion",textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1),fontSize: 30.0))),
            color: Color.fromRGBO(0, 187, 85,1)));
  }
}