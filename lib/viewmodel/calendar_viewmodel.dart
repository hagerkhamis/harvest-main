import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hatvest/model/calendar_model.dart';
import 'package:hatvest/services/calendar_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarService _service = CalendarService();

  List<CalendarEvent> _events = [];
  bool _isLoading = false;
  String? _error;

  List<CalendarEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DateTime? get firstEventDate {
    for (final e in _events) {
      try {
        final parts = e.date.split('-');
        if (parts.length >= 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _service.fetchCalendarEvents();
      _error = null;
    } on DioException catch (e) {
      _events = [];
      _error = _messageFromDio(e);
      debugPrint('Calendar fetch failed: $_error');
    } catch (e) {
      _events = [];
      _error = e.toString();
      debugPrint('Calendar fetch failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageFromDio(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401 || code == 403) {
      return 'unauthorized';
    }
    return 'fetch_failed';
  }
}
