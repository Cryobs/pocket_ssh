import 'package:flutter/material.dart';

class InputBigText extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;

  const InputBigText({
    super.key,
    required this.label,
    this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          cursorColor: Colors.white,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: "Paste your private key here...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white38),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white38),
            ),
          ),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ]
    );
  }
}