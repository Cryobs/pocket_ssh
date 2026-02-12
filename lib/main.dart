import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pocket_ssh/models/private_key.dart';
import 'package:pocket_ssh/pages/server_list.dart';
import 'package:pocket_ssh/pages/settings.dart';
import 'package:pocket_ssh/pages/template.dart';
import 'package:pocket_ssh/pages/terminal.dart';
import 'package:pocket_ssh/services/private_key_controller.dart';
import 'package:pocket_ssh/services/private_key_repo.dart';
import 'package:pocket_ssh/services/server_controller.dart';
import 'package:pocket_ssh/services/server_repo.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PrivateKeyAdapter());
  Hive.registerAdapter(ServerModelAdapter());

  final privateKeyRepo = PrivateKeyRepo();
  await privateKeyRepo.init();

  final serverRepo = ServerRepo();
  await serverRepo.init();

  final prefs = await SharedPreferences.getInstance();
  final settingsRepo = SettingsRepository(prefs);
  final settingsController = SettingsController(settingsRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: settingsController,
        ),
        ChangeNotifierProvider(
          create: (_) => PrivateKeyController(privateKeyRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ServerController(
            settingsController,
            serverRepo,
            privateKeyRepo,
          ),
        ),
      ],
      child: Template(
        pages: [
          const ServerList(),
          TerminalScreen(),
          const Center(
            child: Text(
              "Coming soon",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SettingsPage(),
        ],
      ),
    ),
  );
}