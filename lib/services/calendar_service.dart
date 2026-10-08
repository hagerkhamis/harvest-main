import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/model/calendar_model.dart';

class CalendarService {
  final Dio _dio = dioClient;

  static const _endpointCandidates = [
    'calendar',
    'get_calendar',
    'getCalendar',
  ];

  Future<List<CalendarEvent>> fetchCalendarEvents() async {
    DioException? lastDioError;

    for (final endpoint in _endpointCandidates) {
      try {
        final events = await _fetchFromEndpoint(endpoint);
        return events;
      } on DioException catch (e) {
        lastDioError = e;
        final code = e.response?.statusCode;
        debugPrint('Calendar endpoint "$endpoint" failed: $code ${e.message}');
        if (code == 404) continue;
        break;
      } catch (e) {
        debugPrint('Calendar endpoint "$endpoint" parse error: $e');
      }
    }

    if (lastDioError != null) throw lastDioError;
    return [];
  }

  Future<List<CalendarEvent>> _fetchFromEndpoint(String endpoint) async {
    final response = await _dio.get(
      endpoint,
      options: Options(
        headers: {'requiresToken': true},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode == 401 || statusCode == 403) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Unauthorized',
      );
    }
    if (statusCode >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'HTTP $statusCode',
      );
    }

    return _parseEvents(response.data);
  }

  List<CalendarEvent> _parseEvents(dynamic rawData) {
    dynamic data = rawData;
    while (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        break;
      }
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final status = map['status'];
      if (status == false && map['data'] == null && map['events'] == null) {
        return [];
      }
      final list = _extractEventList(map);
      if (list != null) return _mapEvents(list);
    } else if (data is List) {
      return _mapEvents(data);
    }

    return [];
  }

  List<dynamic>? _extractEventList(Map<String, dynamic> map) {
    const keys = [
      'data',
      'Data',
      'events',
      'Events',
      'calendar',
      'Calendar',
      'items',
      'result',
    ];

    for (final key in keys) {
      final value = map[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractEventList(Map<String, dynamic>.from(value));
        if (nested != null) return nested;
      }
    }
    return null;
  }

  List<CalendarEvent> _mapEvents(List<dynamic> list) {
    final events = <CalendarEvent>[];
    for (final item in list) {
      if (item is! Map) continue;
      try {
        events.add(
          CalendarEvent.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (e) {
        debugPrint('Skipped invalid calendar item: $e');
      }
    }
    return events;
  }
}
