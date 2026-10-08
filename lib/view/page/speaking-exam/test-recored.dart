import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/adult-result/adult-result.dart';
import 'package:hatvest/view/page/survey-page/exam_survey_page.dart';
import 'package:hatvest/view/page/listening-exam/chat-list/chou.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/viewmodel/adult-pt-viewmodel.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';

class AudioRecorderPlayerGruop extends StatefulWidget {
  final int questionId;
  final int applicationId;

  const AudioRecorderPlayerGruop({
    super.key,
    required this.questionId,
    required this.applicationId,
  });

  @override
  _AudioRecorderPlayerGruopState createState() =>
      _AudioRecorderPlayerGruopState();
}

class _AudioRecorderPlayerGruopState extends State<AudioRecorderPlayerGruop> {
  final AudioRecorder _recorder = AudioRecorder();
  String? _audioPath;
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  bool isRecording = false;

  late ExamViewModel _audioViewModel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareRecorder();
  }

  Future<void> _prepareRecorder() async {
    debugPrint("🔊 Preparing recorder...");
    await _configureAudioSession();

    // على iOS هنسيب الـ record هو اللي يطلب الإذن
    if (Platform.isAndroid) {
      await _ensureMicPermissionAndroid();
    }
  }

  // ✅ permission_handler للـ ANDROID فقط
  Future<bool> _ensureMicPermissionAndroid() async {
    final status = await Permission.microphone.status;
    debugPrint("🎤 Android mic permission status: $status");

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      debugPrint("🎤 Android mic permission result: $result");
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Microphone Permission Required"),
            content: const Text(
              "Please enable microphone access from Settings to record your answer.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioViewModel = Provider.of<ExamViewModel>(context);
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: AndroidAudioAttributes(
          usage: AndroidAudioUsage.voiceCommunication,
          contentType: AndroidAudioContentType.speech,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    debugPrint("✅ Audio session configured");
  }

  Future<void> _startRecording() async {
    try {
      debugPrint("▶️ Start recording pressed");

      if (Platform.isAndroid) {
        final allowed = await _ensureMicPermissionAndroid();
        if (!allowed) {
          debugPrint("❌ Android mic permission denied");
          return;
        }
      }

      // 🔹 هنا على iOS / Android: record هو اللي هيطلب الإذن لو أول مرة
      final hasPerm = await _recorder.hasPermission();
      debugPrint("🎤 Recorder hasPermission = $hasPerm");

      if (!hasPerm) {
        if (Platform.isIOS) {
          // غالبًا مفيش NSMicrophoneUsageDescription أو محتاج إعادة تثبيت
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "يرجى تفعيل صلاحية الميكروفون من إعدادات الجهاز (Settings > Privacy > Microphone).",
              ),
            ),
          );
        }
        return;
      }

      if (await _recorder.isRecording()) {
        debugPrint("ℹ️ Already recording, stopping first...");
        await _recorder.stop();
      }

      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (dir == null) {
        debugPrint("❌ Storage directory not found");
        return;
      }

      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      debugPrint("📁 Will record to: $path");

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _audioPath = path;
        isRecording = true;
      });

      debugPrint("✅ Recording started");
    } catch (e, s) {
      debugPrint("❌ Recording error: $e");
      debugPrint("$s");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final isRec = await _recorder.isRecording();
      debugPrint("⏹ Stop recording pressed. isRecording = $isRec");

      if (!isRec) {
        debugPrint("ℹ️ No active recording to stop");
        return;
      }

      final path = await _recorder.stop();
      debugPrint("✅ Recorder stopped, path = $path");

      if (path != null) {
        setState(() {
          _audioPath = path;
          isRecording = false;
        });

        await _initializePlayer(path);
      }
    } catch (e) {
      debugPrint("❌ Error stopping recording: $e");
    }
  }

  Future<void> _initializePlayer(String path) async {
    try {
      _videoController = VideoPlayerController.file(File(path));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowPlaybackSpeedChanging: false,
        allowMuting: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.green,
          handleColor: Colors.greenAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
        customControls:
            const SizedBox(height: 60, child: CustomAudioControls()),
      );
      setState(() {});
      debugPrint("🎧 Player initialized");
    } catch (e) {
      debugPrint("❌ Error initializing player: $e");
    }
  }

  void _deleteRecording() {
    if (_audioPath != null) {
      try {
        File(_audioPath!).deleteSync();
      } catch (_) {}
      _audioPath = null;
    }
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    setState(() {});
  }

  @override
  void dispose() {
    _recorder.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isRecording ? Colors.red : Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
            ),
            child: IconButton(
              onPressed: isRecording ? _stopRecording : _startRecording,
              icon: Icon(isRecording ? Icons.pause : Icons.mic_none),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_audioPath != null &&
            _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized)
          // ... باقي الكود زي ما هو لعرض الـ player ورفع الملف
          Column(
            children: [
              Container(
                height: 60,
                color: grey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                    IconButton(
                      onPressed: _deleteRecording,
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // زر الرفع ... (زي كودك بالظبط)
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_audioPath != null) {
                          setState(() => _isLoading = true);

                          final file = File(_audioPath!);
                          final viewModel = context.read<ExamQuizViewModel>();
                          final profileRefresh = Provider.of<ProfileViewModel>(
                              context,
                              listen: false);

                          final uploadSuccess = await viewModel.uploadAudio(
                            file: file,
                            questionId: widget.questionId,
                            // duration: widget.duration,
                            applicationId: widget.applicationId,
                          );

                          if (uploadSuccess && context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => ExamSurveyPage(
                                  studentExamId: widget.applicationId,
                                  applicationId: widget.applicationId,
                                ),
                              ),
                            );
                          } else {
                            showAwesomeSnackBar(
                              title: "Error",
                              message: "Upload failed",
                              type: SnackbarType.error,
                            );
                          }

                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label:
                    _isLoading ? const Text("Sending...") : const Text("Send"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              )
            ],
          ),
      ],
    );
  }
}

