class AnswerModel {
  final int id;
  final String answer;

  AnswerModel({required this.id, required this.answer});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'],
      answer: json['answer'],
    );
  }
}
 

 class TopicModel {
  final int id;
  final String title;
  final List<AnswerModel> answers;

  TopicModel({required this.id, required this.title, required this.answers});

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      title: json['title'],
      answers: (json['answers'] as List)
          .map((e) => AnswerModel.fromJson(e))
          .toList(),
    );
  }
}

class SurveySectionModel {
  final int id;
  final String title;
  final List<TopicModel> topics;

  SurveySectionModel({
    required this.id,
    required this.title,
    required this.topics,
  });

  factory SurveySectionModel.fromJson(Map<String, dynamic> json) {
    return SurveySectionModel(
      id: json['id'],
      title: json['title'],
      topics: (json['topics'] as List)
          .map((e) => TopicModel.fromJson(e))
          .toList(),
    );
  }
}
