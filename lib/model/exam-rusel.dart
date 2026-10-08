import 'package:hatvest/core/utils/exam_score_helper.dart';
import 'package:hatvest/shared/widgets/instructor_recommendations_card.dart'
    show parseInstructorRecommendations;

class ExamRuseltModel {
  final String name;
  final String email;
  final String track;
  final String instructor;
  final String number;
  final String level;
  final String status;
  final String createdAt;
  final String label;
  final String group;
  final String timeFrame;
  final String discipline;
  final String course;
  final String passStatus;

  final double vocab;
  final double grammer;
  final double reading;
  final double listening;
  final double speaking;
  final double writing;
  final double evaluation;

  final double vocabGrade;
  final double grammerGrade;
  final double readingGrade;
  final double listeningGrade;
  final double writingGrade;
  final double speakingGrade;
  final double evaluationGrade;
  final double allSkillsGrade;
  final double total;
  final List<String> instructorRecommendations;

  ExamRuseltModel({
    required this.name,
    required this.email,
    required this.track,
    required this.instructor,
    required this.number,
    required this.level,
    required this.status,
    required this.createdAt,
    required this.label,
    required this.group,
    required this.timeFrame,
    required this.discipline,
    required this.course,
    required this.passStatus,
    required this.vocab,
    required this.grammer,
    required this.reading,
    required this.listening,
    required this.speaking,
    required this.writing,
    required this.evaluation,
    required this.vocabGrade,
    required this.grammerGrade,
    required this.readingGrade,
    required this.listeningGrade,
    required this.writingGrade,
    required this.speakingGrade,
    required this.evaluationGrade,
    required this.allSkillsGrade,
    required this.total,
    this.instructorRecommendations = const [],
  });

  factory ExamRuseltModel.fromJson(Map<String, dynamic> json) {
    final recommendations = parseInstructorRecommendations(json);

    final vocabGrade = ExamScoreHelper.parse(json['vocabgrade']);
    final grammerGrade = ExamScoreHelper.parse(json['grammergrade']);
    final readingGrade = ExamScoreHelper.parse(json['readinggrade']);
    final listeningGrade = ExamScoreHelper.parse(json['listeninggrade']);
    final writingGrade = ExamScoreHelper.parse(json['writinggrade']);
    final speakingGrade = ExamScoreHelper.parse(json['speakinggrade']);
    final evaluationGrade = ExamScoreHelper.parse(json['evaluationgrade']);

    final vocab = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['vocab']),
      vocabGrade,
    );
    final grammer = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['grammer']),
      grammerGrade,
    );
    final reading = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['reading']),
      readingGrade,
    );
    final listening = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['listening']),
      listeningGrade,
    );
    final speaking = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['speaking']),
      speakingGrade,
    );
    final writing = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['writing']),
      writingGrade,
    );
    final evaluation = ExamScoreHelper.capped(
      ExamScoreHelper.parse(json['evaluation']),
      evaluationGrade,
    );

    final skillScores = [
      vocab,
      grammer,
      reading,
      listening,
      speaking,
      writing,
      evaluation,
    ];
    final skillMaxima = [
      vocabGrade,
      grammerGrade,
      readingGrade,
      listeningGrade,
      speakingGrade,
      writingGrade,
      evaluationGrade,
    ];

    final apiTotal = ExamScoreHelper.parse(json['total']);
    final apiMax = ExamScoreHelper.parse(json['allskillsgrade']);
    final max = ExamScoreHelper.resolveMax(
      apiMax: apiMax,
      total: apiTotal > 0
          ? apiTotal
          : skillScores.fold<double>(0, (a, b) => a + b),
      skillMaxima: skillMaxima,
    );
    final total = ExamScoreHelper.resolveTotal(
      apiTotal: apiTotal,
      max: max,
      skillScores: skillScores,
    );

    return ExamRuseltModel(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      track: json['discipline']?.toString() ?? '',
      instructor: json['Instructor']?.toString() ?? '',
      number: json['Number']?.toString() ?? '',
      level: json['Level']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',
      createdAt: json['CreatedAt']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      group: json['Group']?.toString() ?? '',
      timeFrame: json['TimeFrame']?.toString() ?? '',
      discipline: json['discipline']?.toString() ?? '',
      course: json['Course']?.toString() ?? '',
      passStatus: json['PassStatus']?.toString() ?? '',
      vocab: vocab,
      grammer: grammer,
      reading: reading,
      listening: listening,
      speaking: speaking,
      writing: writing,
      evaluation: evaluation,
      vocabGrade: vocabGrade,
      grammerGrade: grammerGrade,
      readingGrade: readingGrade,
      listeningGrade: listeningGrade,
      writingGrade: writingGrade,
      speakingGrade: speakingGrade,
      evaluationGrade: evaluationGrade,
      allSkillsGrade: max,
      total: total,
      instructorRecommendations: recommendations,
    );
  }
}
