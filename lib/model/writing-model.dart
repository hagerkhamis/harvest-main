import 'dart:convert';

WritingResponse writingResponseFromJson(String str) =>
    WritingResponse.fromJson(json.decode(str));

class WritingResponse {
  List<WritingItem> writing;

  WritingResponse({
    required this.writing,
  });

  factory WritingResponse.fromJson(Map<String, dynamic> json) =>
      WritingResponse(
        writing: json["Writing"] != null
            ? List<WritingItem>.from(
                json["Writing"].map((x) => WritingItem.fromJson(x)))
            : [],
      );
}

class WritingItem {
  String questionId;
  String text;
  String photo;
  List<String> questions;

  WritingItem({
    required this.questionId,
    required this.text,
    required this.photo,
    required this.questions,
  });

  factory WritingItem.fromJson(Map<String, dynamic> json) => WritingItem(
        questionId: json["question_id"],
        text: json["text"],
        photo: json["photo"],
        questions: List<String>.from(json["questions"]),
      );
}
