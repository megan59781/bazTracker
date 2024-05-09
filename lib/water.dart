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
  int startLevel = 0;
  String startTime = "12:00";
  int waterLevel = 0;
  int waterGoal = 800;
  int waterDrank = 740;
  String lastDrank = "21:48";
  int activityLevel = 50;
  int dogWeight = 14;

  @override
  void initState() {
    super.initState();
    currentWater();
    waterSet(DateTime.now(), TimeOfDay.now());
  }

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
    dbhandler
        .child('Water Track')
        .onValue
        .take(1)
        .listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            String dateString = value['date'];
            DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
            if (isToday(date)) {
              // TBD
            } else {
              dbhandler.child("Water Track").child(key).remove();
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
                waterDrank = 0;
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

  // Future<void> addDogDetailsDb(int activity, int weight, int goal) async {
  //   dbhandler.child('Dog Details').onValue.take(1).listen((event) async {
  //     if (event.snapshot.value != null) {
  //       Map<dynamic, dynamic>? data =
  //           event.snapshot.value as Map<dynamic, dynamic>?;
  //       if (data != null) {
  //         await dbhandler.child("Dog Details").update({
  //           "dog_activity": activity,
  //           "dog_weight": weight,
  //           "dog_goal": goal
  //         });
  //       }
  //     } else {
  //       // if no abilities added yet add new with worker_id
  //       Map<String, dynamic> dogList = {
  //         "dog_activity": activity,
  //         "dog_weight": weight,
  //         "dog_goal": goal
  //       };
  //       await dbhandler.child('Dog Details').push().set(dogList);
  //     }
  //   });
  // }

  void dogSettings(BuildContext context, Function(int, int, int) updateGoal) {
    TextEditingController _controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Set Barry's Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 10),
                  const Text("Select Barry's Activity Level",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  RadioListTile(
                    title: const Text('Low', style: TextStyle(fontSize: 16)),
                    value: 40,
                    groupValue: activityLevel,
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value as int; // Cast to int
                      });
                    },
                  ),
                  RadioListTile(
                    title:
                        const Text('Average', style: TextStyle(fontSize: 16)),
                    value: 50,
                    groupValue: activityLevel,
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value as int; // Cast to int
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('High', style: TextStyle(fontSize: 16)),
                    value: 60,
                    groupValue: activityLevel,
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value as int; // Cast to int
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Input Barry's Weight",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Barry\'s Weight in KG',
                    ),
                    onChanged: (value) {
                      dogWeight = int.tryParse(value) ?? 15;
                      print('Input value: $value');
                    },
                  ),
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
                    waterGoal = dogWeight * activityLevel;
                    updateGoal(activityLevel, dogWeight, waterGoal);
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
    return Scaffold(
        backgroundColor: const Color(0xffFCFAFC),
        
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 80),
              const Text(
                "Today's Water Intake",
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff01579B)),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularPercentIndicator(
                    animation: true,
                    animationDuration: 1000,
                    radius: 90,
                    lineWidth: 20,
                    percent: waterDrank / waterGoal,
                    progressColor: const Color(0xff01579B),
                    backgroundColor: const Color(0xff64b5f6),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 30),
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
                        "Goal: ${waterGoal}ml",
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
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  dogSettings(context, (activity, weight, goal) {
                    setState(() {
                      activityLevel = activity;
                      dogWeight = weight;
                      waterGoal = goal;
                    });
                    print(activityLevel);
                    print(dogWeight);
                    print(waterGoal);
                  });
                },
                child: const Text(
                  'Press to change water settings',
                  style: TextStyle(fontSize: 22, color: Color(0xff64b5f6)),
                ),
              ),
              const SizedBox(height: 60),
              Container(
                height: 5.0,
                width: 400.0,
                color: const Color(0xff01579B),
              ),
              const SizedBox(height: 60),
              const Text(
                "Bowl Water Level",
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff01579B)),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(onPressed: null, icon: Icon(Icons.local_drink_outlined, size: 80, color: Color(0xff64b5f6))),
                  SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                    "Bowl Water Level",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "113ml",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Satus: Ok",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  )]),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        )));
  }
}
