import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'shortcut_model.g.dart';

@HiveType(typeId: 1)
class ShortcutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int order;

  ShortcutModel({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    required this.colorValue,
    required this.order,
  });

  IconData get icon =>
      IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => Color(colorValue);
}
