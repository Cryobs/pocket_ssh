import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'services/secure_storage.dart';

const CONNECTION_ATTEMPT = 5;
const CPU_USAGE_CMD = "top -bn1 | grep \"Cpu(s)\" | awk '{print 100 - \$8}'";
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

class Server {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;

  final Statistics stat = Statistics();

  final AuthType authType;
  String? _passwordKey;
  final String? sshKey;

  ServerStatus status;

  SSHClient? _client;



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
  }) : _passwordKey = passwordKey;

  String? get passwordKey => _passwordKey;
  set passwordKey(String? key) => _passwordKey = key;

  /* ==== SSH ==== */
  Future<void> connect() async {
    try {
      status = ServerStatus.connecting;

      String? password;
      if (authType == AuthType.password && _passwordKey != null) {
        password = await getValueFromStorage(_passwordKey!);
      }

      final socket = await SSHSocket.connect(host, port);

      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: password != null ? () => password : null,
        identities: authType == AuthType.sshKey && sshKey != null
            ? SSHKeyPair.fromPem(sshKey!)
            : null,
      );


      status = ServerStatus.connected;
    } catch (e) {
      status = ServerStatus.error;
      print("SSH ERROR: $e");
    }
  }

  Future<void> disconnect() async {
    _client!.close();
    status = ServerStatus.disconnected;
  }

  Future<String> exec(String command) async {
    int counter = 0;
    while (_client == null && counter < CONNECTION_ATTEMPT) {
      await connect();
      counter++;
    }
    if (_client == null) throw Exception("SSH client not connected");
    final result = await _client!.run(command);
    return utf8.decode(result);
  }


  Future<SSHSession?> openSession() async {
    int counter = 0;
    while (_client == null && counter < CONNECTION_ATTEMPT) {
      await connect();
      counter++;
    }
    if (_client == null) throw Exception("SSH client not connected");

    final session = await _client!.shell(
      pty: const SSHPtyConfig(
        width: 80,
        height: 25,
      ),
    );

    return session;
  }
  /* ==== Statistics ==== */
  Future<void> getCPU() async {
    stat.cpu = double.parse((await exec(CPU_USAGE_CMD)).trim());
  }

  Future<void> getMEM() async {
    final result = (await exec(MEM_USAGE_CMD)).trim();
    final parts = result.split(" ");
    if (parts.length == 2) {
      final used = double.parse(parts[0]);
      final total = double.parse(parts[1]);
      stat.memUsed = used / 1024 / 1024 / 1024; /* GB */
      stat.memTotal = total / 1024 / 1024 / 1024; /* GB */
      stat.mem = (used / total) * 100;
    }
  }

  Future<void> getStorage() async {
    final result = (await exec(STORAGE_USAGE_CMD)).trim();
    final parts = result.split(" ");
    if (parts.length == 2) {
      final used = double.parse(parts[0]);
      final total = double.parse(parts[1]);
      stat.storageUsed = used / 1024 / 1024 / 1024; /* GB */
      stat.storageTotal = total / 1024 / 1024 / 1024; /* GB */
      stat.storage = (used / total) * 100;
    }
  }

  Future<void> getUptime() async {
    final output = (await exec(UPTIME_CMD)).trim();
    final parts = output.split(RegExp(r',?\s+'));

    for (int i = 1; i < parts.length; i++) {
      if (parts[i].startsWith('day')) {
        stat.uptime = '${parts[i - 1]} d';
        break;
      } else if (parts[i].startsWith('hour')) {
        stat.uptime = '${parts[i - 1]} h';
        break;
      } else if (parts[i].startsWith('minute')) {
        stat.uptime = '${parts[i-1]} m';
        break;
      }
    }
  }

  Future<void> getTemp() async {
    var temp = (await exec(TEMP_CMD)).trim();
    stat.temp = temp.isNotEmpty ? double.parse(temp)/1000 : 0;
  }

  Future<void> updateStats() async {
    await getCPU();
    await getMEM();
    await getStorage();
    await getUptime();
    await getTemp();
  }
}



class Statistics {
  double cpu = 0; /* % usage */
  double mem = 0; /* % used */
  double storage = 0; /* % used */
  double temp = 0; /* C */
  String uptime = "?"; /* days, hours, minutes */

  double memUsed = 0; /* GB */
  double memTotal = 0; /* GB */
  double storageUsed = 0; /* GB */
  double storageTotal = 0; /* GB */

  Statistics();
}
