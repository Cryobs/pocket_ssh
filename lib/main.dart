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
          child: Center(
            child: Container(
              width: 355,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(40),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double highlightMargin = 10.0;

                  return Stack(
                    children: [
                      // GREEN HIGHLIGHT
                      AnimatedPositioned(
                        left: _getLeftPosition(int_currentIndex, constraints.maxWidth, highlightMargin),
                        top: highlightMargin,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          width: _getWidth(int_currentIndex),
                          height: constraints.maxHeight - (highlightMargin * 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      // ICONS & TEXT
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: highlightMargin,
                          vertical: highlightMargin,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  double _getLeftPosition(int index, double containerWidth, double margin) {
    const double iconOnlyWidth = 28 + 24; // icon + padding

    double activeWidth = _getWidth(int_currentIndex);

    List<double> buttonWidths = [];
    for (int i = 0; i < 4; i++) {
      buttonWidths.add(i == int_currentIndex ? activeWidth : iconOnlyWidth);
    }

    double availableWidth = containerWidth - (margin * 2);

    double totalButtonsWidth = buttonWidths.reduce((a, b) => a + b);

    double spacing = (availableWidth - totalButtonsWidth) / 3;

    double leftPosition = margin;

    for (int i = 0; i < index; i++) {
      leftPosition += buttonWidths[i] + spacing;
    }

    return leftPosition;
  }
}