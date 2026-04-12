import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../theme.dart';

/// Global Event Service - Shared between Chat AI and Calendar
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final List<CalendarEventModel> _events = [];
  final List<VoidCallback> _listeners = [];

  List<CalendarEventModel> get events => List.unmodifiable(_events);

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void addEvent(CalendarEventModel event) {
    _events.add(event);
    _notifyListeners();
  }

  void removeEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    _notifyListeners();
  }

  void updateEvent(CalendarEventModel event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      _notifyListeners();
    }
  }

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  List<CalendarEventModel> getEventsForMonth(int year, int month) {
    return _events.where((event) {
      return event.date.year == year && event.date.month == month;
    }).toList();
  }

  bool hasEventsOnDate(DateTime date) {
    return _events.any((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    });
  }

  // Initialize with sample events
  void initializeSampleEvents() {
    if (_events.isEmpty) {
      final now = DateTime.now();
      _events.addAll([
        CalendarEventModel(
          id: '1',
          title: 'Soccer Practice',
          date: DateTime(now.year, now.month, 11),
          startTime: '4:00 PM',
          endTime: '5:30 PM',
          color: AppColors.accentOrange,
        ),
        CalendarEventModel(
          id: '2',
          title: 'Family Dinner',
          date: DateTime(now.year, now.month, 11),
          startTime: '6:30 PM',
          endTime: '8:00 PM',
          color: AppColors.successGreen,
        ),
        CalendarEventModel(
          id: '3',
          title: 'Parent-Teacher Meeting',
          date: DateTime(now.year, now.month, 13),
          startTime: '3:00 PM',
          endTime: '4:00 PM',
          color: AppColors.primaryBlue,
        ),
        CalendarEventModel(
          id: '4',
          title: 'Dentist Appointment',
          date: DateTime(now.year, now.month, 15),
          startTime: '10:00 AM',
          endTime: '11:00 AM',
          color: AppColors.accentOrange,
        ),
      ]);
    }
  }
}
