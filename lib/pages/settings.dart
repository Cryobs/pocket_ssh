import 'package:flutter/material.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:pocket_ssh/widgets/input_list.dart';
import 'package:pocket_ssh/widgets/private_key_list.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController _settingsController;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsController = context.read<SettingsController>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settingsController.reset();
    });
    super.dispose();
  }

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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: Text(
                        "Settings",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 355,
                  height: 650,
                  padding: const EdgeInsets.all(37),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      /* REFRESH RATE */
                      InputList(
                        items: [
                          DropdownMenuItem(value: 5, child: Text("5 sec")),
                          DropdownMenuItem(value: 10, child: Text("10 sec")),
                          DropdownMenuItem(value: 15, child: Text("15 sec")),
                          DropdownMenuItem(value: 30, child: Text("30 sec")),
                          DropdownMenuItem(value: 45, child: Text("45 sec")),
                          DropdownMenuItem(value: 60, child: Text("60 sec")),
                        ],
                        label: "Refresh Rate",
                        value: settings.draft.refreshRate,
                        onChanged: (v) {
                          settings.setRefreshRateDraft(v);
                        },
                      ),
                      /* DIVIDER */
                      const Divider(),
                      const PrivateKeyList(),
                      /* SAVE BUTTON */
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () async {
                            await settings.save();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Settings saved")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
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