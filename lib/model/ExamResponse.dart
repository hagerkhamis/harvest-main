class Answer {
  final int id;
  final String answer;

  Answer({required this.id, required this.answer});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      answer: json['answer'],
    );
  }
}

class Question {
  final String id;
  final String skill;
  final String questionText;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.skill,
    required this.questionText,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      skill: json['skill'],
      questionText: json['question_text'],
      answers: (json['answers'] as List)
          .map((a) => Answer.fromJson(a))
          .toList(),
    );
  }
}

class ExamResponse {
  final Map<String, List<Question>> sections;

  ExamResponse({required this.sections});

  factory ExamResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<Question>> parsed = {};
    json.forEach((key, value) {
      parsed[key] = List<Question>.from(
        (value as List).map((e) => Question.fromJson(e)),
      );
    });
    return ExamResponse(sections: parsed);
  }
}
