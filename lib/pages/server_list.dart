import 'package:flutter/material.dart';
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
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Text(
                          'No servers yet.\nAdd your first server!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
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
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  server.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editServer(context, server.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFE9220C)),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFE9220C), fontSize: 16),
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
        backgroundColor: const Color(0xFF262626),
        title: const Text(
          "Delete Server",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${server.name}'? This action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFFE9220C)),
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
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting server: $e'),
            backgroundColor: Color(0xFFE9220C),
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