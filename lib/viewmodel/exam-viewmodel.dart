// viewmodels/exam_viewmodel.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/enums/credit_card_type.dart' show SectionType;
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/model/exam-aswer-model.dart';
import 'package:hatvest/model/grammar-model.dart';
import 'package:hatvest/model/listening-model.dart' show ListeningResponse;
import 'package:hatvest/model/reading-model.dart';
import 'package:hatvest/model/speakingquestion-model.dart';
import 'package:hatvest/model/vocab-model.dart' show VocabResponse;
import 'package:hatvest/model/writing-exam-model.dart'
    show WritingExamResponse, WritingResponse;
import 'package:hatvest/services/exam-serives.dart' show ExamQuizService;

class ExamQuizViewModel extends ChangeNotifier {
  final ExamQuizService _service = ExamQuizService();

  VocabResponse? _examData;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> selectedAnswers = {};

  VocabResponse? get examData => _examData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  GrammarResponse? _data;
  GrammarResponse? get data => _data;

  Future<void> loadExam(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _examData = await _service.fetchExam(studentId);
    } catch (e) {
      _errorMessage = "Failed to load exam";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void submitVocabularyAnswers({
    required String applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitVocabularyAnswers({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }
  // Grammer

  Future<void> loadGrammarExam(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.fetchGrammarExam(studentId);
    } catch (e) {
      _errorMessage = "فشل في تحميل الامتحان";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void submitAnswers({
    required String applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitGrammarAnswers({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }
  //

  ReadingResponse? _reading;
  ReadingResponse? get reading => _reading;

  Future<void> loadReadingExam(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    _reading = await _service.fetchReadingExam(applicationId);
    _isLoading = false;
    notifyListeners();
  }

  void submitReadingAnswers({
    required String applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitReadingAnswers({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //

  ListeningResponse? _listening;
  ListeningResponse? get listening => _listening;

  Future<void> loadListeningExam(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    _listening = await _service.fetchListeningExam(applicationId);
    _isLoading = false;
    notifyListeners();
  }
  //

  WritingResponse? _writing;
  WritingResponse? get writing => _writing;

  Future<void> loadWritingExam(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    _writing = await _service.fetchWritingExam(applicationId);
    _isLoading = false;
    notifyListeners();
  }

  final Dio _dio = dioClient;

  Future<bool> submitWritingAnswers(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        'https://harvestcollege.co.uk/api/post_exam_writing',
        data: body,
        options: Options(
          headers: {'requiresToken': true},
        ),
      );
      print("Submitted answers: ${response.data}");

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Submission error: $e");
    }
    return false;
  }

  //
  ExamAnswer? _examAnswer;

  ExamAnswer? get examAnswer => _examAnswer;
  SectionType get selectedSection => _selectedSection;
  SectionType _selectedSection = SectionType.Vocabulary;

  Future<void> fetchAnswers(int examId) async {
    _examAnswer = await _service.fetchExamAnswer(examId);
    notifyListeners();
  }

  void selectSection(SectionType section) {
    _selectedSection = section;
    notifyListeners();
  }

  //>>
  List<SpeakingQuestion> questions = [];
  String? error;

  Future<void> fetchQuestions(int applicationId) async {
    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      questions = await _service.getSpeakingQuestions(
        applicationId: applicationId,
      );
    } catch (e) {
      error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  //>>
  bool isUploading = false;
  String? uploadError;
  String? uploadSuccess;

  Future<bool> uploadAudio({
    required File file,
    required int questionId,
    required int applicationId,
    // required String duration,
  }) async {
    isUploading = true;
    notifyListeners();

    final success = await _service.uploadAudio(file, questionId, applicationId);

    isUploading = false;
    notifyListeners();

    return success;
  }
}
