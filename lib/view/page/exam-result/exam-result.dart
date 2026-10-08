import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/display_localization.dart';
import 'package:hatvest/core/utils/exam_score_helper.dart';
import 'package:hatvest/shared/widgets/instructor_recommendations_card.dart';
import 'package:hatvest/view/page/bottom-nav/bottom-nav.dart';
import 'package:hatvest/view/page/exam_answer_page/exam_answer_page.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/model/exam-rusel.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class ExamRuselt extends StatefulWidget {
  final int applicationId;
  const ExamRuselt({super.key, required this.applicationId});

  @override
  State<ExamRuselt> createState() => _ExamRuseltState();
}

class _ExamRuseltState extends State<ExamRuselt> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchExamResult(widget.applicationId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            "result".tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => BottomNav(index: 1)),
                  (route) => false,
                );
              },
              icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(builder: (_, viewModel, __) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.examResult == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "exam_result_not_available".tr(),
                    style: getBoldStyle(color: blackColors, fontSize: FontSize.s16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "exam_result_try_later".tr(),
                    style: getRegularStyle(color: Colors.grey, fontSize: FontSize.s14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.fetchExamResult(widget.applicationId),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: Text("retry".tr()),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("back".tr()),
                      ),
                    ],
                  )
                ],
              ),
            );
          }

          final pt = viewModel.examResult!;
          return _buildResultPage(context, pt);
        }),
      ),
    );
  }

  Widget _buildResultPage(BuildContext context, ExamRuseltModel pt) {
    final double progress =
        ExamScoreHelper.ratio(pt.total, pt.allSkillsGrade);

    final skills = [
      {"name": DisplayLocalization.skill("Vocabulary"), "value": pt.vocab, "grade": pt.vocabGrade},
      {"name": DisplayLocalization.skill("Grammar"), "value": pt.grammer, "grade": pt.grammerGrade},
      {"name": DisplayLocalization.skill("Reading"), "value": pt.reading, "grade": pt.readingGrade},
      {"name": DisplayLocalization.skill("Listening"), "value": pt.listening, "grade": pt.listeningGrade},
      {"name": DisplayLocalization.skill("Speaking"), "value": pt.speaking, "grade": pt.speakingGrade},
      {"name": DisplayLocalization.skill("Writing"), "value": pt.writing, "grade": pt.writingGrade},
      if (pt.evaluation > 0)
        {"name": DisplayLocalization.skill("Evaluation"), "value": pt.evaluation, "grade": pt.evaluationGrade},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with logo + title
          _buildHeaderCard(pt),
          const SizedBox(height: 16),

          // Student info card
          _buildInfoCard(pt),
          const SizedBox(height: 16),

          // Skills table
          _buildSkillsTable(skills, pt),
          const SizedBox(height: 16),

          // Performance by skill (bar chart)
          _buildSkillsBarChart(skills),
          const SizedBox(height: 16),

          // Circular indicator (below the table)
          _buildChartCard(pt, progress, skills),
          const SizedBox(height: 16),

          // Review button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamAnswerPage(studentExamId: widget.applicationId),
                  ),
                );
              },
              icon: const Icon(Icons.rate_review_outlined, color: Colors.white),
              label: Text(
                "exam_answers_btn".tr(),
                style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructor recommendations (end of student results)
          InstructorRecommendationsCard(
            recommendations: pt.instructorRecommendations,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ExamRuseltModel pt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Image.asset("assets/images/logo.png", height: 50),
          const SizedBox(height: 8),
          Text(
            "harvest_college".tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s18),
          ),
          const SizedBox(height: 4),
          Text(
            "exam_result_title".tr(namedArgs: {'level': DisplayLocalization.level(pt.level)}),
            style: getMediumStyle(color: Colors.redAccent, fontSize: FontSize.s14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ExamRuseltModel pt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _infoRow("name".tr(), pt.name)),
              Expanded(child: _infoRow("number".tr(), pt.number)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoRow("group_teacher".tr(), pt.instructor)),
              Expanded(child: _infoRow("exam_level".tr(), DisplayLocalization.level(pt.level))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoRow("group_code".tr(), pt.group)),
              Expanded(child: _infoRow("label_timeframe".tr(), DisplayLocalization.timeFrame(pt.timeFrame))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoRow("label_course".tr(), DisplayLocalization.course(pt.course))),
              Expanded(child: _infoRow("label_pass_status".tr(), DisplayLocalization.passStatus(pt.passStatus),
                  valueColor: pt.passStatus.toLowerCase() == 'pass' ? Colors.green : Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoRow("status".tr(), DisplayLocalization.status(pt.status))),
              Expanded(child: _infoRow("label_created_at".tr(), DisplayLocalization.dateTime(pt.createdAt))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoRow("label_discipline".tr(), DisplayLocalization.discipline(pt.discipline))),
              Expanded(child: _infoRow("label_track".tr(), DisplayLocalization.track(pt.track))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: getMediumStyle(color: Colors.grey.shade600, fontSize: FontSize.s12),
            ),
            TextSpan(
              text: value,
              style: getBoldStyle(color: valueColor ?? blackColors, fontSize: FontSize.s12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(ExamRuseltModel pt, double progress, List<Map<String, dynamic>> skills) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 90.0,
            lineWidth: 18.0,
            animation: true,
            percent: progress,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(progress * 100).toInt()}%",
                  style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
                ),
                Text(
                  ExamScoreHelper.format(pt.total, pt.allSkillsGrade),
                  style: getMediumStyle(color: Colors.grey, fontSize: FontSize.s12),
                ),
              ],
            ),
            progressColor: primaryColor,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          Text(
            DisplayLocalization.discipline(pt.discipline),
            style: getBoldStyle(color: blackColors, fontSize: FontSize.s16),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: pt.passStatus.toLowerCase() == 'pass'
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pt.passStatus.toLowerCase() == 'pass' ? Colors.green : Colors.red,
              ),
            ),
            child: Text(
              DisplayLocalization.passStatus(pt.passStatus),
              style: getBoldStyle(
                color: pt.passStatus.toLowerCase() == 'pass' ? Colors.green : Colors.red,
                fontSize: FontSize.s12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsBarChart(List<Map<String, dynamic>> skills) {
    if (skills.isEmpty) return const SizedBox.shrink();

    final percents = skills.map((skill) {
      final value = ExamScoreHelper.parse(skill['value']);
      final grade = ExamScoreHelper.parse(skill['grade']);
      return ExamScoreHelper.ratio(value, grade) * 100;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'performance_by_skill'.tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 2,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}%',
                        TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        if (value % 25 != 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}%',
                          style: getRegularStyle(
                            color: Colors.grey.shade600,
                            fontSize: FontSize.s11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= skills.length) {
                          return const SizedBox.shrink();
                        }
                        final label = skills[index]['name'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: SizedBox(
                            width: 40,
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: getMediumStyle(
                                color: Colors.black87,
                                fontSize: FontSize.s11,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(skills.length, (index) {
                  final pct = percents[index].clamp(0.0, 100.0);
                  final color = pct >= 80
                      ? Colors.green
                      : pct >= 50
                          ? Colors.orange
                          : Colors.red;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: pct,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        color: color,
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(skills.length, (index) {
              final pct = percents[index].clamp(0.0, 100.0).toInt();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  '${skills[index]['name']}: $pct%',
                  style: getMediumStyle(
                    color: blackColors,
                    fontSize: FontSize.s11,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTable(List<Map<String, dynamic>> skills, ExamRuseltModel pt) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Expanded(flex: 3, child: Text("skill_label".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12))),
                Expanded(flex: 2, child: Text("score_label".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12))),
                Expanded(flex: 3, child: Text("progress_label".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12))),
                Expanded(flex: 2, child: Text("pass_percent_label".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12))),
              ],
            ),
          ),
          // Skill rows
          ...skills.asMap().entries.map((entry) {
            final i = entry.key;
            final skill = entry.value;
            final double value = ExamScoreHelper.parse(skill["value"]);
            final double grade = ExamScoreHelper.parse(skill["grade"]);
            final double pct = ExamScoreHelper.ratio(value, grade);
            final bool isEven = i % 2 == 0;

            return Container(
              color: isEven ? Colors.grey.shade50 : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text("${i + 1}", style: getMediumStyle(color: Colors.grey, fontSize: FontSize.s12)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(skill["name"] as String, style: getMediumStyle(color: blackColors, fontSize: FontSize.s12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      ExamScoreHelper.format(value, grade),
                      style: getMediumStyle(color: Colors.grey.shade700, fontSize: FontSize.s12),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 0.8 ? Colors.green : pct >= 0.5 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      " ${(pct * 100).toInt()}%",
                      style: getMediumStyle(color: Colors.grey.shade700, fontSize: FontSize.s12),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Total row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Expanded(flex: 3, child: Text("total_label".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12))),
                Expanded(
                  flex: 2,
                  child: Text(
                    ExamScoreHelper.format(pt.total, pt.allSkillsGrade),
                    style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ExamScoreHelper.ratio(pt.total, pt.allSkillsGrade),
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    " ${(ExamScoreHelper.ratio(pt.total, pt.allSkillsGrade) * 100).toInt()}%",
                    style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
