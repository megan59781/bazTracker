import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baz Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Water Sensor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference dbhandler = FirebaseDatabase.instance.ref();
  String water = "Water Sensor";

  // function gets current water from database
  Future<void> currentWater() async {
    dbhandler.child('Water Sensor').onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          int currentVal = data['current_val'];
          print("Current water value: $currentVal");
          String value = currentVal.toString();
          setState(() {
            water = "Current Water: $value";
          });
        }
      }
    });
  }

  // // test write to db
  // Future<void> addDb(String power) async {
  //   Map<String, dynamic> testL = {
  //     "pressed": power,
  //   };
  //   try {
  //     await dbhandler.child("Test").push().set(testL);
  //     print("Data added successfully!");
  //   } catch (e) {
  //     print("Error adding data to Firebase: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(water),
              ElevatedButton(
                onPressed: () {
                  currentWater(); // Call _togglePower function correctly
                },
                child: Text('Water Check'),
              )
            ],
          ),
        ));
  }
}
