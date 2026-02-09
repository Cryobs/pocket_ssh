import 'package:flutter/material.dart';
import 'package:pocket_ssh/widgets/bottom_bar.dart';




class Template extends StatefulWidget {
  final List<Widget> pages;

  const Template({
    super.key,
    required this.pages
  });

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  int currentIndex = 0;

  static const int _primaryColor = 0xFF22C55E;

  static const MaterialColor primarySwatch = MaterialColor(
    _primaryColor,
    {
      50: Color(0xFFE6F9EC),
      100: Color(0xFFBFF0C8),
      200: Color(0xFF99E5A3),
      300: Color(0xFF73DB7F),
      400: Color(0xFF4DD159),
      500: Color(_primaryColor),
      600: Color(0xFF1FA03F),
      700: Color(0xFF178038),
      800: Color(0xFF106031),
      900: Color(0xFF08401A),
    },
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(_primaryColor),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatch,
          accentColor: const Color(_primaryColor),
        )
      ),
      home: Scaffold(
          backgroundColor: Colors.black,
          body: widget.pages[currentIndex],
          bottomNavigationBar: BottomBar(
            currentIndex: currentIndex,
            onChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          )
      ),
    );
  }
}
