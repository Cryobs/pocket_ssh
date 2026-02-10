import 'package:flutter/material.dart';

class InputBigText extends StatefulWidget {
  final String label;
  final String hint;
  const InputBigText({
    super.key,
    required this.label,
    this.hint = "",
  });

  @override
  State<StatefulWidget> createState() => _InputBigTextState();
}
class _InputBigTextState extends State<InputBigText> {

  static const Color INPUT_COLOR = Colors.black38;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16))
        ),
        const SizedBox(height: 15,),
        TextField(
          maxLines: 5,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: Colors.white38
            ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: INPUT_COLOR),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: INPUT_COLOR),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: INPUT_COLOR),
            ),
            fillColor: INPUT_COLOR,
          ),
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}


