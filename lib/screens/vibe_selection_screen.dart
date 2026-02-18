import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
import '../widgets/bird_view_area.dart';
import '../widgets/vibe_picker_sheet.dart';

class VibeSelectionScreen extends StatefulWidget {
  const VibeSelectionScreen({super.key});

  @override
  State<VibeSelectionScreen> createState() => _VibeSelectionScreenState();
}

class _VibeSelectionScreenState extends State<VibeSelectionScreen> {
  int? _selectedVibeIndex;
  BirdAge _birdAge = BirdAge.adult;
  bool _useNewBubblePositioning = false;

  // Sheet extent driven by a ValueNotifier so only BirdViewArea rebuilds
  // during drag, not the entire screen.
  final _sheetExtentNotifier = ValueNotifier<double>(0.38);

  // Cached values — recomputed only when screen metrics change.
  double _computedMinExtent = 0.38;
  double _computedMaxExtent = 0.65;
  double _computedTargetRows = 1.4;

  VibeTheme get _theme {
    if (_selectedVibeIndex == null) return VibeTheme.magic;
    return VibeTheme.fromType(kDefaultVibes[_selectedVibeIndex!].type);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final padding = MediaQuery.paddingOf(context);
    final result = VibePickerSheet.computeMinExtent(
      screenHeight: screenHeight,
      safeAreaBottom: padding.bottom,
    );
    _computedMinExtent = result.extent;
    _computedTargetRows = result.targetRows;
    _computedMaxExtent = VibePickerSheet.computeMaxExtent(
      screenHeight: screenHeight,
      safeAreaTop: padding.top,
      minExtent: _computedMinExtent,
    );
    _sheetExtentNotifier.value = _computedMinExtent;
  }

  @override
  void dispose() {
    _sheetExtentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final birdSize = _birdAge == BirdAge.adult ? 150.0 : 112.5;

    // Pre-compute values for the proximity-based app bar fade.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final safeAreaTop = MediaQuery.paddingOf(context).top;
    // App bar: SafeArea(top) + 8px padding + 48px IconButton + 8px padding.
    final appBarBottom = safeAreaTop + 64;
    // Mirror BirdViewArea's restGap: center, but cap for app bar visibility.
    final leftover = screenHeight * (1 - _computedMinExtent) -
        appBarBottom -
        BirdViewArea.kBirdColumnHeight;
    final maxGap = (leftover - BirdViewArea.kFadeRange)
        .clamp(BirdViewArea.kMinRestGap, double.infinity);
    final restGap =
        (leftover / 2).clamp(BirdViewArea.kMinRestGap, maxGap);

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen bird area (behind everything).
          // Uses ValueListenableBuilder internally so only the bird
          // position rebuilds during sheet drag — not the whole screen.
          Positioned.fill(
            child: BirdViewArea(
              backgroundColor: theme.birdAreaBackground,
              speechBubbleText: theme.speechBubbleText,
              birdAssetPath: theme.birdAssetPath(_birdAge),
              birdSize: birdSize,
              sheetExtentNotifier: _sheetExtentNotifier,
              minExtent: _computedMinExtent,
              maxExtent: _computedMaxExtent,
              topReserved: appBarBottom,
              useNewBubblePositioning: _useNewBubblePositioning,
            ),
          ),

          // Draggable bottom sheet with vibe picker + footer
          VibePickerSheet(
            vibes: kDefaultVibes,
            selectedIndex: _selectedVibeIndex,
            onSelected: (index) {
              setState(() => _selectedVibeIndex = index);
            },
            drawerBackground: theme.drawerBackground,
            footerBackground: theme.footerBackground,
            minExtent: _computedMinExtent,
            maxExtent: _computedMaxExtent,
            targetRows: _computedTargetRows,
            onExtentChanged: (extent) {
              _sheetExtentNotifier.value = extent;
            },
            onDone: () {
              setState(
                () =>
                    _useNewBubblePositioning = !_useNewBubblePositioning,
              );
            },
          ),

          // Fixed transparent app bar — fades as bird column approaches it
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _sheetExtentNotifier,
              builder: (context, sheetExtent, child) {
                // Replicate BirdViewArea gap logic to find column top.
                final range = _computedMaxExtent - _computedMinExtent;
                final t = range > 0
                    ? ((sheetExtent - _computedMinExtent) / range)
                        .clamp(0.0, 1.0)
                    : 0.0;
                final gap =
                    restGap + (BirdViewArea.kMaxExtentGap - restGap) * t;
                final birdColumnTop = screenHeight * (1 - sheetExtent) -
                    gap -
                    BirdViewArea.kBirdColumnHeight;
                final distance = birdColumnTop - appBarBottom;
                final opacity =
                    (distance / BirdViewArea.kFadeRange).clamp(0.0, 1.0);
                return IgnorePointer(
                  ignoring: opacity < 0.1,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/debug'),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                      _buildBirdAgeToggle(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
          _buildAgeOption(BirdAge.baby, 'BABY'),
          _buildAgeOption(BirdAge.adult, 'ADULT'),
        ],
      ),
    );
  }

  Widget _buildAgeOption(BirdAge age, String label) {
    final isSelected = _birdAge == age;
    return GestureDetector(
      onTap: () => setState(() => _birdAge = age),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
