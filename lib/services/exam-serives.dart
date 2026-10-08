// services/exam_service.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hatvest/constants/api_constant.dart';
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/model/exam-aswer-model.dart'
    show ExamAnswer, examAnswerFromJson;
import 'package:hatvest/model/grammar-model.dart' show GrammarResponse;
import 'package:hatvest/model/listening-model.dart'
    show ListeningResponse, listeningResponseFromJson;
import 'package:hatvest/model/reading-model.dart';
import 'package:hatvest/model/speakingquestion-model.dart';
import 'package:hatvest/model/vocab-model.dart' show VocabResponse;
import 'package:hatvest/model/writing-exam-model.dart'
    show WritingExamResponse, WritingResponse, writingResponseFromJson;

class ExamQuizService {
  final Dio _dio = dioClient;

  Future<VocabResponse> fetchExam(int studentId) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getExamVocab}",

      // "https://testsys.harvestcollege.co.uk//get_exam_vocab",
      queryParameters: {"studentId": studentId},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    return VocabResponse.fromJson(response.data);
  }

  Future<void> submitVocabularyAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postExamVocab}",

      // 'https://testsys.harvestcollege.co.uk//post_exam_vocab',
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

  // grammer
  Future<GrammarResponse> fetchGrammarExam(int studentId) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getExamGrammer}",

      // "https://testsys.harvestcollege.co.uk//get_exam_grammer",
      queryParameters: {"applicationId": studentId},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    return GrammarResponse.fromJson(response.data);
  }

  Future<void> submitGrammarAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postExamGrammer}",

      // 'https://testsys.harvestcollege.co.uk//post_exam_grammer',
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

  // reading
  Future<ReadingResponse> fetchReadingExam(String applicationId) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getExamReading}",

      // "https://testsys.harvestcollege.co.uk//get_exam_reading",
      queryParameters: {"applicationId": applicationId},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    return readingResponseFromJson(response.data);
  }

//

  Future<WritingResponse> fetchWritingExam(String applicationId) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getExamWriting}",

      // "https://testsys.harvestcollege.co.uk//get_exam_writing",
      queryParameters: {"applicationId": applicationId},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    return writingResponseFromJson(response.data);
  }

//
  Future<void> submitReadingAnswers(Map<String, dynamic> data) async {
    final response = await _dio.post(
      "${ApiConstants.baseUrl}${ApiConstants.postExamReading}",

      // 'https://testsys.harvestcollege.co.uk//post_exam_reading',
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

  Future<ListeningResponse> fetchListeningExam(String applicationId) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getExamListening}",

      // "https://testsys.harvestcollege.co.uk//get_exam_listening",
      queryParameters: {"applicationId": applicationId},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    return listeningResponseFromJson(response.data);
  }

  //

  Future<ExamAnswer> fetchExamAnswer(int studentExamId) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getExamAnswer}",

      // 'https://testsys.harvestcollege.co.uk//get_exam_answer',
      queryParameters: {
        'student_exam_id': studentExamId,
      },
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    return examAnswerFromJson(response.toString());
  }

  //>>
  Future<List<SpeakingQuestion>> getSpeakingQuestions({
    required int applicationId,
  }) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.getspeakingquestion}",

      // '/getspeakingquestion',
      queryParameters: {
        'applicationId': applicationId,
      },
      options: Options(headers: {
        'requiresToken': true,
      }),
    );

    final data = response.data;

    if (data['status'] != 'success') {
      throw Exception('Failed to load speaking questions');
    }

    final List list = data['Speaking'] ?? [];

    return list.map((e) => SpeakingQuestion.fromJson(e)).toList();
  }

  //>>
  Future<bool> uploadAudio(File file, int questionId, int applicationId) async {
    final fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "question_id": questionId,
      // "timer_input": duration,
      "applicationId": applicationId,
    });

    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.postGroupSpeaking}",

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
}
