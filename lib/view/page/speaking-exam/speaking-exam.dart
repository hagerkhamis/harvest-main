import 'package:flutter/material.dart';
import 'package:hatvest/model/speakingquestion-model.dart';
import 'package:hatvest/view/page/speaking-exam/test-recored.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart';
import 'package:provider/provider.dart';

class SpeakingQuestionPage extends StatefulWidget {
  final int applicationId;

  const SpeakingQuestionPage({super.key, required this.applicationId});

  @override
  State<SpeakingQuestionPage> createState() => _SpeakingQuestionPageState();
}

class _SpeakingQuestionPageState extends State<SpeakingQuestionPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExamQuizViewModel>().fetchQuestions(widget.applicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Speaking Question")),
      body: Consumer<ExamQuizViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.questions.isEmpty) {
            return const Center(child: Text("No questions available"));
          }

          final question = vm.questions.first;

          return _buildSpeaking("Speaking", vm.questions, vm,
              examType: 'Speaking');
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: Text(
          //     question.text,
          //     style: const TextStyle(
          //       fontSize: 18,
          //       height: 1.5,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // );
        },
      ),
    );
  }

  Widget _buildSpeaking(
      String title, List<SpeakingQuestion> items, ExamQuizViewModel viewModel,
      {required String examType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                          color: primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.text,
                              style: getMediumStyle(
                                color: whiteColor,
                              )),
                        )),
                    const SizedBox(height: 8),
                    if (item.photo.isNotEmpty)
                      Image.network(item.photo, height: 200, fit: BoxFit.cover),
                    const SizedBox(height: 12),
                    AudioRecorderPlayerGruop(
                      questionId: int.parse(items.first.questionId),
                      applicationId: int.parse(item.questionId),
                      // duration: elapsedTimeFormatted,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
