import 'package:flutter/material.dart';
import 'package:pocket_ssh/widgets/bottom_bar.dart';



final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

  static const int _primaryColor = 0xFF262626;
  static const int _accentColor = 0xFF22C55E;

  static MaterialColor primarySwatch = const MaterialColor(_primaryColor, {
      50: Color(0xFFE6E6E6),
      100: Color(0xFFBFBFBF),
      200: Color(0xFF535353),
      300: Color(0xFF575757),
      400: Color(0xFF4D4D4D),
      500: Color(_primaryColor),
      600: Color(0xFF1F1F1F),
      700: Color(0xFF171717),
      800: Color(0xFF101010),
      900: Color(0xFF080808),
    }
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(_primaryColor),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatch,
          accentColor: const Color(_accentColor),
          brightness: Brightness.dark
        )
      ),
      home: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(child: widget.pages[currentIndex]),
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
