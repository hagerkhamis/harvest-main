import 'dart:convert';

ReadingResponse readingResponseFromJson(String str) =>
    ReadingResponse.fromJson(json.decode(str));

class ReadingResponse {
  List<ReadingItem> reading;
  final String applicationId;
  final String remainDuration;
  final String status;

  ReadingResponse({
    required this.reading,
    required this.applicationId,
    required this.remainDuration,
    required this.status,
  });

  factory ReadingResponse.fromJson(Map<String, dynamic> json) =>
      ReadingResponse(
        reading: json["Reading"] != null
            ? List<ReadingItem>.from(
                json["Reading"].map((x) => ReadingItem.fromJson(x)))
            : [],
        applicationId: json['applicationId'] ?? 0,
        remainDuration: json['RemainDuration'] ?? "",
        status: json['status'] ?? "",
      );
}

class ReadingItem {
  String questionId;
  String paragraph;
  List<ReadingQuestion> questions;

  ReadingItem({
    required this.questionId,
    required this.paragraph,
    required this.questions,
  });

  factory ReadingItem.fromJson(Map<String, dynamic> json) => ReadingItem(
        questionId: json["question_id"],
        paragraph: json["paragraph"],
        questions: json["questions"] == null
            ? []
            : List<ReadingQuestion>.from(
                json["questions"].map((x) => ReadingQuestion.fromJson(x))),
      );
}

class ReadingQuestion {
  String id;
  String skill;
  String questionText;
  List<ReadingAnswer> answers;

  ReadingQuestion({
    required this.id,
    required this.skill,
    required this.questionText,
    required this.answers,
  });

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) =>
      ReadingQuestion(
        id: json["id"],
        skill: json["skill"],
        questionText: json["question_text"],
        answers: List<ReadingAnswer>.from(
            json["answers"].map((x) => ReadingAnswer.fromJson(x))),
      );
}

class ReadingAnswer {
  int id;
  String answer;

  ReadingAnswer({
    required this.id,
    required this.answer,
  });

  factory ReadingAnswer.fromJson(Map<String, dynamic> json) => ReadingAnswer(
        id: json["id"],
        answer: json["answer"],
      );
}
