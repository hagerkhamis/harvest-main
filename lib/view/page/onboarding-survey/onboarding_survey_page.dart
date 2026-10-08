import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/constants/api_constant.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';

class OnboardingSurveyPage extends StatefulWidget {
  const OnboardingSurveyPage({super.key});

  @override
  State<OnboardingSurveyPage> createState() => _OnboardingSurveyPageState();
}

class _OnboardingSurveyPageState extends State<OnboardingSurveyPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Answers
  String? _mainGoal;
  String? _currentLevel;
  String? _interestedLanguage;
  String? _heardAboutUs;
  String? _preferredLearningMethod;
  String? _preferredSessionTime;

  final List<_SurveyQuestion> _questions = [
    _SurveyQuestion(
      key: 'main_goal',
      question: 'What is your main goal?',
      questionAr: 'ما هو هدفك الرئيسي؟',
      options: ['Learning', 'Improving skills', 'Exam preparation'],
    ),
    _SurveyQuestion(
      key: 'current_level',
      question: 'Which level are you currently at?',
      questionAr: 'ما مستواك الحالي؟',
      options: ['Beginner', 'Intermediate', 'Advanced'],
    ),
    _SurveyQuestion(
      key: 'interested_language',
      question: 'What language or courses are you interested in?',
      questionAr: 'ما اللغة أو الكورسات التي تهتم بها؟',
      options: ['English', 'Dutch'],
    ),
    _SurveyQuestion(
      key: 'heard_about_us',
      question: 'How did you hear about us?',
      questionAr: 'كيف سمعت عنا؟',
      options: ['Social media', 'Friend referral', 'Advertisement', 'Other'],
    ),
    _SurveyQuestion(
      key: 'preferred_learning_method',
      question: 'What is your preferred learning method?',
      questionAr: 'ما طريقة التعلم المفضلة لديك؟',
      options: ['Online', 'In-person', 'Both'],
    ),
    _SurveyQuestion(
      key: 'preferred_session_time',
      question: 'What time suits you best for sessions?',
      questionAr: 'ما الوقت المناسب لك للجلسات؟',
      options: ['Morning', 'Evening'],
    ),
  ];

  String? _currentAnswer() {
    switch (_currentStep) {
      case 0: return _mainGoal;
      case 1: return _currentLevel;
      case 2: return _interestedLanguage;
      case 3: return _heardAboutUs;
      case 4: return _preferredLearningMethod;
      case 5: return _preferredSessionTime;
      default: return null;
    }
  }

  void _setAnswer(String value) {
    setState(() {
      switch (_currentStep) {
        case 0: _mainGoal = value; break;
        case 1: _currentLevel = value; break;
        case 2: _interestedLanguage = value; break;
        case 3: _heardAboutUs = value; break;
        case 4: _preferredLearningMethod = value; break;
        case 5: _preferredSessionTime = value; break;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final dio = dioClient;
      await dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.surveyOnboarding}",
        data: {
          "main_goal": _mainGoal,
          "current_level": _currentLevel,
          "interested_language": _interestedLanguage,
          "heard_about_us": _heardAboutUs,
          "preferred_learning_method": _preferredLearningMethod,
          "preferred_session_time": _preferredSessionTime,
        },
        options: Options(headers: {'requiresToken': true}),
      );
      showAwesomeSnackBar(
        title: "تم!",
        message: "شكراً على إجاباتك",
        type: SnackbarType.success,
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "حدث خطأ، حاول مرة أخرى",
        type: SnackbarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentStep];
    final answer = _currentAnswer();
    final isLast = _currentStep == _questions.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Step ${_currentStep + 1} of ${_questions.length}",
                        style: getMediumStyle(color: grey, fontSize: FontSize.s12),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        child: Text("survey_skip".tr(), style: getMediumStyle(color: grey, fontSize: FontSize.s12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _questions.length,
                      backgroundColor: Colors.grey.shade200,
                      color: primaryColor,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Survey",
                      style: getBoldStyle(color: primaryColor, fontSize: FontSize.s22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.question,
                      style: getBoldStyle(color: blackColors, fontSize: FontSize.s18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.questionAr,
                      style: getMediumStyle(color: grey, fontSize: FontSize.s14),
                    ),
                    const SizedBox(height: 24),
                    ...question.options.map((option) {
                      final isSelected = answer == option;
                      return GestureDetector(
                        onTap: () => _setAnswer(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? primaryColor : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  color: isSelected ? primaryColor : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option,
                                style: isSelected
                                    ? getBoldStyle(color: primaryColor, fontSize: FontSize.s15)
                                    : getMediumStyle(color: blackColors, fontSize: FontSize.s15),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const Spacer(),
                    Text(
                      "Help us understand your needs better",
                      style: getMediumStyle(color: grey, fontSize: FontSize.s12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: GestureDetector(
                onTap: answer == null ? null : () {
                  if (isLast) {
                    _submit();
                  } else {
                    setState(() => _currentStep++);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: answer == null ? Colors.grey.shade300 : primaryColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: answer != null
                        ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            isLast ? "إرسال" : "التالي",
                            style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurveyQuestion {
  final String key;
  final String question;
  final String questionAr;
  final List<String> options;

  const _SurveyQuestion({
    required this.key,
    required this.question,
    required this.questionAr,
    required this.options,
  });
}
