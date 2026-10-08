// // import 'package:audioplayers/audioplayers.dart' show UrlSource;
// // import 'package:flutter/material.dart';
// // import 'package:hatvest/model/adult-pt-model.dart';
// // import 'package:hatvest/viewmodel/adult-pt-viewmodel.dart';
// // import 'package:hatvest/viewmodel/app-viewmodel.dart';
// // import 'package:just_audio/just_audio.dart' show AudioPlayer;
// // import 'package:provider/provider.dart';

// // class LearningScreen extends StatefulWidget {
// //   const LearningScreen({
// //     super.key,
// //   });

// //   @override
// //   State<LearningScreen> createState() => _LearningScreenState();
// // }

// // class _LearningScreenState extends State<LearningScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     final viewModel = Provider.of<ExamViewModel>(context, listen: false);
// //     viewModel.loadExam(1);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final viewModel = Provider.of<ExamViewModel>(context);
// //     final data = viewModel.welcome;

// //     // Show loading indicator while fetching data
// //     if (viewModel.isLoading || data == null) {
// //       return const Scaffold(
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     return DefaultTabController(
// //       length: 5,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Learning'),
// //           bottom: const TabBar(
// //             isScrollable: true,
// //             tabs: [
// //               Tab(text: 'Vocab'),
// //               Tab(text: 'Grammar'),
// //               Tab(text: 'Reading'),
// //               Tab(text: 'Listening'),
// //               Tab(text: 'Writing'),
// //             ],
// //           ),
// //         ),
// //         body: TabBarView(
// //           children: [
// //             _buildQAPage(data.vocab),
// //             _buildQAPage(data.grammer),
// //             _buildReadingPage(data.reading),
// //             _buildListeningPage(data.listening),
// //             _buildWritingPage(data.writing),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildQAPage(List<Grammer> list) {
// //     return PageView.builder(
// //       itemCount: list.length,
// //       itemBuilder: (context, index) {
// //         final q = list[index];
// //         return Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(q.questionText,
// //                   style: const TextStyle(
// //                       fontSize: 18, fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 16),
// //               ...q.answers.map((a) => Text("- ${a.answer}")),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildReadingPage(List<Reading> readingList) {
// //     return ListView.builder(
// //       itemCount: readingList.length,
// //       itemBuilder: (context, index) {
// //         final reading = readingList[index];
// //         return Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(reading.paragraph,
// //                   style: const TextStyle(
// //                       fontSize: 16, fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 16),
// //               SizedBox(
// //                 height: 300,
// //                 child: _buildQAPage(reading.questions),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// // Widget _buildListeningPage(List<Ing> listeningList) {
// //   return ListView.builder(
// //     itemCount: listeningList.length,
// //     itemBuilder: (context, index) {
// //       final l = listeningList[index];

// //       return Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               "Audio: ${l.text}",
// //               style: const TextStyle(fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),

// //             // Play / Pause Button
// //             if (l.record != null && l.record!.isNotEmpty)
// //               Consumer<ExamViewModel>(
// //                 builder: (context, viewModel, _) {
// //                   return Row(
// //                     children: [
// //                       IconButton(
// //                         icon: Icon(
// //                           viewModel.isPlaying
// //                               ? Icons.pause_circle_filled
// //                               : Icons.play_circle_fill,
// //                           size: 48,
// //                           color: Colors.blue,
// //                         ),
// //                         onPressed: () {
// //                           if (viewModel.isPlaying) {
// //                             viewModel.pauseAudio();
// //                           } else {
// //                             viewModel.playAudio(l.record!);
// //                           }
// //                         },
// //                       ),
// //                     ],
// //                   );
// //                 },
// //               )
// //             else
// //               const Text("No audio available",
// //                   style: TextStyle(color: Colors.grey)),

// //             const SizedBox(height: 16),

// //             // Questions (if any)
// //             ...l.questions.map((q) => Text("- $q")).toList(),
// //           ],
// //         ),
// //       );
// //     },
// //   );
// // }

// //   Widget _buildWritingPage(List<Ing> writingList) {
// //     return ListView.builder(
// //       itemCount: writingList.length,
// //       itemBuilder: (context, index) {
// //         final w = writingList[index];
// //         return Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(w.text, style: const TextStyle(fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 8),
// //               TextField(
// //                 maxLines: 5,
// //                 decoration: const InputDecoration(
// //                   border: OutlineInputBorder(),
// //                   hintText: 'Write your answer here...',
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               ElevatedButton(onPressed: () {}, child: const Text("Submit"))
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // // Replace LoginModelResponse with actual data fetching logic
// // // and navigate to LearningScreen(data: yourData) to use it.

// import 'package:flutter/material.dart';
// import 'package:hatvest/model/grammar-model.dart';
// import 'package:hatvest/model/listening-model.dart';
// import 'package:hatvest/model/peaking-model.dart';
// import 'package:hatvest/model/reading-model.dart';
// import 'package:hatvest/model/vocab-model.dart';
// import 'package:hatvest/model/writing-model.dart';
// import 'package:hatvest/viewmodel/adult-pt-viewmodel.dart';
// import 'package:provider/provider.dart';

// // Import your models

// class QuestionsPage extends StatefulWidget {
//   const QuestionsPage({
//     super.key,
//   });

//   @override
//   State<QuestionsPage> createState() => _QuestionsPageState();
// }

// class _QuestionsPageState extends State<QuestionsPage> {
//   @override
//   void initState() {
//     super.initState();
//     final viewModel = Provider.of<ExamViewModel>(context, listen: false);
//     viewModel.loadQuestions(1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ExamViewModel>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Questions Overview")),
//       body: ListView(
//         padding: const EdgeInsets.all(12),
//         children: [
//           _buildSection(
//               "🟣 Vocabulary", viewModel.vocab.map(_buildVocabItem).toList()),
//           _buildSection(
//               "🔵 Grammar", viewModel.grammar.map(_buildGrammarItem).toList()),
//           _buildSection(
//               "🟢 Reading", viewModel.reading.map(_buildReadingItem).toList()),
//           _buildSection("🟠 Listening",
//               viewModel.listening.map(_buildListeningItem).toList()),
//           _buildSection(
//               "🟤 Writing", viewModel.writing.map(_buildWritingItem).toList()),
//           _buildSection("🔴 Speaking",
//               viewModel.speaking.map(_buildSpeakingItem).toList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection(String title, List<Widget> items) {
//     return ExpansionTile(
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//       children: items.isEmpty
//           ? [const Padding(padding: EdgeInsets.all(8), child: Text("No data"))]
//           : items,
//     );
//   }

//   // Render each type:
//   Widget _buildVocabItem(VocabResponse item) {
//     if (item.vocab.isEmpty) return const ListTile(title: Text("No vocab data"));
//     return ListTile(
//       title: Text(item.vocab.first.questionText),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children:
//             item.vocab.first.answers.map((a) => Text("• ${a.answer}")).toList(),
//       ),
//     );
//   }

//   Widget _buildGrammarItem(GrammarResponse item) {
//     return ListTile(
//       title: Text(item.grammar.first.questionText),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: item.grammar.first.answers
//             .map((a) => Text("• ${a.answer}"))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildReadingItem(ReadingResponse item) {
//     return ListTile(
//       title: Text("Paragraph:"),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(item.reading.first.paragraph),
//           const SizedBox(height: 8),
//           ...item.reading.first.questions.map((q) => Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Q: ${q.questionText}"),
//                   ...q.answers.map((a) => Text("• ${a.answer}")),
//                 ],
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildListeningItem(ListeningResponse item) {
//     return ListTile(
//       title: Text(item.listening.first.text),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Audio: ${item.listening.first.record}"),
//           ...item.listening.first.questions.map((q) => Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Q: ${q.questionText}"),
//                   ...q.answers.map((a) => Text("• ${a.answer}")),
//                 ],
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildWritingItem(WritingResponse item) {
//     return ListTile(
//       title: Text(item.writing.first.text),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (item.writing.first.photo.isNotEmpty)
//             Image.network(item.writing.first.photo,
//                 height: 120, width: double.infinity, fit: BoxFit.cover),
//           ...item.writing.first.questions.map((q) => Text("• $q")),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeakingItem(SpeakingQuestionModel item) {
//     return ListTile(
//       title: Text(item.text),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: item.questions.map((q) => Text("• $q")).toList(),
//       ),
//     );
//   }
// }
