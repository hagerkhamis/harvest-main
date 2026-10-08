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
        // "${ApiConstants.baseUrl}${ApiConstants.getslideshow}",

        "https://harvestcollege.co.uk/api/getslideshow",
        options: Options(
          headers: {
            'requiresToken': true,
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List slides = response.data['slides_show'];
        return slides.map((e) => SlideModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load slides');
      }
    } catch (e) {
      throw Exception('Error fetching slides: $e');
    }
  }

  Future<LeadModel> fetchProfile() async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.myProfile}",
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return LeadModel.fromJson(response.data['lead']);
      } else {
        throw Exception("Failed to fetch profile");
      }
    } on DioException catch (e) {
      throw Exception("Error: ${e.response?.data}");
    }
  }

  //>>>
  Future<ResultResponse?> fetchResults() async {
    try {
      final response = await _dio.get(
        "https://harvestcollege.co.uk/api",
        // "${ApiConstants.baseUrl}",
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return ResultResponse.fromJson(response.data);
      } else {
        print('Failed to fetch results: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching results: $e');
      return null;
    }
  }
}
