import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endDate;

  const CountdownTimer({super.key, required this.endDate});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDuration();
    });

    _updateDuration();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _updateDuration();
  //   _timer = Timer.periodic(const Duration(seconds: 1), (_) {
  //     _updateDuration();
  //   });
  // }

  void _updateDuration() {
    final now = DateTime.now();
    setState(() {
      _duration = widget.endDate.difference(now);
      if (_duration.isNegative) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_duration.isNegative) return const Text("Offer ended");
    final days = _duration.inDays;
    final hours = _duration.inHours % 24;
    final minutes = _duration.inMinutes % 60;
    final seconds = _duration.inSeconds % 60;

    return Text(
      "انتهى العرض خلال: $days أيام $hours:$minutes:$seconds",
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }
}
