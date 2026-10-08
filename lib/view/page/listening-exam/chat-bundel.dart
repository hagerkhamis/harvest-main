import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class ChatBundel extends StatelessWidget {
  const ChatBundel(
      {super.key,
      required this.text,
      required this.isSender,
      required this.isLast});

  final String text;
  final bool isSender;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSender) const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSender ? Color(0xFF276bfd) : Color(0xFF343145),
                ),
                padding: EdgeInsets.only(
                  bottom: 9,
                  top: 8,
                  left: 14,
                  right: 12,
                ),
                child: Text(
                  text,
                  style: getMediumStyle(
                    color: whiteColor,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class WaveBubbel extends StatefulWidget {
  const WaveBubbel({
    super.key,
    this.isSender = false,
    this.index,
    this.path,
    this.width,
    required this.appDirectory,
  });
  final bool isSender;
  final int? index;
  final String? path;
  final double? width;
  final Directory appDirectory;

  @override
  State<WaveBubbel> createState() => _WaveBubbelState();
}

class _WaveBubbelState extends State<WaveBubbel> {
  File? file;
  late PlayerController controller;

  late StreamSubscription<PlayerState> playerStateSubscription;

  @override
  void initState() {
    // TODO: implement initState
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
    super.initState();
  }

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,

    // showSeekLine: false,
    // // waveColor: Colors.green,
    // seekLineColor: Colors.red,
  );
  void _preparePlayer() async {
    if (widget.index != null) {
      file = File("${widget.appDirectory.path} /${widget.index}.mp3");
      await file?.writeAsBytes(
        (await rootBundle.load("assets/audios/audio${widget.index}.mp3"))
            .buffer
            .asUint8List(),
      );
      if (widget.index == null && widget.path == null && file?.path == null) {
        return;
      }
    }
    controller.preparePlayer(
      path: widget.path ?? file!.path,
      shouldExtractWaveform: widget.index?.isEven ?? true,
    );

    if (widget.index!.isOdd ?? false) {
      controller
          .extractWaveformData(
              path: widget.path ?? file!.path,
              noOfSamples:
                  playerWaveStyle.getSamplesForWidth(widget.width ?? 200))
          .then(
            (wavefromData) => debugPrint(
              wavefromData.toString(),
            ),
          );
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return widget.path != null || file?.path != null ??
  //   Align(
  //     alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
  //     child: Container(),
  //     ) : SizedBox.shrink();
  // }

  @override
  Widget build(BuildContext context) {
    return (widget.path != null || (file?.path != null))
        ? Align(
            alignment:
                widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(
                left: 40.0,
                bottom: 6,
                top: 6,
                right: widget.isSender ? 0 : 10,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.isSender ? Color(0xFF276bfd) : Color(0xFF343145),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.playerState.isStopped)
                    IconButton(
                      onPressed: () async {
                        if (controller.playerState.isPlaying) {
                          await controller.pausePlayer();
                        } else {
                          controller
                              .setFinishMode(); // set loop mode if available
                          await controller.startPlayer();
                        }
                      },
                      // onPressed: () async {
                      //   controller.playerState.isPlaying
                      //       ? await controller.pausePlayer()
                      //       : await controller.startPlayer(
                      //           forceRefresh: FinishMode.loop);
                      // },
                      icon: Icon(
                        controller.playerState.isPlaying
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                      color: whiteColor,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  AudioFileWaveforms(
                    size: Size(MediaQuery.of(context).size.width / 1.3, 70),
                    playerController: controller,
                    waveformType: widget.index?.isOdd ?? false
                        ? WaveformType.fitWidth
                        : WaveformType.long,
                    playerWaveStyle: playerWaveStyle,
                  ),
                  if (widget.isSender)
                    SizedBox(
                      width: 10,
                    ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
