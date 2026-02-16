import 'package:flutter/material.dart';
import 'package:pocket_ssh/models/private_key.dart';
import 'package:pocket_ssh/services/private_key_controller.dart';
import 'package:pocket_ssh/theme/app_theme.dart';
import 'package:pocket_ssh/widgets/input_big_text.dart';
import 'package:pocket_ssh/widgets/input_pass.dart';
import 'package:pocket_ssh/widgets/input_text.dart';
import 'package:provider/provider.dart';

class PrivateKeyPage extends StatefulWidget {
  final String? keyId;

  const PrivateKeyPage({
    super.key,
    this.keyId,
  });

  @override
  State<PrivateKeyPage> createState() => _PrivateKeyPageState();
}

class _PrivateKeyPageState extends State<PrivateKeyPage> {
  final _nameController = TextEditingController();
  final _passphraseController = TextEditingController();
  final _keyController = TextEditingController();

  bool _isLoading = true;
  bool get _isEditing => widget.keyId != null;

  @override
  void initState() {
    super.initState();
    _loadKeyIfEditing();
  }

  Future<void> _loadKeyIfEditing() async {
    if (_isEditing) {
      final controller = context.read<PrivateKeyController>();
      final key = controller.getKey(widget.keyId!);

      if (key != null) {
        _nameController.text = key.name;
        _passphraseController.text = key.passphrase ?? '';
        _keyController.text = key.key;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passphraseController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter a name");
      return;
    }

    if (_keyController.text.trim().isEmpty) {
      _showSnackBar("Please enter a private key");
      return;
    }

    final controller = context.read<PrivateKeyController>();

    final key = PrivateKey(
      id: widget.keyId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      key: _keyController.text.trim(),
      passphrase: _passphraseController.text.trim().isEmpty
          ? null
          : _passphraseController.text.trim(),
    );

    try {
      if (_isEditing) {
        await controller.updateKey(key);
        _showSnackBar("Key updated successfully");
      } else {
        await controller.addKey(key);
        _showSnackBar("Key saved successfully");
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar("Error saving key: $e");
    }
  }

  Future<void> _deleteKey() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Key"),
        content: const Text(
          "Are you sure you want to delete this key? This action cannot be undone.",
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel",),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: AppColors.errorDark)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<PrivateKeyController>().deleteKey(widget.keyId!);
        if (mounted) {
          _showSnackBar("Key deleted");
          Navigator.pop(context, true);
        }
      } catch (e) {
        _showSnackBar("Error deleting key: $e");
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 355,
              margin: const EdgeInsets.all(26),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _isEditing ? "Edit Private Key" : "Add Private Key",
                            style: Theme.of(context).textTheme.displayLarge
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13,),
                  Container(
                    width: 355,
                    padding: const EdgeInsets.all(37),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InputText(
                          label: "Name",
                          hint: "My Key",
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        InputPass(
                          hint: "Key Passphrase (optional)",
                          controller: _passphraseController,
                        ),
                        const Divider(),
                        InputBigText(
                          label: "Private Key",
                          controller: _keyController,
                        ),
                        const SizedBox(height: 40),

                        /* Save/Update Button */
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveKey,
                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            child: Text(
                              _isEditing ? "Update" : "Save",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        /* Delete Button (only when editing) */
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _deleteKey,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                "Delete Key",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.errorDark),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}