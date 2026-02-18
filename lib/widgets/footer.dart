import 'package:flutter/material.dart';

import '../theme/animation.dart';

/// Footer bar with the "Done" / "Upgrade to send" button.
class Footer extends StatelessWidget {
  const Footer({super.key, required this.backgroundColor, this.onTap});

  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kVibeTransitionDuration,
      curve: kVibeTransitionCurve,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      color: backgroundColor,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text('Done', style: TextStyle(color: Colors.black)),
          ),
        ),
      ),
    );
  }
}
