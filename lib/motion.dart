import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Motion extends StatefulWidget {
  const Motion({super.key});

  @override
  State createState() => MotionState();
}

class MotionState extends State<Motion> {
  DatabaseReference dbhandler = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> motionList = [];

  // Load records after the first frame is drawn
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRecords();
    });
  }

  // Check if the date is today
  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Load motion records from Firebase Realtime Database
  Future<void> loadRecords() async {
    List<Map<String, dynamic>> tempList = [];
    dbhandler.child("Dog Track").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          Map<String, dynamic> dogData = {
            'time': data['dog_time'],
            'date': data['dog_date'],
            'dog': data['dog_present'],
          };
          tempList.add(dogData);
        }
      }
      setState(() {
        motionList = tempList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFAFC),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100), // Add some spacing below app bar
              const Text(
                "Today's Dog Motion",
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff01579B)),
              ),
              const SizedBox(height: 20), // Add spacing between title and list
              ListView.builder(
                shrinkWrap:
                    true, // Use shrinkWrap to allow scrolling within Column
                itemCount: motionList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> motion = motionList[index];
                  return InkWell(
                    onTap: () {
                      // Handle item tap if needed
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          "${motion['dog']} Detected",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                          ),
                        ),
                        subtitle: Text(
                          "Time Detected: ${motion['time']}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
