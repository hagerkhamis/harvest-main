import 'package:flutter/material.dart';
import 'package:hatvest/model/vocab-model.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/grammer-exam/grammer-exam.dart'
  show GrammarExamPage;
import 'package:hatvest/view/page/exam-result/exam-result.dart' show ExamRuselt;
import 'package:hatvest/viewmodel/exam-viewmodel.dart' show ExamQuizViewModel;
import 'package:provider/provider.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hatvest/model/vocab-model.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart' show ExamQuizViewModel;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class VocabExamPage extends StatefulWidget {
  final int studentId;
  final String groupLevel;
  const VocabExamPage(
      {super.key, required this.studentId, required this.groupLevel});

  @override
  State<VocabExamPage> createState() => _VocabExamPageState();
}

class _VocabExamPageState extends State<VocabExamPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  Timer? _countdownTimer;
  bool _timerStarted = false;
  double _examProgress = 1.0;
  Duration _initialDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  final Map<String, int> _selectedAnswers = {};

  // final Map<String, List<int>> _selectedAnswers = {
  //   'Vocab': [],
  // };

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ExamQuizViewModel>(context, listen: false);
    vm.loadExam(widget.studentId);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } else if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }

  void _startCountdown(ExamQuizViewModel viewModel, int applicationId) {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
          _examProgress = 0.0;
        });

        // Submit automatically on time end
        final answers = _selectedAnswers.values.toList(); // this is List<int>

        // final answers = _selectedAnswers['Vocab'] ?? [];
        final timerInput = _formatDuration(_initialDuration);

        viewModel.submitVocabularyAnswers(
          applicationId: applicationId.toString(),
          answers: answers,
          timerInput: timerInput,
        );

        // Show dialog and pop
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Time's Up!"),
            content: const Text(
                "The exam time has ended. Your answers were submitted."),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
          _examProgress = _remainingTime.inSeconds / _initialDuration.inSeconds;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamQuizViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading)
          return const Center(child: CircularProgressIndicator());
        // if (vm.errorMessage != null)
        //   return Center(child: Text(vm.errorMessage!));

        final data = vm.examData!;
        final questions = data.vocab;

        if (!_timerStarted) {
          final parsedDuration = _parseDuration(data.remainDuration);
          _initialDuration = parsedDuration;
          _remainingTime = parsedDuration;
          _startCountdown(vm, data.applicationId);
          _timerStarted = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("${widget.groupLevel}"),
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 12.0,
                        animation: true,
                        animateFromLastPercent: true,
                        percent: _examProgress.clamp(0.0, 1.0),
                        center: Text(
                          _formatDuration(_remainingTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: primaryColor,
                        backgroundColor: Colors.grey[300]!,
                      ),
                      const SizedBox(height: 24),
                      _buildSection('Vocab', questions, vm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      String title, List<VocabQuestion> questions, ExamQuizViewModel viewModel,
      {String? examType}) {
    if (questions.isEmpty) return const SizedBox();

    // final question = questions[currentIndex];

    final isLast = currentIndex == questions.length - 1;
    final question = questions[currentIndex];
    final questionId = question.id;
    final hasAnswer = viewModel.selectedAnswers.containsKey(questionId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with Q index - the "Q" and index in green color
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$title (',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: 'Q${currentIndex + 1}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // green color for Q index
                ),
              ),
              TextSpan(
                text: '/${questions.length})',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8),
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
                  height: 120,
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
                      vertical: 20,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Q${currentIndex + 1}- ',
                            style: getRegularStyle(
                              color: darkGreen,
                              fontSize: FontSize.s16,
                            ),
                          ),
                          TextSpan(
                            text: question.questionText,
                            style: getBoldStyle(
                              color: whiteColor,
                              fontSize: FontSize.s16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...question.answers.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final answer = entry.value;
                    return ListTile(
                      title: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: dividerColor),
                          borderRadius: BorderRadius.circular(15),
                          color: _selectedAnswers[questionId.toString()] ==
                                  answer.id
                              ? Colors.green.shade100
                              : moreBoldWhite,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${index + 1}. ',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSize.s18,
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
                      onTap: () {
                        setState(() {
                          // _selectedAnswers[title]!.add(answer.id);
                          setState(() {
                            _selectedAnswers[questionId.toString()] = answer.id;
                          });
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex > 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              currentIndex--;
                            });
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                "Previous",
                                style: getRegularStyle(
                                  color: whiteColor,
                                  fontSize: AppSize.s16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (currentIndex < questions.length - 1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            final questionId = question.id;
                            final questionAnswerIds =
                                question.answers.map((a) => a.id).toList();
                            final selectedId =
                                _selectedAnswers[questionId.toString()];
                            final isAnswered = selectedId != null &&
                                questionAnswerIds.contains(selectedId);

                            if (isAnswered) {
                              setState(() {
                                currentIndex++;
                              });
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              showAwesomeSnackBar(
                                // context: context,
                                title: "Error!",
                                message:
                                    "Please select an answer before continuing.",
                                type: SnackbarType.error,
                              );
                            }
                          },
                          child: Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              color: darkGreen,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                "Next",
                                style: getRegularStyle(
                                  color: whiteColor,
                                  fontSize: AppSize.s16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (currentIndex == questions.length - 1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            if (isLast) {
                              final answers = _selectedAnswers.values.toList();
                              final timerInput =
                                  _formatDuration(_initialDuration);

                              viewModel.submitVocabularyAnswers(
                                applicationId: viewModel.examData!.applicationId
                                    .toString(),
                                answers: answers,
                                timerInput: timerInput,
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExamRuselt(
                                    applicationId:
                                        viewModel.examData!.applicationId,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 35,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                "Submit Answers",
                                style: getRegularStyle(
                                  color: whiteColor,
                                  fontSize: AppSize.s16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
