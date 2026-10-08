class SpeakingQuestionModel {
  final String questionId;
  final String text;
  final String photo;
  final List<String> questions;

  SpeakingQuestionModel({
    required this.questionId,
    required this.text,
    required this.photo,
    required this.questions,
  });

  factory SpeakingQuestionModel.fromJson(Map<String, dynamic> json) {
    return SpeakingQuestionModel(
      questionId: json['question_id'] ?? '',
      text: json['text'] ?? '',
      photo: json['photo'] ?? '',
      questions: List<String>.from(json['questions'] ?? []),
    );
  }
}
