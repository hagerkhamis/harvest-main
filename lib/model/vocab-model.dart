// models/vocab_response.dart
class VocabResponse {
  final List<VocabQuestion> vocab;
  final int applicationId;
  final String remainDuration;
  final String status;

  VocabResponse({
    required this.vocab,
    required this.applicationId,
    required this.remainDuration,
    required this.status,
  });

  factory VocabResponse.fromJson(Map<String, dynamic> json) {
    return VocabResponse(
      vocab: json['Vocab'] != null
          ? List<VocabQuestion>.from(
              json['Vocab'].map((x) => VocabQuestion.fromJson(x)))
          : [],
      applicationId: json['applicationId'] ?? 0,
      remainDuration: json['RemainDuration'] ?? "",
      status: json['status'] ?? "",
    );
  }
}

class VocabQuestion {
  final String id;
  final String skill;
  final String questionText;
  final List<Answer> answers;

  VocabQuestion({
    required this.id,
    required this.skill,
    required this.questionText,
    required this.answers,
  });

  factory VocabQuestion.fromJson(Map<String, dynamic> json) {
    return VocabQuestion(
      id: json['id'],
      skill: json['skill'],
      questionText: json['question_text'],
      answers:
          List<Answer>.from(json['answers'].map((x) => Answer.fromJson(x))),
    );
  }
}

class Answer {
  final int id;
  final String answer;

  Answer({
    required this.id,
    required this.answer,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      answer: json['answer'],
    );
  }
}
