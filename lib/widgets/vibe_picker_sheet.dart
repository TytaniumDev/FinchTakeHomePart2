import 'dart:ui' show PointerDeviceKind;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
import 'adaptive_grid_delegate.dart';
import 'footer.dart';
import 'vibe_drawer.dart';

/// A draggable bottom sheet that contains the vibe picker grid and footer.
///
/// Uses the desktop/web pattern from Flutter's official example: the drag
/// handle has a [GestureDetector] that manually drives `initialChildSize`,
/// while the vibe grid scrolls independently with its own controller.
/// The [Footer] sits below the grid in a [Column] so the grid is
/// hard-clipped at the bottom for a clean fading edge.
class VibePickerSheet extends StatefulWidget {
  const VibePickerSheet({
    super.key,
    required this.vibes,
    required this.selectedIndex,
    required this.onSelected,
    required this.drawerBackground,
    required this.footerBackground,
    required this.minExtent,
    required this.targetRows,
    this.onExtentChanged,
    this.onDone,
  });

  static const double kMaxExtent = 0.65;
  static const double kMinExtentFloor = 0.3;
  static const double kMinExtentCeiling = 0.45;
  static const double kHandleHeight = 24.0;
  static const double kFooterBaseHeight = 80.0;

  /// Computes the dynamic min extent and target rows for a given screen.
  ///
  /// Finds the largest N (full rows) where showing N rows + 40% of the next
  /// row keeps the sheet extent within [kMinExtentFloor, kMinExtentCeiling].
  static ({double extent, double targetRows}) computeMinExtent({
    required double screenHeight,
    required double safeAreaBottom,
  }) {
    final overhead = kHandleHeight + kFooterBaseHeight + safeAreaBottom;
    const maxTile = SliverGridDelegateWithAdaptiveHeight.kDefaultMaxTileHeight;
    const spacing =
        SliverGridDelegateWithAdaptiveHeight.kDefaultMainAxisSpacing;

    // Try increasing N from 1 upward; find the largest that fits.
    int bestN = 0;
    for (int n = 1; n <= 6; n++) {
      final gridHeight = (n + 0.4) * maxTile + n * spacing;
      final extent = (overhead + gridHeight) / screenHeight;
      if (extent <= kMinExtentCeiling) {
        bestN = n;
      } else {
        break;
      }
    }

    if (bestN == 0) {
      // Very small screen — use ceiling with fallback rows.
      return (extent: kMinExtentCeiling, targetRows: 1.4);
    }

    final gridHeight = (bestN + 0.4) * maxTile + bestN * spacing;
    final extent = ((overhead + gridHeight) / screenHeight).clamp(
      kMinExtentFloor,
      kMinExtentCeiling,
    );
    return (extent: extent, targetRows: bestN + 0.4);
  }

  final List<VibeOption> vibes;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final Color drawerBackground;
  final Color footerBackground;
  final double minExtent;
  final double targetRows;
  final ValueChanged<double>? onExtentChanged;
  final VoidCallback? onDone;

  @override
  State<VibePickerSheet> createState() => _VibePickerSheetState();
}

class _VibePickerSheetState extends State<VibePickerSheet> {
  late double _sheetPosition;
  final _gridScrollController = ScrollController();
  double _cachedSafeAreaBottom = 0;

  @override
  void initState() {
    super.initState();
    _sheetPosition = widget.minExtent;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedSafeAreaBottom = MediaQuery.paddingOf(context).bottom;
  }

  @override
  void didUpdateWidget(VibePickerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minExtent != widget.minExtent &&
        _sheetPosition < widget.minExtent) {
      _sheetPosition = widget.minExtent;
    }
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  void _onHandleDrag(DragUpdateDetails details, double viewHeight) {
    setState(() {
      _sheetPosition -= details.delta.dy / viewHeight;
      _sheetPosition = _sheetPosition.clamp(
        widget.minExtent,
        VibePickerSheet.kMaxExtent,
      );
    });
    widget.onExtentChanged?.call(_sheetPosition);
  }

  void _onHandleDragEnd(DragEndDetails details) {
    final mid = (widget.minExtent + VibePickerSheet.kMaxExtent) / 2;
    final target = _sheetPosition > mid
        ? VibePickerSheet.kMaxExtent
        : widget.minExtent;
    setState(() => _sheetPosition = target);
    widget.onExtentChanged?.call(_sheetPosition);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewHeight = constraints.maxHeight;

        final minSheetHeight = viewHeight * widget.minExtent;
        final availableGridHeight =
            minSheetHeight -
            VibePickerSheet.kHandleHeight -
            VibePickerSheet.kFooterBaseHeight -
            _cachedSafeAreaBottom;

        final gridDelegate = SliverGridDelegateWithAdaptiveHeight(
          availableGridHeight: availableGridHeight,
          targetVisibleRows: widget.targetRows,
        );
        final iconSize = gridDelegate.scaledIconSize();
        final tileScale = gridDelegate.scaleFactor;

        return DraggableScrollableSheet(
          key: ValueKey(widget.minExtent),
          initialChildSize: _sheetPosition,
          minChildSize: widget.minExtent,
          maxChildSize: VibePickerSheet.kMaxExtent,
          snap: true,
          snapSizes: [widget.minExtent, VibePickerSheet.kMaxExtent],
          builder: (context, scrollController) {
            // scrollController is unused — the handle drives the sheet
            // position manually, and the grid has its own controller.
            return Container(
              decoration: BoxDecoration(
                color: widget.drawerBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _DragHandle(
                    color: widget.drawerBackground,
                    onVerticalDragUpdate: (details) =>
                        _onHandleDrag(details, viewHeight),
                    onVerticalDragEnd: _onHandleDragEnd,
                  ),

                  // Vibe grid with its own scroll controller — scrolls
                  // independently of the sheet position.
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.stylus,
                          PointerDeviceKind.trackpad,
                        },
                      ),
                      child: FadingEdgeScrollView.fromScrollView(
                        child: CustomScrollView(
                          controller: _gridScrollController,
                          slivers: [
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverGrid(
                                gridDelegate: gridDelegate,
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return VibeOptionTile(
                                      vibe: widget.vibes[index],
                                      isSelected:
                                          widget.selectedIndex == index,
                                      onTap: () =>
                                          widget.onSelected(index),
                                    iconSize: iconSize,
                                    scale: tileScale,
                                    );
                                  },
                                  childCount: widget.vibes.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Footer(
                    backgroundColor: widget.footerBackground,
                    onTap: widget.onDone,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// The pill-shaped drag indicator at the top of the sheet.
/// Accepts vertical drag gestures to drive the sheet position.
class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.color,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final Color color;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Container(
        height: 24,
        color: color,
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
    );
  }
}
