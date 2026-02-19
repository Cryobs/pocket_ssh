import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';


class ExtraKeyboard extends StatefulWidget {
  final void Function(List<int> bytes) sendRawBytes;
  final void Function(String value) sendRaw;
  final bool ctrlActive;
  final bool altActive;
  final VoidCallback onToggleCtrl;
  final VoidCallback onToggleAlt;

  const ExtraKeyboard({
    super.key,
    required this.sendRaw,
    required this.sendRawBytes,
    required this.ctrlActive,
    required this.altActive,
    required this.onToggleCtrl,
    required this.onToggleAlt,
  });

  @override
  State<StatefulWidget> createState() => _ExtraKeyboardState();

}

class _ExtraKeyboardState extends State<ExtraKeyboard> {


  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    super.dispose();
  }


  bool _onHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (!widget.ctrlActive && !widget.altActive) return false;

    final logical = event.logicalKey;

    if (_isBareModifier(logical)) return false;

    if (widget.ctrlActive) {
      final consumed = _handleCtrlKey(event);
      if (consumed) widget.onToggleCtrl();
      return consumed;
    }

    if (widget.altActive) {
      final consumed = _handleAltKey(event);
      if (consumed) widget.onToggleAlt();
      return consumed;
    }

    return false;
  }

  bool _handleCtrlKey(KeyEvent event) {
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      final code = char.toUpperCase().codeUnitAt(0);
      // Ctrl+A..Z → bytes 1..26, Ctrl+[ → 27, etc.
      if (code >= 64 && code <= 95) {
        widget.sendRawBytes([code - 64]);
        return true;
      }
    }
    // Ctrl + special keys
    final seq = _ctrlSpecialSeq(event.logicalKey);
    if (seq != null) {
      widget.sendRawBytes(utf8.encode(seq));
      return true;
    }
    return false;
  }

  bool _handleAltKey(KeyEvent event) {
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      widget.sendRawBytes([0x1B, ...utf8.encode(char)]);
      return true;
    }
    final seq = _specialKeySeq(event.logicalKey);
    if (seq != null) {
      // Alt + special key: ESC prefix + sequence
      widget.sendRawBytes([0x1B, ...utf8.encode(seq)]);
      return true;
    }
    return false;
  }

  bool _isBareModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  String? _ctrlSpecialSeq(LogicalKeyboardKey key) {
    // Word-jump sequences (Ctrl+Arrow)
    if (key == LogicalKeyboardKey.arrowLeft) return '\x1B[1;5D';
    if (key == LogicalKeyboardKey.arrowRight) return '\x1B[1;5C';
    if (key == LogicalKeyboardKey.arrowUp) return '\x1B[1;5A';
    if (key == LogicalKeyboardKey.arrowDown) return '\x1B[1;5B';
    return null;
  }

  String? _specialKeySeq(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return '\x1B[A';
    if (key == LogicalKeyboardKey.arrowDown) return '\x1B[B';
    if (key == LogicalKeyboardKey.arrowLeft) return '\x1B[D';
    if (key == LogicalKeyboardKey.arrowRight) return '\x1B[C';
    if (key == LogicalKeyboardKey.home) return '\x1B[H';
    if (key == LogicalKeyboardKey.end) return '\x1B[F';
    if (key == LogicalKeyboardKey.pageUp) return '\x1B[5~';
    if (key == LogicalKeyboardKey.pageDown) return '\x1B[6~';
    if (key == LogicalKeyboardKey.delete) return '\x1B[3~';
    return null;
  }



  String _fKeySeq(int n) {
    const map = {
      1: '\x1BOP',
      2: '\x1BOQ',
      3: '\x1BOR',
      4: '\x1BOS',
      5: '\x1B[15~',
      6: '\x1B[17~',
      7: '\x1B[18~',
      8: '\x1B[19~',
      9: '\x1B[20~',
      10: '\x1B[21~',
      11: '\x1B[23~',
      12: '\x1B[24~',
    };
    return map[n] ?? '';
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(top: BorderSide(color: Color(0xFF3A3A3C), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  // Modifiers
                  _KeyBtn(
                    label: "Ctrl",
                    isToggle: true,
                    isActive: widget.ctrlActive,
                    onTap: widget.onToggleCtrl,
                  ),
                  _KeyBtn(
                    label: "Alt",
                    isToggle: true,
                    isActive: widget.altActive,
                    onTap: widget.onToggleAlt,
                  ),
                  const _Div(),

                  // Common specials
                  _KeyBtn(label: "Esc", onTap: () => widget.sendRaw("\x1B")),
                  _KeyBtn(label: "Tab", onTap: () => widget.sendRaw("\t")),
                  _KeyBtn(
                      label: "^C",
                      tooltip: "Ctrl+C — interrupt",
                      isDestructive: true,
                      onTap: () => widget.sendRawBytes([3])),
                  const _Div(),

                  // Symbols
                  _KeyBtn(label: "~", onTap: () => widget.sendRaw("~")),
                  _KeyBtn(label: "/", onTap: () => widget.sendRaw("/")),
                  _KeyBtn(label: "|", onTap: () => widget.sendRaw("|")),
                  _KeyBtn(label: r"\", onTap: () => widget.sendRaw(r"\")),
                  _KeyBtn(label: "-", onTap: () => widget.sendRaw("-")),
                  _KeyBtn(label: "_", onTap: () => widget.sendRaw("_")),
                  _KeyBtn(label: r"$", onTap: () => widget.sendRaw(r"$")),
                  _KeyBtn(label: '"', onTap: () => widget.sendRaw('"')),
                  _KeyBtn(label: "'", onTap: () => widget.sendRaw("'")),
                  _KeyBtn(label: "`", onTap: () => widget.sendRaw("`")),
                  _KeyBtn(label: "&", onTap: () => widget.sendRaw("&")),
                  _KeyBtn(label: "*", onTap: () => widget.sendRaw("*")),
                  _KeyBtn(label: "!", onTap: () => widget.sendRaw("!")),
                  _KeyBtn(label: "?", onTap: () => widget.sendRaw("?")),
                  const _Div(),

                  // F-keys
                  for (int i = 1; i <= 12; i++)
                    _KeyBtn(
                      label: "F$i",
                      onTap: () => widget.sendRaw(_fKeySeq(i)),
                    ),
                  const _Div(),

                  // Navigation
                  _KeyBtn(label: "Home", onTap: () => widget.sendRaw("\x1B[H")),
                  _KeyBtn(label: "End", onTap: () => widget.sendRaw("\x1B[F")),
                  _KeyBtn(label: "PgUp", onTap: () => widget.sendRaw("\x1B[5~")),
                  _KeyBtn(label: "PgDn", onTap: () => widget.sendRaw("\x1B[6~")),
                  _KeyBtn(
                      label: "Del",
                      isDestructive: true,
                      onTap: () => widget.sendRaw("\x1B[3~")),
                  const _Div(),

                  _KeyBtn(
                      label: "Clr",
                      tooltip: "Ctrl+L",
                      onTap: () => widget.sendRawBytes([12])),
                ],
              ),
            ),
          ),

          // Fixed divider
          Container(
              width: 1,
              height: double.infinity,
              color: const Color(0xFF3A3A3C)),

          // Fixed joystick
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _SwipeArrowPad(onDirection: widget.sendRaw),
          ),
        ],
      ),
    );
  }

}



