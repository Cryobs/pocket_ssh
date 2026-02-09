import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:pocket_ssh/widgets/input_text.dart';
import 'package:pocket_ssh/widgets/input_pass.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return SafeArea(
      child: SingleChildScrollView(
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
                  Container(
                    width: 355,
                    height: 650,
                    padding: const EdgeInsets.all(37),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Column(
                      children: [
                        InputText(
                          label: "Name",
                          hint: "Your Name",
                        )
                        InputPass(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }

}