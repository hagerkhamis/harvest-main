import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/display_localization.dart';
import 'package:hatvest/core/utils/exam_score_helper.dart';
import 'package:hatvest/shared/widgets/instructor_recommendations_card.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class AdultRuselt extends StatefulWidget {
  final int applicationId;

  const AdultRuselt({super.key, required this.applicationId});
  @override
  State<AdultRuselt> createState() => _AdultRuseltState();
}

class _AdultRuseltState extends State<AdultRuselt> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchAdultResult(widget.applicationId),
      child: Scaffold(
        appBar: AppBar(
          title: Text("result".tr(),
              style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20)),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (_, viewModel, __) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final pt = viewModel.adultResult;

            if (pt == null) {
              return Center(child: Text("no_data_available".tr()));
            }

            final double progress =
                ExamScoreHelper.ratio(pt.total, pt.allSkillsGrade);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircularPercentIndicator(
                    radius: 110.0,
                    lineWidth: 40.0,
                    animation: true,
                    percent: progress,
                    center: Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    progressColor: primaryColor,
                    backgroundColor: Colors.grey[300]!,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DisplayLocalization.track(pt.track),
                    style: getBoldStyle(
                      color: blackColors,
                      fontSize: FontSize.s18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSkillBreakdown([
                    {
                      "name": "Vocabulary",
                      "value": pt.vocab,
                      "grade": pt.vocabGrade
                    },
                    {
                      "name": "Grammar",
                      "value": pt.grammer,
                      "grade": pt.grammerGrade
                    },
                    {
                      "name": "Reading",
                      "value": pt.reading,
                      "grade": pt.readingGrade
                    },
                    {
                      "name": "Listening",
                      "value": pt.listening,
                      "grade": pt.listeningGrade
                    },
                    {
                      "name": "Speaking",
                      "value": pt.speaking,
                      "grade": pt.speakingGrade
                    },
                    {
                      "name": "Writing",
                      "value": pt.writing,
                      "grade": pt.writingGrade
                    },
                  ]),
                  const SizedBox(height: 16),
                  InstructorRecommendationsCard(
                    recommendations: pt.instructorRecommendations,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkillBreakdown(List<Map<String, dynamic>> skills) {
    return Column(
      children: skills.map((skill) {
        final String name = DisplayLocalization.skill(skill["name"] ?? "");
        final double value = ExamScoreHelper.parse(skill["value"]);
        final double grade = ExamScoreHelper.parse(skill["grade"]);
        final double progress = ExamScoreHelper.ratio(value, grade);
        
        // تحديد اللون حسب النسبة - تدرج ألوان جذاب
        Color barColor;
        if (progress >= 0.95) {
          barColor = Color(0xFF1B5E20); // أخضر غامق للممتاز
        } else if (progress >= 0.85) {
          barColor = Color(0xFF4CAF50); // أخضر فاتح للجيد جداً
        } else if (progress >= 0.70) {
          barColor = Color(0xFF8BC34A); // ليموني للجيد
        } else if (progress >= 0.50) {
          barColor = Color(0xFFFF9800); // برتقالي للمتوسط
        } else {
          barColor = Color(0xFFE91E63); // وردي للضعيف
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  name,
                  style: getRegularStyle(color: blackColors),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 15,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ExamScoreHelper.format(value, grade),
                style: getRegularStyle(color: blackColors),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