class _KeyBtn extends StatelessWidget {
  final String label;
  final String? tooltip;
  final VoidCallback onTap;
  final bool isToggle;
  final bool isActive;
  final bool isDestructive;

  const _KeyBtn({
    required this.label,
    required this.onTap,
    this.tooltip,
    this.isToggle = false,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg, border;

    if (isToggle && isActive) {
      bg = AppColors.primaryDark;
      fg = AppColors.textPrimaryDark;
      border = AppColors.primaryDark;
    } else if (isDestructive) {
      bg = const Color(0xFF2C1515);
      fg = const Color(0xFFFF6B6B);
    } else {
      bg = AppColors.btnOnSurface;
      fg = AppColors.textPrimaryDark;
    }

    Widget w = GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );

    if (tooltip != null) w = Tooltip(message: tooltip!, child: w);
    return w;
  }
}


class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 5),
    color: AppColors.dividerDark,
  );
}

/* ==== Swipe joystick ==== */

class _SwipeArrowPad extends StatefulWidget {
  final void Function(String seq) onDirection;
  const _SwipeArrowPad({required this.onDirection});

  @override
  State<_SwipeArrowPad> createState() => _SwipeArrowPadState();
}

class _SwipeArrowPadState extends State<_SwipeArrowPad> {
  String? _active;
  Timer? _repeatTimer;
  Offset? _origin;

  static const double _size = 40.0;
  static const double _threshold = 6.0;

  static const _seqs = {
    'up': '\x1B[A',
    'down': '\x1B[B',
    'left': '\x1B[D',
    'right': '\x1B[C',
  };

  void _fire(String dir) {
    if (_active == dir) return;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    setState(() => _active = dir);
    final seq = _seqs[dir]!;
    widget.onDirection(seq);
    HapticFeedback.selectionClick();
    _repeatTimer = Timer(const Duration(milliseconds: 350), () {
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        widget.onDirection(seq);
      });
    });
  }

  void _stop() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    if (_active != null) setState(() => _active = null);
    _origin = null;
  }

  void _onPanStart(DragStartDetails d) => _origin = d.localPosition;

  void _onPanUpdate(DragUpdateDetails d) {
    if (_origin == null) return;
    final dx = d.localPosition.dx - _origin!.dx;
    final dy = d.localPosition.dy - _origin!.dy;
    if (dx.abs() < _threshold && dy.abs() < _threshold) return;

    final dir = dx.abs() > dy.abs()
        ? (dx > 0 ? 'right' : 'left')
        : (dy > 0 ? 'down' : 'up');

    if (_active != dir) {
      _origin = d.localPosition;
      _fire(dir);
    }
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: (_) => _stop(),
      onPanCancel: _stop,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: AppColors.btnOnSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                top: 1,
                child: _Arrow(
                    icon: Icons.keyboard_arrow_up, active: _active == 'up')),
            Positioned(
                bottom: 1,
                child: _Arrow(
                    icon: Icons.keyboard_arrow_down,
                    active: _active == 'down')),
            Positioned(
                left: 1,
                child: _Arrow(
                    icon: Icons.keyboard_arrow_left,
                    active: _active == 'left')),
            Positioned(
                right: 1,
                child: _Arrow(
                    icon: Icons.keyboard_arrow_right,
                    active: _active == 'right')),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textDisabledDark,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
      ),
    );
  }
}



class _Arrow extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _Arrow({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: 14,
    color: active ? AppColors.primaryDark : AppColors.textDisabledDark,
  );
}