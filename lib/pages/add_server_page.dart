import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ssh/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pocket_ssh/services/server_controller.dart';
import 'package:pocket_ssh/services/private_key_controller.dart';
import 'package:pocket_ssh/widgets/input_text.dart';
import 'package:pocket_ssh/widgets/input_pass.dart';
import 'package:pocket_ssh/widgets/input_list.dart';
import '../models/server.dart';
import '../services/secure_storage.dart';

class AddServerPage extends StatefulWidget {
  final String? serverId;

  const AddServerPage({
    super.key,
    this.serverId,
  });

  @override
  State<AddServerPage> createState() => _AddServerPageState();
}

class _AddServerPageState extends State<AddServerPage> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _authType = 'Password';
  String? _selectedKeyId;
  String _selectedKeyName = 'None';
  bool _isLoading = true;

  bool get _isEditing => widget.serverId != null;

  @override
  void initState() {
    super.initState();
    _loadServerIfEditing();
  }

  Future<void> _loadServerIfEditing() async {
    if (_isEditing) {
      final controller = context.read<ServerController>();
      final serverModel = controller.getServerModel(widget.serverId!);

      if (serverModel != null) {
        _nameController.text = serverModel.name;
        _hostController.text = serverModel.host;
        _portController.text = serverModel.port.toString();
        _usernameController.text = serverModel.username;
        _authType = serverModel.authType == 0 ? 'Password' : 'SSH Key';

        if (serverModel.authType == 1 && serverModel.sshKeyId != null) {
          _selectedKeyId = serverModel.sshKeyId;
          final privateKeyController = context.read<PrivateKeyController>();
          final key = privateKeyController.getKey(serverModel.sshKeyId!);
          _selectedKeyName = key?.name ?? 'None';
        }

        if (serverModel.authType == 0 && serverModel.passwordKey != null) {
          try {
            final password = await SecureStorageService.getValue(serverModel.passwordKey!);
            if (password != null) {
              _passwordController.text = password;
            }
          } catch (e) {
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidIP(String host) {
    final ipv4Pattern = RegExp(
        r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$'
    );

    // IPv6
    final ipv6Pattern = RegExp(
        r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'
    );

    return ipv4Pattern.hasMatch(host) || ipv6Pattern.hasMatch(host);
  }

  bool _isValidDomain(String host) {
    final domainPattern = RegExp(
        r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
    );

    if (host.toLowerCase() == 'localhost') {
      return true;
    }

    return domainPattern.hasMatch(host);
  }

  bool _isValidHost(String host) {
    return _isValidIP(host) || _isValidDomain(host);
  }

  Future<void> _saveServer() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter server name");
      return;
    }

    final host = _hostController.text.trim();
    if (host.isEmpty) {
      _showSnackBar("Please enter host");
      return;
    }

    if (!_isValidHost(host)) {
      _showSnackBar("Please enter a valid IP address or domain name");
      return;
    }

    if (_portController.text.trim().isEmpty) {
      _showSnackBar("Please enter port");
      return;
    }

    final port = int.tryParse(_portController.text);
    if (port == null || port < 1 || port > 65535) {
      _showSnackBar("Port must be between 1 and 65535");
      return;
    }

    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar("Please enter username");
      return;
    }

    if (_authType == 'Password' && _passwordController.text.trim().isEmpty) {
      _showSnackBar("Please enter password");
      return;
    }

    if (_authType == 'SSH Key' && (_selectedKeyId == null || _selectedKeyName == 'None')) {
      _showSnackBar("Please select an SSH key");
      return;
    }

    final controller = context.read<ServerController>();
    String? passwordKey;

    if (_authType == 'Password') {
      if (_isEditing) {
        final existingServer = controller.getServerModel(widget.serverId!);
        passwordKey = existingServer?.passwordKey ?? 'server_password_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        passwordKey = 'server_password_${DateTime.now().millisecondsSinceEpoch}';
      }
      await SecureStorageService.saveValue(passwordKey, _passwordController.text.trim());
    }

    final server = ServerModel(
      id: widget.serverId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      host: host,
      port: port,
      username: _usernameController.text.trim(),
      authType: _authType == 'Password' ? 0 : 1,
      passwordKey: passwordKey,
      sshKeyId: _selectedKeyId,
    );

    try {
      if (_isEditing) {
        await controller.updateServer(server);
        _showSnackBar("Server updated successfully");
      } else {
        await controller.addServer(server);
        _showSnackBar("Server saved successfully");
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar("Error saving server: $e");
    }
  }

  Future<void> _deleteServer() async {
    if (!_isEditing) return;

    if (!mounted) return;

    final controller = Provider.of<ServerController>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Server"),
        content: const Text(
          "Are you sure you want to delete this server? This action cannot be undone.",
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Delete", style: TextStyle(color: AppColors.errorDark)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final serverModel = controller.getServerModel(widget.serverId!);

        if (serverModel?.passwordKey != null) {
          await SecureStorageService.deleteValue(serverModel!.passwordKey!);
        }

        await controller.deleteServer(widget.serverId!);

        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Server deleted")),
            );
            Navigator.pop(context, true);
          } catch (_) {
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          try {
            _showSnackBar("Error deleting server: $e");
          } catch (_) {
          }
        }
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (_) {
      }
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

    final privateKeyController = Provider.of<PrivateKeyController>(context);
    final keys = privateKeyController.keys;
    final keyOptions = ['None', ...keys.map((k) => k.name)];

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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _isEditing ? "Edit Server" : "Add Server",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13,),
                  Container(
                    width: 355,
                    padding: const EdgeInsets.all(37),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InputText(
                          label: "Name",
                          hint: "My Server",
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        InputText(
                          label: "Host",
                          hint: "192.168.1.100 or example.com",
                          controller: _hostController,
                        ),
                        const SizedBox(height: 16),
                        InputText(
                          label: "Port",
                          hint: "22",
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InputText(
                          label: "Username",
                          hint: "root",
                          controller: _usernameController,
                        ),
                        const Divider(),
                        InputList(
                          label: 'Auth Type',
                          options: const ['Password', 'SSH Key'],
                          value: _authType,
                          onChanged: (value) {
                            setState(() {
                              _authType = value;
                              if (_authType == 'SSH Key') {
                                _passwordController.clear();
                              } else {
                                _selectedKeyId = null;
                                _selectedKeyName = 'None';
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_authType == 'Password')
                          InputPass(
                            hint: "Enter password",
                            controller: _passwordController,
                          ),
                        if (_authType == 'SSH Key')
                          InputList(
                            label: 'SSH Key',
                            options: keyOptions,
                            value: _selectedKeyName,
                            onChanged: (value) {
                              setState(() {
                                _selectedKeyName = value;
                                if (value == 'None') {
                                  _selectedKeyId = null;
                                } else {
                                  try {
                                    final key = keys.firstWhere((k) => k.name == value);
                                    _selectedKeyId = key.id;
                                  } catch (e) {
                                    print("Key not found: $e");
                                    _selectedKeyId = null;
                                  }
                                }
                              });
                            },
                          ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveServer,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              _isEditing ? "Update" : "Save",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _deleteServer,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                "Delete Server",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.errorDark)
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