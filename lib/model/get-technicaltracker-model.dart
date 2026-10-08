// models/pt_skills.dart

class PtSkillsTex {
    String name;
    String label;
    String track;
    String email;
    String level;
    String vocab;
    String grammer;
    String reading;
    String listening;
    String speaking;
    String writing;
    String? evaluation;
    double total;
    String vocabgrade;
    String grammergrade;
    String readinggrade;
    String listeninggrade;
    String writinggrade;
    String speakinggrade;
    String? evaluationgrade;
    String allskillsgrade;
    String? allgrade;
    String? instructor;
    String? number;
    String? status;
    DateTime? createdAt;

    PtSkillsTex({
        required this.name,
        required this.label,
        required this.track,
        required this.email,
        required this.level,
        required this.vocab,
        required this.grammer,
        required this.reading,
        required this.listening,
        required this.speaking,
        required this.writing,
        this.evaluation,
        required this.total,
        required this.vocabgrade,
        required this.grammergrade,
        required this.readinggrade,
        required this.listeninggrade,
        required this.writinggrade,
        required this.speakinggrade,
        this.evaluationgrade,
        required this.allskillsgrade,
        this.allgrade,
        this.instructor,
        this.number,
        this.status,
        this.createdAt,
    });

    factory PtSkillsTex.fromJson(Map<String, dynamic> json) => PtSkillsTex(
        name: json["name"],
        label: json["label"],
        track: json["Track"],
        email: json["email"],
        level: json["Level"],
        vocab: json["vocab"],
        grammer: json["grammer"],
        reading: json["reading"],
        listening: json["listening"],
        speaking: json["speaking"],
        writing: json["writing"],
        evaluation: json["evaluation"],
        total: json["total"]?.toDouble(),
        vocabgrade: json["vocabgrade"],
        grammergrade: json["grammergrade"],
        readinggrade: json["readinggrade"],
        listeninggrade: json["listeninggrade"],
        writinggrade: json["writinggrade"],
        speakinggrade: json["speakinggrade"],
        evaluationgrade: json["evaluationgrade"],
        allskillsgrade: json["allskillsgrade"],
        allgrade: json["allgrade"],
        instructor: json["Instructor"],
        number: json["Number"],
        status: json["Status"],
        createdAt: json["CreatedAt"] == null ? null : DateTime.parse(json["CreatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "label": label,
        "Track": track,
        "email": email,
        "Level": level,
        "vocab": vocab,
        "grammer": grammer,
        "reading": reading,
        "listening": listening,
        "speaking": speaking,
        "writing": writing,
        "evaluation": evaluation,
        "total": total,
        "vocabgrade": vocabgrade,
        "grammergrade": grammergrade,
        "readinggrade": readinggrade,
        "listeninggrade": listeninggrade,
        "writinggrade": writinggrade,
        "speakinggrade": speakinggrade,
        "evaluationgrade": evaluationgrade,
        "allskillsgrade": allskillsgrade,
        "allgrade": allgrade,
        "Instructor": instructor,
        "Number": number,
        "Status": status,
        "CreatedAt": createdAt?.toIso8601String(),
    };
}

// class PtSkillsTex {
//   final String name;
//   final String label;
//   final String email;
//   final String track;
//   final double vocab;
//   final double grammar;
//   final double reading;
//   final double listening;
//   final double speaking;
//   final double writing;
//   final double total;

//   PtSkillsTex({
//     required this.name,
//     required this.label,
//     required this.email,
//     required this.track,
//     required this.vocab,
//     required this.grammar,
//     required this.reading,
//     required this.listening,
//     required this.speaking,
//     required this.writing,
//     required this.total,
//   });

//   factory PtSkillsTex.fromJson(Map<String, dynamic> json) {
//     return PtSkillsTex(
//       name: json['name'],
//       label: json['label'],
//       email: json['email'],
//       track: json['Track'],
//       vocab: double.parse(json['vocab'] ?? '0'),
//       grammar: double.parse(json['grammer'] ?? '0'),
//       reading: double.parse(json['reading'] ?? '0'),
//       listening: double.parse(json['listening'] ?? '0'),
//       speaking: double.parse(json['speaking'] ?? '0'),
//       writing: double.parse(json['writing'] ?? '0'),
//       total: double.parse(json['total'].toString()),
//     );
//   }
// }

// models/exam_skills.dart

class ExamSkill {
    String name;
    String label;
    String track;
    String email;
    String level;
    String vocab;
    String grammer;
    String reading;
    String listening;
    String speaking;
    String writing;
    String? evaluation;
    double total;
    String vocabgrade;
    String grammergrade;
    String readinggrade;
    String listeninggrade;
    String writinggrade;
    String speakinggrade;
    String? evaluationgrade;
    String allskillsgrade;
    String? allgrade;
    String? instructor;
    String? number;
    String? status;
    DateTime? createdAt;

    ExamSkill({
        required this.name,
        required this.label,
        required this.track,
        required this.email,
        required this.level,
        required this.vocab,
        required this.grammer,
        required this.reading,
        required this.listening,
        required this.speaking,
        required this.writing,
        this.evaluation,
        required this.total,
        required this.vocabgrade,
        required this.grammergrade,
        required this.readinggrade,
        required this.listeninggrade,
        required this.writinggrade,
        required this.speakinggrade,
        this.evaluationgrade,
        required this.allskillsgrade,
        this.allgrade,
        this.instructor,
        this.number,
        this.status,
        this.createdAt,
    });

    factory ExamSkill.fromJson(Map<String, dynamic> json) => ExamSkill(
        name: json["name"],
        label: json["label"],
        track: json["Track"],
        email: json["email"],
        level: json["Level"],
        vocab: json["vocab"],
        grammer: json["grammer"],
        reading: json["reading"],
        listening: json["listening"],
        speaking: json["speaking"],
        writing: json["writing"],
        evaluation: json["evaluation"],
        total: json["total"]?.toDouble(),
        vocabgrade: json["vocabgrade"],
        grammergrade: json["grammergrade"],
        readinggrade: json["readinggrade"],
        listeninggrade: json["listeninggrade"],
        writinggrade: json["writinggrade"],
        speakinggrade: json["speakinggrade"],
        evaluationgrade: json["evaluationgrade"],
        allskillsgrade: json["allskillsgrade"],
        allgrade: json["allgrade"],
        instructor: json["Instructor"],
        number: json["Number"],
        status: json["Status"],
        createdAt: json["CreatedAt"] == null ? null : DateTime.parse(json["CreatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "label": label,
        "Track": track,
        "email": email,
        "Level": level,
        "vocab": vocab,
        "grammer": grammer,
        "reading": reading,
        "listening": listening,
        "speaking": speaking,
        "writing": writing,
        "evaluation": evaluation,
        "total": total,
        "vocabgrade": vocabgrade,
        "grammergrade": grammergrade,
        "readinggrade": readinggrade,
        "listeninggrade": listeninggrade,
        "writinggrade": writinggrade,
        "speakinggrade": speakinggrade,
        "evaluationgrade": evaluationgrade,
        "allskillsgrade": allskillsgrade,
        "allgrade": allgrade,
        "Instructor": instructor,
        "Number": number,
        "Status": status,
        "CreatedAt": createdAt?.toIso8601String(),
    };
}

// class ExamSkill {
//   final String label;
//   final String level;
//   final double vocab;
//   final double grammar;
//   final double reading;
//   final double listening;
//   final double speaking;
//   final double writing;
//   final double total;

//   ExamSkill({
//     required this.label,
//     required this.level,
//     required this.vocab,
//     required this.grammar,
//     required this.reading,
//     required this.listening,
//     required this.speaking,
//     required this.writing,
//     required this.total,
//   });

//   factory ExamSkill.fromJson(Map<String, dynamic> json) {
//     return ExamSkill(
//       label: json['label'],
//       level: json['Level'],
//       vocab: double.parse(json['vocab'] ?? '0'),
//       grammar: double.parse(json['grammer'] ?? '0'),
//       reading: double.parse(json['reading'] ?? '0'),
//       listening: double.parse(json['listening'] ?? '0'),
//       speaking: double.parse(json['speaking'] ?? '0'),
//       writing: double.parse(json['writing'] ?? '0'),
//       total: double.parse(json['total'].toString()),
//     );
//   }
// }




