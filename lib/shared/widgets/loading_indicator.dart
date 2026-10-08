import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final Color? backgroundColor;
  final Color color;

  const LoadingIndicator({
    Key? key,
    this.backgroundColor,
    required this.color,
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: widget.color,
        backgroundColor: widget.backgroundColor,
      ),
    );
  }
}
