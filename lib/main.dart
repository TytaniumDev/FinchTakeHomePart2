import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'debug/bird_position_test_screen.dart';
import 'debug/debug_picker_screen.dart';
import 'debug/draggable_sheet_test_screen.dart';
import 'debug/grid_scaling_test_screen.dart';
import 'models/vibe_data.dart';
import 'widgets/bird_view_area.dart';
import 'widgets/vibe_picker_sheet.dart';

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
      initialRoute: '/',
      routes: {
        '/': (_) => const VibeSelectionScreen(),
        '/debug': (_) => const DebugPickerScreen(),
        '/debug/bird': (_) => const BirdPositionTestScreen(),
        '/debug/sheet': (_) => const DraggableSheetTestScreen(),
        '/debug/grid': (_) => const GridScalingTestScreen(),
      },
    );
  }
}

class VibeSelectionScreen extends StatefulWidget {
  const VibeSelectionScreen({super.key});

  @override
  State<VibeSelectionScreen> createState() => _VibeSelectionScreenState();
}

class _VibeSelectionScreenState extends State<VibeSelectionScreen> {
  int? _selectedVibeIndex;
  BirdAge _birdAge = BirdAge.adult;

  // Sheet extent driven by a ValueNotifier so only BirdViewArea rebuilds
  // during drag, not the entire screen.
  final _sheetExtentNotifier = ValueNotifier<double>(0.38);

  // Cached values — recomputed only when screen metrics change.
  double _computedMinExtent = 0.38;
  double _computedTargetRows = 1.4;
  double _screenHeight = 800;

  VibeTheme get _theme {
    if (_selectedVibeIndex == null) return VibeTheme.magic;
    return VibeTheme.fromType(kDefaultVibes[_selectedVibeIndex!].type);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenHeight = MediaQuery.sizeOf(context).height;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final result = VibePickerSheet.computeMinExtent(
      screenHeight: _screenHeight,
      safeAreaBottom: safeAreaBottom,
    );
    _computedMinExtent = result.extent;
    _computedTargetRows = result.targetRows;
    if (_sheetExtentNotifier.value < _computedMinExtent) {
      _sheetExtentNotifier.value = _computedMinExtent;
    }
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
              screenHeight: _screenHeight,
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
            targetRows: _computedTargetRows,
            onExtentChanged: (extent) {
              _sheetExtentNotifier.value = extent;
            },
            onDone: () {
              // Handle done
            },
          ),

          // Fixed transparent app bar with close button and age toggle
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/debug'),
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
