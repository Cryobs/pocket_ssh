import 'package:flutter/material.dart';
import 'package:pocket_ssh/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pocket_ssh/widgets/add_server_widget.dart';
import 'package:pocket_ssh/widgets/server_widget.dart';
import 'package:pocket_ssh/pages/add_server_page.dart';

import '../services/secure_storage.dart';
import '../services/server_controller.dart';
import '../ssh_core.dart';

class ServerList extends StatefulWidget {
  const ServerList({super.key});

  @override
  State<StatefulWidget> createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  bool _isAutoConnecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoConnectServers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Consumer<ServerController>(
        builder: (context, controller, child) {
          final servers = controller.getAllServers();

          return ListView(
            children: [
              Column(
                children: [
                  ...servers.map((server) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ServerWidget(
                      server: server,
                      online: server.status == ServerStatus.connected,
                      onTap: () => _connectToServer(context, server),
                      onLongPress: () => _showServerOptions(context, server),
                    ),
                  )),
                  if (servers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Text(
                          'No servers yet.\nAdd your first server!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ),
                  AddServerWidget(
                    onTap: () => _navigateToAddServer(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showServerOptions(BuildContext context, Server server) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  server.name,
                  style: Theme.of(context).textTheme.titleSmall
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(
                  'Edit',
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editServer(context, server.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.errorDark),
                title: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.errorDark)
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteServer(context, server);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddServer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddServerPage(),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _editServer(BuildContext context, String serverId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServerPage(serverId: serverId),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  Future<void> _confirmDeleteServer(BuildContext context, Server server) async {
    if (!mounted) return;

    final controller = Provider.of<ServerController>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          "Delete Server",
        ),
        content: Text(
          "Are you sure you want to delete '${server.name}'? This action cannot be undone.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text("Cancel")
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: AppColors.errorDark),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final serverModel = controller.getServerModel(server.id);

    try {
      if (serverModel?.passwordKey != null) {
        await SecureStorageService.deleteValue(serverModel!.passwordKey!);
      }

      await controller.deleteServer(server.id);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server deleted'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting server: $e'),
            backgroundColor: AppColors.errorDark
          ),
        );
      }
    }
  }

  void _connectToServer(BuildContext context, Server server) async {
    if (!mounted) return;

    final controller = context.read<ServerController>();

    try {
      await controller.connectToServer(server.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: const Color(0xFFE9220C),
          ),
        );
      }
    }
  }

  void _autoConnectServers() async {
    if (_isAutoConnecting) return;
    _isAutoConnecting = true;

    final controller = context.read<ServerController>();
    final servers = controller.getAllServers();

    for (final server in servers) {
      if (server.status != ServerStatus.connected) {
        try {
          await controller.connectToServer(server.id);
        } catch (error) {
          print("Auto-connect failed for ${server.name}: $error");
        }
      }
    }

    _isAutoConnecting = false;
  }
}