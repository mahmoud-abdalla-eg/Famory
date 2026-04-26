import 'package:flutter/material.dart';

class CalendarEventModel {
  final String? id;
  final String title;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? time;
  final String? who;
  final Color color;

  const CalendarEventModel({
    this.id,
    required this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.time,
    this.who,
    required this.color,
  });
}

// class CalendarEvent extends CalendarEventModel {
//   const CalendarEvent({
//     required super.title,
//     required super.time,
//     required super.who,
//     required super.color,
//   });
// }
