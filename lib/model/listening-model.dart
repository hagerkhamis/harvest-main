import 'dart:convert';

ListeningResponse listeningResponseFromJson(String str) =>
    ListeningResponse.fromJson(json.decode(str));

//
class ListeningResponse {
  List<ListeningItem> listening;
  final String applicationId;
  final String remainDuration;
  final String status;

  ListeningResponse({
    required this.listening,
    required this.applicationId,
    required this.remainDuration,
    required this.status,
  });

  factory ListeningResponse.fromJson(Map<String, dynamic> json) =>
      ListeningResponse(
        listening: json["Listening"] != null
            ? List<ListeningItem>.from(
                json["Listening"].map((x) => ListeningItem.fromJson(x)))
            : [],
        applicationId: json['applicationId'] ?? 0,
        remainDuration: json['RemainDuration'] ?? "",
        status: json['status'] ?? "",
      );
}

class ListeningItem {
  String questionId;
  String text;
  String record;
  List<ListeningQuestion> questions;

  ListeningItem({
    required this.questionId,
    required this.text,
    required this.record,
    required this.questions,
  });

  factory ListeningItem.fromJson(Map<String, dynamic> json) => ListeningItem(
        questionId: json["question_id"],
        text: json["text"],
        record: json["record"],
        questions: List<ListeningQuestion>.from(
            json["questions"].map((x) => ListeningQuestion.fromJson(x))),
      );
}

class ListeningQuestion {
  String id;
  String skill;
  String questionText;
  List<ListeningAnswer> answers;

  ListeningQuestion({
    required this.id,
    required this.skill,
    required this.questionText,
    required this.answers,
  });

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) =>
      ListeningQuestion(
        id: json["id"],
        skill: json["skill"],
        questionText: json["question_text"],
        answers: List<ListeningAnswer>.from(
            json["answers"].map((x) => ListeningAnswer.fromJson(x))),
      );
}

class ListeningAnswer {
  int id;
  String answer;

  ListeningAnswer({
    required this.id,
    required this.answer,
  });

  factory ListeningAnswer.fromJson(Map<String, dynamic> json) =>
      ListeningAnswer(
        id: json["id"],
        answer: json["answer"],
      );
}
