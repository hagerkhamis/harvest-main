import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/kids-pt-result/kids-pt-result.dart'
    show kidsPtRuselt;
import 'package:hatvest/view/page/listening-exam/chat-list/chat-list.dart'
    show VoiceAudio;
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';
import 'package:hatvest/viewmodel/adult-pt-viewmodel.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../model/kids-pt-exam-model.dart'
    show Grammer, KidsPtExamModel, Listening, Reading, Writing;

class KidsPtExam extends StatefulWidget {
  const KidsPtExam({Key? key}) : super(key: key);

  @override
  State<KidsPtExam> createState() => _KidsPtExamState();
}

class _KidsPtExamState extends State<KidsPtExam> {
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _timerStarted = false;

  bool _isStageLoading = false;
  bool isSubmitting = false; // Add this in your ViewModel or State class

  // text answer of wreting
  Map<String, TextEditingController> _controllers = {};

  int _currentParagraphIndex = 0;
  int _currentLisIndex = 0;

  Map<String, int> _currentQuestionIndices =
      {}; // Keep index per paragraph title
  // int _currentParagraphIndex = 0; // new
  // Map<String, int> _currentQuestionIndexPerParagraph = {}; // new

  int _currentWritingIndex = 0;
  Map<String, String> _writingAnswers = {};

  final PageController _pageController = PageController();

  double _examProgress = 1.0;
  Duration _initialDuration = Duration.zero;
  String _currentStage = 'Vocabulary';
  int _currentQuestionIndex = 0;
  int _currentListeningIndex = 0;
  bool _isExpanded = true;
//
  late Timer _elapsedTimer;
  int _elapsedSeconds = 0;

  final Map<String, int> _currentIndices = {
    'Vocabulary': 0,
    'Grammar': 0,
    'Reading': 0,
    'Listening': 0,
    'Writing': 0,
  };

