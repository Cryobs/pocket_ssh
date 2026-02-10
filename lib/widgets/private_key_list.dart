import 'package:flutter/material.dart';
import 'package:pocket_ssh/pages/private_key_page.dart';
import 'package:pocket_ssh/services/private_key_controller.dart';
import 'package:provider/provider.dart';

class PrivateKeyList extends StatelessWidget {
  const PrivateKeyList({super.key});

  void _navigateToAddKey(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivateKeyPage(),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Key added successfully"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditKey(BuildContext context, String keyId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivateKeyPage(keyId: keyId),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Key updated successfully"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyController = context.watch<PrivateKeyController>();
    final keys = keyController.keys;

    return Column(
      children: [
        const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            "Private Keys",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == keys.length) {
              return GestureDetector(
                onTap: () => _navigateToAddKey(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_circle_outline, color: Colors.white38),
                  ),
                ),
              );
            }

            // Элемент списка
            return GestureDetector(
              onTap: () => _navigateToEditKey(context, keys[index].id),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black38,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        keys[index].name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: keys.length + 1,
        )
      ],
    );
  }
}