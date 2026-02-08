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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
