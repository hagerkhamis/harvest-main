import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hatvest/core/constants/api_constant.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/model/placement_test_action_model.dart';

class PlacementTestService {
  final Dio _dio = dioClient;

  Future<PlacementTestActionResponse> fetchPlacementTestAction() async {
    final response = await _dio.get(
      ApiConstants.placementTestAction,
      options: Options(
        headers: {'requiresToken': true},
        sendTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );

    dynamic raw = response.data;
    while (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        break;
      }
    }

    if (raw is! Map) {
      throw Exception('Invalid placement test action response');
    }

    final parsed = PlacementTestActionResponse.fromJson(
      Map<String, dynamic>.from(raw),
    );

    // Proceed when an action is present even if status is oddly typed.
    if (!parsed.status && parsed.action.trim().isEmpty) {
      throw Exception(
        parsed.message.isNotEmpty
            ? parsed.message
            : 'Placement test action failed',
      );
    }

    return parsed;
  }
}
