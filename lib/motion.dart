import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Motion extends StatefulWidget {
  const Motion({super.key});

  @override
  State createState() => MotionState();
}

class MotionState extends State<Motion> {
  // Firebase Authentication and Google Sign In to sign out
  DatabaseReference dbhandler = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffFCFAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xffFCFAFC),
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: Text("Motion")),
          ),
          automaticallyImplyLeading: false, // Remove the back button
        ),
        body: const Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              SizedBox(height: 55),
              Text(
                "Motion",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3A4276)),
              ),
            ]))));
  }
}
