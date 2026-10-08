// screens/exam_answer_page.dart
import 'package:flutter/material.dart';
import 'package:hatvest/enums/credit_card_type.dart' show SectionType;
import 'package:hatvest/model/exam-aswer-model.dart' show AnswerBg, Grammar;
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';

import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart' show ExamQuizViewModel;
import 'package:provider/provider.dart';

class ExamAnswerPage extends StatelessWidget {
  final int studentExamId;

  const ExamAnswerPage({required this.studentExamId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamQuizViewModel()..fetchAnswers(studentExamId),
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: dividerColor,
          automaticallyImplyLeading: false,
          title: Text(
            "اجابات الاختبار",
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
              icon: Icon(
                Icons.arrow_forward,
                color: blackColors,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Consumer<ExamQuizViewModel>(
              builder: (context, vm, _) {
                if (vm.examAnswer == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: SectionType.values.map((section) {
                          final selected = vm.selectedSection == section;
                          return GestureDetector(
                            onTap: () => vm.selectSection(section),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? darkGreen : whiteColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(section.name,
                                    style: getMediumStyle(
                                      color:
                                          selected ? whiteColor : blackColors,
                                    )),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // const Divider(),

                    // Section Content
                    Expanded(
                      child: _buildSectionContent(vm),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(ExamQuizViewModel vm) {
    switch (vm.selectedSection) {
      case SectionType.Vocabulary:
        return Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            children: [
              _buildGrammarList(vm.examAnswer!.vocabulary),
            ],
          ),
        );
      case SectionType.Grammar:
        return Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            children: [
              _buildGrammarList(vm.examAnswer!.grammar),
            ],
          ),
        );
      case SectionType.Listening:
        return Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            children: vm.examAnswer!.listening.map((item) {
              return _buildGrammarList(item.questions);
            }).toList(),
          ),
        );
      case SectionType.Reading:
        return Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            children: vm.examAnswer!.reading.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: ExpandableText(
                          text: item.paragraph,
                          trimLines: 3,
                          style: getMediumStyle(
                            color: blackColors,
                            fontSize: FontSize.s18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildGrammarList(item.questions),
                ],
              );
            }).toList(),
          ),
        );
      case SectionType.Writing:
        return Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            children: vm.examAnswer!.writing.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.text,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...item.answers.map((ans) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (ans.answer ?? "")
                                .replaceAll("<br/>", "\n")
                                .replaceAll("\\n", "\n")
                                .trim(),
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      )),
                ],
              );
            }).toList(),
          ),
        );
    }
  }

  Widget _buildGrammarList(List<Grammar> list) {
    return Column(
      children: list.asMap().entries.map((entry) {
        int questionIndex = entry.key;
        Grammar question = entry.value;

        return Card(
          margin: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text with "Q1 -"
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Q${questionIndex + 1} - ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        TextSpan(
                          text: question.questionText,
                          style: getMediumStyle(color: blackColors),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Answers displayed vertically with "1-", "2-", etc.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: question.answers.asMap().entries.map((ansEntry) {
                      int answerIndex = ansEntry.key;
                      var ans = ansEntry.value;

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getAnswerColor(ans.answerBg),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${answerIndex + 1}- ${ans.answer}',
                          style: getMediumStyle(
                            color: _getAnswerTextColor(ans.answerBg),
                            fontSize: FontSize.s18,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getAnswerColor(AnswerBg bg) {
    switch (bg) {
      case AnswerBg.GREEN:
        return darkGreen;
      case AnswerBg.RED:
        return discountRed;
      case AnswerBg.NON:
        return moreBoldWhite;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getAnswerTextColor(AnswerBg bg) {
    switch (bg) {
      case AnswerBg.GREEN:
        return whiteColor;
      case AnswerBg.RED:
        return whiteColor;
      case AnswerBg.NON:
        return blackColors;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getAnswerNumColor(AnswerBg bg) {
    switch (bg) {
      case AnswerBg.GREEN:
        return whiteColor;
      case AnswerBg.RED:
        return whiteColor;
      case AnswerBg.NON:
        return lighttGreen;
      default:
        return Colors.grey.shade200;
    }
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.trimLines = 4,
    this.style,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  late String firstHalf;
  late String secondHalf;
  bool hasOverflow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final span = TextSpan(text: widget.text, style: widget.style);
      final tp = TextPainter(
        text: span,
        maxLines: widget.trimLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: MediaQuery.of(context).size.width - 40);

      setState(() {
        hasOverflow = tp.didExceedMaxLines;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasOverflow)
          TextButton(
            onPressed: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? "عرض أقل" : "عرض المزيد",
              style: getMediumStyle(
                color: blackColors,
              ),
            ),
          ),
        Text(
          widget.text,
          style: widget.style,
          maxLines: isExpanded ? null : widget.trimLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
