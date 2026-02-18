import 'dart:async';

import 'package:flutter/material.dart';

/// Reveals [text] character by character with a typewriter effect.
class AnimatedTypedText extends StatefulWidget {
  const AnimatedTypedText({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 30),
    this.startDelay = Duration.zero,
    this.style,
  });

  final String text;
  final Duration charDelay;
  final Duration startDelay;
  final TextStyle? style;

  @override
  State<AnimatedTypedText> createState() => _AnimatedTypedTextState();
}

class _AnimatedTypedTextState extends State<AnimatedTypedText> {
  Timer? _timer;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(AnimatedTypedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer?.cancel();
    _charCount = 0;
    if (widget.startDelay > Duration.zero) {
      _timer = Timer(widget.startDelay, () {
        _timer = Timer.periodic(widget.charDelay, _onTick);
      });
    } else {
      _timer = Timer.periodic(widget.charDelay, _onTick);
    }
  }

  void _onTick(Timer timer) {
    if (_charCount >= widget.text.length) {
      timer.cancel();
      return;
    }
    setState(() => _charCount++);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible full text reserves the final size immediately.
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Text(widget.text, style: widget.style),
        ),
        Text(widget.text.substring(0, _charCount), style: widget.style),
      ],
    );
  }
}
