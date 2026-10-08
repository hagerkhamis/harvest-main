class ExamItem {
  final int id;
  final String title;
  final String course;
  final String level;
  final String date;
  final int score;
  final String status;
  final String downloadUrl;

  ExamItem({
    required this.id,
    required this.title,
    required this.course,
    required this.level,
    required this.date,
    required this.score,
    required this.status,
    required this.downloadUrl,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      course: json['course']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString() ?? '',
    );
  }
}
