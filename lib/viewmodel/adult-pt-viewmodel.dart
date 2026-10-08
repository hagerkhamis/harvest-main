import 'dart:io';

import 'package:audioplayers/audioplayers.dart' show AudioPlayer, UrlSource;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/model/adult-pt-model.dart';
import 'package:hatvest/model/kids-pt-exam-model.dart' show KidsPtExamModel;
import 'package:hatvest/services/adult-pt-serives.dart';

class ExamViewModel extends ChangeNotifier {
  final ExamService _service = ExamService();

  Welcome? welcome;
  Duration remainDuration = Duration(minutes: 50, seconds: 30);
  late final Ticker _ticker;
  KidsPtExamModel? kidsPtExamModel;

  // bool isLoading = true;
  // List<VocabResponse> vocab = [];
  // List<GrammarResponse> grammar = [];
  // List<ReadingResponse> reading = [];
  // List<ListeningResponse> listening = [];
  // List<WritingResponse> writing = [];
  // List<SpeakingQuestionModel> speaking = [];

  bool isLoading = false;
  String? error;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  //
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, int> _selectedAnswers = {};

  void playAudio(String url) async {
    await _audioPlayer.stop(); // stop previous audio
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void selectAnswer(String questionId, int answerId) {
    _selectedAnswers[questionId] = answerId;
    notifyListeners();
  }

  int? selectedAnswerIdForQuestion(String questionId) {
    return _selectedAnswers[questionId];
  }
  //

  Future<void> loadExam(int trackId) async {
    isLoading = true;
    // notifyListeners();

    welcome = await _service.fetchExam(trackId);

    if (welcome != null) {
      remainDuration = Duration(seconds: welcome!.remainDuration);
    }

    isLoading = false;
    notifyListeners();
  }

  //
  Future<void> loadKidsExam(int trackId) async {
    isLoading = true;
    // notifyListeners();

    kidsPtExamModel = await _service.fetchKidsExam(trackId);

    if (kidsPtExamModel != null) {
      remainDuration = Duration(seconds: kidsPtExamModel!.remainDuration);
    }

    isLoading = false;
    notifyListeners();
  }

  // Future<void> loadQuestions(int trackId) async {
  //   isLoading = true;
  //   error = null;
  //   notifyListeners();

  //   try {
  //     final data = await _service.fetchQuestions(trackId);

  //     vocab =
  //         (data['Vocab'] as List).map((e) => VocabResponse.fromJson(e)).toList();

  //     grammar = (data['Grammer'] as List)
  //         .map((e) => GrammarResponse.fromJson(e))
  //         .toList();

  //     reading = (data['Reading'] as List)
  //         .map((e) => ReadingResponse.fromJson(e))
  //         .toList();

  //     listening = (data['Listening'] as List)
  //         .map((e) => ListeningResponse.fromJson(e))
  //         .toList();

  //     writing = (data['Writing'] as List)
  //         .map((e) => WritingResponse.fromJson(e))
  //         .toList();

  //     speaking = (data['Speaking'] as List)
  //         .map((e) => SpeakingQuestionModel.fromJson(e))
  //         .toList();
  //   } catch (e) {
  //     error = e.toString();
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

//
  void setTimerTicker(Ticker ticker) {
    _ticker = ticker;
  }

  void tickTimer() {
    remainDuration -= Duration(seconds: 1);
    notifyListeners();
  }

  //
  Future<void> submitAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitAdultVocab({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //
  Future<void> submitGrammerAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitGrammerVocab({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //
  Future<void> submitReadingAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitReadingVocab({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //
  Future<void> submitListeningAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitListeningVocab({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  final Dio _dio = dioClient;
  Future<void> submitWritingAnswers(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        'https://harvestcollege.co.uk/api/post_adult_writing',
        data: body,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );
      print("Submitted answers: ${response.data}");
    } catch (e) {
      print("Submission error: $e");
    }
  }

  // void submitWritingAnswers(Map<String, dynamic> body) async {
  //   try {
  //     final response = await _dio.post(
  //       'https://harvestcollege.co.uk/api/post_adult_writing',
  //       data: body,
  //       options: Options(
  //         headers: {
  //           'requiresToken': true,
  //         },
  //       ),
  //     );
  //     print("Submitted answers: ${response.data}");
  //   } catch (e) {
  //     print("Submission error: $e");
  //   }
  // }

  //
  Future<void> uploadSpeakingRecording({
    required int applicationId,
    required File file,
    required String questionId,
    required String duration,
  }) async {
    final formData = FormData.fromMap({
      'applicationId': applicationId,
      'file': await MultipartFile.fromFile(file.path,
          filename: 'recorded_audio.m4a'),
      'question_id': questionId,
      duration: duration,
    });

    try {
      final response = await _dio.post('/post_adult_speaking', data: formData);
      print("Upload response: ${response.data}");
    } catch (e) {
      print("Upload error: $e");
    }
  }
  //

  bool isUploading = false;
  String? uploadError;
  String? uploadSuccess;

  Future<bool> uploadAudio({
    required File file,
    required int questionId,
    required int applicationId,
    required String duration,
  }) async {
    isUploading = true;
    notifyListeners();

    final success =
        await _service.uploadAudio(file, questionId, duration, applicationId);

    isUploading = false;
    notifyListeners();

    return success;
  }

  //
  Future<bool> finishExam({
    required String applicationId,
    required String timerInput,
  }) async {
    isUploading = true;
    notifyListeners();

    final success = await _service.finishExam(
      applicationId: applicationId,
      timerInput: timerInput,
    );

    isUploading = false;
    notifyListeners();

    return success;
  }

//
//>>>>>>>> Kids pt

  Future<bool> finishKidsPtExam({
    required String applicationId,
    required String timerInput,
  }) async {
    isUploading = true;
    notifyListeners();

    final success = await _service.finishKidsPtExam(
      applicationId: applicationId,
      timerInput: timerInput,
    );

    isUploading = false;
    notifyListeners();

    return success;
  }

//>> Vocab
  Future<void> submitKidsVocabAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitKidsPtVocab({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //>> Grammer
  Future<void> submitKidsGrammerAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitKidsGrammerAnswers({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //>> Reading

  Future<void> submitKidsReadingAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitKidsReadingAnswers({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }

  //>> Listing
  Future<void> submitKidsListeningAnswers({
    required int applicationId,
    required List<int> answers,
    required String timerInput,
  }) async {
    try {
      await _service.submitKidsListeningAnswers({
        "applicationId": applicationId,
        "answers": answers,
        "timer_input": timerInput,
      });
    } catch (e) {
      debugPrint("Error submitting answers: $e");
    }
  }
  //>> writng

  Future<void> submitKidsWritingAnswers(Map<String, dynamic> body) async {
    try {
      await _service.submitKidsWritingAnswers(body);
    } catch (e) {
      debugPrint("Submission error: $e");
    }
  }
}
