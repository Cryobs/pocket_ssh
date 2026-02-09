import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ssh/ssh_core.dart';
import 'package:pocket_ssh/services/secure_storage.dart';
import 'dart:convert';
import 'package:xterm/xterm.dart';

class TerminalScreen extends StatefulWidget {
  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late final Terminal terminal = Terminal();
  Server server = Server(
      id: "1",
      name: "Server 1",
      host: "192.168.10.24",
      port: 22,
      username: "server",
      authType: AuthType.password
  );
  SSHSession? session;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initTerminal();
  }

  Future<void> _initTerminal() async {
    terminal.write('Connecting to ${server.host}...\r\n');

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
    await server.updateStats();
    print("CPU: ${server.stat.cpu}%");
    print("MEM: ${server.stat.mem}% (${server.stat.memUsed}/${server.stat.memTotal})");
    print("DISK: ${server.stat.storage}% (${server.stat.storageUsed}/${server.stat.storageTotal})");
    print("TEMP: ${server.stat.temp} C");
    print("UPTIME: ${server.stat.uptime}");
  }

  Future<void> _connectToServer() async {
    try {
      await SecureStorageService.savePassword(
        "server_${server.id}_password",
        "ZAQ!2wsx",
      );
      server.passwordKey = "server_${server.id}_password";

      await server.connect();

      if (server.status != ServerStatus.connected) {
        terminal.write('\r\nFailed to connect\r\n');
        return;
      }

      session = await server.openSession();

      if (session == null) {
        terminal.write('\r\nFailed to open session\r\n');
        return;
      }

      _isConnected = true;

      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);

      session!.stdout.cast<List<int>>().transform(const Utf8Decoder()).listen(
            (data) {
          terminal.write(data);
        },
        onError: (error) {
          terminal.write('\r\nSTDOUT Error: $error\r\n');
        },
        onDone: () {
          terminal.write('\r\nConnection closed\r\n');
          setState(() {
            _isConnected = false;
          });
        },
      );

      session!.stderr.cast<List<int>>().transform(const Utf8Decoder()).listen(
            (data) {
          terminal.write(data);
        },
        onError: (error) {
          terminal.write('\r\nSTDERR Error: $error\r\n');
        },
      );

      terminal.write('Connected!\r\n');

    } catch (e) {
      terminal.write('\r\nConnection error: $e\r\n');
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  void dispose() {
    session?.close();
    server.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TerminalView(
          terminal,
          autofocus: true,
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}