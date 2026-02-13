import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A speech bubble with a tail, displaying [text].
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(text),
        ),
        // Tail pointing down toward the bird
        SvgPicture.asset(
          'assets/speech-bubble-tail.svg',
          width: 16,
          height: 8,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ],
    );
  }
}
