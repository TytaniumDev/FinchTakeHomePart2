import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/vibe_data.dart';
import '../theme/animation.dart';

// Visual constants for VibeOptionTile.
const _kTileBorderRadius = 16.0;

/// Fraction of the circle diameter used for the icon (icon = 50% of circle).
const _kIconSizeRatio = 0.5;

/// Background opacity applied to the tile container when selected.
const _kSelectedBackgroundOpacity = 0.2;

/// Fraction of white mixed into the base color for unselected tile circles
/// (subtle lighten so dark theme colors remain legible).
const _kThemeColorWhiteMix = 0.05;

// Precomputed selected-state background color (white at kSelectedBackgroundOpacity).
const _kSelectedBackgroundColor = Color.fromRGBO(
  255,
  255,
  255,
  _kSelectedBackgroundOpacity,
);

/// A single vibe option tile showing an icon and label.
class VibeOptionTile extends StatelessWidget {
  const VibeOptionTile({
    super.key,
    required this.vibe,
    required this.isSelected,
    required this.onTap,
    this.iconSize = 64,
    this.scale = 1.0,
  });

  final VibeOption vibe;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final baseColor = VibeTheme.fromType(vibe.type).birdAreaBackground;
    final themeColor = Color.lerp(
      baseColor,
      Colors.white,
      _kThemeColorWhiteMix,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: kVibeTransitionDuration,
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: isSelected ? _kSelectedBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(_kTileBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: kVibeTransitionDuration,
              curve: Curves.easeInOut,
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : themeColor,
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  VibeTheme.fromType(vibe.type).iconAssetPath,
                  width: iconSize * _kIconSizeRatio,
                  height: iconSize * _kIconSizeRatio,
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              vibe.label,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
