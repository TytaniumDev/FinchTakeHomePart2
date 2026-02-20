import 'package:flutter/material.dart';

import '../theme/animation.dart';

const _kFooterHorizontalPadding = 24.0;
const _kFooterVerticalPadding = 16.0;
const _kDoneButtonBorderRadius = 14.0;

/// Footer bar with the "Done" button.
class Footer extends StatelessWidget {
  const Footer({super.key, required this.backgroundColor, this.onTap});

  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kVibeTransitionDuration,
      curve: kStandardCurve,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: _kFooterHorizontalPadding,
        right: _kFooterHorizontalPadding,
        top: _kFooterVerticalPadding,
        bottom: MediaQuery.paddingOf(context).bottom + _kFooterVerticalPadding,
      ),
      color: backgroundColor,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kDoneButtonBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_kDoneButtonBorderRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: _kFooterVerticalPadding,
            ),
            child: const Center(
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
