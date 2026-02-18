import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
import '../theme/animation.dart';

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
    final themeColor = Color.lerp(baseColor, Colors.white, 0.05);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: kVibeTransitionDuration,
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(255, 255, 255, 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
                child: Icon(
                  vibe.icon,
                  color: isSelected ? themeColor : Colors.white,
                  size: iconSize * 0.5,
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
