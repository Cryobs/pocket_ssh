import 'package:flutter/material.dart';
import 'package:pocket_ssh/services/settings_storage.dart';
import 'package:pocket_ssh/widgets/input_list.dart';
import 'package:pocket_ssh/widgets/input_text.dart';
import 'package:pocket_ssh/widgets/private_key_list.dart';
import 'package:provider/provider.dart';

import '../widgets/input_pass.dart';


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
                    child: Column(
                      children: [
                        /* REFRESH RATE */
                        InputList(
                          options: const [
                            "5 sec",
                            "10 sec",
                            "15 sec",
                            "30 sec",
                            "45 sec",
                            "60 sec",
                          ],
                          label: "Refresh Rate",
                          value: "${settings.draft.refreshRate} sec",
                          onChanged: (v) {
                            final value = int.parse(v.split(" ").first);
                            settings.setRefreshRateDraft(value);
                          },

                        ),
                        /* DIVIDER */
                        const Divider(
                          color: Colors.white38,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                          height: 20,
                        ),
                        PrivateKeyList(),

                        /* SAVE BUTTON */
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () async {
                              await settings.save();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Settings saved")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 8,
                              )
                            ),
                            child: const Text("Save", style: TextStyle(fontSize: 16),),
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
