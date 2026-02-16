import 'package:flutter/material.dart';
import 'package:pocket_ssh/theme/app_theme.dart';

class AddServerWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const AddServerWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantDark,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 130,
              child: Center(
                child: Icon(
                  Icons.add_circle_outline,
                  size: 48,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}