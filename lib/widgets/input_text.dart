import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  final String label;
  final String hint;
  const InputText({
    super.key,
    required this.label,
    required this.hint
  });

  @override
  State<StatefulWidget> createState() => _InputTextState();
}
class _InputTextState extends State<InputText> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextField(
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: Colors.white38
                  ),
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.white),
              ),
            )
        )
      ],
    );
  }
}


