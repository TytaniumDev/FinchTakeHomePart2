import 'package:flutter/material.dart';

import '../models/vibe_data.dart';

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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(vibe.icon, color: Colors.grey, size: iconSize * 0.5)),
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
