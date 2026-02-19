import 'package:flutter/material.dart';

import '../theme/colors.dart';

enum VibeType { magic, newYears }

enum BirdAge {
  baby,
  adult;

  static const double kAdultSize = 150.0;
  static const double kBabySize = 112.5;

  double get size => this == BirdAge.adult ? kAdultSize : kBabySize;
}

/// A single selectable vibe option shown in the drawer grid.
class VibeOption {
  const VibeOption({
    required this.label,
    required this.icon,
    required this.type,
  });

  final String label;
  final IconData icon;
  final VibeType type;
}

/// Resolves theme colors, text, and asset paths for a given [VibeType].
class VibeTheme {
  const VibeTheme._({
    required this.drawerBackground,
    required this.footerBackground,
    required this.birdAreaBackground,
    required this.speechBubbleText,
    required this.birdAssetPrefix,
  });

  final Color drawerBackground;
  final Color footerBackground;
  final Color birdAreaBackground;
  final String speechBubbleText;
  final String birdAssetPrefix;

  /// Returns the bird SVG asset path for the given [age].
  String birdAssetPath(BirdAge age) {
    final ageSuffix = age == BirdAge.adult ? 'ADULT' : 'BABY';
    return 'assets/${birdAssetPrefix}_$ageSuffix.svg';
  }

  static const magic = VibeTheme._(
    drawerBackground: VibeColors.magicDrawerBackground,
    footerBackground: VibeColors.magicFooterBackground,
    birdAreaBackground: VibeColors.magicBirdAreaBackground,
    speechBubbleText: 'Your heart holds so many bright pages,\ncheep!',
    birdAssetPrefix: 'bird-pose-smart-book',
  );

  static const newYears = VibeTheme._(
    drawerBackground: VibeColors.newYearsDrawerBackground,
    footerBackground: VibeColors.newYearsFooterBackground,
    birdAreaBackground: VibeColors.newYearsBirdAreaBackground,
    speechBubbleText: "Let's end the year with kindness!",
    birdAssetPrefix: 'bird-pose-celebrate-confetti',
  );

  /// Resolves the theme for a given [vibeType].
  static VibeTheme fromType(VibeType type) {
    switch (type) {
      case VibeType.magic:
        return magic;
      case VibeType.newYears:
        return newYears;
    }
  }
}

/// The default list of vibe options shown in the drawer.
// TODO: Replace placeholder labels/icons with actual vibe data and integrate
// the unused SVG assets (balloon.svg, books.svg, open_book.svg, party_popper.svg).
const List<VibeOption> kDefaultVibes = [
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
  VibeOption(label: 'Magic', icon: Icons.auto_stories, type: VibeType.magic),
  VibeOption(
    label: 'New Years',
    icon: Icons.celebration,
    type: VibeType.newYears,
  ),
];
