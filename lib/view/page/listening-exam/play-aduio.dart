// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:flutter/material.dart';

// import 'dart:io';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class WhatsAppAudioRecorder extends StatefulWidget {
//   @override
//   State<WhatsAppAudioRecorder> createState() => _WhatsAppAudioRecorderState();
// }

// class _WhatsAppAudioRecorderState extends State<WhatsAppAudioRecorder> {
//   late RecorderController _recorderController;
//   late PlayerController _playerController;
//   final AudioPlayer _player = AudioPlayer();

//   bool _isRecording = false;
//   bool _isPlaying = false;
//   String? _recordedFilePath;

//   @override
//   void initState() {
//     super.initState();
//     _recorderController = RecorderController();
//     _playerController = PlayerController();
//   }

//   Future<void> _startRecording() async {
//     // var status = await Permission.microphone.request();
//     // if (status != PermissionStatus.granted) {
//     //   ScaffoldMessenger.of(context).(
//     //     SnackBar(content: Text("Microphone permission required")),
//     //   );
//     //   return;
//     // }

//     Directory tempDir = await getTemporaryDirectory();
//     String path = "${tempDir.path}/whatsapp_record.aac";

//     await _recorderController.record(path: path);
//     setState(() {
//       _isRecording = true;
//       _recordedFilePath = path;
//     });
//   }

//   Future<void> _stopRecording() async {
//     await _recorderController.stop(false);
//     setState(() {
//       _isRecording = false;
//     });
//   }

//   Future<void> _playAudio() async {
//     if (_recordedFilePath == null) return;

//     await _playerController.preparePlayer(
//       path: _recordedFilePath!,
//       shouldExtractWaveform: true, // Extracts waveform automatically
//     );

//     await _player.setFilePath(_recordedFilePath!);
//     _player.play();

//     setState(() => _isPlaying = true);

//     _player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         setState(() => _isPlaying = false);
//       }
//     });
//   }

//   void _stopAudio() async {
//     await _player.stop();
//     setState(() => _isPlaying = false);
//   }

//   void _deleteRecording() {
//     if (_recordedFilePath != null) {
//       File(_recordedFilePath!).deleteSync();
//       setState(() {
//         _recordedFilePath = null;
//         _isPlaying = false;
//       });
//     }
//   }

//   void _rewind() async {
//     final newPosition = _player.position - Duration(seconds: 5);
//     await _player
//         .seek(newPosition < Duration.zero ? Duration.zero : newPosition);
//   }

//   void _forward() async {
//     final duration = _player.duration ?? Duration.zero;
//     final newPosition = _player.position + Duration(seconds: 5);
//     await _player.seek(newPosition > duration ? duration : newPosition);
//   }

//   @override
//   void dispose() {
//     _recorderController.dispose();
//     _playerController.dispose();
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("WhatsApp Audio Recorder")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_isRecording)
//               AudioWaveforms(
//                 size: Size(MediaQuery.of(context).size.width, 50),
//                 recorderController: _recorderController,
//                 waveStyle: WaveStyle(
//                   waveColor: Colors.green,
//                   extendWaveform: true,
//                   showMiddleLine: false,
//                 ),
//               ),
//             if (_recordedFilePath != null && !_isRecording)
//               AudioFileWaveforms(
//                 size: Size(MediaQuery.of(context).size.width, 50),
//                 playerController: _playerController,
//                 playerWaveStyle: PlayerWaveStyle(
//                   fixedWaveColor: Colors.green,
//                   liveWaveColor: Colors.greenAccent,
//                 ),
//               ),
//             SizedBox(height: 40),
//             GestureDetector(
//               onLongPress: _startRecording,
//               onLongPressUp: _stopRecording,
//               child: Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _isRecording ? Colors.red : Colors.green,
//                 ),
//                 child: Icon(
//                   Icons.mic,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             if (_recordedFilePath != null && !_isRecording)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: _deleteRecording,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.replay_5, color: Colors.blue),
//                     onPressed: _rewind,
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       _isPlaying ? Icons.stop : Icons.play_arrow,
//                       size: 30,
//                       color: Colors.green,
//                     ),
//                     onPressed: _isPlaying ? _stopAudio : _playAudio,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.forward_5, color: Colors.blue),
//                     onPressed: _forward,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
