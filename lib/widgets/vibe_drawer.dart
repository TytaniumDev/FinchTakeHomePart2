import 'package:flutter/material.dart';

import '../models/vibe_data.dart';

/// A single vibe option tile showing an icon and label.
class VibeOptionTile extends StatelessWidget {
  const VibeOptionTile({
    super.key,
    required this.vibe,
    required this.isSelected,
    required this.onTap,
  });

  final VibeOption vibe;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
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
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(vibe.icon, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
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