// class AudioRecorderPlayerGruop extends StatefulWidget {
//   final int questionId;
//   final int applicationId;

//   const AudioRecorderPlayerGruop({
//     super.key,
//     required this.questionId,
//     required this.applicationId,
//   });

//   @override
//   _AudioRecorderPlayerGruopState createState() =>
//       _AudioRecorderPlayerGruopState();
// }

// class _AudioRecorderPlayerGruopState extends State<AudioRecorderPlayerGruop> {
//   final AudioRecorder _recorder = AudioRecorder();
//   String? _audioPath;
//   ChewieController? _chewieController;
//   VideoPlayerController? _videoController;

//   bool isRecording = false;

//   late ExamViewModel _audioViewModel;
//   bool _isLoading = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _audioViewModel = Provider.of<ExamViewModel>(context);
//   }

//   Future<void> _startRecording() async {
//     try {
//       final micStatus = await Permission.microphone.request();

//       if (!micStatus.isGranted) {
//         print("Microphone permission not granted");
//         return;
//       }

//       // تأكد أن التسجيل غير نشط قبل البدء
//       if (await _recorder.isRecording()) {
//         await _recorder.stop();
//       }

//       final encoder = Platform.isIOS ? AudioEncoder.aacLc : AudioEncoder.aacHe;
//       final dir = await getApplicationDocumentsDirectory();
//       final path =
//           '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
//       await _recorder.start(
//         RecordConfig(
//           encoder: encoder,
//           bitRate: 128000,
//           sampleRate: 44100,
//         ),
//         path: path,
//       );

//       setState(() {
//         _audioPath = path;
//         isRecording = true;
//       });

//       print("Recording started: $path");
//     } catch (e) {
//       print("Error starting recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final isRec = await _recorder.isRecording();
//       if (!isRec) {
//         print("No active recording to stop");
//         return;
//       }

//       final path = await _recorder.stop();

//       if (path != null) {
//         setState(() {
//           _audioPath = path;
//           isRecording = false;
//         });

//         print("Recording saved: $path");
//         await _initializePlayer(path);
//       }
//     } catch (e) {
//       print("Error stopping recording: $e");
//     }
//   }

//   Future<void> _initializePlayer(String path) async {
//     _videoController = VideoPlayerController.file(File(path));
//     await _videoController!.initialize();
//     _chewieController = ChewieController(
//       videoPlayerController: _videoController!,
//       autoPlay: false,
//       looping: false,
//       allowPlaybackSpeedChanging: false,
//       allowMuting: false,
//       materialProgressColors: ChewieProgressColors(
//         playedColor: Colors.green,
//         handleColor: Colors.greenAccent,
//         backgroundColor: Colors.grey,
//         bufferedColor: Colors.lightGreen,
//       ),
//       customControls: const SizedBox(height: 60, child: CustomAudioControls()),
//     );
//     setState(() {});
//   }

//   void _deleteRecording() {
//     if (_audioPath != null) {
//       File(_audioPath!).deleteSync();
//       _audioPath = null;
//     }
//     _chewieController?.dispose();
//     _videoController?.dispose();
//     _chewieController = null;
//     _videoController = null;
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     _recorder.dispose();
//     _chewieController?.dispose();
//     _videoController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Center(
//           child: Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: isRecording ? Colors.red : Colors.green,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 5,
//                   spreadRadius: 1,
//                 )
//               ],
//             ),
//             child: IconButton(
//               onPressed: isRecording ? _stopRecording : _startRecording,
//               icon: isRecording ? Icon(Icons.pause) : Icon(Icons.mic_none),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         if (_audioPath != null &&
//             _chewieController != null &&
//             _chewieController!.videoPlayerController.value.isInitialized)
//           Column(
//             children: [
//               Container(
//                 height: 60,
//                 color: grey,
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: AspectRatio(
//                         aspectRatio: _videoController!.value.aspectRatio,
//                         child: Chewie(controller: _chewieController!),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: _deleteRecording,
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton.icon(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         if (_audioPath != null) {
//                           setState(() => _isLoading = true);

//                           final file = File(_audioPath!);
//                           final viewModel = context.read<ExamQuizViewModel>();
//                           final profileRefresh = Provider.of<ProfileViewModel>(
//                               context,
//                               listen: false);

//                           final uploadSuccess = await viewModel.uploadAudio(
//                             file: file,
//                             questionId: widget.questionId,
//                             // duration: widget.duration,
//                             applicationId: widget.applicationId,
//                           );

//                           if (uploadSuccess && context.mounted) {
//                             Navigator.of(context).pushReplacement(
//                               MaterialPageRoute(
//                                 builder: (_) => SurveyPage(
//                                   applicationId: widget.questionId,
//                                 ),
//                               ),
//                             );
//                           } else {
//                             showAwesomeSnackBar(
//                               title: "Error",
//                               message: "Upload failed",
//                               type: SnackbarType.error,
//                             );
//                           }

//                           if (mounted) setState(() => _isLoading = false);
//                         }
//                       },
//                 icon: _isLoading
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Icon(Icons.upload),
//                 label:
//                     _isLoading ? const Text("Sending...") : const Text("Send"),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               )
//             ],
//           ),
//       ],
//     );
//   }
// }
