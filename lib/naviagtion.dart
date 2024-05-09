import 'package:baz_tracker/motion.dart';
import 'package:baz_tracker/treats.dart';
import 'package:baz_tracker/water.dart';
import 'package:flutter/material.dart';

// Define WorkerNavigationBar widget
class BazNavigationBar extends StatefulWidget {

  const BazNavigationBar(
      {super.key});

  @override
  State<BazNavigationBar> createState() =>
      BazNavigationBarState();
}

class BazNavigationBarState extends State<BazNavigationBar> {
  // Constructor

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // Page widget options
  static List<Widget> _widgetOptions() => [
        const Water(),
        const Treats(),
        const Motion(),
      ];

  // It updates the selected index and triggers a rebuild of the widget.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the Scaffold widget
    return Scaffold(
      body: Center(
        child: _widgetOptions()[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            label: 'Water', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cookie_outlined),
            label: 'Treats', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            label: 'Motion',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:const Color(0xff64b5f6),
        onTap: _onItemTapped,
      ),
    );
  }
} 