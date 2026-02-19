import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
import '../theme/colors.dart';
import '../widgets/vibe_picker_sheet.dart';

/// Isolated test screen for verifying draggable sheet behavior.
///
/// Embeds the real [VibePickerSheet] with mock data and overlays
/// the current extent value so you can watch it update while dragging.
class DraggableSheetTestScreen extends StatefulWidget {
  const DraggableSheetTestScreen({super.key});

  @override
  State<DraggableSheetTestScreen> createState() =>
      _DraggableSheetTestScreenState();
}

class _DraggableSheetTestScreenState extends State<DraggableSheetTestScreen> {
  int? _selectedIndex;
  double _currentExtent = 0.38;

  // Cached from computeMinExtent/computeMaxExtent — updated in didChangeDependencies.
  double _minExtent = 0.38;
  double _maxExtent = 0.65;
  double _targetRows = 1.4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final padding = MediaQuery.paddingOf(context);
    final result = VibePickerSheet.computeMinExtent(
      screenHeight: screenHeight,
      safeAreaBottom: padding.bottom,
    );
    _minExtent = result.extent;
    _targetRows = result.targetRows;
    _maxExtent = VibePickerSheet.computeMaxExtent(
      screenHeight: screenHeight,
      safeAreaTop: padding.top,
      minExtent: _minExtent,
    );
    if (_currentExtent < _minExtent) {
      _currentExtent = _minExtent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with label
          Positioned.fill(
            child: Container(
              color: VibeColors.magicBirdAreaBackground,
              child: SafeArea(
                child: Column(
                  children: [
                    // Back button row
                    _BackButtonRow(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 16),

                    // Extent readout
                    _ExtentReadout(
                      extent: _currentExtent,
                      minExtent: _minExtent,
                      maxExtent: _maxExtent,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // The actual draggable sheet under test
          VibePickerSheet(
            vibes: kDefaultVibes,
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
            drawerBackground: VibeColors.magicDrawerBackground,
            footerBackground: VibeColors.magicFooterBackground,
            minExtent: _minExtent,
            maxExtent: _maxExtent,
            targetRows: _targetRows,
            onExtentChanged: (extent) {
              setState(() => _currentExtent = extent);
            },
            onDone: () {},
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _BackButtonRow extends StatelessWidget {
  const _BackButtonRow({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }
}

class _ExtentReadout extends StatelessWidget {
  const _ExtentReadout({
    required this.extent,
    required this.minExtent,
    required this.maxExtent,
  });

  final double extent;
  final double minExtent;
  final double maxExtent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Draggable Sheet Test',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Current extent: ${extent.toStringAsFixed(3)}',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Min: ${minExtent.toStringAsFixed(3)}  |  Max: ${maxExtent.toStringAsFixed(3)}',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}
