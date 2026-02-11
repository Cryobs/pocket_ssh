
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// PALETA
final List<Color> teamColors = [
Color(0xFF1C7CA6),
Color(0xFF54A4AF),
Color(0xFF9E1C60),
Color(0xFF986A44),
Color(0xFFE52020),
Color(0xFF9141AC),
Color(0xFF750E21),
Color(0xFFD63838),
];

class EditableShortcutTile extends StatefulWidget {
const EditableShortcutTile({super.key});

@override
State<EditableShortcutTile> createState() => _EditableShortcutTileState();
}

class _EditableShortcutTileState extends State<EditableShortcutTile> {
String title = 'New';
IconData icon = Icons.apps;
late Color backgroundColor;

Color tempColor = Colors.blue;

@override
void initState() {
super.initState();
backgroundColor =
teamColors[Random().nextInt(teamColors.length)];
}

@override
Widget build(BuildContext context) {
return Container(
width: 175,
height: 175,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: backgroundColor,
borderRadius: BorderRadius.circular(20),
),
child: Stack(
children: [
/// MENU
Positioned(
top: 0,
right: 0,
child: PopupMenuButton<String>(
  icon: Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.more_vert,
      color: Colors.white,
      size: 18,
    ),
  ),
onSelected: (value) {
if (value == 'name') _changeName();
if (value == 'icon') _changeIcon();
if (value == 'color') _changeColor();
},
itemBuilder: (context) => const [
PopupMenuItem(
value: 'name',
child: Text('Change name'),
),
PopupMenuItem(
value: 'icon',
child: Text('Change icon'),
),
PopupMenuItem(
value: 'color',
child: Text('Change color'),
),
],
),
),

/// ZAWARTOŚĆ
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(icon, color: Colors.white, size: 32),
const Spacer(),
Text(
title,
style: const TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
],
),
],
),
);
}

// =========================
// ZMIANA NAZWY
// =========================
void _changeName() {
final controller = TextEditingController(text: title);

showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Change name'),
content: TextField(controller: controller),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
setState(() {
title = controller.text;
});
Navigator.pop(context);
},
child: const Text('Save'),
),
],
),
);
}

// =========================
// ZMIANA IKONY
// =========================
void _changeIcon() {
showDialog(
context: context,
builder: (context) => SimpleDialog(
title: const Text('Chose icon'),
children: [
_iconOption(Icons.language),
_iconOption(Icons.security),
_iconOption(Icons.folder),
_iconOption(Icons.web),
],
),
);
}

Widget _iconOption(IconData newIcon) {
return IconButton(
icon: Icon(newIcon),
onPressed: () {
setState(() {
icon = newIcon;
});
Navigator.pop(context);
},
);
}

// =========================
// ZMIANA KOLORU (PALETA + HEX)
// =========================
void _changeColor() {
tempColor = backgroundColor;

showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Chose color'),
content: SingleChildScrollView(
child: Column(
children: [
ColorPicker(
pickerColor: tempColor,
onColorChanged: (color) {
setState(() {
tempColor = color;
});
},
enableAlpha: false,
showLabel: true,
pickerAreaHeightPercent: 0.8,
),
const SizedBox(height: 12),
Text(
'#${tempColor.value.toRadixString(16).substring(2).toUpperCase()}',
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
],
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
setState(() {
backgroundColor = tempColor;
});
Navigator.pop(context);
},
child: const Text('Save'),
),
],
),
);
}
}
