class SpeakingQuestion {
  final String questionId;
  final String text;
  final String photo;

  SpeakingQuestion({
    required this.questionId,
    required this.text,
    required this.photo,
  });

  factory SpeakingQuestion.fromJson(Map<String, dynamic> json) {
    return SpeakingQuestion(
      questionId: json['question_id'] ?? "",
      text: json['text'] ?? "",
      photo: json['photo'] ?? "",
    );
  }
}
