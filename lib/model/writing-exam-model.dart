// To parse this JSON data, do
//
//     final writingResponse = writingResponseFromJson(jsonString);

import 'dart:convert';

WritingResponse writingResponseFromJson(String str) => WritingResponse.fromJson(json.decode(str));

String writingResponseToJson(WritingResponse data) => json.encode(data.toJson());

class WritingResponse {
    List<Writing> writing;
    int applicationId;
    String remainDuration;
    String status;

    WritingResponse({
        required this.writing,
        required this.applicationId,
        required this.remainDuration,
        required this.status,
    });

    factory WritingResponse.fromJson(Map<String, dynamic> json) => WritingResponse(
        writing: List<Writing>.from(json["Writing"].map((x) => Writing.fromJson(x))),
        applicationId: json["applicationId"],
        remainDuration: json["RemainDuration"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "Writing": List<dynamic>.from(writing.map((x) => x.toJson())),
        "applicationId": applicationId,
        "RemainDuration": remainDuration,
        "status": status,
    };
}

class Writing {
    String questionId;
    String text;
    String photo;
    List<String> questions;

    Writing({
        required this.questionId,
        required this.text,
        required this.photo,
        required this.questions,
    });

    factory Writing.fromJson(Map<String, dynamic> json) => Writing(
        questionId: json["question_id"],
        text: json["text"],
        photo: json["photo"],
        questions: List<String>.from(json["questions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "text": text,
        "photo": photo,
        "questions": List<dynamic>.from(questions.map((x) => x)),
    };
}
