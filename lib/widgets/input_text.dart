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
        Text(widget.label, style: TextStyle(color: Colors.white)),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: Colors.white38
                  ),
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.white),
              ),
            )
        )
      ],
    );
  }
}


