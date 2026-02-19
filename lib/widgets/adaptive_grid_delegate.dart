import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// A sliver grid delegate that computes tile height to guarantee
/// [targetVisibleRows] fit in the available cross-axis extent.
///
/// On small screens the tiles shrink so that at least 1 full row + a peek of
/// the next row are visible at [VibePickerSheet.kMinExtent]. On large screens,
/// tiles are capped at [maxTileHeight] so they never grow beyond the original
/// design size.
class SliverGridDelegateWithAdaptiveHeight extends SliverGridDelegate {
  SliverGridDelegateWithAdaptiveHeight({
    required this.availableGridHeight,
    this.crossAxisCount = kDefaultCrossAxisCount,
    this.mainAxisSpacing = kDefaultMainAxisSpacing,
    this.crossAxisSpacing = kDefaultCrossAxisSpacing,
    this.targetVisibleRows = kDefaultTargetVisibleRows,
    this.maxTileHeight = kDefaultMaxTileHeight,
    this.minTileHeight = kDefaultMinTileHeight,
  });

  static const double kDefaultMaxTileHeight = 128;
  static const double kDefaultMainAxisSpacing = 8;
  static const int kDefaultCrossAxisCount = 3;
  static const double kDefaultCrossAxisSpacing = 8.0;

  /// 1 full row + 40% peek of the next row.
  static const double kDefaultTargetVisibleRows = 1.4;

  /// Minimum tile height — prevents content overflow on very small screens.
  static const double kDefaultMinTileHeight = 84.0;

  /// Default icon size at full tile height (used by [scaledIconSize]).
  static const double kDefaultBaseIconSize = 64.0;

  /// Minimum icon size regardless of scale (prevents icons from becoming unusable).
  static const double kDefaultMinIconSize = 48.0;

  /// The height available for the grid at min extent (worst case).
  final double availableGridHeight;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// How many rows (including partial) should be visible.
  /// 1.4 = 1 full row + 40% peek of row 2.
  final double targetVisibleRows;

  /// Tiles never exceed this height (the original design size).
  final double maxTileHeight;

  /// Tiles never shrink below this height (prevents content overflow).
  final double minTileHeight;

  static const double _minMainAxisSpacing = 2;

  /// Tile height and spacing, computed once on first access.
  ///
  /// Safe to cache because all inputs are final.
  late final ({double tileHeight, double spacing}) _metrics = _computeMetrics();

  ({double tileHeight, double spacing}) _computeMetrics() {
    final numGaps = targetVisibleRows.ceil() - 1;

    // 1. Try with full spacing — if tiles fit at max, no scaling needed.
    final fullGaps = numGaps * mainAxisSpacing;
    final tileAtFullSpacing =
        (availableGridHeight - fullGaps) / targetVisibleRows;

    if (tileAtFullSpacing >= maxTileHeight) {
      return (tileHeight: maxTileHeight, spacing: mainAxisSpacing);
    }

    // 2. Try with min spacing — see if tiles fit without shrinking.
    final minGaps = numGaps * _minMainAxisSpacing;
    final tileAtMinSpacing =
        (availableGridHeight - minGaps) / targetVisibleRows;

    if (tileAtMinSpacing >= maxTileHeight) {
      // Tiles fit at max; use just enough spacing to fill the rest.
      final leftover = availableGridHeight - targetVisibleRows * maxTileHeight;
      final spacing = numGaps > 0
          ? (leftover / numGaps).clamp(_minMainAxisSpacing, mainAxisSpacing)
          : mainAxisSpacing;
      return (tileHeight: maxTileHeight, spacing: spacing);
    }

    // 3. Spacing is at minimum — now shrink tiles.
    final tileHeight = tileAtMinSpacing.clamp(minTileHeight, maxTileHeight);
    return (tileHeight: tileHeight, spacing: _minMainAxisSpacing);
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final m = _metrics;
    final usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final tileWidth = usableCrossAxisExtent / crossAxisCount;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: m.tileHeight + m.spacing,
      crossAxisStride: tileWidth + crossAxisSpacing,
      childMainAxisExtent: m.tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  /// The ratio of the computed tile height to [maxTileHeight], clamped 0–1.
  /// Use this to proportionally scale padding, spacing, etc. inside tiles.
  double get scaleFactor => _metrics.tileHeight / maxTileHeight;

  /// Returns the icon size scaled proportionally to tile height.
  /// Base: [kDefaultBaseIconSize] at [kDefaultMaxTileHeight]. Floored at [minIconSize].
  double scaledIconSize({
    double baseIconSize = kDefaultBaseIconSize,
    double minIconSize = kDefaultMinIconSize,
  }) {
    return math.max(baseIconSize * scaleFactor, minIconSize);
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithAdaptiveHeight oldDelegate) {
    return oldDelegate.availableGridHeight != availableGridHeight ||
        oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.targetVisibleRows != targetVisibleRows ||
        oldDelegate.maxTileHeight != maxTileHeight ||
        oldDelegate.minTileHeight != minTileHeight;
  }
}
