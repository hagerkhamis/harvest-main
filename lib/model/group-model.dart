class GroupModel {
  final int id;
  final int studentId;
  final String track;
  final String code;
  final String title;
  final String days;
  final String room;
  final String branch;
  final String instructor;
  final String time;
  final String levels;
  final String start;
  final String end;
  final int confirmation;
  final String book;
  final String bookStatus;
  final String bookStatusCode;
  final String attendance;
  final String examStatus;
  final String examStatusCode;
  final String step;
  final String studentExamId;
  final String quizStatus;
  final String quizStatusCode;
  final String quizStep;
  final String studentQuizId;

  GroupModel({
    required this.id,
    required this.studentId,
    required this.track,
    required this.code,
    required this.title,
    required this.days,
    required this.room,
    required this.branch,
    required this.instructor,
    required this.time,
    required this.levels,
    required this.start,
    required this.end,
    required this.confirmation,
    required this.book,
    required this.bookStatus,
    required this.bookStatusCode,
    required this.attendance,
    required this.examStatus,
    required this.examStatusCode,
    required this.step,
    required this.studentExamId,
    required this.quizStatus,
    required this.quizStatusCode,
    required this.quizStep,
    required this.studentQuizId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      studentId: json['student_id'],
      track: json['Track'],
      code: json['code'],
      title: json['title'],
      days: json['Days'],
      room: json['Room'],
      branch: json['Branch'],
      instructor: json['Instructor'],
      time: json['Time'],
      levels: json['Levels'],
      start: json['Start'],
      end: json['End'],
      confirmation: json['confirmation'],
      book: json['book'],
      bookStatus: json['book_status'],
      bookStatusCode: json['book_status_code'],
      attendance: json['attendance'],
      examStatus: json['exam_status'],
      examStatusCode: json['exam_status_code'],
      step: json['step'],
      studentExamId: json['student_exam_id'],
      quizStatus: json['quiz_status'],
      quizStatusCode: json['quiz_status_code'],
      quizStep: json['quiz_step'],
      studentQuizId: json['student_quiz_id'],
    );
  }
}
