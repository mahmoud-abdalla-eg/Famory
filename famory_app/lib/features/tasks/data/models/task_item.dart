import 'package:flutter/material.dart';

class TaskItem {
  String id;
  String title;
  String subtitle;
  String pillText;
  Color pillColor;
  Color pillBg;
  bool isDone;

  TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pillText,
    required this.pillColor,
    required this.pillBg,
    this.isDone = false,
  });
}
