import 'package:flutter/material.dart';

import '../theme/app_theme.dart';


class OnlineIndicator extends StatefulWidget {
  final bool online;
  const OnlineIndicator({super.key, required this.online});

  @override
  State<StatefulWidget> createState() => _OnlineIndicatorState();
}

class _OnlineIndicatorState extends State<OnlineIndicator> {
  static const Color green = AppColors.successDark;
  static const Color red = AppColors.errorDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.online ? "Online" : "Offline",
          style: TextStyle(
            color: widget.online ? green : red,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        CircleAvatar(
          radius: 5,
          backgroundColor: widget.online ? green : red,
        )
      ],
    );
  }

}
