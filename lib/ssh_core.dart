import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'services/secure_storage.dart';

const CONNECTION_ATTEMPT = 5;

const ALL_STATS_CMD = '''
cpu_usage=\$(grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}')
mem_info=\$(free -b | awk '/Mem:/ {printf("%d %d", \$3, \$2)}')
storage_info=\$(df --block-size=1 --total | awk '/total/ {print \$3, \$2}')
uptime_info=\$(uptime -p)
temp_info=\$(cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
echo "\$cpu_usage|\$mem_info|\$storage_info|\$uptime_info|\$temp_info"
''';

const CPU_USAGE_CMD = "grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}'";
const CPU_USAGE_CMD_ALT = "mpstat 1 1 | awk '/Average/ {print 100 - \$NF}'";

final STORAGE_USAGE_CMD = "df --block-size=1 --total | awk '/total/ {print \$3, \$2}'";
const UPTIME_CMD = "uptime -p";
const TEMP_CMD = "cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1";
const MEM_USAGE_CMD = "free -b | awk '/Mem:/ {printf(\"%d %d\", \$3, \$2)}'";

enum AuthType {
  password,
  sshKey,
}

enum ServerStatus {
  disconnected,
  connecting,
  connected,
  error,
}

extension ServerCheck on Server {
  bool get isAlive {
    if (client == null) {
      status = ServerStatus.disconnected;
      return false;
    }

    try {
      if (client!.isClosed) {
        status = ServerStatus.disconnected;
        client = null;
        return false;
      }
      return true;
    } catch (e) {
      status = ServerStatus.disconnected;
      client = null;
      return false;
    }
  }
}

class Server {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  Statistics? stat;
  final AuthType authType;
  String? _passwordKey;
  final String? sshKey;
  ServerStatus status;
  bool online;
  SSHClient? client;

  Server({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    this.authType = AuthType.password,
    String? passwordKey,
    this.sshKey,
    this.status = ServerStatus.disconnected,
    this.stat,
    this.online = false,
  }) : _passwordKey = passwordKey;

  String? get passwordKey => _passwordKey;
  set passwordKey(String? key) => _passwordKey = key;

