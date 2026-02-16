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
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            value: value,
            borderRadius: BorderRadius.circular(20),
            dropdownColor: Theme.of(context).canvasColor,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
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
