import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hatvest/model/reading-model.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/listening-exam/listening-exam.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class ReadingExamPage extends StatefulWidget {
  final String applicationId;
  const ReadingExamPage({super.key, required this.applicationId});

  @override
  State<ReadingExamPage> createState() => _ReadingExamPageState();
}

class _ReadingExamPageState extends State<ReadingExamPage> {
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

  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ExamQuizViewModel>(context, listen: false);
    vm.loadReadingExam(widget.applicationId);
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

        final data = vm.reading!;
        final readingItems = data.reading;
        final currentItem = readingItems[_currentParagraphIndex];
        final questions = currentItem.questions;

        if (!_timerStarted) {
          final parsedDuration = _parseDuration(data.remainDuration);
          _initialDuration = parsedDuration;
          _remainingTime = parsedDuration;
          _startCountdown(vm, data.applicationId);
          _timerStarted = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Reading Exam"),
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
                        _buildReadingSection(currentItem, vm),
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

  Widget _buildReadingSection(ReadingItem item, ExamQuizViewModel viewModel) {
    final questions = item.questions;

    if (questions.isEmpty) {
      return const Center(child: Text("No questions available."));
    }

    if (_currentQuestionIndex >= questions.length) {
      _currentQuestionIndex = 0;
    }

    final question = questions[_currentQuestionIndex];
    final questionId = question.id;
    final selectedId = _selectedAnswers[questionId];

    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final isFirstQuestion =
        _currentQuestionIndex == 0 && _currentParagraphIndex == 0;
    final isLastParagraph =
        _currentParagraphIndex == viewModel.reading!.reading.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Reading(',
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
                  color: Colors.green,
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
        const SizedBox(height: 10),
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
                children: [
                  // Text(item.paragraph),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paragraph with toggle icon

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
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.paragraph,
                                style: getBoldStyle(
                                  color: whiteColor,
                                  fontSize: FontSize.s16,
                                ),
                                maxLines: _isExpanded ? null : 2,
                                overflow: _isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _isExpanded ? "Show less" : "Show more",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: FontSize.s14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(color: green),

                      // Question with corrected index
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Q${_currentQuestionIndex + 1}- ',
                                style: getRegularStyle(
                                  color: darkGreen,
                                  fontSize: FontSize.s16,
                                ),
                              ),
                              TextSpan(
                                text: question.questionText,
                                style: getBoldStyle(
                                  color: blackColors,
                                  fontSize: FontSize.s16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  ...question.answers.map((answer) {
                    final isSelected = selectedId == answer.id;

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
                          setState(() {
                            _selectedAnswers[questionId.toString()] = answer.id;
                          });
                        });
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // === PREVIOUS BUTTON ===
                      if (!isFirstQuestion)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_currentQuestionIndex > 0) {
                                  _currentQuestionIndex--;
                                } else if (_currentParagraphIndex > 0) {
                                  _currentParagraphIndex--;
                                  _currentQuestionIndex = viewModel
                                          .reading!
                                          .reading[_currentParagraphIndex]
                                          .questions
                                          .length -
                                      1;
                                }
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
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

                      // === NEXT BUTTON ===
                      if (!isLastQuestion || !isLastParagraph)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              final questionAnswerIds =
                                  question.answers.map((a) => a.id).toList();
                              final selectedId =
                                  _selectedAnswers[questionId.toString()];
                              final isAnswered = selectedId != null &&
                                  questionAnswerIds.contains(selectedId);

                              if (!isAnswered) {
                                showAwesomeSnackBar(
                                  // context: context,
                                  title: "Error",
                                  message:
                                      "Please select an answer before continuing.",
                                  type: SnackbarType.error,
                                );

                                return;
                              }

                              setState(() {
                                if (_currentQuestionIndex <
                                    questions.length - 1) {
                                  _currentQuestionIndex++;
                                } else if (_currentParagraphIndex <
                                    viewModel.reading!.reading.length - 1) {
                                  _currentParagraphIndex++;
                                  _currentQuestionIndex = 0;
                                }
                              });
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

                      // === SUBMIT BUTTON ===
                      if (isLastQuestion && isLastParagraph)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              final answers = _selectedAnswers.values.toList();
                              final timerInput =
                                  _formatDuration(_initialDuration);

                              viewModel.submitReadingAnswers(
                                applicationId: viewModel.reading!.applicationId,
                                answers: answers,
                                timerInput: timerInput,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListeningExamPage(
                                    applicationId:
                                        viewModel.reading!.applicationId,
                                  ),
                                ),
                              );

    
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
              )),
        ),
      ],
    );
  }
}
