import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/animation.dart';
import 'animated_typed_text.dart';

/// A speech bubble with a tail, displaying [text].
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text, this.tailXOffset = -25});

  final String text;
  final double tailXOffset;

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
          child: AnimatedSize(
            duration: kVibeTransitionDuration,
            curve: kVibeTransitionCurve,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            child: AnimatedTypedText(
              text: text,
              startDelay: const Duration(milliseconds: 100),
            ),
          ),
        ),
        // Tail pointing down toward the bird
        Transform.translate(
          offset: Offset(tailXOffset, -1),
          child: Transform.flip(
            flipX: tailXOffset > 0.5,
            child: SvgPicture.asset(
              'assets/speech-bubble-tail.svg',
              width: 16,
              height: 10,
            ),
          ),
        ),
      ],
    );
  }
}
