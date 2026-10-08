import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/model/exam_model.dart';

class ExamListService {
  final Dio _dio = dioClient;

  Future<List<ExamItem>> fetchExams() async {
    try {
      final response = await _dio.get(
        'get_exams',
        options: Options(headers: {'requiresToken': true}),
      );

      dynamic raw = response.data;
      while (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {
          break;
        }
      }

      List<dynamic> list = [];
      if (raw is Map) {
        final data = raw['data'];
        if (data is Map) {
          final completed = data['completed_exams'];
          if (completed is List) list.addAll(completed);
          final upcoming = data['upcoming_exams'];
          if (upcoming is List) list.addAll(upcoming);
          final pending = data['pending_exams'];
          if (pending is List) list.addAll(pending);
        } else if (data is List) {
          list = data;
        }
      } else if (raw is List) {
        list = raw;
      }

      return list
          .where((e) => e is Map)
          .map((e) => ExamItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load exams: $e');
    }
  }
}
