import 'package:flutter/material.dart';
import 'package:pocket_ssh/theme/app_theme.dart';

class AddShortcutTile extends StatelessWidget {
  final VoidCallback onAdd;

  const AddShortcutTile({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 175,
        height: 175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.surfaceVariantDark,
        ),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.onSurfaceVariant,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
