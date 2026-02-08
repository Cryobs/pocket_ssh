import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  /* Constants */
  static const List<NavItem> _items = [
    NavItem(Icons.home_rounded, "Home"),
    NavItem(Icons.terminal, "SSH"),
    NavItem(Icons.arrow_circle_down, "Shortcuts"),
    NavItem(Icons.settings, "Settings"),
  ];

  static const double _barHeight = 70;
  static const double _barWidth = 355;
  static const double _safePadding = 10;
  static const double _iconSize = 28;
  static const double _itemHPadding = 12;
  static const double _textSpacing = 6;
  static const int _animDuration = 400;

  static const int _containerColor = 0x00171717;
  static const int _barColor = 0xFF262626;
  static const int _highlightColor = 0xFF22C55E;

  static const double _barRadius = 40;
  static const double _highlightRadius = 80;


  static final TextStyle _textStyle = TextStyle(
    color: Colors.black.withOpacity(0.6),
    fontWeight: FontWeight.w900,
    fontSize: 14,
  );


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 90,
        color: const Color(_containerColor),
        child: Center(
          child: Container(
            width: _barWidth,
            height: _barHeight,
            decoration: BoxDecoration(
              color: const Color(_barColor),
              borderRadius: BorderRadius.circular(_barRadius),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // GREEN HIGHLIGHT
                    AnimatedPositioned(
                      left: _getLeftPosition(currentIndex, constraints.maxWidth, _safePadding),
                      top: _safePadding,
                      duration: const Duration(milliseconds: _animDuration),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: _animDuration),
                        curve: Curves.easeInOut,
                        width: _itemWidth(currentIndex),
                        height: constraints.maxHeight - (_safePadding * 2),
                        decoration: BoxDecoration(
                          color: const Color(_highlightColor),
                          borderRadius: BorderRadius.circular(_highlightRadius),
                        ),
                      ),
                    ),
                    // ICONS & TEXT
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _safePadding,
                        vertical: _safePadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _items.length,
                              (i) => _navItem(_items[i], i),
                        ),
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

  Widget _navItem(NavItem item, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {onChanged(index);},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: _animDuration),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: _itemHPadding),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isSelected ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.3),
              size: _iconSize,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: _animDuration),
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: _textSpacing),
                        Text(item.label, style: _textStyle),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  double _textWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }



  double _itemWidth(int index) {
    final textW = _textWidth(_items[index].label);
    return _iconSize +
        (_itemHPadding * 2) +
        _textSpacing +
        textW;
  }

  double get _iconOnlyWidth =>
      _iconSize + (_itemHPadding * 2);


  double _getLeftPosition(int index, double containerWidth, double margin) {
    final count = _items.length;

    final widths = List.generate(
      count,
          (i) => i == currentIndex ? _itemWidth(i) : _iconOnlyWidth,
    );

    final available = containerWidth - (_safePadding * 2);
    final spacing = (available - widths.reduce((a, b) => a + b)) / (count - 1);

    double left = _safePadding;
    for (int i = 0; i < index; i++) {
      left += widths[i] + spacing;
    }

    return left;  }
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem(this.icon, this.label);
}

