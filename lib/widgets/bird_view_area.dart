import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/bird_anchor_data.dart';
import '../theme/animation.dart';
import 'speech_bubble.dart';

/// Displays the bird and speech bubble.
///
/// The bird column is centered in the space above the sheet at rest, with a gap
/// that shrinks to 4px at max extent. On small screens where centering would
/// leave less than 12px, the gap floors at 12px.
///
/// Uses a [ValueListenableBuilder] to rebuild only the positioning layer when
/// the sheet extent changes during drag, avoiding a full parent rebuild.
class BirdViewArea extends StatelessWidget {
  const BirdViewArea({
    super.key,
    required this.backgroundColor,
    required this.speechBubbleText,
    required this.birdAssetPath,
    this.birdSize = 150,
    required this.sheetExtentNotifier,
    required this.minExtent,
    required this.maxExtent,
    required this.topReserved,
    this.useNewBubblePositioning = false,
  });

  // Approximate height of the bird column (speech bubble + gap + bird container).
  // Must stay in sync with the Column layout in build().
  static const double kBirdColumnHeight = 80 + 4 + 150; // 234
  static const double kMinRestGap = 12.0;
  static const double kMaxExtentGap = 4.0;
  static const double kFadeRange = 40.0;

  final Color backgroundColor;
  final String speechBubbleText;
  final String birdAssetPath;
  final double birdSize;
  final ValueNotifier<double> sheetExtentNotifier;
  final double minExtent;
  final double maxExtent;

  /// Space reserved at the top of the screen (safe area + app bar).
  /// The bird column is centered between this and the sheet top.
  final double topReserved;

  /// When true, positions the speech bubble using per-asset anchor data
  /// so the tail aligns with the bird's mouth.
  final bool useNewBubblePositioning;

  Widget _buildOldLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpeechBubble(text: speechBubbleText),
        const SizedBox(height: 4),
        SizedBox(
          height: 150,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              birdAssetPath,
              width: birdSize,
              height: birdSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewLayout(BirdAnchor anchor) {
    final tailXOffset = (anchor.mouthX - 0.5) * birdSize;
    final bubbleBottom = birdSize * (1 - anchor.safeAreaTopY);

    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bird at bottom center
          Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              birdAssetPath,
              width: birdSize,
              height: birdSize,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bubbleBottom,
            child: SpeechBubble(
              text: speechBubbleText,
              tailXOffset: tailXOffset,
            ),
          ),
          // Speech bubble positioned so tail tip sits at safeAreaTopY
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchor = useNewBubblePositioning ? kBirdAnchors[birdAssetPath] : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        // Center the bird between app bar and sheet, but cap so the bird
        // top stays at least kFadeRange below topReserved (app bar visible).
        final leftover =
            availableHeight * (1 - minExtent) - topReserved - kBirdColumnHeight;
        final maxGap =
            (leftover - kFadeRange).clamp(kMinRestGap, double.infinity);
        final restGap = (leftover / 2).clamp(kMinRestGap, maxGap);

        return Stack(
          children: [
            AnimatedContainer(
              duration: kVibeTransitionDuration,
              curve: kVibeTransitionCurve,
              color: backgroundColor,
            ),
            ValueListenableBuilder<double>(
              valueListenable: sheetExtentNotifier,
              builder: (context, sheetExtent, child) {
                final range = maxExtent - minExtent;
                final t = range > 0
                    ? ((sheetExtent - minExtent) / range).clamp(0.0, 1.0)
                    : 0.0;
                final gap = restGap + (kMaxExtentGap - restGap) * t;
                final bottomOffset = availableHeight * sheetExtent + gap;

                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottomOffset,
                  child: child!,
                );
              },
              child: anchor != null
                  ? _buildNewLayout(anchor)
                  : _buildOldLayout(),
            ),
          ],
        );
      },
    );
  }
}
