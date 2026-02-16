import 'package:flutter/material.dart';
import 'package:pocket_ssh/theme/app_theme.dart';
import 'package:pocket_ssh/widgets/bottom_bar.dart';
import 'package:pocket_ssh/pages/shortcuts_page.dart';



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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
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
