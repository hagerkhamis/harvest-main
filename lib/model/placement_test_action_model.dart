import 'package:hatvest/core/utils/exam_score_helper.dart';

class PlacementTestActionResponse {
  final bool status;
  final String message;
  final String action;
  final String? leadType;
  final int? applicationId;
  final String? ptLevel;
  final PtApplicationRef? adultPtApplication;
  final PtApplicationRef? kidsPtApplication;
  final PlacementTestResultPreview? result;

  PlacementTestActionResponse({
    required this.status,
    required this.message,
    required this.action,
    this.leadType,
    this.applicationId,
    this.ptLevel,
    this.adultPtApplication,
    this.kidsPtApplication,
    this.result,
  });

  factory PlacementTestActionResponse.fromJson(Map<String, dynamic> json) {
    return PlacementTestActionResponse(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      leadType: json['lead'] is Map
          ? json['lead']['type']?.toString()
          : null,
      applicationId: _parseInt(json['application_id']),
      ptLevel: json['pt_level']?.toString(),
      adultPtApplication: json['adult_pt_application'] is Map
          ? PtApplicationRef.fromJson(
              Map<String, dynamic>.from(json['adult_pt_application'] as Map),
            )
          : null,
      kidsPtApplication: json['kids_pt_application'] is Map
          ? PtApplicationRef.fromJson(
              Map<String, dynamic>.from(json['kids_pt_application'] as Map),
            )
          : null,
      result: json['result'] is Map
          ? PlacementTestResultPreview.fromJson(
              Map<String, dynamic>.from(json['result'] as Map),
            )
          : null,
    );
  }

  static bool _parseStatus(dynamic status) {
    if (status == null) return true;
    if (status == true || status == 1) return true;
    final text = status.toString().toLowerCase().trim();
    return text == 'true' ||
        text == '1' ||
        text == 'success' ||
        text == 'ok' ||
        text == 'done';
  }

  int? get resolvedApplicationId {
    if (applicationId != null && applicationId! > 0) return applicationId;
    if (adultPtApplication?.id != null && adultPtApplication!.id! > 0) {
      return adultPtApplication!.id;
    }
    if (kidsPtApplication?.id != null && kidsPtApplication!.id! > 0) {
      return kidsPtApplication!.id;
    }
    return null;
  }

  String get levelLabel {
    final fromResult = result?.level ?? '';
    if (fromResult.trim().isNotEmpty) return fromResult.trim();
    final fromPt = ptLevel ?? '';
    if (fromPt.trim().isNotEmpty) return fromPt.trim();
    return '';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class PtApplicationRef {
  final int? id;
  final String finish;

  PtApplicationRef({this.id, this.finish = '0'});

  factory PtApplicationRef.fromJson(Map<String, dynamic> json) {
    return PtApplicationRef(
      id: PlacementTestActionResponse._parseInt(json['id']),
      finish: json['finish']?.toString() ?? '0',
    );
  }

  bool get isFinished => (int.tryParse(finish) ?? 0) != 0;
}

class PlacementTestResultPreview {
  final String name;
  final String email;
  final String track;
  final String instructor;
  final String number;
  final String level;
  final String status;
  final String? total;
  final String? allSkillsGrade;

  PlacementTestResultPreview({
    this.name = '',
    this.email = '',
    this.track = '',
    this.instructor = '',
    this.number = '',
    this.level = '',
    this.status = '',
    this.total,
    this.allSkillsGrade,
  });

  factory PlacementTestResultPreview.fromJson(Map<String, dynamic> json) {
    return PlacementTestResultPreview(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      track: json['track']?.toString() ?? '',
      instructor: json['Instructor']?.toString() ??
          json['instructor']?.toString() ??
          '',
      number: json['Number']?.toString() ?? json['number']?.toString() ?? '',
      level: json['Level']?.toString() ?? json['level']?.toString() ?? '',
      status: json['Status']?.toString() ?? json['status']?.toString() ?? '',
      total: json['total']?.toString(),
      allSkillsGrade: json['allskillsgrade']?.toString() ??
          json['allSkillsGrade']?.toString(),
    );
  }

  double get progress {
    final resultValue = ExamScoreHelper.parse(total);
    final grade = ExamScoreHelper.parse(allSkillsGrade);
    return ExamScoreHelper.ratio(resultValue, grade);
  }
}
