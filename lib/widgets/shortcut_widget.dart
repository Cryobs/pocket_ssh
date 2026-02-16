import 'package:flutter/material.dart';
import 'package:pocket_ssh/models/shortcut_model.dart';

class EditableShortcutTile extends StatelessWidget {
  final ShortcutModel shortcut;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EditableShortcutTile({
    super.key,
    required this.shortcut,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lighten(shortcut.color, 0.15),
            shortcut.color,
            _darken(shortcut.color, 0.15),
          ],
        ),
      ),
      child: Stack(
        children: [
          /// IKONA
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              shortcut.icon,
              color: Colors.white,
              size: 28,
            ),
          ),

          /// MENU
          Positioned(
            top: -8,
            right: -5,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: _menuDot(),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') _confirmDelete(context);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

          /// TEKST
          Center(
            child: Text(
              shortcut.title,
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
    );
  }

  // =========================
  // DELETE CONFIRM
  // =========================
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete shortcut'),
        content: Text(
          'Are you sure you want to delete "${shortcut.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================
  Widget _menuDot() => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.25),
    ),
    child: const Icon(
      Icons.more_horiz,
      color: Colors.white,
      size: 18,
    ),
  );
}

/// =========================
/// GRADIENT
/// =========================
Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
      .toColor();
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}
