import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int int_currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
      ),
      body: Center(
        child: Text(
          'Zakładka: $int_currentIndex',
          style: const TextStyle(
              fontSize: 24,
          color: Colors.black)

        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: int_currentIndex,
        onTap: (index) {
          setState(() {
            int_currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.terminal),
            label: 'SSH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_circle_down_rounded),
            label: 'Shortcuts',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        )],
      ),
    );
  }
}
