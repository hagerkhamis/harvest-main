// To parse this JSON data, do
//
//     final examAnswer = examAnswerFromJson(jsonString);

import 'dart:convert';

ExamAnswer examAnswerFromJson(String str) => ExamAnswer.fromJson(json.decode(str));

String examAnswerToJson(ExamAnswer data) => json.encode(data.toJson());

class ExamAnswer {
    List<Grammar> vocabulary;
    List<Grammar> grammar;
    List<Listening> listening;
    List<Reading> reading;
    List<Writing> writing;
    String message;

    ExamAnswer({
        required this.vocabulary,
        required this.grammar,
        required this.listening,
        required this.reading,
        required this.writing,
        required this.message,
    });

    factory ExamAnswer.fromJson(Map<String, dynamic> json) => ExamAnswer(
        vocabulary: List<Grammar>.from(json["Vocabulary"].map((x) => Grammar.fromJson(x))),
        grammar: List<Grammar>.from(json["Grammar"].map((x) => Grammar.fromJson(x))),
        listening: List<Listening>.from(json["Listening"].map((x) => Listening.fromJson(x))),
        reading: List<Reading>.from(json["Reading"].map((x) => Reading.fromJson(x))),
        writing: List<Writing>.from(json["Writing"].map((x) => Writing.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "Vocabulary": List<dynamic>.from(vocabulary.map((x) => x.toJson())),
        "Grammar": List<dynamic>.from(grammar.map((x) => x.toJson())),
        "Listening": List<dynamic>.from(listening.map((x) => x.toJson())),
        "Reading": List<dynamic>.from(reading.map((x) => x.toJson())),
        "Writing": List<dynamic>.from(writing.map((x) => x.toJson())),
        "message": message,
    };
}

class Grammar {
    String id;
    Skill skill;
    String questionText;
    List<GrammarAnswer> answers;

    Grammar({
        required this.id,
        required this.skill,
        required this.questionText,
        required this.answers,
    });

    factory Grammar.fromJson(Map<String, dynamic> json) => Grammar(
        id: json["id"],
        skill: skillValues.map[json["skill"]]!,
        questionText: json["question_text"],
        answers: List<GrammarAnswer>.from(json["answers"].map((x) => GrammarAnswer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "skill": skillValues.reverse[skill],
        "question_text": questionText,
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
    };
}

class GrammarAnswer {
    int id;
    String answer;
    AnswerBg answerBg;

    GrammarAnswer({
        required this.id,
        required this.answer,
        required this.answerBg,
    });

    factory GrammarAnswer.fromJson(Map<String, dynamic> json) => GrammarAnswer(
        id: json["id"],
        answer: json["answer"],
        answerBg: answerBgValues.map[json["answer_bg"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "answer": answer,
        "answer_bg": answerBgValues.reverse[answerBg],
    };
}

enum AnswerBg {
    GREEN,
    NON,
    RED
}

final answerBgValues = EnumValues({
    "green": AnswerBg.GREEN,
    "non": AnswerBg.NON,
    "Red": AnswerBg.RED
});

enum Skill {
    GRAMMAR,
    LISTENING,
    READING,
    VOCABULARY
}

final skillValues = EnumValues({
    "Grammar": Skill.GRAMMAR,
    "Listening": Skill.LISTENING,
    "Reading": Skill.READING,
    "Vocabulary": Skill.VOCABULARY
});

class Listening {
    String questionId;
    String text;
    String record;
    List<Grammar> questions;

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
        questions: List<Grammar>.from(json["questions"].map((x) => Grammar.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "text": text,
        "record": record,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
    };
}

class Reading {
    String questionId;
    String paragraph;
    List<Grammar> questions;

    Reading({
        required this.questionId,
        required this.paragraph,
        required this.questions,
    });

    factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        questionId: json["question_id"],
        paragraph: json["paragraph"],
        questions: List<Grammar>.from(json["questions"].map((x) => Grammar.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "paragraph": paragraph,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
    };
}

class Writing {
    String questionId;
    String text;
    String photo;
    List<String> questions;
    List<WritingAnswer> answers;

    Writing({
        required this.questionId,
        required this.text,
        required this.photo,
        required this.questions,
        required this.answers,
    });

    factory Writing.fromJson(Map<String, dynamic> json) => Writing(
        questionId: json["question_id"],
        text: json["text"],
        photo: json["photo"],
        questions: List<String>.from(json["questions"].map((x) => x)),
        answers: List<WritingAnswer>.from(json["answers"].map((x) => WritingAnswer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "text": text,
        "photo": photo,
        "questions": List<dynamic>.from(questions.map((x) => x)),
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
    };
}

class WritingAnswer {
    String? answer;

    WritingAnswer({
        required this.answer,
    });

    factory WritingAnswer.fromJson(Map<String, dynamic> json) => WritingAnswer(
        answer: json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
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
