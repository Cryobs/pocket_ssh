import 'package:flutter/material.dart';

class InputList extends StatelessWidget {
  final String label;
  final List<DropdownMenuItem> items;
  final value;
  final ValueChanged onChanged;

  const InputList({
    super.key,
    required this.label,
    required this.items,
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
          child: DropdownButton(
            value: value,
            borderRadius: BorderRadius.circular(20),
            dropdownColor: const Color(0xFF262626),
            iconEnabledColor: Colors.white,
            items: items,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
