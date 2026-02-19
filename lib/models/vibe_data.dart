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
  const VibeOption({required this.label, required this.type});

  final String label;
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
    required this.backgroundAssetPath,
    required this.skyColor,
    required this.iconAssetPath,
  });

  /// Y coordinate of the ground line in the background SVG (viewBox 0 0 375 812).
  static const double kGroundLineY = 428.0;

  final Color drawerBackground;
  final Color footerBackground;
  final Color birdAreaBackground;
  final String speechBubbleText;
  final String birdAssetPrefix;
  final String backgroundAssetPath;
  final Color skyColor;
  final String iconAssetPath;

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
    backgroundAssetPath: 'assets/books.svg',
    skyColor: VibeColors.magicSkyColor,
    iconAssetPath: 'assets/open_book.svg',
  );

  static const newYears = VibeTheme._(
    drawerBackground: VibeColors.newYearsDrawerBackground,
    footerBackground: VibeColors.newYearsFooterBackground,
    birdAreaBackground: VibeColors.newYearsBirdAreaBackground,
    speechBubbleText: "Let's end the year with kindness!",
    birdAssetPrefix: 'bird-pose-celebrate-confetti',
    backgroundAssetPath: 'assets/balloon.svg',
    skyColor: VibeColors.newYearsSkyColor,
    iconAssetPath: 'assets/party_popper.svg',
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
const List<VibeOption> kDefaultVibes = [
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
  VibeOption(label: 'Magic', type: VibeType.magic),
  VibeOption(label: 'New Years', type: VibeType.newYears),
];
