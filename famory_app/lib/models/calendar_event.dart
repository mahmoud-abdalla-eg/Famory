import 'package:flutter/material.dart';
import '../theme.dart';

/// Calendar Event Model
class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final Color color;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.color = AppColors.primaryBlue,
  });

  String get timeRange {
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    } else if (startTime != null) {
      return startTime!;
    }
    return 'All day';
  }

  int get day => date.day;
  int get month => date.month;
  int get year => date.year;

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    Color? color,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
    );
  }
}
