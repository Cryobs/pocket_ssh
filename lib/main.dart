import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/adapters.dart';

// PAGES
import 'package:pocket_ssh/pages/template.dart';
import 'package:pocket_ssh/pages/shortcuts_page.dart';
import 'package:pocket_ssh/pages/settings.dart';
import 'package:pocket_ssh/pages/server_list.dart';
import 'package:pocket_ssh/pages/terminal.dart';

// MODELS
import 'package:pocket_ssh/models/shortcut_model.dart';
import 'package:pocket_ssh/models/private_key.dart';
import 'package:pocket_ssh/models/server.dart';

// SERVICES / REPOS
import 'package:pocket_ssh/services/shortcuts_repository.dart';
import 'package:pocket_ssh/services/private_key_repo.dart';
import 'package:pocket_ssh/services/private_key_controller.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:pocket_ssh/services/server_controller.dart';
import 'package:pocket_ssh/services/server_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // HIVE INIT
  // =========================
  await Hive.initFlutter();

  // ADAPTERY
  Hive.registerAdapter(ShortcutModelAdapter());
  Hive.registerAdapter(PrivateKeyAdapter());
  Hive.registerAdapter(ServerModelAdapter());

  // =========================
  // REPOZYTORIA
  // =========================
  final shortcutsRepo = ShortcutsRepository();
  await shortcutsRepo.init();

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
        /// SETTINGS
        ChangeNotifierProvider(
          create: (_) => SettingsController(
            SettingsRepository(prefs),
          ),
        ),

        /// PRIVATE KEYS
        ChangeNotifierProvider(
          create: (_) => PrivateKeyController(privateKeyRepo),
        ),

        /// SHORTCUTS (Hive)
        Provider<ShortcutsRepository>.value(
          value: shortcutsRepo,
        ),        
        
        /// SERVER
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
          ShortcutsPage(),
          const SettingsPage(),
        ],
      ),
    ),
  );
}