  final Map<String, List<int>> _selectedAnswers = {
    'Vocabulary': [],
    'Grammar': [],
    'Reading': [],
    'Listening': [],
    'Writing': [],
  };

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ExamViewModel>(context, listen: false);
    viewModel.loadKidsExam(1);
    // _currentQuestionIndexPerParagraph['Reading'] = 0; // new
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isSubmitting = false;

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
          _examProgress = 0.0;
        });
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          _examProgress = _remainingTime.inSeconds / _initialDuration.inSeconds;
        });
      }
    });
  }

  String get elapsedTimeFormatted {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _elapsedTimer.cancel();

    super.dispose();
  }

  void _skipEmptyStages(KidsPtExamModel model) {
    const order = [
      'Vocabulary',
      'Grammar',
      'Reading',
      'Listening',
      'Writing',
    ];

    bool isEmpty(String stage) {
      switch (stage) {
        case 'Vocabulary':
          return model.vocab.isEmpty;
        case 'Grammar':
          return model.grammer.isEmpty;
        case 'Reading':
          return model.reading.isEmpty;
        case 'Listening':
          return model.listening.isEmpty;
        case 'Writing':
          return model.writing.isEmpty;
        default:
          return false;
      }
    }

    var index = order.indexOf(_currentStage);
    if (index < 0) index = 0;

    while (index < order.length && isEmpty(order[index])) {
      index++;
    }

    if (index >= order.length) {
      index = order.length - 1;
    }

    final nextStage = order[index];
    if (nextStage != _currentStage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentStage = nextStage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamViewModel>(
      builder: (context, viewModel, _) {
        final kidsPtExamModel = viewModel.kidsPtExamModel;

        if (viewModel.isLoading || kidsPtExamModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!_timerStarted && kidsPtExamModel.remainDuration > 0) {
          _initialDuration = Duration(seconds: kidsPtExamModel.remainDuration);
          _remainingTime = _initialDuration;
          _startCountdown();
          _timerStarted = true;
        }

        _skipEmptyStages(kidsPtExamModel);

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: dividerColor,
            title: Text(
              "اختبار تحديد المستوي",
              style: getBoldStyle(
                color: blackColors,
                fontSize: FontSize.s20,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_forward),
              )
            ],
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [

              // Scrollable content
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 10),
                              if (_currentStage == 'Vocabulary')
                                _buildSection(
                                    "Vocabulary",
                                    kidsPtExamModel.vocab,
                                    viewModel,
                                    examType: 'vocab'),
                              if (_currentStage == 'Grammar')
                                _buildSection(
                                    "Grammar",
                                    kidsPtExamModel.grammer,
                                    viewModel,
                                    examType: 'grammar'),
                              if (_currentStage == 'Reading')
                                _buildReadingSection(
                                  "Reading",
                                  kidsPtExamModel.reading,
                                  viewModel,
                                  examType: "reading",
                                ),
                              if (_currentStage == 'Listening')
                                _buildListeningSection(
                                  "Listening",
                                  kidsPtExamModel.listening,
                                  viewModel,
                                  examType: "listening",
                                ),
                              if (_currentStage == 'Writing')
                                _buildWritingSection(
                                  "Writing",
                                  kidsPtExamModel.writing,
                                  viewModel,
                                  examType: "writing",
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      String title, List<Grammer> questions, ExamViewModel viewModel,
      {String? examType}) {
    if (questions.isEmpty) return const SizedBox();

    final currentIndex = _currentIndices[title]!;
    final question = questions[currentIndex];

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
                          color: _selectedAnswers[title]!.contains(answer.id)
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
                          final selectedList = _selectedAnswers[title]!;

                          // Clear previous answer selections for this question
                          final questionAnswerIds =
                              question.answers.map((a) => a.id).toList();
                          selectedList.removeWhere(
                              (id) => questionAnswerIds.contains(id));

                          // Add only the newly selected answer
                          selectedList.add(answer.id);
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (currentIndex < questions.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentIndex > 0)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndices[title] = currentIndex - 1;
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey, // Previous button color
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
                          )
                        else
                          const SizedBox(
                              width: 100), // Placeholder to align "Next"

                        GestureDetector(
                          onTap: () {
                            final selectedForThisSection =
                                _selectedAnswers[title]!;
                            final questionAnswerIds =
                                question.answers.map((a) => a.id).toList();

                            final isAnswered = selectedForThisSection.any(
                              (id) => questionAnswerIds.contains(id),
                            );

                            if (isAnswered) {
                              setState(() {
                                _currentIndices[title] = currentIndex + 1;
                              });
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
                      ],
                    ),
                  ),
                if (currentIndex == questions.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _isStageLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GestureDetector(
                              onTap: () async {
                                if (examType == 'vocab') {
                                  setState(() => _isStageLoading = true);
                                  await viewModel.submitKidsVocabAnswers(
                                    applicationId: viewModel
                                        .kidsPtExamModel!.applicationId,
                                    answers: _selectedAnswers[title]!,
                                    timerInput: elapsedTimeFormatted, // "mm:ss"
                                  );

                                  setState(() {
                                    _currentStage =
                                        'Grammar'; // move to grammar
                                    _isStageLoading = false;
                                  });
                                } else if (examType == 'grammar') {
                                  setState(() => _isStageLoading = true);
                                  await viewModel.submitKidsGrammerAnswers(
                                    applicationId: viewModel
                                        .kidsPtExamModel!.applicationId,
                                    answers: _selectedAnswers[title]!,

                                    timerInput: elapsedTimeFormatted, // "mm:ss"

                                    // timerInput:
                                    //     "${viewModel.remainDuration.inMinutes}:${(viewModel.remainDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                                  );

                                  setState(() {
                                    _currentStage =
                                        'Reading'; // move to reading
                                    _isStageLoading = false;
                                  });
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
          ),
        ),
      ],
    );
  }

//

  Widget _buildReadingSection(
      String title, List<Reading> readings, ExamViewModel viewModel,
      {String? examType}) {
    if (readings.isEmpty || _currentParagraphIndex >= readings.length) {
      return const Center(child: Text("No more paragraphs."));
    }

    final currentReading = readings[_currentParagraphIndex];
    final questions = currentReading.questions;

    return _buildSectionReading(
      title,
      questions,
      viewModel,
      paragraphText: currentReading.paragraph,
      totalParagraphs: readings.length,
      currentParagraph: _currentParagraphIndex,
      onNextParagraph: () {
        setState(() {
          _currentParagraphIndex++;
          _currentIndices[title] = 0;
        });
      },
    );
  }

  Widget _buildSectionReading(
    String title,
    List<Grammer> questions,
    ExamViewModel viewModel, {
    required String paragraphText,
    required int totalParagraphs,
    required int currentParagraph,
    required VoidCallback onNextParagraph,
    String? examType,
  }) {
    if (questions.isEmpty) return const SizedBox();

    final currentIndex = _currentIndices[title]!;
    final question = questions[currentIndex];
    final paragraph = viewModel.kidsPtExamModel!.reading.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Text
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
                // Paragraph & Question
                // Add this in your State class

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
                          paragraphText,
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

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                    color: whiteColor,
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
                              color: primaryColor,
                              fontSize: FontSize.s18,
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
                          color: _selectedAnswers[title]!.contains(answer.id)
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
                          final selectedList = _selectedAnswers[title]!;

                          final questionAnswerIds =
                              question.answers.map((a) => a.id).toList();
                          selectedList.removeWhere(
                              (id) => questionAnswerIds.contains(id));

                          // Add only the newly selected answer
                          selectedList.add(answer.id);
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
                if (currentIndex < questions.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentIndex > 0)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndices[title] = currentIndex - 1;
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey, // Previous button color
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
                          )
                        else
                          const SizedBox(
                              width: 100), // Placeholder to align "Next"

                        GestureDetector(
                          onTap: () {
                            final selectedForThisSection =
                                _selectedAnswers[title]!;
                            final questionAnswerIds =
                                question.answers.map((a) => a.id).toList();

                            final isAnswered = selectedForThisSection.any(
                              (id) => questionAnswerIds.contains(id),
                            );

                            if (isAnswered) {
                              setState(() {
                                _currentIndices[title] = currentIndex + 1;
                              });
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
                      ],
                    ),
                  ),
                if (currentIndex == questions.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          if (_isSubmitting)
                            return; // Prevent multiple submissions

                          if (currentParagraph == totalParagraphs - 1) {
                            setState(() =>
                                _isSubmitting = true); // Show loading indicator

                            try {
                              await viewModel.submitKidsReadingAnswers(
                                applicationId:
                                    viewModel.kidsPtExamModel!.applicationId,
                                answers: _selectedAnswers[title]!,
                                timerInput: elapsedTimeFormatted,
                              );

                              setState(() {
                                _currentStage = 'Listening';
                                _isSubmitting = false;
                              });
                            } catch (e) {
                              setState(() => _isSubmitting = false);
                              showAwesomeSnackBar(
                                title: "Error",
                                message: "Submission failed: ${e.toString()}",
                                type: SnackbarType.error,
                              );
            
                            }
                          } else {
                            onNextParagraph();
                          }
                        },
                        child: Container(
                          width: 180,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isSubmitting
                                ? Colors.grey
                                : (currentParagraph == totalParagraphs - 1
                                    ? primaryColor
                                    : darkGreen),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: whiteColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    currentParagraph == totalParagraphs - 1
                                        ? "Submit Answers"
                                        : "Next Paragraph",
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
          ),
        ),
      ],
    );
  }

  Widget _buildListeningSection(
      String title, List<Listening> items, ExamViewModel viewModel,
      {String? examType}) {
    final currentItem = items[_currentListeningIndex];

    final questions = currentItem.questions;

    if (_currentQuestionIndex >= questions.length) {
      _currentQuestionIndex = 0;
    }

    final currentIndex = _currentIndices[title] ?? 0;
    final question = questions[_currentQuestionIndex];
    final questionId = question.id;
    final selectedId = _selectedAnswers[questionId];

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
                    key: ValueKey(
                        currentItem.record!), // Force rebuild when URL changes
                    audioUrl: currentItem.record!,
                  ),
                ),
                // Question
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Q${_currentQuestionIndex + 1}- ',
                          style: getRegularStyle(
                              color: darkGreen, fontSize: FontSize.s16),
                        ),
                        TextSpan(
                          text: question.questionText,
                          style: getBoldStyle(
                              color: blackColors, fontSize: FontSize.s16),
                        ),
                      ],
                    ),
                  ),
                ),

                // Answers
                ...question.answers.asMap().entries.map((entry) {
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
                        color:
                            _selectedAnswers[title]?.contains(answer.id) == true
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
                                  color: blackColors, fontSize: FontSize.s18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        final selectedList = _selectedAnswers[title] ?? [];
                        final questionAnswerIds =
                            question.answers.map((a) => a.id).toList();
                        selectedList.removeWhere(
                            (id) => questionAnswerIds.contains(id));
                        selectedList.add(answer.id);
                        _selectedAnswers[title] = selectedList;
                      });
                    },
                  );
                }),

                const SizedBox(height: 20),

                // Navigation Buttons

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentQuestionIndex > 0)
                        _buildNavButton(
                          "Previous",
                          () {
                            setState(() {
                              _currentQuestionIndex--;
                            });
                          },
                          grey,
                        ),
                      if (!(_currentListeningIndex == items.length - 1 &&
                          _currentQuestionIndex == questions.length - 1))
                        _buildNavButton("Next", () {
                          final selectedIds = _selectedAnswers[title] ?? [];
                          final questionAnswerIds =
                              question.answers.map((a) => a.id).toList();
                          final isAnswered = selectedIds
                              .any((id) => questionAnswerIds.contains(id));

                          if (isAnswered) {
                            setState(() {
                              if (_currentQuestionIndex <
                                  questions.length - 1) {
                                // Move to next question in the same record
                                _currentQuestionIndex++;
                              } else if (_currentListeningIndex <
                                  items.length - 1) {
                                // Move to the next record (reset question index)
                                _currentListeningIndex++;
                                _currentQuestionIndex = 0;
                                // Clear previous answers (optional)
                                _selectedAnswers[title] = [];
                              }
                            });
                          } else {
                            showAwesomeSnackBar(
                              title: "Error",
                              message:
                                  "Please select an answer before continuing.",
                              type: SnackbarType.error,
                            );
                  
                          }
                        }, darkGreen),
                      if (_currentListeningIndex == items.length - 1 &&
                          _currentQuestionIndex == questions.length - 1)
                        GestureDetector(
                          onTap: () async {
                            if (isSubmitting) return; // Prevent multiple taps

                            setState(
                                () => isSubmitting = true); // Start loading

                            try {
                              await viewModel.submitKidsListeningAnswers(
                                applicationId:
                                    viewModel.kidsPtExamModel!.applicationId,
                                answers: _selectedAnswers[title]!,
                                timerInput: elapsedTimeFormatted,
                              );

                              // Only move to Writing stage if submission succeeds
                              setState(() {
                                _currentStage = 'Writing';
                                isSubmitting = false;
                              });
                            } catch (e) {
                              setState(() => isSubmitting =
                                  false); // Stop loading on error

                              showAwesomeSnackBar(
                                title: "Error",
                                message: "Failed to submit: ${e.toString()}",
                                type: SnackbarType.error,
                              );
              
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 35,
                            decoration: BoxDecoration(
                              color: isSubmitting
                                  ? Colors.grey
                                  : primaryColor, // Disable button while loading
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: isSubmitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: whiteColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Submit Answers",
                                      style: getRegularStyle(
                                        color: whiteColor,
                                        fontSize: AppSize.s16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

//
  Widget _buildNavButton(String label, VoidCallback onTap, Color? color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 35,
        decoration: BoxDecoration(
          color: color ?? darkGreen,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            label,
            style: getRegularStyle(color: whiteColor, fontSize: AppSize.s16),
          ),
        ),
      ),
    );
  }

  //

  Widget _buildWritingSection(
    String title,
    List<Writing> writingList,
    ExamViewModel viewModel, {
    String? examType,
  }) {
    if (writingList.isEmpty) {
      return const Center(child: Text("No writing tasks available."));
    }

    final currentWriting = writingList[_currentWritingIndex];
    final answerKey = "${currentWriting.questionId}-answer";

    // Initialize controller if not exists
    if (!_controllers.containsKey(answerKey)) {
      _controllers[answerKey] = TextEditingController();
    }

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

                // Just one TextFormField for the answer
                TextFormField(
                  controller: _controllers[answerKey],
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: "Write your answer here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

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
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                await _sendAllWritingAnswers(
                                    viewModel, writingList);
                                setState(() => _isLoading = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Submit"),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildWritingSection(
  //   String title,
  //   List<Writing> writingList,
  //   ExamViewModel viewModel, {
  //   String? examType,
  // }) {
  //   if (writingList.isEmpty) {
  //     return const Center(child: Text("No writing tasks available."));
  //   }

  //   final currentWriting = writingList[_currentWritingIndex];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Header
  //       RichText(
  //         text: TextSpan(
  //           children: [
  //             TextSpan(
  //               text: '$title (',
  //               style: const TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             TextSpan(
  //               text: 'Task ${_currentWritingIndex + 1}',
  //               style: const TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.green,
  //               ),
  //             ),
  //             TextSpan(
  //               text: '/${writingList.length})',
  //               style: const TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 10),

  //       // Writing Text
  //       Card(
  //         elevation: 4,
  //         margin: const EdgeInsets.symmetric(horizontal: 8),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 currentWriting.text,
  //                 style:
  //                     getBoldStyle(color: primaryColor, fontSize: FontSize.s18),
  //               ),
  //               const SizedBox(height: 10),

  //               // Photo (if available)
  //               if (currentWriting.photo.isNotEmpty)
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Image.network(
  //                     currentWriting.photo,
  //                     fit: BoxFit.cover,
  //                     height: 200,
  //                     width: double.infinity,
  //                   ),
  //                 ),

  //               const SizedBox(height: 20),

  //               // Questions with TextFormField
  //               ...currentWriting.questions.asMap().entries.map((entry) {
  //                 final index = entry.key;
  //                 final question = entry.value;
  //                 // final questionId = question.id.toString();
  //                 final answerKey = "${currentWriting.questionId}-$index";

  //                 // Initialize controller if not exists
  //                 if (!_controllers.containsKey(answerKey)) {
  //                   _controllers[answerKey] = TextEditingController();
  //                 }

  //                 return Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(12),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: dividerColor),
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: Colors.grey.shade50,
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           question.toString(), // Display question text
  //                           style: getRegularStyle(
  //                               color: blackColors, fontSize: FontSize.s16),
  //                         ),
  //                         const SizedBox(height: 8),
  //                         TextFormField(
  //                           controller: _controllers[answerKey],
  //                           maxLines: 4,
  //                           decoration: InputDecoration(
  //                             hintText: "Write your answer here...",
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                             ),
  //                             filled: true,
  //                             fillColor: Colors.white,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               }).toList(),

  //               const SizedBox(height: 20),

  //               // Navigation Button
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   if (_currentWritingIndex < writingList.length - 1)
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           _currentWritingIndex++;
  //                         });
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: primaryColor,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       child: Text(
  //                         "Next",
  //                         style: getMediumStyle(
  //                           color: whiteColor,
  //                         ),
  //                       ),
  //                     )
  //                   else
  //                     ElevatedButton(
  //                       onPressed: _isLoading
  //                           ? null
  //                           : () async {
  //                               setState(() => _isLoading = true);
  //                               await _sendAllWritingAnswers(
  //                                   viewModel, writingList);
  //                               setState(() => _isLoading = false);
  //                             },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: darkGreen,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       child: _isLoading
  //                           ? const SizedBox(
  //                               width: 20,
  //                               height: 20,
  //                               child: CircularProgressIndicator(
  //                                 color: Colors.white,
  //                                 strokeWidth: 2,
  //                               ),
  //                             )
  //                           : const Text("Submit"),
  //                     )
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  bool _isLoading = false;

  Future<void> _sendAllWritingAnswers(
      ExamViewModel viewModel, List<Writing> writingList) async {
    final Map<String, String> answersToSend = {};

    for (final writing in writingList) {
      final questionId = writing.questionId;
      final answerKey = "$questionId-answer"; // Matches your TextFormField key
      final answer = _controllers[answerKey]?.text ?? '';

      if (answer.trim().isNotEmpty) {
        answersToSend[questionId] = answer.trim();
      }

      _controllers[answerKey]?.clear();
    }

    await viewModel.submitKidsWritingAnswers({
      "applicationId": viewModel.kidsPtExamModel!.applicationId,
      "timer_input": elapsedTimeFormatted,
      "answers": answersToSend,
    });

    final finishSuccess = await viewModel.finishKidsPtExam(
      applicationId: viewModel.kidsPtExamModel!.applicationId.toString(),
      timerInput: elapsedTimeFormatted,
    );

    final profileRefresh =
        Provider.of<ProfileViewModel>(context, listen: false);
    await profileRefresh.getProfile();

    if (finishSuccess && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => kidsPtRuselt(
            applicationId: viewModel.kidsPtExamModel!.applicationId,
          ),
        ),
      );
    }
  }

  // Future<void> _sendAllWritingAnswers(
  //     ExamViewModel viewModel, List<Writing> writingList) async {
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

  //   await viewModel.submitKidsWritingAnswers({
  //     "applicationId": viewModel.kidsPtExamModel!.applicationId,
  //     "timer_input":
  //         elapsedTimeFormatted, // Replace with actual timer value if needed
  //     "answers": answersToSend,
  //   });

  //   final finishSuccess = await viewModel.finishKidsPtExam(
  //     applicationId: viewModel.kidsPtExamModel!.applicationId.toString(),
  //     timerInput: elapsedTimeFormatted, // you can make this dynamic
  //   );

  //   final profileRefresh = Provider.of<ProfileViewModel>(context);
  //   final refreshUser = await profileRefresh.getProfile();

  //   if (finishSuccess && context.mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => kidsPtRuselt(
  //           applicationId: viewModel.kidsPtExamModel!.applicationId,
  //         ),
  //       ),
  //     );
  //   }
  // }
}
