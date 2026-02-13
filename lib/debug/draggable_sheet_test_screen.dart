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
  double _currentExtent = VibePickerSheet.kMinExtent;

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
                    _ExtentReadout(extent: _currentExtent),
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
  const _ExtentReadout({required this.extent});

  final double extent;

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
          'Min: ${VibePickerSheet.kMinExtent}  |  Max: ${VibePickerSheet.kMaxExtent}',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}
