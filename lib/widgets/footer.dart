import 'package:flutter/material.dart';

import '../theme/animation.dart';

const _kFooterHorizontalPadding = 24.0;
const _kFooterVerticalPadding = 16.0;
const _kDoneButtonBorderRadius = 24.0;

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
        left: _kFooterHorizontalPadding,
        right: _kFooterHorizontalPadding,
        top: _kFooterVerticalPadding,
        bottom: MediaQuery.paddingOf(context).bottom + _kFooterVerticalPadding,
      ),
      color: backgroundColor,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: _kFooterVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_kDoneButtonBorderRadius),
          ),
          child: const Center(
            child: Text('Done', style: TextStyle(color: Colors.black)),
          ),
        ),
      ),
    );
  }
}
