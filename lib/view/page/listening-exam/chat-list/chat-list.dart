import 'package:flutter/material.dart';
import 'package:hatvest/view/page/listening-exam/chat-list/chou.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VoiceAudio extends StatefulWidget {
  final String audioUrl;

  const VoiceAudio({super.key, required this.audioUrl});

  @override
  State<VoiceAudio> createState() => _VoiceAudioState();
}

class _VoiceAudioState extends State<VoiceAudio> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.audioUrl));

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      showControls: true,
      customControls: const CustomAudioControls(),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: 16 / 2, // slim layout for audio
      child: Chewie(controller: _chewieController!),
    );
  }
}
