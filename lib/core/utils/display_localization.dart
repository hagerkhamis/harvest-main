import 'package:easy_localization/easy_localization.dart';

/// Localizes labels and API/backend display values for the current locale.
class DisplayLocalization {
  DisplayLocalization._();

  static const _skillKeys = <String, String>{
    'vocabulary': 'skill_vocabulary',
    'grammar': 'skill_grammar',
    'grammer': 'skill_grammar',
    'reading': 'skill_reading',
    'listening': 'skill_listening',
    'speaking': 'skill_speaking',
    'writing': 'skill_writing',
    'evaluation': 'skill_evaluation',
  };

  static const _trackKeys = <String, String>{
    'smart': 'track_smart',
    'intensive': 'track_intensive',
    'classic': 'track_classic',
    'premium': 'track_premium',
  };

  static const _statusKeys = <String, String>{
    'done': 'status_done',
    'pending': 'exam_status_pending',
    'completed': 'exam_status_completed',
    'pass': 'pass_status_pass',
    'fail': 'pass_status_fail',
    'failed': 'pass_status_fail',
  };

  static const _courseKeys = <String, String>{
    'english diploma': 'course_english_diploma',
  };

  static const _timeFrameKeys = <String, String>{
    '6 months diploma': 'timeframe_6_months',
    '6 month diploma': 'timeframe_6_months',
  };

  static String skill(String name) {
    final key = _skillKeys[name.toLowerCase().trim()];
    return key != null ? key.tr() : name;
  }

  static String level(String? value) {
    if (value == null || value.isEmpty) return '';
    final trimmed = value.trim();
    final match =
        RegExp(r'^level\s*(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (match != null) {
      return 'level_number'.tr(namedArgs: {'number': match.group(1)!});
    }
    final arMatch = RegExp(r'^المستوى\s*(\d+)$').firstMatch(trimmed);
    if (arMatch != null) {
      return 'level_number'.tr(namedArgs: {'number': arMatch.group(1)!});
    }
    final numOnly = RegExp(r'^(\d+)$').firstMatch(trimmed);
    if (numOnly != null) {
      return 'level_number'.tr(namedArgs: {'number': numOnly.group(1)!});
    }
    return trimmed;
  }

  static String examTitle(String? value) {
    if (value == null || value.isEmpty) return '';
    final trimmed = value.trim();

    final modelMatch = RegExp(
      r'^exam\s+level\s+(\d+)\s+model\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (modelMatch != null) {
      return 'exam_list_title'.tr(namedArgs: {
        'level': modelMatch.group(1)!,
        'model': modelMatch.group(2)!,
      });
    }

    final levelMatch = RegExp(
      r'^exam\s+level\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (levelMatch != null) {
      return 'exam_list_title_level'.tr(namedArgs: {'level': levelMatch.group(1)!});
    }

    return trimmed
        .replaceAllMapped(
          RegExp(r'\blevel\s+(\d+)\b', caseSensitive: false),
          (m) => 'level_number'.tr(namedArgs: {'number': m.group(1)!}),
        )
        .replaceAll(RegExp(r'\bexam\b', caseSensitive: false), 'exam_word'.tr())
        .replaceAll(RegExp(r'\bmodel\b', caseSensitive: false), 'exam_model_word'.tr());
  }