  Future<void> connect() async {
    if (status == ServerStatus.connecting) return;

    try {
      status = ServerStatus.connecting;

      String? password;
      if (authType == AuthType.password && _passwordKey != null) {
        password = await getValueFromStorage(_passwordKey!);
      }

      final socket = await SSHSocket.connect(host, port)
          .timeout(const Duration(seconds: 10));

      client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: password != null ? () => password : null,
        identities: authType == AuthType.sshKey && sshKey != null
            ? SSHKeyPair.fromPem(sshKey!)
            : null,
      );

      status = ServerStatus.connected;
    } catch (e) {
      print(sshKey);
      status = ServerStatus.error;
      client = null;
      print("SSH ERROR: $e");
    }
  }

  Future<void> disconnect() async {
    client?.close();
    client = null;
    status = ServerStatus.disconnected;
  }

  Future<String> exec(String command) async {
    int counter = 0;
    while (client == null && counter < CONNECTION_ATTEMPT) {
      await connect();
      counter++;
    }
    if (client == null) throw Exception("SSH client not connected");

    try {
      final result = await client!.run(command);
      return utf8.decode(result);
    } catch (e) {
      status = ServerStatus.disconnected;
      client = null;
      rethrow;
    }
  }

  Future<SSHSession?> openSession() async {
    int counter = 0;
    while (client == null && counter < CONNECTION_ATTEMPT) {
      await connect();
      counter++;
    }
    if (client == null) throw Exception("SSH client not connected");

    try {
      final session = await client!.shell(
        pty: const SSHPtyConfig(
          width: 80,
          height: 25,
        ),
      );
      return session;
    } catch (e) {
      status = ServerStatus.disconnected;
      client = null;
      rethrow;
    }
  }

  Future<void> checkOnline() async {
    if (status == ServerStatus.connected) {
      online = true;
      return;
    }
    try {
      await connect();
      if (status == ServerStatus.connected) {
        online = true;
        return;
      }
      await disconnect();
    } catch (e) {
      online = false;
    }
  }

  Future<void> updateStatsOptimized() async {
    if (status != ServerStatus.connected || client == null) {
      print("⚠️ Cannot update stats - not connected to $name");
      return;
    }

    try {
      final result = (await exec(ALL_STATS_CMD)).trim();
      final parts = result.split('|');

      if (parts.length == 5) {
        _parseCPU(parts[0]);
        _parseMemory(parts[1]);
        _parseStorage(parts[2]);
        _parseUptime(parts[3]);
        _parseTemp(parts[4]);
      }
    } catch (e) {
      if (e.toString().contains('SSHAuthFailError')) {
        print("🔒 Auth error for $name - disconnecting");
        status = ServerStatus.error;
        client = null;
        return;
      }

      print("OPTIMIZED STATS ERROR for $name: $e");    }
  }

  void _parseCPU(String cpuStr) {
    final cpuValue = double.tryParse(cpuStr.trim());
    if (cpuValue != null && cpuValue >= 0 && cpuValue <= 100) {
      stat?.cpu = cpuValue;
    } else {
      stat?.cpu = 0;
    }
  }

  void _parseMemory(String memStr) {
    final parts = memStr.trim().split(" ");
    if (parts.length == 2) {
      final used = double.tryParse(parts[0]);
      final total = double.tryParse(parts[1]);

      if (used != null && total != null && total > 0) {
        stat?.memUsed = used / 1024 / 1024 / 1024;
        stat?.memTotal = total / 1024 / 1024 / 1024;
        stat?.mem = (used / total) * 100;
      } else {
        stat?.mem = 0;
        stat?.memUsed = 0;
        stat?.memTotal = 0;
      }
    }
  }

  void _parseStorage(String storageStr) {
    final parts = storageStr.trim().split(" ");
    if (parts.length == 2) {
      final used = double.tryParse(parts[0]);
      final total = double.tryParse(parts[1]);

      if (used != null && total != null && total > 0) {
        stat?.storageUsed = used / 1024 / 1024 / 1024;
        stat?.storageTotal = total / 1024 / 1024 / 1024;
        stat?.storage = (used / total) * 100;
      } else {
        stat?.storage = 0;
        stat?.storageUsed = 0;
        stat?.storageTotal = 0;
      }
    }
  }

  void _parseUptime(String uptimeStr) {
    final parts = uptimeStr.trim().split(RegExp(r',?\s+'));

    bool found = false;
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].startsWith('day')) {
        stat?.uptime = '${parts[i - 1]} d';
        found = true;
        break;
      } else if (parts[i].startsWith('hour')) {
        stat?.uptime = '${parts[i - 1]} h';
        found = true;
        break;
      } else if (parts[i].startsWith('minute')) {
        stat?.uptime = '${parts[i - 1]} m';
        found = true;
        break;
      }
    }

    if (!found) {
      stat?.uptime = "?";
    }
  }

  void _parseTemp(String tempStr) {
    if (tempStr.trim().isNotEmpty) {
      final tempValue = double.tryParse(tempStr.trim());
      stat?.temp = tempValue != null ? tempValue / 1000 : 0;
    } else {
      stat?.temp = 0;
    }
  }

}

class Statistics {
  double cpu;
  double mem;
  double storage;
  double temp;
  String uptime;
  double memUsed;
  double memTotal;
  double storageUsed;
  double storageTotal;

  Statistics({
    this.cpu = 0,
    this.mem = 0,
    this.storage = 0,
    this.temp = 0,
    this.uptime = "?",
    this.memUsed = 0,
    this.memTotal = 0,
    this.storageUsed = 0,
    this.storageTotal = 0,
  });
}