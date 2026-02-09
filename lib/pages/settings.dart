import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return SafeArea(
      child: Center(
          child: Container(
            width: 355,
            margin: const EdgeInsets.all(26),
            child: Column(
              children: [
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 13),
                      child: Text("Settings", style: TextStyle(color: Colors.white, fontSize: 36)),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    width: 355,
                    padding: EdgeInsets.all(37),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Refresh rate", style: TextStyle(color: Colors.white, fontSize: 16),),

                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }

}