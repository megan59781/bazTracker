import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Socket sock = await Socket.connect('192.168.5.207', 80);
  runApp(MyApp(channel: sock));
}

class MyApp extends StatelessWidget {
  final Socket channel;

  MyApp({required this.channel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', channel: channel),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Socket channel;
  final String title;

  MyHomePage({Key? key, required this.title, required this.channel})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _togglePower() {
    widget.channel.write('POWER\n');
  }

  @override
  void dispose() {
    widget.channel.close();
    super.dispose();
  }

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
              Text("test"),
              ElevatedButton(
                onPressed: _togglePower,
                child: Text('Button'),
              )
            ],
          ),
        ));
  }
}
