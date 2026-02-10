import 'package:flutter/material.dart';

class InputPass extends StatefulWidget {
  final String hint;
  const InputPass({super.key, this.hint = "Password"});
  
  @override
  State<StatefulWidget> createState() => _InputPassState();
}

class _InputPassState extends State<InputPass> {
  bool _obscureText = true;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        cursorColor: Colors.white,
        obscureText: _obscureText,
        style: const TextStyle(
          color: Colors.white
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white38),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          border: InputBorder.none,

          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
        ),
      ),
    );
  }
  
}