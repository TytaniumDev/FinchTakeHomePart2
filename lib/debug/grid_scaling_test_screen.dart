import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
import '../theme/colors.dart';
import '../widgets/adaptive_grid_delegate.dart';
import '../widgets/vibe_option_tile.dart';
import '../widgets/vibe_picker_sheet.dart';

/// Device presets for quick testing.
class _DevicePreset {
  const _DevicePreset(this.label, this.height);
  final String label;
  final double height;
}

const _kPresets = [
  _DevicePreset('iPhone SE', 667),
  _DevicePreset('iPhone 14', 844),
  _DevicePreset('iPhone 14 Pro Max', 932),
  _DevicePreset('Pixel 5', 851),
  _DevicePreset('iPad Mini', 1024),
  _DevicePreset('iPad Mini (1133)', 1133),
  _DevicePreset('iPad Pro 12.9"', 1366),
];

/// Debug screen for testing adaptive grid scaling at various simulated heights.
///
/// Renders a simulated drawer (handle + grid + footer) clipped to the exact
/// min-extent sheet height for the selected device, so you see precisely what
/// a user on that device would see.
class GridScalingTestScreen extends StatefulWidget {
  const GridScalingTestScreen({super.key});

  @override
  State<GridScalingTestScreen> createState() => _GridScalingTestScreenState();
}

class _GridScalingTestScreenState extends State<GridScalingTestScreen> {
  double _viewHeight = 667; // default to iPhone SE
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compute dynamic min extent for the simulated screen height.
    final result = VibePickerSheet.computeMinExtent(
      screenHeight: _viewHeight,
      safeAreaBottom: 0,
    );
    final minExtent = result.extent;
    final targetRows = result.targetRows;

    final minSheetHeight = _viewHeight * minExtent;
    final availableGridHeight =
        minSheetHeight -
        VibePickerSheet.kHandleHeight -
        VibePickerSheet.kFooterBaseHeight;

    final gridDelegate = SliverGridDelegateWithAdaptiveHeight(
      availableGridHeight: availableGridHeight,
      targetVisibleRows: targetRows,
    );
    final iconSize = gridDelegate.scaledIconSize();
    final tileScale = gridDelegate.scaleFactor;

    return Scaffold(
      appBar: AppBar(title: const Text('Grid Scaling')),
      body: Column(
        children: [
          // ── Controls ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View: ${_viewHeight.round()}px  |  '
                  'Extent: ${minExtent.toStringAsFixed(3)}  |  '
                  'Rows: ${targetRows.toStringAsFixed(1)}  |  '
                  'Sheet: ${minSheetHeight.round()}px  |  '
                  'Grid: ${availableGridHeight.round()}px  |  '
                  'Icon: ${iconSize.round()}px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  min: 500,
                  max: 1400,
                  value: _viewHeight,
                  onChanged: (v) => setState(() => _viewHeight = v),
                ),
                Wrap(
                  spacing: 8,
                  children: _kPresets.map((p) {
                    return ActionChip(
                      label: Text(p.label),
                      onPressed: () => setState(() => _viewHeight = p.height),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),

          // ── Simulated drawer at min extent ──────────────────────────────
          Expanded(
            child: Container(
              color: Colors.black54,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: minSheetHeight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: VibeColors.magicDrawerBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          height: VibePickerSheet.kHandleHeight,
                          alignment: Alignment.center,
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Grid — takes remaining space between handle and footer
                        Expanded(
                          child: CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate: gridDelegate,
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final vibe = kDefaultVibes[index];
                                    return VibeOptionTile(
                                      vibe: vibe,
                                      isSelected: false,
                                      onTap: () {},
                                      iconSize: iconSize,
                                      scale: tileScale,
                                    );
                                  }, childCount: kDefaultVibes.length),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Footer
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          color: VibeColors.magicFooterBackground,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                'Done',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
