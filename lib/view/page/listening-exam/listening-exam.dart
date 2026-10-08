import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hatvest/model/listening-model.dart' show ListeningItem;
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/listening-exam/chat-list/chat-list.dart';
import 'package:hatvest/view/page/writing-exam/writing-exam.dart'
    show WritingExamPage;
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart';
import 'package:just_audio/just_audio.dart' show AudioPlayer;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class ListeningExamPage extends StatefulWidget {
  final String applicationId;
  const ListeningExamPage({super.key, required this.applicationId});

  @override
  State<ListeningExamPage> createState() => _ListeningExamPageState();
}

class _ListeningExamPageState extends State<ListeningExamPage> {
  final PageController _pageController = PageController();
  int _currentListeningIndex = 0;
  int _currentQuestionIndex = 0;
  Timer? _countdownTimer;
  bool _timerStarted = false;
  double _examProgress = 1.0;
  Duration _initialDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  final Map<String, int> _selectedAnswers = {};
  int currentIndex = 0;

  bool _isExpanded = false;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    final vm = Provider.of<ExamQuizViewModel>(context, listen: false);
    vm.loadListeningExam(widget.applicationId);
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();

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
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = vm.listening;
        if (data == null || data.listening.isEmpty) {
          return const Center(child: Text("No listening items available."));
        }

        final listeningItems = data.listening;

        if (_currentListeningIndex >= listeningItems.length) {
          return const Center(child: Text("No more paragraphs."));
        }

        final currentItem = listeningItems[_currentListeningIndex];
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
            title: const Text("listening Exam"),
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.green,
                          backgroundColor: Colors.grey[300]!,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildReadingSection(currentItem, vm),
                          ),
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

  Widget _buildReadingSection(ListeningItem item, ExamQuizViewModel viewModel) {
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
        _currentQuestionIndex == 0 && _currentListeningIndex == 0;
    final isLastParagraph =
        _currentListeningIndex == viewModel.listening!.listening.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    child: VoiceAudio(
                      audioUrl: item.record!,
                    ),
                    // child: AudioPlayerWidget(audioUrl: item.record),
                  ),
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
                      if (!isFirstQuestion)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_currentQuestionIndex > 0) {
                                  _currentQuestionIndex--;
                                } else if (_currentListeningIndex > 0) {
                                  _currentListeningIndex--;
                                  _currentQuestionIndex = viewModel
                                          .listening!
                                          .listening[_currentListeningIndex]
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
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Center(
                                child: Text(
                                  "Previous",
                                  style: getRegularStyle(
                                    color: blackColors,
                                    fontSize: AppSize.s16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_currentQuestionIndex < questions.length - 1)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
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
                                  if (_currentQuestionIndex <
                                      questions.length - 1) {
                                    setState(() {
                                      _currentQuestionIndex++;
                                    });
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                } else {
                                  showAwesomeSnackBar(
                                    title: "Error",
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
                        ),
                      if (_currentQuestionIndex == questions.length - 1)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                if (isLastQuestion) {
                                  final answers =
                                      _selectedAnswers.values.toList();
                                  final timerInput =
                                      _formatDuration(_initialDuration);

                                  viewModel.submitReadingAnswers(
                                    applicationId:
                                        viewModel.listening!.applicationId,
                                    answers: answers,
                                    timerInput: timerInput,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WritingExamPage(
                                        applicationId:
                                            viewModel.listening!.applicationId,
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
