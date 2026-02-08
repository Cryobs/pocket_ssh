import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: const Color(0x00171717), // Transparent
        child: Center(
          child: Container(
            width: 355,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(40),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double highlightMargin = 10.0;

                return Stack(
                  children: [
                    // GREEN HIGHLIGHT
                    AnimatedPositioned(
                      left: _getLeftPosition(currentIndex, constraints.maxWidth, highlightMargin, context),
                      top: highlightMargin,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: _getWidth(currentIndex, context),
                        height: constraints.maxHeight - (highlightMargin * 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    // ICONS & TEXT
                    Padding(
                      padding: const EdgeInsets.symmetric(
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
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {onChanged(index);},
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

  double _textWidth(
      String text,
      TextStyle style,
      ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }


  double _getWidth(int index, BuildContext context) {
    const double iconWidth = 28;
    const double padding = 24;
    const double spacing = 6;

    final labels = ["Home", "SSH", "Shortcuts", "Settings"];

    const textStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 14,
    );

    final textW = _textWidth(labels[index], textStyle);

    return iconWidth + padding + spacing + textW;
  }

  double _getLeftPosition(int index, double containerWidth, double margin, BuildContext context) {
    const double iconOnlyWidth = 28 + 24; // icon + padding

    double activeWidth = _getWidth(currentIndex, context);

    List<double> buttonWidths = [];
    for (int i = 0; i < 4; i++) {
      buttonWidths.add(i == currentIndex ? activeWidth : iconOnlyWidth);
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
