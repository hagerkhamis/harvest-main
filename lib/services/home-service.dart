import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hatvest/constants/api_constant.dart' show ApiConstants;
import 'package:hatvest/interceptors/dio_client.dart' show dioClient;
import 'package:hatvest/model/home-model.dart' show ResultResponse;
import 'package:hatvest/model/profile-model.dart' show LeadModel;
import 'package:hatvest/model/slide_model.dart' show SlideModel;

class HomeService {
  final Dio _dio = dioClient;

  Future<List<SlideModel>> fetchSlides() async {
    try {
      final response = await _dio.get(
        ApiConstants.getslideshow,
        options: Options(
          headers: {
            'requiresToken': true,
            'Accept': 'application/json',
          },
        ),
      );
      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      List slidesData = [];
      if (rawData is List) {
        slidesData = List.from(rawData);
      } else if (rawData is Map && rawData.containsKey('slides_show') && rawData['slides_show'] is List) {
        slidesData = List.from(rawData['slides_show']);
      }
      
      return slidesData
          .where((e) => e is Map)
          .map((json) => SlideModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw Exception('Error fetching slides: $e');
    }
  }

  Future<LeadModel> fetchProfile() async {
    try {
      final response = await _dio.post(
        ApiConstants.myProfile,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is Map && rawData.containsKey('lead')) {
        return LeadModel.fromJson(rawData['lead']);
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map && rawData[0].containsKey('lead')) {
        return LeadModel.fromJson(rawData[0]['lead']);
      } else {
        throw Exception("Unexpected profile data format");
      }
    } on DioException catch (e) {
      throw Exception("Error: ${e.response?.data}");
    }
  }

  //>>>
  Future<ResultResponse?> fetchResults() async {
    try {
      // Re-route from forbidden root to working offers endpoint
      final response = await _dio.get(
        ApiConstants.offers,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      if (rawData is Map) {
        return ResultResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map) {
        return ResultResponse.fromJson(Map<String, dynamic>.from(rawData[0]));
      } else {
        debugPrint('⚠️ Unexpected results format or empty data: $rawData');
        return null;
      }
    } catch (e) {
      print('Error fetching results: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    required String fName,
    required String lName,
    required String mName,
    required String email,
    required String mobile1,
    required String mobile2,
    required String gender,
  }) async {
    final response = await _dio.post(
      ApiConstants.updateProfile,
      data: {
        'f_name': fName,
        'l_name': lName,
        'm_name': mName,
        'email': email,
        'gender': gender,
        'mobile_1': mobile1,
        'mobile_2': mobile2,
        'image': '',
      },
      options: Options(headers: {'requiresToken': true}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}
