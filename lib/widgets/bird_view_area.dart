import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'speech_bubble.dart';

/// Displays the bird and speech bubble.
///
/// The bird's feet (bottom of the column) are anchored to the top edge of the
/// draggable sheet. A [parallaxOffset] shifts the bird up as the sheet expands.
class BirdViewArea extends StatelessWidget {
  const BirdViewArea({
    super.key,
    required this.backgroundColor,
    required this.speechBubbleText,
    required this.birdAssetPath,
    this.birdSize = 150,
    this.parallaxOffset = 0,
    this.sheetExtent = 0.38,
  });

  final Color backgroundColor;
  final String speechBubbleText;
  final String birdAssetPath;
  final double birdSize;
  final double parallaxOffset;
  final double sheetExtent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        // Position the column's bottom at the sheet's top edge, shifted by
        // parallax. A small gap (8px) keeps the feet from touching the sheet.
        final bottomOffset =
            availableHeight * sheetExtent + parallaxOffset + 8;

        return Stack(
          children: [
            Container(color: backgroundColor),
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomOffset,
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
