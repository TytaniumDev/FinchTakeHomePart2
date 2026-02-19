import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/animation.dart';
import 'animated_typed_text.dart';

const _kTailWidth = 16.0;
const _kTailHeight = 10.0;
const _kTailOverlap = 1.0;
const _kBubblePadding = 16.0;
const _kBubbleMargin = 16.0;
const _kBubbleRadius = 16.0;

/// Delay before the typewriter animation starts — gives the theme transition
/// time to settle before text begins revealing.
const _kBubbleTextStartDelay = Duration(milliseconds: 100);

/// A speech bubble with a left-aligned tail (aligned to the text start).
///
/// Uses a [Stack] so the tail positions relative to the bubble body, not
/// the parent width. The tail sits at the left text edge (margin + padding).
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _BubbleBody(text: text),
        Positioned(
          bottom: -(_kTailHeight - _kTailOverlap),
          left: _kBubbleMargin + _kBubblePadding,
          child: _SpeechBubbleTail(),
        ),
      ],
    );
  }
}

/// A speech bubble whose tail aligns with the bird's mouth.
///
/// [mouthX] is a normalized 0–1 fraction where 0.5 = center of the bird.
/// The tail is offset from center by `(mouthX - 0.5) * birdWidth` pixels,
/// and flipped when the mouth is on the right half (mouthX > 0.5).
class MouthAlignedSpeechBubble extends StatelessWidget {
  const MouthAlignedSpeechBubble({
    super.key,
    required this.text,
    required this.mouthX,
    required this.birdWidth,
  });

  final String text;
  final double mouthX;
  final double birdWidth;

  @override
  Widget build(BuildContext context) {
    final tailPixelOffset = (mouthX - 0.5) * birdWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BubbleBody(text: text),
        Transform.translate(
          offset: Offset(tailPixelOffset, -_kTailOverlap),
          child: Transform.flip(
            flipX: mouthX > 0.5,
            child: _SpeechBubbleTail(),
          ),
        ),
      ],
    );
  }
}

/// Shared bubble container: white rounded box with animated text.
class _BubbleBody extends StatelessWidget {
  const _BubbleBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kBubblePadding),
      margin: const EdgeInsets.symmetric(horizontal: _kBubbleMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kBubbleRadius),
      ),
      child: AnimatedSize(
        duration: kVibeTransitionDuration,
        curve: kVibeTransitionCurve,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        child: AnimatedTypedText(
          text: text,
          startDelay: _kBubbleTextStartDelay,
        ),
      ),
    );
  }
}

class _SpeechBubbleTail extends StatelessWidget {
  const _SpeechBubbleTail();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/speech-bubble-tail.svg',
      width: _kTailWidth,
      height: _kTailHeight,
    );
  }
}
