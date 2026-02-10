import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pocket_ssh/models/private_key.dart';
import 'package:pocket_ssh/pages/private_key_page.dart';
import 'package:pocket_ssh/pages/settings.dart';
import 'package:pocket_ssh/pages/template.dart';
import 'package:pocket_ssh/services/private_key_controller.dart';
import 'package:pocket_ssh/services/private_key_repo.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PrivateKeyAdapter());

  final privateKeyRepo = PrivateKeyRepo();
  await privateKeyRepo.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SettingsController(SettingsRepository(prefs)),
          ),
          ChangeNotifierProvider(
            create: (_) => PrivateKeyController(privateKeyRepo),
          ),
        ],
        child: const Template(pages: [
          Center(child: Text("Page 0", style: TextStyle(color: Colors.white),)),
          Center(child: Text("Page 1", style: TextStyle(color: Colors.white),)),
          PrivateKeyPage(),
          SettingsPage(),
      ],),
      ),
  );

}

