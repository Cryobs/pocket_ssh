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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black38,
      ),
      body: Center(
        child: Text(
          'Zakładka: $int_currentIndex',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFF171717),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // CIEMNE TŁO PASKA
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  // ZIELONE PODŚWIETLENIE - przemieszcza się w szarym kontenerze
                  AnimatedPositioned(
                    left: _getLeftPosition(int_currentIndex, constraints.maxWidth),
                    top: 10,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: _getWidth(int_currentIndex),
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  // IKONY + TEKST AKTYWNEGO PRZYCISKU - dynamicznie rozmieszczone
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navItem(Icons.home_rounded, "Home", 0),
                        _navItem(Icons.terminal, "SSH", 1),
                        _navItem(Icons.arrow_circle_down_rounded, "Shortcuts", 2),
                        _navItem(Icons.settings, "Settings", 3),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = int_currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          int_currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.3),
              size: 28,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  double _getWidth(int index) {
    const double iconWidth = 28;
    const double padding = 24;
    const double spacing = 6;

    Map<int, double> textWidths = {
      0: 42,  // "Home"
      1: 32,  // "SSH"
      2: 75,  // "Shortcuts"
      3: 65,  // "Settings"
    };

    return iconWidth + padding + spacing + (textWidths[index] ?? 0);
  }

  double _getLeftPosition(int index, double totalWidth) {
    const double iconOnlyWidth = 28 + 24; // ikona + padding

    Map<int, double> itemWidths = {
      0: int_currentIndex == 0 ? _getWidth(0) : iconOnlyWidth,
      1: int_currentIndex == 1 ? _getWidth(1) : iconOnlyWidth,
      2: int_currentIndex == 2 ? _getWidth(2) : iconOnlyWidth,
      3: int_currentIndex == 3 ? _getWidth(3) : iconOnlyWidth,
    };

    double totalItemsWidth = itemWidths.values.reduce((a, b) => a + b);

    double availableSpace = totalWidth - totalItemsWidth;
    double spacing = availableSpace / 5;

    double leftPosition = spacing;

    for (int i = 0; i < index; i++) {
      leftPosition += itemWidths[i]! + spacing;
    }

    return leftPosition;
  }
}