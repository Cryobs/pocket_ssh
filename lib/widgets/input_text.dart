import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ssh/theme/app_theme.dart';

class InputText extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const InputText({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              controller: controller,
              cursorColor: AppColors.textPrimaryDark,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
                border: InputBorder.none,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        )
      ],
    );
  }
}