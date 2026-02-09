import 'package:flutter/material.dart';
import 'package:pocket_ssh/pages/settings.dart';
import 'package:pocket_ssh/pages/template.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_ssh/widgets/input_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsController(
        SettingsRepository(prefs),
      ),
      child: const Template(pages: [
        Center(child: Text("Page 0", style: TextStyle(color: Colors.white),)),
        Center(child: Text("Page 1", style: TextStyle(color: Colors.white),)),
        Center(child: Text("Page 2", style: TextStyle(color: Colors.white),)),
        SettingsPage(),

      ],)
    )
  );
}

