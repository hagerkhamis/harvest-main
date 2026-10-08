// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  List<Grammer> vocab;
  List<Grammer> grammer;
  List<Reading> reading;
  List<Listening> listening;
  List<Writing> writing;
  List<SpeakingItem> speaking;
  int applicationId;
  int remainDuration;
  String message;

  Welcome({
    required this.vocab,
    required this.grammer,
    required this.reading,
    required this.listening,
    required this.writing,
    required this.speaking,
    required this.applicationId,
    required this.remainDuration,
    required this.message,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        vocab:
            List<Grammer>.from(json["Vocab"].map((x) => Grammer.fromJson(x))),
        grammer:
            List<Grammer>.from(json["Grammer"].map((x) => Grammer.fromJson(x))),
        reading:
            List<Reading>.from(json["Reading"].map((x) => Reading.fromJson(x))),
        listening: List<Listening>.from(
            json["Listening"].map((x) => Listening.fromJson(x))),
        writing:
            List<Writing>.from(json["Writing"].map((x) => Writing.fromJson(x))),
        speaking: List<SpeakingItem>.from(
            json["Speaking"].map((x) => SpeakingItem.fromJson(x))),
        applicationId: json["applicationId"],
        remainDuration: json["RemainDuration"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "Vocab": List<dynamic>.from(vocab.map((x) => x.toJson())),
        "Grammer": List<dynamic>.from(grammer.map((x) => x.toJson())),
        "Reading": List<dynamic>.from(reading.map((x) => x.toJson())),
        "Listening": List<dynamic>.from(listening.map((x) => x.toJson())),
        "Writing": List<dynamic>.from(writing.map((x) => x.toJson())),
        "Speaking": List<dynamic>.from(speaking.map((x) => x.toJson())),
        "applicationId": applicationId,
        "RemainDuration": remainDuration,
        "message": message,
      };
}

class Grammer {
  String id;
  Skill skill;
  String questionText;
  List<Answer> answers;

  Grammer({
    required this.id,
    required this.skill,
    required this.questionText,
    required this.answers,
  });

  factory Grammer.fromJson(Map<String, dynamic> json) => Grammer(
        id: json["id"],
        skill: skillValues.map[json["skill"]]!,
        questionText: json["question_text"],
        answers:
            List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "skill": skillValues.reverse[skill],
        "question_text": questionText,
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
      };
}

class Answer {
  int id;
  String answer;

  Answer({
    required this.id,
    required this.answer,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: json["id"],
        answer: json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "answer": answer,
      };
}

enum Skill { GRAMMAR, LISTENING, READING, VOCABULARY }

final skillValues = EnumValues({
  "Grammar": Skill.GRAMMAR,
  "Listening": Skill.LISTENING,
  "Reading": Skill.READING,
  "Vocabulary": Skill.VOCABULARY
});

class Ing {
  String questionId;
  String text;
  String? record;
  List<dynamic> questions;
  String? photo;

  Ing({
    required this.questionId,
    required this.text,
    this.record,
    required this.questions,
    this.photo,
  });

  factory Ing.fromJson(Map<String, dynamic> json) => Ing(
        questionId: json["question_id"],
        text: json["text"],
        record: json["record"],
        questions: List<dynamic>.from(json["questions"].map((x) => x)),
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "text": text,
        "record": record,
        "questions": List<dynamic>.from(questions.map((x) => x)),
        "photo": photo,
      };
}

class Reading {
  String questionId;
  String paragraph;
  List<Grammer> questions;

  Reading({
    required this.questionId,
    required this.paragraph,
    required this.questions,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        questionId: json["question_id"],
        paragraph: json["paragraph"],
        questions: List<Grammer>.from(
            json["questions"].map((x) => Grammer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "paragraph": paragraph,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class Listening {
  String questionId;
  String? text;
  String? record;
  List<Grammer> questions;

  Listening({
    required this.questionId,
    required this.text,
    required this.record,
    required this.questions,
  });

  factory Listening.fromJson(Map<String, dynamic> json) => Listening(
        questionId: json["question_id"],
        text: json["text"],
        record: json["record"],
        questions: List<Grammer>.from(
            json["questions"].map((x) => Grammer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "text": text,
        "record": record,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
      };
}


// class ListeningItem {
//   String questionId;
//   String text;
//   String record;
//   List<ListeningQuestion> questions;

//   ListeningItem({
//     required this.questionId,
//     required this.text,
//     required this.record,
//     required this.questions,
//   });

//   factory ListeningItem.fromJson(Map<String, dynamic> json) => ListeningItem(
//         questionId: json["question_id"],
//         text: json["text"],
//         record: json["record"],
//         questions: List<ListeningQuestion>.from(
//             json["questions"].map((x) => ListeningQuestion.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "question_id": questionId,
//         "text": text,
//         "record": record,
//         "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
//       };
// }

// class ListeningQuestion {
//   String id;
//   String skill;
//   String questionText;
//   List<ListeningAnswer> answers;

//   ListeningQuestion({
//     required this.id,
//     required this.skill,
//     required this.questionText,
//     required this.answers,
//   });

//   factory ListeningQuestion.fromJson(Map<String, dynamic> json) =>
//       ListeningQuestion(
//         id: json["id"],
//         skill: json["skill"],
//         questionText: json["question_text"],
//         answers: List<ListeningAnswer>.from(
//             json["answers"].map((x) => ListeningAnswer.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "skill": skill,
//         "question_text": questionText,
//         "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
//       };
// }

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

  Map<String, dynamic> toJson() => {
        "id": id,
        "answer": answer,
      };
}

class Writing {
  String questionId;
  String text;
  String photo;
  List<dynamic> questions;

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
        questions: List<dynamic>.from(json["questions"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "text": text,
        "photo": photo,
        "questions": List<dynamic>.from(questions.map((x) => x)),
      };
}

class SpeakingItem {
  final String questionId;
  final String text;
  final String photo;
  final List<dynamic> questions;

  SpeakingItem({
    required this.questionId,
    required this.text,
    required this.photo,
    required this.questions,
  });

  factory SpeakingItem.fromJson(Map<String, dynamic> json) {
    return SpeakingItem(
      questionId: json['question_id'] ?? '',
      text: json['text'] ?? '',
      photo: json['photo'] ?? '',
      questions: json['questions'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'text': text,
      'photo': photo,
      'questions': questions,
    };
  }
}
