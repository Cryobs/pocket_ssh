import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
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

  static Color successColor = AppColors.successDark;
  static const Color warningColor = AppColors.warningDark;
  static const Color errorColor = AppColors.errorDark;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnlineServers();
    });
  }

  @override
  void dispose() {
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
                       Text(
                         option.name,
                         style: Theme.of(context).textTheme.bodyMedium,
                       ),
                       const SizedBox(width: 12,),
                       Text(
                         option.host,
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: AppColors.textSecondaryDark
                         )
                       ),
                       const SizedBox(width: 12,),
                       Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text(
                             option.online ? "Online" : "Offline",
                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                               color: option.online ? successColor : errorColor,
                             ),
                           ),
                           const SizedBox(width: 6),
                           CircleAvatar(
                             radius: 5,
                             backgroundColor: option.online ? successColor : errorColor,
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
                 setState(() {
                   selectedServer = v;
                 });
                 _initTerminal();
               },
             );
            },
          ),
          Expanded(
              child: TerminalView(
                padding: const EdgeInsets.all(5),
                terminal,
                autofocus: true,
                theme: TerminalThemes.whiteOnBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initTerminal() async {
    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);
    terminal.write('Connecting to ${selectedServer?.host}...\r\n');

    terminal.onOutput = (data) {
      if (session != null && _isConnected) {
        session!.write(utf8.encode(data));
      }
    };

    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      if (session != null && _isConnected) {
        session!.resizeTerminal(width, height, pixelWidth, pixelHeight);
      }
    };

    await _connectToServer();
    await selectedServer?.updateStatsOptimized();
  }

  void _checkOnlineServers() {
    final controller = context.read<ServerController>();
    controller.checkOnlineServers();
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

      _stdoutSubscription = session!.stdout
          .cast<List<int>>()
          .transform(const Utf8Decoder())
          .listen(
            (data) {
          if (mounted) {
            terminal.write(data);
          }
        },
        onError: (error) {
          if (mounted) {
            terminal.write('\r\nSTDOUT Error: $error\r\n');
          }
        },
        onDone: () {
          if (mounted) {
            terminal.write('\r\nConnection closed\r\n');
            setState(() {
              _isConnected = false;
            });
          }
        },
        cancelOnError: true,
      );

      _stderrSubscription = session!.stderr
          .cast<List<int>>()
          .transform(const Utf8Decoder())
          .listen(
            (data) {
          if (mounted) {
            terminal.write(data);
          }
        },
        onError: (error) {
          if (mounted) {
            terminal.write('\r\nSTDERR Error: $error\r\n');
          }
        },
        cancelOnError: true,
      );

      terminal.write('Connected!\r\n');
    } catch (e) {
      terminal.write('\r\nConnection error: $e\r\n');
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }
}