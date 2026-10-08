import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hatvest/model/reading-model.dart';
import 'package:hatvest/model/writing-exam-model.dart';
import 'package:hatvest/view/page/exam-result/exam-result.dart';
import 'package:hatvest/view/page/listening-exam/listening-exam.dart';
import 'package:hatvest/view/page/speaking-exam/speaking-exam.dart'
    show SpeakingQuestionPage;
import 'package:hatvest/view/page/survey-page/survey-page.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class WritingExamPage extends StatefulWidget {
  final String applicationId;
  const WritingExamPage({super.key, required this.applicationId});

  @override
  State<WritingExamPage> createState() => _WritingExamPageState();
}

class _WritingExamPageState extends State<WritingExamPage> {
  final PageController _pageController = PageController();
  int _currentParagraphIndex = 0;
  int _currentQuestionIndex = 0;
  Timer? _countdownTimer;
  bool _timerStarted = false;
  double _examProgress = 1.0;
  Duration _initialDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  final Map<String, int> _selectedAnswers = {};
  int currentIndex = 0;

  int _currentWritingIndex = 0;

  Map<String, TextEditingController> _controllers = {};

  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ExamQuizViewModel>(context, listen: false);
    vm.loadWritingExam(widget.applicationId);
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

  void _startCountdown(ExamQuizViewModel viewModel, String applicationId) {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
          _examProgress = 0.0;
        });
        final answers = _selectedAnswers.values.toList();
        final timerInput = _formatDuration(_initialDuration);
        viewModel.submitReadingAnswers(
          applicationId: applicationId,
          answers: answers,
          timerInput: timerInput,
        );
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

        final data = vm.writing!;
        final readingItems = data.writing;
        final currentItem = readingItems[_currentParagraphIndex];
        final questions = currentItem.questions;

        if (!_timerStarted) {
          final parsedDuration = _parseDuration(data.remainDuration);
          _initialDuration = parsedDuration;
          _remainingTime = parsedDuration;
          _startCountdown(vm, data.applicationId.toString());
          _timerStarted = true;
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircularPercentIndicator(
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
                            progressColor: Colors.green,
                            backgroundColor: Colors.grey[300]!,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWritingSection(
                          "Writing",
                          data.writing,
                          vm,
                          examType: "writing",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWritingSection(
    String title,
    List<Writing> writingList,
    ExamQuizViewModel viewModel, {
    String? examType,
  }) {
    if (writingList.isEmpty) {
      return const Center(child: Text("No writing tasks available."));
    }

    final currentWriting = writingList[_currentWritingIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                text: 'Task ${_currentWritingIndex + 1}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text: '/${writingList.length})',
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

        // Writing Text
        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentWriting.text,
                  style:
                      getBoldStyle(color: primaryColor, fontSize: FontSize.s18),
                ),
                const SizedBox(height: 10),

                // Photo (if available)
                if (currentWriting.photo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      currentWriting.photo,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),

                const SizedBox(height: 20),

                // Questions with TextFormField
                ...currentWriting.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  // final questionId = question.id.toString();
                  final answerKey = "${currentWriting.questionId}-$index";

                  // Initialize controller if not exists
                  if (!_controllers.containsKey(answerKey)) {
                    _controllers[answerKey] = TextEditingController();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: dividerColor),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.toString(), // Display question text
                            style: getRegularStyle(
                                color: blackColors, fontSize: FontSize.s16),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _controllers[answerKey],
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Write your answer here...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                // Navigation Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentWritingIndex < writingList.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentWritingIndex++;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Next",
                          style: getMediumStyle(
                            color: whiteColor,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null // disable button while loading
                            : () =>
                                _sendAllWritingAnswers(viewModel, writingList),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Submit"),
                      )

                    // ElevatedButton(
                    //   onPressed: () {
                    //     _sendAllWritingAnswers(viewModel, writingList);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: darkGreen,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   child: const Text("Submit"),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isSubmitting = false;

  void _sendAllWritingAnswers(
    ExamQuizViewModel viewModel,
    List<Writing> writingList,
  ) async {
    setState(() => _isSubmitting = true);

    final Map<String, String> answersToSend = {};

    for (final writing in writingList) {
      final questionId = writing.questionId;

      for (int i = 0; i < writing.questions.length; i++) {
        final answerKey = "$questionId-$i";
        final answer = _controllers[answerKey]?.text ?? '';

        if (answer.trim().isNotEmpty) {
          if (answersToSend.containsKey(questionId)) {
            answersToSend[questionId] =
                "${answersToSend[questionId]!}<br/>${answer.trim()}";
          } else {
            answersToSend[questionId] = answer.trim();
          }
        }

        _controllers[answerKey]?.clear();
      }
    }

    final success = await viewModel.submitWritingAnswers({
      "applicationId": viewModel.writing!.applicationId,
      "timer_input": "10:00", // Replace with actual timer if needed
      "answers": answersToSend,
    });

    setState(() => _isSubmitting = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeakingQuestionPage(
          applicationId: int.parse(viewModel.listening!.applicationId),
        ),
      ),
    );
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (_) => SurveyPage(
    //       applicationId: viewModel.writing!.applicationId,
    //     ),
    //   ),
    // );

    // if (success) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (_) => SurveyPage(
    //         applicationId: viewModel.writing!.applicationId,
    //       ),
    //     ),
    //   );
    // }
  }

  // bool _isSubmitting = false;

  // void _sendAllWritingAnswers(
  //   ExamQuizViewModel viewModel,
  //   List<Writing> writingList,
  // ) async {
  //   final Map<String, String> answersToSend = {};

  //   for (final writing in writingList) {
  //     final questionId = writing.questionId;

  //     for (int i = 0; i < writing.questions.length; i++) {
  //       final answerKey = "$questionId-$i";
  //       final answer = _controllers[answerKey]?.text ?? '';

  //       if (answer.trim().isNotEmpty) {
  //         if (answersToSend.containsKey(questionId)) {
  //           answersToSend[questionId] =
  //               "${answersToSend[questionId]!}<br/>${answer.trim()}";
  //         } else {
  //           answersToSend[questionId] = answer.trim();
  //         }
  //       }

  //       _controllers[answerKey]?.clear();
  //     }
  //   }

  //   final success = await viewModel.submitWritingAnswers({
  //     "applicationId": viewModel.writing!.applicationId,
  //     "timer_input": "10:00", // Replace with actual timer if needed
  //     "answers": answersToSend,
  //   });

  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(
  //       builder: (_) => SurveyPage(
  //         applicationId: viewModel.writing!.applicationId,
  //       ),
  //     ),
  //   );
  // }
}
