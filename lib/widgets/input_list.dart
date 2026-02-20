import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class InputList<T> extends StatelessWidget {
  final String label;
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final T? value;
  final ValueChanged<T> onChanged;

  const InputList({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = "Select",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white38),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(12),
                hint: Text(
                  hint,
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                iconEnabledColor: AppColors.textPrimaryDark,
                style: Theme.of(context).textTheme.bodyMedium,
                items: items,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}