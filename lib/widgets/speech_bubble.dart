import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/animation.dart';
import 'animated_typed_text.dart';

/// A speech bubble with a tail, displaying [text].
///
/// [mouthX] is a normalized 0–1 fraction where 0.5 = center of the bird.
/// When provided with [birdWidth], the tail is offset from center by
/// `(mouthX - 0.5) * birdWidth` pixels, and flipped when the mouth is
/// on the right half (mouthX > 0.5).
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.text,
    this.mouthX = 0.33,
    this.birdWidth = 0,
  });

  final String text;

  /// Normalized 0–1 horizontal mouth position (0.5 = center).
  final double mouthX;

  /// Width of the bird SVG, used to compute the pixel offset for the tail.
  /// When 0, the tail sits at center with no offset.
  final double birdWidth;

  @override
  Widget build(BuildContext context) {
    final tailPixelOffset = (mouthX - 0.5) * birdWidth;

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
        // Tail pointing down toward the bird.
        // -1px closes the subpixel gap between bubble and tail.
        Transform.translate(
          offset: Offset(tailPixelOffset, -1),
          child: Transform.flip(
            flipX: mouthX > 0.5,
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
