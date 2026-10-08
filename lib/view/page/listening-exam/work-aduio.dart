// //
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

// class AudioPlayerWidget extends StatefulWidget {
//   final String audioUrl;

//   const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

//   @override
//   State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   late AudioPlayer _player;

//   @override
//   void initState() {
//     super.initState();
//     _player = AudioPlayer();
//     _player.setUrl(widget.audioUrl);
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   void _togglePlayPause() async {
//     if (_player.playing) {
//       await _player.pause();
//     } else {
//       await _player.play();
//     }
//   }

//   void _rewind() async {
//     Duration current = _player.position;
//     Duration target = current - const Duration(seconds: 5);
//     await _player.seek(target > Duration.zero ? target : Duration.zero);
//   }

//   void _forward() async {
//     Duration current = _player.position;
//     Duration total = _player.duration ?? Duration.zero;
//     Duration target = current + const Duration(seconds: 5);
//     await _player.seek(target < total ? target : total);
//   }

//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: _player.playerStateStream,
//       builder: (context, snapshot) {
//         final isPlaying = snapshot.data?.playing ?? false;

//         return Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.replay_5),
//               onPressed: _rewind,
//             ),
//             IconButton(
//               icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//               onPressed: _togglePlayPause,
//             ),
//             IconButton(
//               icon: const Icon(Icons.forward_5),
//               onPressed: _forward,
//             ),
//             StreamBuilder<Duration>(
//               stream: _player.positionStream,
//               builder: (context, positionSnapshot) {
//                 final position = positionSnapshot.data ?? Duration.zero;
//                 final duration = _player.duration ?? Duration.zero;

//                 return Text(
//                   "${_formatDuration(position)} / ${_formatDuration(duration)}",
//                   style: const TextStyle(fontSize: 14),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
