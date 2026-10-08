// services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hatvest/constants/api_constant.dart';
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/model/about-app.dart' show AboutResponse;
import 'package:hatvest/model/branch.dart';
import 'package:hatvest/model/country.dart';
import 'package:hatvest/model/get_help_model.dart' show GetHelpResponse;

class ApiService {
  final Dio _dio = dioClient;

  Future<BranchesResponse> getBranches() async {
    try {
      final response = await _dio.get(
        ApiConstants.getBranches,
        options: Options(
          responseType: ResponseType.json,
          headers: {
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

      if (rawData is Map) {
        return BranchesResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else {
        throw Exception('Unexpected response format for branches');
      }
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  Future<CountriesResponse> getCountries() async {
    try {
      final response = await _dio.get(
        ApiConstants.getCountry,
        options: Options(
          responseType: ResponseType.json,
          headers: {
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

      if (rawData is Map) {
        return CountriesResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else {
        throw Exception('Unexpected response format for countries');
      }
    } catch (e) {
      throw Exception('Failed to load countries: $e');
    }
  }
  //

  Future<AboutResponse?> fetchAboutData() async {
    try {
      final response = await _dio.get(
        ApiConstants.aboutApp,
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
        return AboutResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map) {
        return AboutResponse.fromJson(Map<String, dynamic>.from(rawData[0] as Map));
      }
    } catch (e) {
      debugPrint('Error fetching about data: $e');
    }
    return null;
  }

  //>>
  Future<GetHelpResponse?> fetchGetHelp() async {
    try {
      final response = await _dio.get(
        ApiConstants.getHelp,
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
        return GetHelpResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map) {
        return GetHelpResponse.fromJson(Map<String, dynamic>.from(rawData[0] as Map));
      }
    } catch (e) {
      debugPrint('❌ Error fetching Get Help: $e');
    }
    return null;
  }
  
}
