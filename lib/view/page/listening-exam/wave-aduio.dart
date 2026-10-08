// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// class WhatsAppAudioBubble extends StatefulWidget {
//   final String audioUrl;

//   const WhatsAppAudioBubble({Key? key, required this.audioUrl}) : super(key: key);

//   @override
//   State<WhatsAppAudioBubble> createState() => _WhatsAppAudioBubbleState();
// }

// class _WhatsAppAudioBubbleState extends State<WhatsAppAudioBubble> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final PlayerController _waveformController = PlayerController();
//   bool _isPlaying = false;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;
//   String? _localPath;

//   @override
//   void initState() {
//     super.initState();
//     _downloadAndPrepare();
//   }

//   Future<void> _downloadAndPrepare() async {
//     try {
//       final uri = Uri.parse(widget.audioUrl);
//       final response = await http.get(uri);

//       final tempDir = await getTemporaryDirectory();
//       final fileName = basename(uri.path);
//       final file = File('${tempDir.path}/$fileName');
//       await file.writeAsBytes(response.bodyBytes);

//       _localPath = file.path;

//       await _audioPlayer.setFilePath(_localPath!);

//       await _waveformController.preparePlayer(
//         path: _localPath!,
//         shouldExtractWaveform: true,
//       );

//       _audioPlayer.positionStream.listen((pos) {
//         setState(() => _position = pos);
//       });

//       _audioPlayer.playerStateStream.listen((state) {
//         if (state.processingState == ProcessingState.completed) {
//           setState(() {
//             _isPlaying = false;
//             _position = Duration.zero;
//           });
//           _audioPlayer.seek(Duration.zero);
//           _waveformController.stopPlayer();
//         }
//       });

//       _duration = _audioPlayer.duration ?? Duration.zero;
//     } catch (e) {
//       print('Audio init failed: $e');
//     }
//   }

//   void _togglePlayPause() async {
//     if (_isPlaying) {
//       await _audioPlayer.pause();
//       await _waveformController.stopPlayer();
//     } else {
//       await _audioPlayer.play();
//       await _waveformController.startPlayer();
//     }
//     setState(() => _isPlaying = !_isPlaying);
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _waveformController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _localPath == null
//         ? const Center(child: CircularProgressIndicator())
//         : Container(
//             margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: _togglePlayPause,
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.green,
//                     child: Icon(
//                       _isPlaying ? Icons.pause : Icons.play_arrow,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: AudioFileWaveforms(
//                     playerController: _waveformController,
//                     size: const Size(double.infinity, 40),
//                     enableSeekGesture: true,
//                     waveformType: WaveformType.fitWidth,
//                     playerWaveStyle: const PlayerWaveStyle(
//                       fixedWaveColor: Colors.grey,
//                       liveWaveColor: Colors.green,
//                       showSeekLine: true,
//                       seekLineThickness: 2,
//                       spacing: 4,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _formatDuration(_duration - _position),
//                   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           );
//   }
// }
