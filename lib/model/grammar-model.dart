class GrammarResponse {
  final List<GrammarQuestion> grammar;
  final String applicationId;
  final String remainDuration;
  final String status;

  GrammarResponse({
    required this.grammar,
    required this.applicationId,
    required this.remainDuration,
    required this.status,
  });

  factory GrammarResponse.fromJson(Map<String, dynamic> json) {
    return GrammarResponse(
      grammar: json['Grammer'] != null
          ? List<GrammarQuestion>.from(
              json['Grammer'].map((x) => GrammarQuestion.fromJson(x)))
          : [],
      applicationId: json['applicationId'] ?? "",
      remainDuration: json['RemainDuration'] ?? "",
      status: json['status'] ?? "",
    );
  }
}

class GrammarQuestion {
  final String id;
  final String skill;
  final String questionText;
  final List<GrammarAnswer> answers;

  GrammarQuestion({
    required this.id,
    required this.skill,
    required this.questionText,
    required this.answers,
  });

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    return GrammarQuestion(
      id: json['id'],
      skill: json['skill'],
      questionText: json['question_text'],
      answers: List<GrammarAnswer>.from(
          json['answers'].map((x) => GrammarAnswer.fromJson(x))),
    );
  }
}

class GrammarAnswer {
  final int id;
  final String answer;

  GrammarAnswer({
    required this.id,
    required this.answer,
  });

  factory GrammarAnswer.fromJson(Map<String, dynamic> json) {
    return GrammarAnswer(
      id: json['id'],
      answer: json['answer'].trim(),
    );
  }
}
