import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid.dart';

class Water extends StatefulWidget {
  const Water({super.key});

  @override
  State createState() => WaterState();
}

class WaterState extends State<Water> {
  // Firebase Authentication and Google Sign In to sign out
  DatabaseReference dbhandler = FirebaseDatabase.instance.ref();
  String water = "Water Sensor";
  int startLevel = 0;
  String startTime = "12:00";
  int waterLevel = 0;
  int waterGoal = 800;
  int iWaterDrank = 750;
  String lastDrank = "12:00";
  int activityLevel = 50;
  int dogWeight = 14;

  // @override
  // void initState() {
  //   super.initState();
  //   currentWater();
  //   waterSet(DateTime.now(), TimeOfDay.now());
  // }

  Future<void> currentWater() async {
    dbhandler.child('Water Sensor').onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          int currentVal = data['current_val'];
          // String time = data['water_time'];
          // String date = data['water_date'];
          setState(() {
            waterLevel = currentVal;
          });
        }
      }
    });
  }

  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> waterSet(DateTime date, TimeOfDay time) async {
    dbhandler.child('Water Track').onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            String dateString = value['date'];
            DateTime date = DateFormat('dd/mm/yyyy').parse(dateString);
            if (isToday(date)) {
              // TBD
            } else {
              dbhandler.child("Treat Track").child(key).remove();
            }
          });
        }
      } else {
        dbhandler
            .child('Water Sensor')
            .onValue
            .listen((DatabaseEvent event) async {
          if (event.snapshot.value != null) {
            Map<dynamic, dynamic>? data =
                event.snapshot.value as Map<dynamic, dynamic>?;

            if (data != null) {
              int currentVal = data['current_val'];
              String time = data['water_time'];
              String date = data['water_date'];
              await addWaterChange(date, time, currentVal, 0);
              setState(() {
                startLevel = currentVal;
                startTime = time;
                waterLevel = currentVal;
                iWaterDrank = 0;
              });
            }
          }
        });
      }
    });
  }

  Future<void> addWaterChange(
      String date, String time, int waterLevel, int waterDrank) async {
    String waterId = const Uuid().v4();
    Map<String, dynamic> water = {
      "id": waterId,
      "date": date,
      "time": time,
      "current_level": waterLevel,
      "current_drank": waterDrank,
    };
    try {
      await dbhandler.child("Water Track").push().set(water);
    } catch (error) {
      print("Error saving to Firebase: $error");
    }
  }

  void dogSettings(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Set Barry's Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text("Select Barry's Activity Level",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  RadioListTile(
                    title: Text('Low', style: TextStyle(fontSize: 16)),
                    value: 40,
                    groupValue: activityLevel,
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value as int; // Cast to int
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Average', style: TextStyle(fontSize: 16)),
                    value: 50,
                    groupValue: activityLevel,
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value as int; // Cast to int
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('High', style: TextStyle(fontSize: 16)),
                    value: 60,
                    groupValue: activityLevel,
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value as int; // Cast to int
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Input Barry's Weight", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Barry\'s Weight in KG',
                      )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      //TO DO ADD TO DB
                      int parsedWeight = int.tryParse(controller.text) ?? 15;
                      dogWeight = parsedWeight;
                      waterGoal = dogWeight * activityLevel;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String goal = waterGoal.toString();
    String waterDrank = iWaterDrank.toString();
    return Scaffold(
        backgroundColor: const Color(0xffFCFAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xffFCFAFC),
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: Text("Water")),
          ),
          automaticallyImplyLeading: false, // Remove the back button
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Today's Water Intake",
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff01579B)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularPercentIndicator(
                    animation: true,
                    animationDuration: 1000,
                    radius: 90,
                    lineWidth: 20,
                    percent: 0.8,
                    progressColor: const Color(0xff01579B),
                    backgroundColor: const Color(0xff64b5f6),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Dog: Barry",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Total Drank: ${waterDrank}ml",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Goal: ${goal}ml",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Last Drank: $lastDrank",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  dogSettings(context);
                },
                child: const Text(
                  'Press to change water settings',
                  style: TextStyle(fontSize: 22, color: Color(0xff64b5f6)),
                ),
              ),
              const SizedBox(height: 20),
              Text(dogWeight.toString()),
              Text(activityLevel.toString()),

              // Text(water),
              // ElevatedButton(
              //   onPressed: () {
              //     currentWater(); // Call _togglePower function correctly
              //   },
              //   child: const Text('Water Check'),
              // )
            ],
          ),
        )));
  }
}
