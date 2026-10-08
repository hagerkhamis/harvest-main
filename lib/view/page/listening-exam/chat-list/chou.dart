import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:video_player/video_player.dart';

class CustomAudioControls extends StatefulWidget {
  const CustomAudioControls({super.key});

  @override
  State<CustomAudioControls> createState() => _CustomAudioControlsState();
}

class _CustomAudioControlsState extends State<CustomAudioControls> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chewieController = ChewieController.of(context);
    _controller = _chewieController.videoPlayerController;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final position = value.position;
        final duration = value.duration;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          color: grey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  value.isPlaying ? _controller.pause() : _controller.play();
                },
              ),
              Expanded(
                child: Slider(
                  value: position.inMilliseconds
                      .toDouble()
                      .clamp(0.0, duration.inMilliseconds.toDouble()),
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                ),
              ),
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
