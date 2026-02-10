import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/colors.dart';

void main() {
  runApp(
    DevicePreview(enabled: true, builder: (context) => const VibesScreen()),
  );
}

class VibesScreen extends StatelessWidget {
  const VibesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finch UI Exercise',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.rubikTextTheme()
            .apply(bodyColor: Colors.black, displayColor: Colors.black)
            .copyWith(
              bodyMedium: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
      home: const VibeSelectionScreen(),
    );
  }
}

class VibeSelectionScreen extends StatefulWidget {
  const VibeSelectionScreen({super.key});

  @override
  State<VibeSelectionScreen> createState() => _VibeSelectionScreenState();
}

enum VibeType { magic, newYears }

enum BirdAge { baby, adult }

class _VibeSelectionScreenState extends State<VibeSelectionScreen> {
  int? _selectedVibeIndex;
  BirdAge _birdAge = BirdAge.adult;

  VibeType _getVibeType(int index) {
    return index.isEven ? VibeType.magic : VibeType.newYears;
  }

  Color get _drawerBackgroundColor {
    if (_selectedVibeIndex == null) {
      return VibeColors.magicDrawerBackground;
    }
    return _getVibeType(_selectedVibeIndex!) == VibeType.magic
        ? VibeColors.magicDrawerBackground
        : VibeColors.newYearsDrawerBackground;
  }

  Color get _footerBackgroundColor {
    if (_selectedVibeIndex == null) {
      return VibeColors.magicFooterBackground;
    }
    return _getVibeType(_selectedVibeIndex!) == VibeType.magic
        ? VibeColors.magicFooterBackground
        : VibeColors.newYearsFooterBackground;
  }

  Color get _birdAreaBackgroundColor {
    // Candidate todo: this should be updated to replace the bird area background image
    if (_selectedVibeIndex == null) {
      return VibeColors.magicBirdAreaBackground;
    }
    return _getVibeType(_selectedVibeIndex!) == VibeType.magic
        ? VibeColors.magicBirdAreaBackground
        : VibeColors.newYearsBirdAreaBackground;
  }

  String get _speechBubbleText {
    if (_selectedVibeIndex != null &&
        _getVibeType(_selectedVibeIndex!) == VibeType.newYears) {
      return "Let's end the year with kindness!";
    }
    return 'Your heart holds so many bright pages,\ncheep!';
  }

  String get _birdAssetPath {
    final ageSuffix = _birdAge == BirdAge.adult ? 'ADULT' : 'BABY';
    if (_selectedVibeIndex != null &&
        _getVibeType(_selectedVibeIndex!) == VibeType.newYears) {
      return 'assets/bird-pose-celebrate-confetti_$ageSuffix.svg';
    }
    return 'assets/bird-pose-smart-book_$ageSuffix.svg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildBirdViewArea(context),
                      const SizedBox(height: 400),
                    ],
                  ),
                  Positioned(
                    top: 450 - 24,
                    left: 0,
                    right: 0,
                    child: _buildVibeDrawer(context),
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildBirdViewArea(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 450,
      color: _birdAreaBackgroundColor,
      child: Stack(
        children: [
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () {
                // Handle close
              },
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black26),
            ),
          ),
          // Bird age toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: _buildBirdAgeToggle(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_speechBubbleText),
                ),
                // Bird SVG
                SvgPicture.asset(
                  _birdAssetPath,
                  width: _birdAge == BirdAge.adult ? 150 : 112.5,
                  height: _birdAge == BirdAge.adult ? 150 : 112.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeDrawer(BuildContext context) {
    final vibes = [
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
      ('Magic', Icons.auto_stories),
      ('New Years', Icons.celebration),
      ('Magic', Icons.auto_stories),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _drawerBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          for (int row = 0; row < 5; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildVibeOption(
                    row * 3 + col,
                    vibes[row * 3 + col].$1,
                    vibes[row * 3 + col].$2,
                  ),
              ],
            ),
            if (row < 4) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildVibeOption(int index, String label, IconData icon) {
    final isSelected = _selectedVibeIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedVibeIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(255, 255, 255, 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBirdAgeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _birdAge = BirdAge.baby;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _birdAge == BirdAge.baby
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'BABY',
                style: TextStyle(
                  color: _birdAge == BirdAge.baby ? Colors.black : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _birdAge = BirdAge.adult;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _birdAge == BirdAge.adult
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ADULT',
                style: TextStyle(
                  color: _birdAge == BirdAge.adult
                      ? Colors.black
                      : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      color: _footerBackgroundColor,
      child: GestureDetector(
        onTap: () {
          // Handle done
        },
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
