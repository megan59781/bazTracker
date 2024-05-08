import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Treats extends StatefulWidget {
  const Treats({super.key});

  @override
  State createState() => TreatsState();
}

class TreatsState extends State<Treats> {
  // Firebase Authentication and Google Sign In to sign out
  DatabaseReference dbhandler = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> treatList = [];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to wait until the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTreatRecords(); // Load treat records after the first frame is drawn
    });
  }

  Future<void> addTreatDb(DateTime date, TimeOfDay time) async {
    String treatId = const Uuid().v4();
    String dateString = DateFormat('dd-MM-yyyy').format(date);
    Map<String, dynamic> treat = {
      "id": treatId,
      "date": dateString,
      "time": time.format(context),
    };
    try {
      await dbhandler.child("Treat Track").push().set(treat);
    } catch (error) {
      print("Error saving to Firebase: $error");
    }
  }

  DateTime today = DateTime.now();

  Future<void> loadTreatRecords() async {
    List<Map<String, dynamic>> tempList = [];
    dbhandler.child("Treat Track").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            String dateString = value['date'];
            DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);

            if (isToday(date)) {
              Map<String, dynamic> treatData = {
                'time': value['time'],
                'date': value['date'],
              };
              tempList.add(treatData);
            } else {
              // Remove the treat record if it is not from today
              dbhandler.child("Treat Track").child(key).remove();
            }
          });
        }
      }
      setState(() {
        treatList = tempList;
      });
    });
  }

  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> fireTreat() async {
    dbhandler
        .child('Treat')
        .onValue
        .take(1)
        .listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          await dbhandler.child('Treat').update({
            "button_on": 1,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xffFCFAFC),
        title: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Center(child: Text("Treats")),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: treatList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> treat = treatList[index];
                  return InkWell(
                    onTap: () {
                      // Handle item tap if needed
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: const Text("Treat Thrown", style: TextStyle(color: Colors.black, fontSize: 22)),
                        subtitle: Text("Time Given: ${treat['time']}",
                            style: const TextStyle(color: Colors.blue, fontSize: 15)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 240,
              height: 70,
              child: ElevatedButton(
                onPressed: () async {
                  await fireTreat();
                  await addTreatDb(DateTime.now(), TimeOfDay.now());
                  loadTreatRecords(); // Refresh treat records after adding a new treat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff01579B),
                ),
                child: const Text(
                  'Fire Treats',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
