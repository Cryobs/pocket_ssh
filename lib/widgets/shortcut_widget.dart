import 'package:flutter/material.dart';
import 'package:pocket_ssh/models/shortcut_model.dart';
import '../services/script_history_repo.dart';

class EditableShortcutTile extends StatefulWidget {
  final ShortcutModel shortcut;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const EditableShortcutTile({
    super.key,
    required this.shortcut,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<EditableShortcutTile> createState() => _EditableShortcutTileState();
}

class _EditableShortcutTileState extends State<EditableShortcutTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.shortcut.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 0),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.75 : 1.0,
          duration: const Duration(milliseconds: 0),
          child: Container(
            width: 175,
            height: 175,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_lighten(base, 0.15), base, _darken(base, 0.15)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.2 : 0.5),
                  offset: Offset(0, _pressed ? 2 : 6),
                  blurRadius: _pressed ? 6 : 12,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Icon(widget.shortcut.icon, color: Colors.white, size: 28),
                ),
                Positioned(top: -8, right: -5, child: _buildMenu(context)),
                Center(
                  child: Text(
                    widget.shortcut.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) => PopupMenuButton<String>(
    padding: EdgeInsets.zero,
    icon: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
      ),
      child: const Icon(Icons.more_horiz, color: Colors.white, size: 18),
    ),
    onSelected: (value) {
      if (value == 'edit') widget.onEdit();
      if (value == 'delete') _confirmDelete(context);
      if (value == 'history') _showHistory(context);
    },
    itemBuilder: (context) => const [
      PopupMenuItem(value: 'edit', child: Text('Edit')),
      PopupMenuItem(
        value: 'delete',
        child: Text('Delete', style: TextStyle(color: Colors.red)),
      ),
      PopupMenuItem(
        value: 'history',
        child: Text('History', style: TextStyle(color: Colors.blueAccent)),
      ),
    ],
  );

  void _showHistory(BuildContext context) {
    final historyRepo = ScriptHistoryRepository();
    final runs = historyRepo.getRuns(widget.shortcut.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('History: ${widget.shortcut.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: runs.isEmpty
              ? const Text('No runs yet.')
              : ListView.builder(
            shrinkWrap: true,
            itemCount: runs.length,
            itemBuilder: (_, index) {
              final run = runs[index];
              return ExpansionTile(
                title: Text(run.startTime.toLocal().toIso8601String()),
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black12,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(run.output),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete shortcut'),
        content: Text('Are you sure you want to delete "${widget.shortcut.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}