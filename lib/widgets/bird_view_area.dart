import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/bird_anchor_data.dart';
import '../models/vibe_data.dart';
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
    required this.backgroundAssetPath,
    required this.skyColor,
  });

  static const double kBirdContainerHeight = 150.0;

  // Background SVG viewBox size (must match the SVG asset's viewBox attribute).
  static const double _kSvgDesignWidth = 375.0;
  static const double _kSvgDesignHeight = 812.0;

  // Component heights that compose kBirdColumnHeight.
  // Must stay in sync with the Column layout in _buildOldLayout().
  static const double _kSpeechBubbleHeight = 80.0;
  static const double _kBubbleGap = 4.0;

  /// Approximate height of the bird column (speech bubble + gap + bird container).
  static const double kBirdColumnHeight =
      _kSpeechBubbleHeight + _kBubbleGap + kBirdContainerHeight; // 234

  static const double kMinRestGap = 12.0;
  static const double kMaxExtentGap = 4.0;
  static const double kFadeRange = 40.0;

  /// Horizontal margin applied to the bird column (left and right).
  static const double kBirdHorizontalPadding = 16.0;

  /// Computes the rest gap (space between app bar and bird column at min extent).
  /// Used by both BirdViewArea and the app bar fade in VibeSelectionScreen.
  static double computeRestGap({
    required double availableHeight,
    required double minExtent,
    required double topReserved,
  }) {
    final leftover =
        availableHeight * (1 - minExtent) - topReserved - kBirdColumnHeight;
    final maxGap = (leftover - kFadeRange).clamp(kMinRestGap, double.infinity);
    return (leftover / 2).clamp(kMinRestGap, maxGap);
  }

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

  final String backgroundAssetPath;
  final Color skyColor;

  Widget _buildOldLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpeechBubble(text: speechBubbleText),
        const SizedBox(height: _kBubbleGap),
        SizedBox(
          height: kBirdContainerHeight,
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
    final bubbleBottom = birdSize * (1 - anchor.safeAreaTopY);

    return SizedBox(
      height: kBirdContainerHeight,
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
          // Speech bubble positioned so tail tip sits at safeAreaTopY
          Positioned(
            left: 0,
            right: 0,
            bottom: bubbleBottom,
            child: MouthAlignedSpeechBubble(
              text: speechBubbleText,
              mouthX: anchor.mouthX,
              birdWidth: birdSize,
            ),
          ),
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
        final screenWidth = constraints.maxWidth;
        final restGap = computeRestGap(
          availableHeight: availableHeight,
          minExtent: minExtent,
          topReserved: topReserved,
        );

        // SVG scaling: fit width, compute rendered height and ground offset.
        final scale = screenWidth / _kSvgDesignWidth;
        final svgRenderedHeight = _kSvgDesignHeight * scale;
        final groundFromSvgTop = VibeTheme.kGroundLineY * scale;

        // Pre-build SVG widget (doesn't rebuild during drag).
        final svgWidget = AnimatedSwitcher(
          duration: kVibeTransitionDuration,
          child: SvgPicture.asset(
            backgroundAssetPath,
            key: ValueKey(backgroundAssetPath),
            fit: BoxFit.fill,
            width: screenWidth,
            height: svgRenderedHeight,
          ),
        );

        // Pre-build bird column (doesn't rebuild during drag).
        final birdWidget = anchor != null
            ? _buildNewLayout(anchor)
            : _buildOldLayout();

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Sky color fills gap above SVG.
            AnimatedContainer(
              duration: kVibeTransitionDuration,
              curve: kVibeTransitionCurve,
              color: skyColor,
            ),
            // SVG background + bird, both repositioned on each drag frame.
            ValueListenableBuilder<double>(
              valueListenable: sheetExtentNotifier,
              builder: (context, sheetExtent, _) {
                // Bird positioning math (UNCHANGED).
                final range = maxExtent - minExtent;
                final t = range > 0
                    ? ((sheetExtent - minExtent) / range).clamp(0.0, 1.0)
                    : 0.0;
                final gap = restGap + (kMaxExtentGap - restGap) * t;
                final bottomOffset = availableHeight * sheetExtent + gap;

                // SVG ground anchored to bird feet.
                final birdFeetFromTop = availableHeight - bottomOffset;
                final svgTop = birdFeetFromTop - groundFromSvgTop;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: svgTop,
                      left: 0,
                      right: 0,
                      height: svgRenderedHeight,
                      child: svgWidget,
                    ),
                    Positioned(
                      left: kBirdHorizontalPadding,
                      right: kBirdHorizontalPadding,
                      bottom: bottomOffset,
                      child: birdWidget,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
