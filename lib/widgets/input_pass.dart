import 'package:flutter/material.dart';
import 'package:pocket_ssh/theme/app_theme.dart';

class InputPass extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;

  const InputPass({
    super.key,
    required this.hint,
    this.controller,
  });

  @override
  State<InputPass> createState() => _InputPassState();
}

class _InputPassState extends State<InputPass> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            cursorColor: AppColors.textPrimaryDark,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondaryDark,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}