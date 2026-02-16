import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/server.dart';
import '../services/settings_storage.dart';
import '../services/server_repo.dart';
import '../services/private_key_repo.dart';
import '../ssh_core.dart';

class ServerController extends ChangeNotifier {
  final ServerRepo serverRepo;
  final PrivateKeyRepo privateKeyRepo;
  final SettingsController settingsController;
  final List<Server> _servers = [];
  Timer? _updateTimer;
  Timer? _healthCheckTimer;

  ServerController(
      this.settingsController,
      this.serverRepo,
      this.privateKeyRepo,
      ) {
    _init();
  }

  Future<void> _init() async {
    await _loadServers();
    _startAutoUpdate();
    _startHealthCheck();
    settingsController.addListener(_onSettingsChanged);
  }

  List<Server> getAllServers() => _servers;

  Server? getServer(String id) {
    try {
      return _servers.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  ServerModel? getServerModel(String id) {
    return serverRepo.getById(id);
  }

  Future<void> _loadServers() async {
    _servers.clear();
    final serverModels = serverRepo.getAll();
    for (var serverModel in serverModels) {
      String? sshKeyContent;
      if (serverModel.sshKeyId != null) {
        final key = privateKeyRepo.getById(serverModel.sshKeyId!);
        sshKeyContent = key?.key;
      }

      final server = Server(
        id: serverModel.id,
        name: serverModel.name,
        host: serverModel.host,
        port: serverModel.port,
        username: serverModel.username,
        authType: serverModel.authType == 0 ? AuthType.password : AuthType.sshKey,
        passwordKey: serverModel.passwordKey,
        sshKey: sshKeyContent,
        stat: Statistics(),
      );
      _servers.add(server);
    }
    notifyListeners();
  }

  Future<void> addServer(ServerModel serverModel) async {
    await serverRepo.save(serverModel);
    String? sshKeyContent;
    if (serverModel.sshKeyId != null) {
      final key = privateKeyRepo.getById(serverModel.sshKeyId!);
      sshKeyContent = key?.key;
    }

    final server = Server(
      id: serverModel.id,
      name: serverModel.name,
      host: serverModel.host,
      port: serverModel.port,
      username: serverModel.username,
      authType: serverModel.authType == 0 ? AuthType.password : AuthType.sshKey,
      passwordKey: serverModel.passwordKey,
      sshKey: sshKeyContent,
      stat: Statistics(),
    );
    _servers.add(server);
    notifyListeners();
  }

  Future<void> updateServer(ServerModel serverModel) async {
    final index = _servers.indexWhere((s) => s.id == serverModel.id);
    if (index != -1) {
      final oldStat = _servers[index].stat;
      final oldStatus = _servers[index].status;
      final oldOnline = _servers[index].online;
      final oldClient = _servers[index].client;

      await serverRepo.save(serverModel);

      String? sshKeyContent;
      if (serverModel.sshKeyId != null) {
        final key = privateKeyRepo.getById(serverModel.sshKeyId!);
        sshKeyContent = key?.key;
      }

      final server = Server(
        id: serverModel.id,
        name: serverModel.name,
        host: serverModel.host,
        port: serverModel.port,
        username: serverModel.username,
        authType: serverModel.authType == 0 ? AuthType.password : AuthType.sshKey,
        passwordKey: serverModel.passwordKey,
        sshKey: sshKeyContent,
        stat: oldStat,
        status: oldStatus,
        online: oldOnline,
      );
      server.client = oldClient;
      _servers[index] = server;
      notifyListeners();
    }
  }

  Future<void> deleteServer(String id) async {
    final server = getServer(id);
    if (server != null && server.status == ServerStatus.connected) {
      await server.disconnect();
    }
    await serverRepo.delete(id);
    _servers.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void _startAutoUpdate() {
    _updateTimer?.cancel();
    final interval = settingsController.settings.refreshRate;
    _updateTimer = Timer.periodic(
      Duration(seconds: interval),
          (_) => _updateAllServersStats(),
    );
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _checkServerHealth(),
    );
  }

  Future<void> _checkServerHealth() async {
    bool hasChanges = false;

    for (final server in _servers) {
      final wasOnline = server.online;
      final wasConnected = server.status == ServerStatus.connected;
      final isAlive = server.isAlive;

      if (wasConnected && !isAlive) {
        server.status = ServerStatus.disconnected;
        server.client = null;
        server.online = false;
        hasChanges = true;
        debugPrint('Server ${server.name} disconnected');
      }
      else if (!wasConnected) {
        final isReachable = await _quickOnlineCheck(server);
        if (server.online != isReachable) {
          server.online = isReachable;
          hasChanges = true;
          debugPrint('Server ${server.name} online status: $isReachable');
        }
      }
      else if (wasConnected && isAlive) {
        if (!server.online) {
          server.online = true;
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<bool> _quickOnlineCheck(Server server) async {
    try {
      final socket = await SSHSocket.connect(server.host, server.port)
          .timeout(const Duration(seconds: 3));
      socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _onSettingsChanged() {
    _startAutoUpdate();
  }

  Future<void> _updateAllServersStats() async {
    for (final server in _servers) {
      try {
        if (!server.isAlive) {
          await server.connect();
        }

        if (server.status == ServerStatus.connected) {
          await server.updateStatsOptimized();

          if (!server.online) {
            server.online = true;
          }

          notifyListeners();
        } else {
          if (server.online) {
            server.online = false;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Error updating stats for ${server.name}: $e');
        if (server.online) {
          server.online = false;
          notifyListeners();
        }
      }
    }
  }

  Future<void> updateServerStats(String id) async {
    final server = getServer(id);
    if (server != null && server.status == ServerStatus.connected) {
      try {
        await server.updateStatsOptimized();
        if (!server.online) {
          server.online = true;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating stats for ${server.name}: $e');
        server.online = false;
        notifyListeners();
      }
    }
  }

  Future<void> checkOnlineServers() async {
    bool hasChanges = false;

    for (final server in _servers) {
      final wasOnline = server.online;
      final isOnline = await _quickOnlineCheck(server);

      if (wasOnline != isOnline) {
        server.online = isOnline;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<void> connectToServer(String id) async {
    final server = getServer(id);
    if (server != null) {
      try {
        await server.connect();
        if (server.status == ServerStatus.connected) {
          await server.updateStatsOptimized();
          server.online = true;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error connecting to ${server.name}: $e');
        server.status = ServerStatus.error;
        server.online = false;
        notifyListeners();
      }
    }
  }

  Future<void> disconnectFromServer(String id) async {
    final server = getServer(id);
    if (server != null && server.status == ServerStatus.connected) {
      try {
        await server.disconnect();
        notifyListeners();
      } catch (e) {
        debugPrint('Error disconnecting from ${server.name}: $e');
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _healthCheckTimer?.cancel();
    settingsController.removeListener(_onSettingsChanged);
    for (final server in _servers) {
      if (server.status == ServerStatus.connected) {
        server.disconnect();
      }
    }
    super.dispose();
  }
}