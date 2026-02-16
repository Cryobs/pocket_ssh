import 'package:flutter/material.dart';


class SshController extends ChangeNotifier {
  bool _connected = false;

  bool get isConnected => _connected;


  Future<void> connect({
    required String host,
    required String user,
    required int port,
  }) async {
    // TODO: prawdziwe połączenie SSH
    _connected = true;
    notifyListeners();
  }


  Future<void> disconnect() async {
    _connected = false;
    notifyListeners();
  }



  Future<void> run(String command) async {
    if (!_connected) {
      debugPrint('❌ SSH not connected');
      return;
    }

    debugPrint('▶️ SSH RUN: $command');

    // TODO:
    // tutaj docelowo:
    // client.execute(command);
  }
}
