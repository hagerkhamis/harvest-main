import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/display_localization.dart';
import 'package:hatvest/core/utils/exam_score_helper.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class TrackProgressPage extends StatefulWidget {
  @override
  _TrackProgressPageState createState() => _TrackProgressPageState();
}

class _TrackProgressPageState extends State<TrackProgressPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "page_track_progress".tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
            ),
          ],
        ),
        body: Stack(
          children: [
            // خلفية بيضا نضيفة
            Container(
              color: const Color(0xFFF5F5F5),
            ),
            // محتوى الصفحة
            Consumer<ProfileViewModel>(builder: (_, viewModel, __) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pt = viewModel.ptSkills;
          final exams = viewModel.examSkills;

          if (pt == null && exams.isEmpty) {
            return Center(child: Text("no_data_available".tr()));
          }

          final double ptGrade = pt?.total ?? 0.0;
          final double examGrade =
              ExamScoreHelper.parse(pt?.allskillsgrade, 0);
          final double resolvedMax = ExamScoreHelper.resolveMax(
            apiMax: examGrade,
            total: ptGrade,
            skillMaxima: pt == null
                ? const []
                : [
                    ExamScoreHelper.parse(pt.vocabgrade),
                    ExamScoreHelper.parse(pt.grammergrade),
                    ExamScoreHelper.parse(pt.readinggrade),
                    ExamScoreHelper.parse(pt.listeninggrade),
                    ExamScoreHelper.parse(pt.speakinggrade),
                    ExamScoreHelper.parse(pt.writinggrade),
                  ],
          );
          final double resolvedTotal = ExamScoreHelper.resolveTotal(
            apiTotal: ptGrade,
            max: resolvedMax,
            skillScores: pt == null
                ? const []
                : [
                    ExamScoreHelper.capped(
                      ExamScoreHelper.parse(pt.vocab),
                      ExamScoreHelper.parse(pt.vocabgrade),
                    ),
                    ExamScoreHelper.capped(
                      ExamScoreHelper.parse(pt.grammer),
                      ExamScoreHelper.parse(pt.grammergrade),
                    ),
                    ExamScoreHelper.capped(
                      ExamScoreHelper.parse(pt.reading),
                      ExamScoreHelper.parse(pt.readinggrade),
                    ),
                    ExamScoreHelper.capped(
                      ExamScoreHelper.parse(pt.listening),
                      ExamScoreHelper.parse(pt.listeninggrade),
                    ),
                    ExamScoreHelper.capped(
                      ExamScoreHelper.parse(pt.speaking),
                      ExamScoreHelper.parse(pt.speakinggrade),
                    ),
                    ExamScoreHelper.capped(
                      ExamScoreHelper.parse(pt.writing),
                      ExamScoreHelper.parse(pt.writinggrade),
                    ),
                  ],
          );
          final double progress =
              ExamScoreHelper.ratio(resolvedTotal, resolvedMax);

          // Build list of pages dynamically
          final pages = <Widget>[];

          // PT page
          if (pt != null) {
            pages.add(_buildProgressPage(
              label: DisplayLocalization.level(pt.label),
              progress: progress,
              overallGrade: null,
              skills: [
                {
                  "name": "Vocabulary",
                  "value": ExamScoreHelper.capped(
                    ExamScoreHelper.parse(pt.vocab),
                    ExamScoreHelper.parse(pt.vocabgrade),
                  ),
                  "grade": ExamScoreHelper.parse(pt.vocabgrade),
                },
                {
                  "name": "Grammar",
                  "value": ExamScoreHelper.capped(
                    ExamScoreHelper.parse(pt.grammer),
                    ExamScoreHelper.parse(pt.grammergrade),
                  ),
                  "grade": ExamScoreHelper.parse(pt.grammergrade),
                },
                {
                  "name": "Reading",
                  "value": ExamScoreHelper.capped(
                    ExamScoreHelper.parse(pt.reading),
                    ExamScoreHelper.parse(pt.readinggrade),
                  ),
                  "grade": ExamScoreHelper.parse(pt.readinggrade),
                },
                {
                  "name": "Listening",
                  "value": ExamScoreHelper.capped(
                    ExamScoreHelper.parse(pt.listening),
                    ExamScoreHelper.parse(pt.listeninggrade),
                  ),
                  "grade": ExamScoreHelper.parse(pt.listeninggrade),
                },
                {
                  "name": "Speaking",
                  "value": ExamScoreHelper.capped(
                    ExamScoreHelper.parse(pt.speaking),
                    ExamScoreHelper.parse(pt.speakinggrade),
                  ),
                  "grade": ExamScoreHelper.parse(pt.speakinggrade),
                },
                {
                  "name": "Writing",
                  "value": ExamScoreHelper.capped(
                    ExamScoreHelper.parse(pt.writing),
                    ExamScoreHelper.parse(pt.writinggrade),
                  ),
                  "grade": ExamScoreHelper.parse(pt.writinggrade),
                },
              ],
            ));
          }

          // Exam pages
          pages.addAll(exams.map((exam) {
            final skillScores = [
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.vocab),
                ExamScoreHelper.parse(exam.vocabgrade),
              ),
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.grammer),
                ExamScoreHelper.parse(exam.grammergrade),
              ),
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.reading),
                ExamScoreHelper.parse(exam.readinggrade),
              ),
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.listening),
                ExamScoreHelper.parse(exam.listeninggrade),
              ),
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.speaking),
                ExamScoreHelper.parse(exam.speakinggrade),
              ),
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.writing),
                ExamScoreHelper.parse(exam.writinggrade),
              ),
              ExamScoreHelper.capped(
                ExamScoreHelper.parse(exam.evaluation),
                ExamScoreHelper.parse(exam.evaluationgrade),
              ),
            ];
            final skillMaxima = [
              ExamScoreHelper.parse(exam.vocabgrade),
              ExamScoreHelper.parse(exam.grammergrade),
              ExamScoreHelper.parse(exam.readinggrade),
              ExamScoreHelper.parse(exam.listeninggrade),
              ExamScoreHelper.parse(exam.speakinggrade),
              ExamScoreHelper.parse(exam.writinggrade),
              ExamScoreHelper.parse(exam.evaluationgrade),
            ];
            final apiTotal = ExamScoreHelper.parse(exam.total);
            final apiMax = ExamScoreHelper.parse(exam.allskillsgrade);
            final examMax = ExamScoreHelper.resolveMax(
              apiMax: apiMax,
              total: apiTotal,
              skillMaxima: skillMaxima,
            );
            final resultValue = ExamScoreHelper.resolveTotal(
              apiTotal: apiTotal,
              max: examMax,
              skillScores: skillScores,
            );
            final examProgress =
                ExamScoreHelper.ratio(resultValue, examMax);

            return _buildProgressPage(
              label: DisplayLocalization.level(exam.level),
              progress: examProgress,
              overallGrade: null,
              skills: [
                {
                  "name": "Vocabulary",
                  "value": skillScores[0],
                  "grade": skillMaxima[0],
                },
                {
                  "name": "Grammar",
                  "value": skillScores[1],
                  "grade": skillMaxima[1],
                },
                {
                  "name": "Reading",
                  "value": skillScores[2],
                  "grade": skillMaxima[2],
                },
                {
                  "name": "Listening",
                  "value": skillScores[3],
                  "grade": skillMaxima[3],
                },
                {
                  "name": "Speaking",
                  "value": skillScores[4],
                  "grade": skillMaxima[4],
                },
                {
                  "name": "Writing",
                  "value": skillScores[5],
                  "grade": skillMaxima[5],
                },
                if (skillMaxima[6] > 0 || skillScores[6] > 0)
                  {
                    "name": "Evaluation",
                    "value": skillScores[6],
                    "grade": skillMaxima[6],
                  },
              ],
            );
          }));

          // Last page: Overall grade summary
          final allGrades = <Map<String, String>>[];
          if (pt?.allgrade != null && pt!.allgrade!.isNotEmpty) {
            allGrades.add({"label": DisplayLocalization.level(pt.label.isEmpty ? "PT" : pt.label), "grade": pt.allgrade!});
          }
          for (final exam in exams) {
            if (exam.allgrade != null && exam.allgrade!.isNotEmpty) {
              allGrades.add({"label": DisplayLocalization.level(exam.level.isEmpty ? exam.label : exam.level), "grade": exam.allgrade!});
            }
          }
          if (allGrades.isNotEmpty) {
            pages.add(_buildOverallGradePage(allGrades));
          }

          return SizedBox.expand(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: pages,
                ),

                // Right arrow
                if (_currentPage < pages.length - 1)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios,
                          size: 35, color: blackColors),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                // Left arrow
                if (_currentPage > 0)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          size: 35, color: blackColors),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPage({
    required String label,
    required double progress,
    required List<Map<String, dynamic>> skills,
    String? overallGrade,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            CircularPercentIndicator(
              radius: 110.0,
              lineWidth: 40.0,
              animation: true,
              percent: progress.clamp(0.0, 1.0),
              center: Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              progressColor: primaryColor,
              backgroundColor: Colors.grey[300]!,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: getBoldStyle(color: blackColors, fontSize: FontSize.s18),
            ),
            const SizedBox(height: 16),
            _buildSkillBreakdown(skills),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallGradePage(List<Map<String, String>> grades) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Icon(Icons.emoji_events_rounded, size: 80, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              "overall_grade".tr(),
              style: getBoldStyle(color: blackColors, fontSize: FontSize.s22),
            ),
            const SizedBox(height: 30),
            ...grades.map((g) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.9), primaryColor.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    g["label"] ?? "",
                    style: getBoldStyle(color: Colors.white, fontSize: FontSize.s18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      g["grade"] ?? "",
                      style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
                    ),
                  ),
                ],
              ),
            )),
          ],
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
        final int percentage = (progress * 100).toInt();
        
        // Determine color based on percentage
        Color barColor;
        if (percentage >= 70) {
          barColor = const Color(0xFF4CAF50); // Green
        } else if (percentage >= 50) {
          barColor = const Color(0xFFFF9800); // Orange
        } else {
          barColor = const Color(0xFFF44336); // Red
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  name,
                  style: getBoldStyle(color: blackColors, fontSize: FontSize.s14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$percentage%",
                style: getBoldStyle(color: barColor, fontSize: FontSize.s14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 18,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                ExamScoreHelper.format(value, grade),
                style: getMediumStyle(color: blackColors, fontSize: FontSize.s14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