  static String date(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateTime.parse(value);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return value;
    }
  }

  static String passStatus(String? value) => _lookup(_statusKeys, value);

  static String track(String? value) => _lookup(_trackKeys, value);

  static String discipline(String? value) => track(value);

  static String status(String? value) => _lookup(_statusKeys, value);

  static String course(String? value) => _lookup(_courseKeys, value);

  static String timeFrame(String? value) => _lookup(_timeFrameKeys, value);

  static String time(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .replaceAll(RegExp(r'\bAM\b', caseSensitive: false), 'time_am'.tr())
        .replaceAll(RegExp(r'\bPM\b', caseSensitive: false), 'time_pm'.tr())
        .replaceAll(' : ', ' — ');
  }

  static String days(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .split('/')
        .map((part) => _translateDay(part.trim()))
        .where((part) => part.isNotEmpty)
        .join(' / ');
  }

  static String branch(String? value) {
    if (value == null || value.isEmpty) return '';
    final key = _branchAliases[_normalize(value)];
    return key != null ? key.tr() : value.trim();
  }

  static String room(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.trim();
  }

  static String groupExamStatus({
    String? code,
    String? label,
  }) {
    if (code != null && code.trim().isNotEmpty) {
      final codeKey = _groupExamCodeKeys[code.toLowerCase().trim()];
      if (codeKey != null) return codeKey.tr();
    }

    final localized = _lookup(_groupExamLabelKeys, label);
    if (localized.isNotEmpty) return localized;
    return label?.trim() ?? '';
  }

  static String _translateDay(String day) {
    if (day.isEmpty) return '';
    final key = _dayAliases[_normalize(day)];
    return key != null ? key.tr() : day;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static const _dayAliases = <String, String>{
    'sunday': 'day_sunday',
    'الأحد': 'day_sunday',
    'monday': 'day_monday',
    'الاثنين': 'day_monday',
    'tuesday': 'day_tuesday',
    'الثلاثاء': 'day_tuesday',
    'wednesday': 'day_wednesday',
    'الأربعاء': 'day_wednesday',
    'thursday': 'day_thursday',
    'الخميس': 'day_thursday',
    'friday': 'day_friday',
    'الجمعة': 'day_friday',
    'saturday': 'day_saturday',
    'السبت': 'day_saturday',
  };

  static const _branchAliases = <String, String>{
    'فرع مدينة نصر': 'branch_nasr_city',
    'nasr city branch': 'branch_nasr_city',
    'nasr city': 'branch_nasr_city',
    'فرع الدقي': 'branch_dokki',
    'dokki branch': 'branch_dokki',
    'dokki': 'branch_dokki',
    'فرع الهرم': 'branch_pyramids',
    'pyramids branch': 'branch_pyramids',
    'pyramids': 'branch_pyramids',
    'فرع شبرا': 'branch_shobra',
    'shobra branch': 'branch_shobra',
    'shobra': 'branch_shobra',
    'فرع المعادي': 'branch_maadi',
    'maadi branch': 'branch_maadi',
    'maadi': 'branch_maadi',
    'فرع الشيخ زايد': 'branch_sheikh_zayed',
    'sheikh zayed branch': 'branch_sheikh_zayed',
    'sheikh zayed': 'branch_sheikh_zayed',
    'فرع التجمع الخامس': 'branch_fifth_settlement',
    'fifth settlement branch': 'branch_fifth_settlement',
    'fifth settlement': 'branch_fifth_settlement',
    'فرع خدمة العملاء': 'branch_customer_service',
    'customer service branch': 'branch_customer_service',
    'customer service': 'branch_customer_service',
    'الفرع الاداري': 'branch_admin',
    'الفرع الإداري': 'branch_admin',
    'admin branch': 'branch_admin',
    'administrative branch': 'branch_admin',
    'فرع الاوت دور': 'branch_out_door',
    'فرع الأوت دور': 'branch_out_door',
    'out door branch': 'branch_out_door',
    'outdoor branch': 'branch_out_door',
  };

  static const _groupExamCodeKeys = <String, String>{
    'show_result': 'group_exam_show_result',
    'start_exam': 'group_exam_start',
    'complete_exam': 'group_exam_complete',
    'pending': 'exam_status_pending',
    'completed': 'exam_status_completed',
    'upcoming': 'exam_status_upcoming',
  };

  static const _groupExamLabelKeys = <String, String>{
    'show result': 'group_exam_show_result',
    'عرض النتيجة': 'group_exam_show_result',
    'start exam': 'group_exam_start',
    'بدء الامتحان': 'group_exam_start',
    'ابدأ الامتحان': 'group_exam_start',
    'complete exam': 'group_exam_complete',
    'إكمال الامتحان': 'group_exam_complete',
    'اكمال الامتحان': 'group_exam_complete',
    'استكمال الامتحان': 'group_exam_complete',
    'exam': 'group_exam',
    'الامتحان': 'group_exam',
    'pending': 'exam_status_pending',
    'معلق': 'exam_status_pending',
    'معلّق': 'exam_status_pending',
    'completed': 'exam_status_completed',
    'مكتمل': 'exam_status_completed',
    'upcoming': 'exam_status_upcoming',
    'قادم': 'exam_status_upcoming',
  };

  static String dateTime(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateTime.parse(value).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} $h:$m';
    } catch (_) {
      return value;
    }
  }

  static String _lookup(Map<String, String> map, String? value) {
    if (value == null || value.isEmpty) return '';
    final key = map[value.toLowerCase().trim()];
    return key != null ? key.tr() : value;
  }
}
