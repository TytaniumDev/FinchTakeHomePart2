import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'speech_bubble.dart';

/// Displays the bird and speech bubble.
///
/// The bird's feet (bottom of the column) are anchored to the top edge of the
/// draggable sheet. A parallax offset shifts the bird up as the sheet expands.
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
    required this.screenHeight,
  });

  final Color backgroundColor;
  final String speechBubbleText;
  final String birdAssetPath;
  final double birdSize;
  final ValueNotifier<double> sheetExtentNotifier;
  final double minExtent;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return Stack(
          children: [
            Container(color: backgroundColor),
            ValueListenableBuilder<double>(
              valueListenable: sheetExtentNotifier,
              builder: (context, sheetExtent, child) {
                final dragDelta = sheetExtent - minExtent;
                final parallaxOffset = -dragDelta * screenHeight * 0.3;
                final bottomOffset =
                    availableHeight * sheetExtent + parallaxOffset + 8;

                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottomOffset,
                  child: child!,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    child: SpeechBubble(text: speechBubbleText),
                  ),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
