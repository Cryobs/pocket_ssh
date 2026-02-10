import 'package:flutter/material.dart';

class InputList extends StatelessWidget {
  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const InputList({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            borderRadius: BorderRadius.circular(20),
            dropdownColor: const Color(0xFF262626),
            iconEnabledColor: Colors.white,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
