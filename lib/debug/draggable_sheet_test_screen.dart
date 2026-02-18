import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
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

  // Cached from computeMinExtent — updated in didChangeDependencies.
  double _minExtent = 0.38;
  double _targetRows = 1.4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final result = VibePickerSheet.computeMinExtent(
      screenHeight: screenHeight,
      safeAreaBottom: safeAreaBottom,
    );
    _minExtent = result.extent;
    _targetRows = result.targetRows;
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
              color: const Color(0xFF2A5641),
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
            drawerBackground: const Color(0xFF1B4934),
            footerBackground: const Color(0xFF285641),
            minExtent: _minExtent,
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
  const _ExtentReadout({required this.extent, required this.minExtent});

  final double extent;
  final double minExtent;

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
          'Min: ${minExtent.toStringAsFixed(3)}  |  Max: ${VibePickerSheet.kMaxExtent}',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}
