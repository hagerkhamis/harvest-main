import 'package:flutter/material.dart';

enum CalendarEventType { exam, lecture, task, other }

CalendarEventType parseCalendarEventType(String type) {
  final t = type.toLowerCase().trim();
  if (t.contains('exam') || t.contains('امتحان') || t == 'اختبار') {
    return CalendarEventType.exam;
  }
  if (t.contains('lecture') ||
      t.contains('class') ||
      t.contains('lesson') ||
      t.contains('محاضر') ||
      t.contains('محاضرة')) {
    return CalendarEventType.lecture;
  }
  if (t.contains('task') ||
      t.contains('homework') ||
      t.contains('assignment') ||
      t.contains('مهمة') ||
      t.contains('واجب')) {
    return CalendarEventType.task;
  }
  return CalendarEventType.other;
}

class CalendarEventTypeStyle {
  final Color color;
  final IconData icon;

  const CalendarEventTypeStyle({required this.color, required this.icon});

  static CalendarEventTypeStyle of(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.exam:
        return const CalendarEventTypeStyle(
          color: Color(0xFFE53935),
          icon: Icons.assignment_outlined,
        );
      case CalendarEventType.lecture:
        return const CalendarEventTypeStyle(
          color: Color(0xFF1E88E5),
          icon: Icons.school_outlined,
        );
      case CalendarEventType.task:
        return const CalendarEventTypeStyle(
          color: Color(0xFFFB8C00),
          icon: Icons.task_alt_outlined,
        );
      case CalendarEventType.other:
        return const CalendarEventTypeStyle(
          color: Color(0xFF607D8B),
          icon: Icons.event_outlined,
        );
    }
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String instructor;
  final String room;
  final String branch;
  final String status;
  final String type;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.instructor,
    required this.room,
    required this.branch,
    required this.status,
    required this.type,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: _field(json, const ['id', 'Id', 'event_id']),
      title: _field(json, const ['title', 'Title', 'name', 'Name']),
      date: _field(json, const ['date', 'Date', 'event_date', 'day']),
      startTime: _field(json, const [
        'start_time',
        'startTime',
        'StartTime',
        'time',
        'Time',
      ]),
      endTime: _field(json, const ['end_time', 'endTime', 'EndTime']),
      instructor: _field(json, const ['instructor', 'Instructor']),
      room: _field(json, const ['room', 'Room']),
      branch: _field(json, const ['branch', 'Branch']),
      status: _field(json, const ['status', 'Status']),
      type: _field(json, const ['type', 'Type', 'event_type', 'category']),
    );
  }

  static String _field(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  CalendarEventType get eventType => parseCalendarEventType(type);

  bool get isPlacementTest {
    final t = type.toLowerCase().trim();
    final titleLower = title.toLowerCase();
    return t == 'pt' ||
        t.contains('placement') ||
        titleLower.contains('placement') ||
        title.contains('تحديد المستوى') ||
        title.contains('اختبار تحديد');
  }

  int get displayPriority {
    if (isPlacementTest) return 4;
    switch (eventType) {
      case CalendarEventType.task:
        return 0;
      case CalendarEventType.lecture:
        return 1;
      case CalendarEventType.exam:
        return 2;
      case CalendarEventType.other:
        return 3;
    }
  }

  static List<CalendarEvent> sortedForDisplay(List<CalendarEvent> events) {
    final copy = List<CalendarEvent>.from(events);
    copy.sort((a, b) => a.displayPriority.compareTo(b.displayPriority));
    return copy;
  }
}
