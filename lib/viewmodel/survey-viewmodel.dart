import 'package:flutter/material.dart';
import 'package:hatvest/model/survey-model.dart' show SurveySectionModel;
import 'package:hatvest/services/survey-serives.dart' show SurveyService;

class SurveyViewModel extends ChangeNotifier {
  final SurveyService _service = SurveyService();

  List<SurveySectionModel> sections = [];
  bool isLoading = false;

  // To store selected answers and comments
  Map<int, Map<int, Map<String, dynamic>>> answers = {};

  Future<void> loadSurvey() async {
    isLoading = true;
    notifyListeners();
    sections = await _service.fetchSurvey();
    isLoading = false;
    notifyListeners();
  }

  void selectAnswer(int sectionId, int topicId, int answerId) {
    answers[sectionId] ??= {};
    answers[sectionId]![topicId] = {
      "answer_id": answerId,
      "comment": answers[sectionId]![topicId]?["comment"] ?? "",
    };
    notifyListeners();
  }

  void setComment(int sectionId, int topicId, String comment) {
    answers[sectionId] ??= {};
    answers[sectionId]![topicId] = {
      "answer_id": answers[sectionId]![topicId]?["answer_id"],
      "comment": comment,
    };
    notifyListeners();
  }

  Future<bool> submitSurvey() async {
    final List<Map<String, dynamic>> payload = sections.map((section) {
      final sectionAnswers = answers[section.id] ?? {};
      return {
        "id": section.id,
        "title": section.title,
        "topics": section.topics.map((topic) {
          final topicAnswer = sectionAnswers[topic.id];
          return {
            "id": topic.id,
            "answer_id": topicAnswer?["answer_id"],
            "comment": topicAnswer?["comment"] ?? "",
          };
        }).toList(),
      };
    }).toList();

    return await _service.postSurveyAnswers(payload);
  }
}
