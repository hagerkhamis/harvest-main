import 'package:dio/dio.dart';
import 'package:hatvest/constants/api_constant.dart';
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/model/survey-model.dart' show SurveySectionModel;

class SurveyService {
  final Dio _dio = dioClient;

  Future<List<SurveySectionModel>> fetchSurvey() async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.surveySections}",

      // 'https://testsys.harvestcollege.co.uk//survey/sections',
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    final List sections = response.data['survey_sections'];
    return sections.map((e) => SurveySectionModel.fromJson(e)).toList();
  }

  Future<bool> postSurveyAnswers(List<Map<String, dynamic>> sections) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.surveyStore}",
      data: {"survey_sections": sections},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    return response.statusCode == 200;
  }

  Future<List<SurveySectionModel>> fetchExamSurvey() async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.surveyExamSections}",
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    final List sections = response.data['survey_sections'];
    return sections.map((e) => SurveySectionModel.fromJson(e)).toList();
  }

  Future<bool> postExamSurveyAnswers(
      int studentExamId, List<Map<String, dynamic>> sections) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.surveyExamStore}",
      data: {
        "student_exam_id": studentExamId,
        "survey_sections": sections,
      },
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    return response.statusCode == 200;
  }
}
