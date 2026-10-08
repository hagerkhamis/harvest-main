import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hatvest/constants/api_constant.dart';
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/model/adult-pt-model.dart' show Welcome;
import 'package:hatvest/model/adultPt-model.dart' show AdultPtModel;
import 'package:hatvest/model/kids-pt-exam-model.dart' show KidsPtExamModel;

class ExamService {
  final Dio _dio = dioClient;
  // final String baseUrl = 'https://testsys.harvestcollege.co.uk/';

  // Future<Map<String, dynamic>> fetchQuestions(int trackId) async {
  //   try {
  //     final response = await _dio.get(
  //       '$baseUrl/get_adult_question',
  //       queryParameters: {'track_id': trackId},
  //       options: Options(
  //         headers: {
  //           'requiresToken': true,
  //         },
  //       ),
  //     );

  //     return response.data;
  //   } catch (e) {
  //     throw Exception('Error fetching questions: $e');
  //   }
  // }

  Future<Welcome> fetchExam(int trackId) async {
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.getAdultQuestion}",
        // '$baseUrl/get_adult_question',
        queryParameters: {'track_id': trackId},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      return Welcome.fromJson(response.data);
    } catch (e) {
      print("ExamService Error: $e");
      rethrow;
    }
  }

  Future<KidsPtExamModel> fetchKidsExam(int trackId) async {
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.getKidsQuestions}",

        // 'https://testsys.harvestcollege.co.uk//get_kids_questions',
        queryParameters: {'track_id': trackId},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      return KidsPtExamModel.fromJson(response.data);
    } catch (e) {
      print("ExamService Error: $e");
      rethrow;
    }
  }

//kidsPtExamModel
  //
  Future<void> submitAdultVocab(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postAdultVocab}",

      // 'https://testsys.harvestcollege.co.uk//post_adult_vocab',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //
  Future<void> submitGrammerVocab(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postAdultGrammer}",

      // 'https://testsys.harvestcollege.co.uk//post_adult_grammer',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //
  Future<void> submitReadingVocab(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postAdultReading}",

      // 'https://testsys.harvestcollege.co.uk//post_adult_reading',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //
  Future<void> submitListeningVocab(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postAdultListening}",

      // 'https://testsys.harvestcollege.co.uk//post_adult_listening',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //

  Future<bool> uploadAudio(
      File file, int questionId, String duration, int applicationId) async {
    final fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "question_id": questionId,
      "timer_input": duration,
      "applicationId": applicationId,
    });

    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.postAdultSpeaking}",

        // 'https://testsys.harvestcollege.co.uk//post_adult_speaking',
        data: formData,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }

  Future<bool> finishExam({
    required String applicationId,
    required String timerInput,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.finishExam}",

        // 'https://testsys.harvestcollege.co.uk//finish_exam',
        data: {
          "applicationId": applicationId,
          "timer_input": timerInput,
        },
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("finishExam error: $e");
      return false;
    }
  }

  //>>>>>> Kids pt

  Future<bool> finishKidsPtExam({
    required String applicationId,
    required String timerInput,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.finishKidsExam}",

        // 'https://testsys.harvestcollege.co.uk//finish_kids_exam',
        data: {
          "applicationId": applicationId,
          "timer_input": timerInput,
        },
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("finishExam error: $e");
      return false;
    }
  }

  //>> Vocab
  Future<void> submitKidsPtVocab(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postKidsVocab}",

      // 'https://testsys.harvestcollege.co.uk//post_kids_vocab',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //>> Grammer
  Future<void> submitKidsGrammerAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postKidsGrammer}",

      // 'https://testsys.harvestcollege.co.uk//post_kids_grammer',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //>> Reading
  Future<void> submitKidsReadingAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postKidsReading}",

      // 'https://testsys.harvestcollege.co.uk//post_kids_reading',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  //>> Listing

  Future<void> submitKidsListeningAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postKidsListening}",

      // 'https://testsys.harvestcollege.co.uk//post_kids_listening',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit answers");
    }
  }

  Future<void> submitKidsWritingAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postKidsWriting}",
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to submit writing answers");
    }
  }
}
