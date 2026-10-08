import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class InstructorRecommendationsCard extends StatelessWidget {
  final List<String> recommendations;
  final bool showWhenEmpty;

  const InstructorRecommendationsCard({
    super.key,
    required this.recommendations,
    this.showWhenEmpty = true,
  });

  List<String> get _items =>
      recommendations.where((s) => s.trim().isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty && !showWhenEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.rate_review_outlined, color: primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  'instructor_recommendations_title'.tr(),
                  style: getBoldStyle(color: primaryColor, fontSize: FontSize.s16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: items.isEmpty
                ? Text(
                    'instructor_recommendations_empty'.tr(),
                    style: getRegularStyle(
                      color: Colors.grey.shade600,
                      fontSize: FontSize.s14,
                    ),
                  )
                : items.length == 1
                ? Text(
                    items.first,
                    style: getRegularStyle(
                      color: blackColors,
                      fontSize: FontSize.s14,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: getRegularStyle(
                                      color: blackColors,
                                      fontSize: FontSize.s14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Parses instructor recommendations from API JSON (multiple key variants).
List<String> parseInstructorRecommendations(Map<String, dynamic> json) {
  final dynamic raw = json['instructor_recommendations'] ??
      json['InstructorRecommendations'] ??
      json['Instructor_Recommendations'] ??
      json['instructorRecommendations'] ??
      json['instructor_recommendation'] ??
      json['Instructor_Recommendation'] ??
      json['recommendations'] ??
      json['Recommendations'] ??
      json['instructor_notes'] ??
      json['InstructorNotes'] ??
      json['instructor_note'];

  return _extractRecommendationTexts(raw);
}

List<String> _extractRecommendationTexts(dynamic raw) {
  if (raw == null) return [];

  if (raw is List) {
    final items = <String>[];
    for (final item in raw) {
      items.addAll(_extractRecommendationTexts(item));
    }
    return items.where((s) => s.trim().isNotEmpty).toList();
  }

  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    // Nested payload: { title, instructor_name, recommendations, has_recommendations }
    final nested = map['recommendations'] ??
        map['Recommendations'] ??
        map['recommendation'] ??
        map['notes'] ??
        map['note'] ??
        map['text'] ??
        map['content'] ??
        map['message'];
    if (nested != null) {
      return _extractRecommendationTexts(nested);
    }

    for (final key in const ['title', 'body', 'value', 'desc', 'description']) {
      final value = map[key]?.toString().trim() ?? '';
      if (value.isNotEmpty &&
          !value.contains('has_recommendations') &&
          value != 'توصيات المحاضر' &&
          value.toLowerCase() != 'instructor recommendations') {
        return [value];
      }
    }
    return [];
  }

  final text = raw.toString().trim();
  if (text.isEmpty) return [];
  // Avoid showing raw map dumps like "{title: ..., has_recommendations: false}".
  if (text.startsWith('{') && text.contains('has_recommendations')) {
    return [];
  }
  return [text];
}
