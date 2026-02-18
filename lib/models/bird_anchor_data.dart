/// Anchor points for positioning the speech bubble relative to a bird SVG.
class BirdAnchor {
  const BirdAnchor({
    required this.mouthX,
    required this.mouthY,
    required this.safeAreaTopY,
  });

  /// Horizontal mouth position, 0-1 left-to-right within the bird box.
  final double mouthX;

  /// Vertical mouth position, 0-1 top-to-bottom (used for debug overlay).
  final double mouthY;

  /// Vertical position for the bubble bottom anchor, 0-1 top-to-bottom.
  /// The speech bubble tail tip sits at this Y coordinate.
  final double safeAreaTopY;
}

/// Per-asset anchor data, keyed by the full asset path string returned
/// by [VibeTheme.birdAssetPath].
const Map<String, BirdAnchor> kBirdAnchors = {
  'assets/bird-pose-smart-book_ADULT.svg': BirdAnchor(
    mouthX: 0.6166,
    mouthY: 0.4269,
    safeAreaTopY: 0.3125,
  ),
  'assets/bird-pose-smart-book_BABY.svg': BirdAnchor(
    mouthX: 0.6196,
    mouthY: 0.4372,
    safeAreaTopY: 0.3139,
  ),
  'assets/bird-pose-celebrate-confetti_ADULT.svg': BirdAnchor(
    mouthX: 0.3848,
    mouthY: 0.3389,
    safeAreaTopY: 0.2831,
  ),
  'assets/bird-pose-celebrate-confetti_BABY.svg': BirdAnchor(
    mouthX: 0.3804,
    mouthY: 0.3491,
    safeAreaTopY: 0.2714,
  ),
};
