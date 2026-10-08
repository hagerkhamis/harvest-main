import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/adult-result/adult-result.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/exam_survey_viewmodel.dart';
import 'package:provider/provider.dart';

class ExamSurveyPage extends StatelessWidget {
  final int studentExamId;
  final int applicationId;

  const ExamSurveyPage({
    super.key,
    required this.studentExamId,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamSurveyViewModel()..loadExamSurvey(),
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: Text("survey_exam_title".tr()),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<ExamSurveyViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(viewModel.errorMessage!,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => viewModel.loadExamSurvey(),
                      child: Text("retry".tr()),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.sections.isEmpty) {
              // لو مفيش استبيان - روح مباشرةً للنتيجة
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AdultRuselt(applicationId: applicationId),
                  ),
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = viewModel.sections[sectionIndex];
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Q${sectionIndex + 1} - ',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            TextSpan(
                              text: section.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...section.topics.asMap().entries.map((entry) {
                        final index = entry.key;
                        final topic = entry.value;

                        return Column(
                          children: [
                            Card(
                              elevation: 4,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          topLeft: Radius.circular(8),
                                        ),
                                        color: primaryColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0,
                                          vertical: 12,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Q${index + 1}- ',
                                                style: getRegularStyle(
                                                  color: whiteColor,
                                                  fontSize: FontSize.s14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: topic.title,
                                                style: getBoldStyle(
                                                  color: whiteColor,
                                                  fontSize: FontSize.s14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // اختيارات الإجابة
                                    if (topic.answers.isNotEmpty)
                                      Column(
                                        children: List.generate(
                                            topic.answers.length, (i) {
                                          final answer = topic.answers[i];
                                          final isSelected =
                                              viewModel.answers[section.id]
                                                      ?[topic.id]
                                                      ?["answer_id"] ==
                                                  answer.id;

                                          return GestureDetector(
                                            onTap: () {
                                              viewModel.selectAnswer(
                                                  section.id,
                                                  topic.id,
                                                  answer.id);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: dividerColor),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: isSelected
                                                      ? Colors.green.shade100
                                                      : moreBoldWhite,
                                                ),
                                                margin: const EdgeInsets.only(
                                                    bottom: 6),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '${i + 1}- ',
                                                        style: const TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              FontSize.s18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: answer.answer,
                                                        style: getRegularStyle(
                                                          color: blackColors,
                                                          fontSize: FontSize.s18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    // حقل التعليق
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: "Comment (optional)",
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          viewModel.setComment(
                                              section.id, topic.id, value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ExamSurveyViewModel>(
            builder: (context, viewModel, _) {
              return GestureDetector(
                onTap: () async {
                  final success =
                      await viewModel.submitExamSurvey(studentExamId);
                  if (!context.mounted) return;

                  if (success) {
                    showAwesomeSnackBar(
                      title: "تم!",
                      message: "تم إرسال التقييم بنجاح",
                      type: SnackbarType.success,
                    );
                  } else {
                    showAwesomeSnackBar(
                      title: "خطأ",
                      message: "فشل إرسال التقييم، حاول مرة أخرى",
                      type: SnackbarType.error,
                    );
                  }

                  // دايماً روح للنتيجة بعد الاستبيان
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            AdultRuselt(applicationId: applicationId),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      "إرسال التقييم",
                      style: getRegularStyle(
                        color: whiteColor,
                        fontSize: AppSize.s16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
