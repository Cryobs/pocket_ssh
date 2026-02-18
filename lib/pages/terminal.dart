import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ssh/services/server_controller.dart';
import 'package:pocket_ssh/ssh_core.dart';
import 'package:pocket_ssh/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:xterm/xterm.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late final Terminal terminal = Terminal();
  SSHSession? session;
  bool _isConnected = false;
  Server? selectedServer;

  StreamSubscription? _stdoutSubscription;
  StreamSubscription? _stderrSubscription;

  static Color successColor = AppColors.successDark;
  static const Color warningColor = AppColors.warningDark;
  static const Color errorColor = AppColors.errorDark;

  bool _ctrlActive = false;
  bool _altActive = false;

  @override
  void initState() {
    super.initState();
    // Global hardware keyboard listener — works regardless of focus
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnlineServers();
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _cleanupConnection();
    super.dispose();
  }

  void _cleanupConnection() {
    _stdoutSubscription?.cancel();
    _stderrSubscription?.cancel();
    _stdoutSubscription = null;
    _stderrSubscription = null;
    session?.close();
    selectedServer?.disconnect();
    _isConnected = false;
  }

  // ─── Global hardware keyboard handler ────────────────────────────────────
  // Returns true to consume the event (prevent further propagation),
  // false to let xterm handle it normally.

  bool _onHardwareKey(KeyEvent event) {
    // Only act on key down / repeat
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    // Only intercept when one of our modifier toggles is active
    if (!_ctrlActive && !_altActive) return false;

    final logical = event.logicalKey;

    // Let bare modifier keys pass through
    if (_isBareModifier(logical)) return false;

    if (_ctrlActive) {
      final consumed = _handleCtrlKey(event);
      if (consumed) setState(() => _ctrlActive = false);
      return consumed;
    }

    if (_altActive) {
      final consumed = _handleAltKey(event);
      if (consumed) setState(() => _altActive = false);
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
        _sendRawBytes([code - 64]);
        return true;
      }
    }
    // Ctrl + special keys
    final seq = _ctrlSpecialSeq(event.logicalKey);
    if (seq != null) {
      _sendRawBytes(utf8.encode(seq));
      return true;
    }
    return false;
  }

  bool _handleAltKey(KeyEvent event) {
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      _sendRawBytes([0x1B, ...utf8.encode(char)]);
      return true;
    }
    final seq = _specialKeySeq(event.logicalKey);
    if (seq != null) {
      // Alt + special key: ESC prefix + sequence
      _sendRawBytes([0x1B, ...utf8.encode(seq)]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Consumer<ServerController>(
              builder: (context, controller, child) {
                final servers = controller.getAllServers();
                return DropdownButton<Server>(
                  value: selectedServer,
                  hint: Text("Select a server"),
                  borderRadius: BorderRadius.circular(15),
                  padding: const EdgeInsets.all(12),
                  items: servers.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(option.name,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 12),
                          Text(option.host,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                  color: AppColors.textSecondaryDark)),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(option.online ? "Online" : "Offline",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                      color: option.online
                                          ? successColor
                                          : errorColor)),
                              const SizedBox(width: 6),
                              CircleAvatar(
                                radius: 5,
                                backgroundColor:
                                option.online ? successColor : errorColor,
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    session?.close();
                    selectedServer?.disconnect();
                    setState(() => selectedServer = v);
                    _initTerminal();
                  },
                );
              },
            ),
            Expanded(
              child: TerminalView(
                padding: const EdgeInsets.all(5),
                terminal,
                theme: TerminalThemes.whiteOnBlack,
              ),
            ),
            _buildExtraKeyboard(),
          ],
        ),
      ),
    );
  }

  // ─── Keyboard: scrollable keys + fixed joystick ───────────────────────────

  Widget _buildExtraKeyboard() {
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
                    isActive: _ctrlActive,
                    onTap: _toggleCtrl,
                  ),
                  _KeyBtn(
                    label: "Alt",
                    isToggle: true,
                    isActive: _altActive,
                    onTap: _toggleAlt,
                  ),
                  const _Div(),

                  // Common specials
                  _KeyBtn(label: "Esc", onTap: () => _sendRaw("\x1B")),
                  _KeyBtn(label: "Tab", onTap: () => _sendRaw("\t")),
                  _KeyBtn(
                      label: "^C",
                      tooltip: "Ctrl+C — interrupt",
                      isDestructive: true,
                      onTap: () => _sendRawBytes([3])),
                  const _Div(),

                  // Symbols
                  _KeyBtn(label: "~", onTap: () => _sendRaw("~")),
                  _KeyBtn(label: "/", onTap: () => _sendRaw("/")),
                  _KeyBtn(label: "|", onTap: () => _sendRaw("|")),
                  _KeyBtn(label: r"\", onTap: () => _sendRaw(r"\")),
                  _KeyBtn(label: "-", onTap: () => _sendRaw("-")),
                  _KeyBtn(label: "_", onTap: () => _sendRaw("_")),
                  _KeyBtn(label: r"$", onTap: () => _sendRaw(r"$")),
                  _KeyBtn(label: '"', onTap: () => _sendRaw('"')),
                  _KeyBtn(label: "'", onTap: () => _sendRaw("'")),
                  _KeyBtn(label: "`", onTap: () => _sendRaw("`")),
                  _KeyBtn(label: "&", onTap: () => _sendRaw("&")),
                  _KeyBtn(label: "*", onTap: () => _sendRaw("*")),
                  _KeyBtn(label: "!", onTap: () => _sendRaw("!")),
                  _KeyBtn(label: "?", onTap: () => _sendRaw("?")),
                  const _Div(),

                  // F-keys
                  for (int i = 1; i <= 12; i++)
                    _KeyBtn(
                      label: "F$i",
                      onTap: () => _sendRaw(_fKeySeq(i)),
                    ),
                  const _Div(),

                  // Navigation
                  _KeyBtn(label: "Home", onTap: () => _sendRaw("\x1B[H")),
                  _KeyBtn(label: "End", onTap: () => _sendRaw("\x1B[F")),
                  _KeyBtn(label: "PgUp", onTap: () => _sendRaw("\x1B[5~")),
                  _KeyBtn(label: "PgDn", onTap: () => _sendRaw("\x1B[6~")),
                  _KeyBtn(
                      label: "Del",
                      isDestructive: true,
                      onTap: () => _sendRaw("\x1B[3~")),
                  const _Div(),

                  _KeyBtn(
                      label: "Clr",
                      tooltip: "Ctrl+L",
                      onTap: () => _sendRawBytes([12])),
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
            child: _SwipeArrowPad(onDirection: _sendRaw),
          ),
        ],
      ),
    );
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

  // ─── Modifiers ────────────────────────────────────────────────────────────

  void _toggleCtrl() {
    setState(() {
      _ctrlActive = !_ctrlActive;
      if (_ctrlActive) _altActive = false;
    });
  }

  void _toggleAlt() {
    setState(() {
      _altActive = !_altActive;
      if (_altActive) _ctrlActive = false;
    });
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  void _sendRawBytes(List<int> bytes) {
    if (session == null || !_isConnected) return;
    session!.write(Uint8List.fromList(bytes));
  }

  void _sendRaw(String value) {
    if (session == null || !_isConnected) return;

    if (_ctrlActive && value.length == 1) {
      final code = value.toUpperCase().codeUnitAt(0);
      session!.write(Uint8List.fromList([code - 64]));
      setState(() => _ctrlActive = false);
    } else if (_altActive) {
      session!.write(Uint8List.fromList([0x1B, ...utf8.encode(value)]));
      setState(() => _altActive = false);
    } else {
      session!.write(Uint8List.fromList(utf8.encode(value)));
    }
  }

  // ─── Terminal init / connect ──────────────────────────────────────────────

  Future<void> _initTerminal() async {
    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);
    terminal.write('Connecting to ${selectedServer?.host}...\r\n');

    terminal.onOutput = (data) {
      if (session == null || !_isConnected) return;

      // Intercept soft keyboard input when Ctrl is active
      if (_ctrlActive && data.length == 1) {
        final code = data.toUpperCase().codeUnitAt(0);
        if (code >= 64 && code <= 95) {
          session!.write(Uint8List.fromList([code - 64]));
          if (mounted) setState(() => _ctrlActive = false);
          return;
        }
      }

      // Intercept soft keyboard input when Alt is active
      if (_altActive && data.length == 1) {
        session!.write(Uint8List.fromList([0x1B, ...utf8.encode(data)]));
        if (mounted) setState(() => _altActive = false);
        return;
      }

      session!.write(utf8.encode(data));
    };

    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      if (session != null && _isConnected)
        session!.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };

    await _connectToServer();
    await selectedServer?.updateStatsOptimized();
  }

  void _checkOnlineServers() {
    context.read<ServerController>().checkOnlineServers();
  }

  Future<void> _connectToServer() async {
    try {
      await selectedServer?.connect();

      if (selectedServer?.status != ServerStatus.connected) {
        terminal.write('\r\nFailed to connect\r\n');
        return;
      }

      session = await selectedServer?.openSession();
      if (session == null) {
        terminal.write('\r\nFailed to open session\r\n');
        return;
      }

      _isConnected = true;
      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);

      _stdoutSubscription =
          const Utf8Decoder(allowMalformed: true).bind(session!.stdout).listen(
                (data) {
              if (mounted) terminal.write(data);
            },
            onError: (e) {
              if (mounted) terminal.write('\r\nSTDOUT Error: $e\r\n');
            },
            onDone: () {
              if (mounted) {
                terminal.write('\r\nConnection closed\r\n');
                setState(() => _isConnected = false);
              }
            },
          );

      _stderrSubscription =
          const Utf8Decoder(allowMalformed: true).bind(session!.stderr).listen(
                (data) {
              if (mounted) terminal.write(data);
            },
            onError: (e) {
              if (mounted) terminal.write('\r\nSTDERR Error: $e\r\n');
            },
          );

      terminal.write('Connected!\r\n');
    } catch (e) {
      terminal.write('\r\nConnection error: $e\r\n');
      if (mounted) setState(() => _isConnected = false);
    }
  }
}

// ─── Key button ───────────────────────────────────────────────────────────────

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
      fg = Colors.white;
      border = AppColors.primaryDark;
    } else if (isDestructive) {
      bg = const Color(0xFF2C1515);
      fg = const Color(0xFFFF6B6B);
      border = const Color(0xFF5C2020);
    } else {
      bg = const Color(0xFF2C2C2E);
      fg = Colors.white;
      border = const Color(0xFF3A3A3C);
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
          border: Border.all(color: border, width: 0.5),
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

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 5),
    color: const Color(0xFF3A3A3C),
  );
}

// ─── Swipe joystick ───────────────────────────────────────────────────────────

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
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3A3A3C), width: 0.5),
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
                  color: const Color(0xFF555557),
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
    color: active ? AppColors.primaryDark : const Color(0xFF666668),
  );
}