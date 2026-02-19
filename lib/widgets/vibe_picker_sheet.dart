import 'dart:ui' show PointerDeviceKind;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
import '../theme/animation.dart';
import 'adaptive_grid_delegate.dart';
import 'bird_view_area.dart';
import 'footer.dart';
import 'vibe_option_tile.dart';

/// A draggable bottom sheet that contains the vibe picker grid and footer.
///
/// The grid's scroll controller is the sheet's own controller, so scrolling
/// up expands the sheet first (until max), then scrolls content; scrolling
/// down collapses the sheet first (until min), then stops. The drag handle
/// also drives extent via a manual [GestureDetector].
class VibePickerSheet extends StatefulWidget {
  const VibePickerSheet({
    super.key,
    required this.vibes,
    required this.selectedIndex,
    required this.onSelected,
    required this.drawerBackground,
    required this.footerBackground,
    required this.minExtent,
    required this.maxExtent,
    required this.targetRows,
    this.onExtentChanged,
    this.onDone,
  });

  static const double kMinExtentFloor = 0.3;
  static const double kMinExtentCeiling = 0.45;
  static const double kHandleHeight = 24.0;
  static const double kFooterBaseHeight = 80.0;

  /// Corner radius of the top of the sheet.
  static const double kSheetTopBorderRadius = 24.0;

  /// Horizontal padding applied to the vibe grid inside the sheet.
  static const double kGridHorizontalPadding = 16.0;

  // Layout constants for computing max extent.
  static const double _kTopMargin = 12;
  static const double _kSpeechBubbleHeight = 80;
  static const double _kBubbleToBirdGap = 4;
  static const double _kBirdContainerHeight = BirdViewArea.kBirdContainerHeight;
  static const double _kMinGapToSheet = 4;

  // Extent computation constants.
  /// Minimum buffer between min and max extent (prevents them from colliding).
  static const double _kMaxExtentMinBuffer = 0.05;

  /// Absolute ceiling for max extent regardless of screen size.
  static const double _kMaxExtentAbsoluteCeiling = 0.70;

  /// Maximum number of full rows checked when computing min extent.
  static const int _kMaxRowsToCheck = 6;

  /// Fraction of the next row that peeks above the fold (e.g. 0.4 = 40%).
  static const double _kRowPeekFraction = 0.4;

  /// Computes the dynamic max extent so the bird column always fits above
  /// the sheet. Clamped to [minExtent + _kMaxExtentMinBuffer, _kMaxExtentAbsoluteCeiling].
  static double computeMaxExtent({
    required double screenHeight,
    required double safeAreaTop,
    required double minExtent,
  }) {
    const reservedAbove =
        _kTopMargin +
        _kSpeechBubbleHeight +
        _kBubbleToBirdGap +
        _kBirdContainerHeight +
        _kMinGapToSheet;
    final maxExtent = 1.0 - (safeAreaTop + reservedAbove) / screenHeight;
    return maxExtent.clamp(
      minExtent + _kMaxExtentMinBuffer,
      _kMaxExtentAbsoluteCeiling,
    );
  }

  /// Computes the dynamic min extent and target rows for a given screen.
  ///
  /// Finds the largest N (full rows) where showing N rows + [_kRowPeekFraction]
  /// of the next row keeps the sheet extent within [kMinExtentFloor, kMinExtentCeiling].
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
    for (int n = 1; n <= _kMaxRowsToCheck; n++) {
      final gridHeight = (n + _kRowPeekFraction) * maxTile + n * spacing;
      final extent = (overhead + gridHeight) / screenHeight;
      if (extent <= kMinExtentCeiling) {
        bestN = n;
      } else {
        break;
      }
    }

    if (bestN == 0) {
      // Very small screen — use ceiling with fallback rows.
      return (extent: kMinExtentCeiling, targetRows: 1 + _kRowPeekFraction);
    }

    final gridHeight = (bestN + _kRowPeekFraction) * maxTile + bestN * spacing;
    final extent = ((overhead + gridHeight) / screenHeight).clamp(
      kMinExtentFloor,
      kMinExtentCeiling,
    );
    return (extent: extent, targetRows: bestN + _kRowPeekFraction);
  }

  final List<VibeOption> vibes;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final Color drawerBackground;
  final Color footerBackground;
  final double minExtent;
  final double maxExtent;
  final double targetRows;
  final ValueChanged<double>? onExtentChanged;
  final VoidCallback? onDone;

  @override
  State<VibePickerSheet> createState() => _VibePickerSheetState();
}

class _VibePickerSheetState extends State<VibePickerSheet> {
  late double _sheetPosition;
  final _sheetController = DraggableScrollableController();
  double _cachedSafeAreaBottom = 0;
  double _cachedViewHeight = 0;

  // Cached grid delegate and derived values — recomputed only when inputs change.
  SliverGridDelegateWithAdaptiveHeight? _gridDelegate;
  double _gridIconSize = 64;
  double _gridTileScale = 1;
  double _lastAvailableGridHeight = -1;

  @override
  void initState() {
    super.initState();
    _sheetPosition = widget.minExtent;
    _sheetController.addListener(_onSheetExtentChanged);
  }

  void _onSheetExtentChanged() {
    if (!_sheetController.isAttached) return;
    final size = _sheetController.size;
    if (size != _sheetPosition) {
      _sheetPosition = size;
      widget.onExtentChanged?.call(size);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedSafeAreaBottom = MediaQuery.paddingOf(context).bottom;
    _cachedViewHeight = MediaQuery.sizeOf(context).height;
  }

  @override
  void didUpdateWidget(VibePickerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minExtent != widget.minExtent ||
        oldWidget.maxExtent != widget.maxExtent) {
      _sheetPosition = widget.minExtent;
      // Sync the controller after the framework applies the new min/max.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _sheetController.isAttached) {
          _sheetController.jumpTo(_sheetPosition);
        }
      });
    }
    // Invalidate delegate cache if targetRows changed.
    if (oldWidget.targetRows != widget.targetRows) {
      _lastAvailableGridHeight = -1;
    }
  }

  void _ensureGridDelegate(double availableGridHeight) {
    if (availableGridHeight == _lastAvailableGridHeight &&
        _gridDelegate != null) {
      return;
    }
    _lastAvailableGridHeight = availableGridHeight;
    _gridDelegate = SliverGridDelegateWithAdaptiveHeight(
      availableGridHeight: availableGridHeight,
      targetVisibleRows: widget.targetRows,
    );
    _gridIconSize = _gridDelegate!.scaledIconSize();
    _gridTileScale = _gridDelegate!.scaleFactor;
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetExtentChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onHandleDrag(DragUpdateDetails details) {
    _sheetPosition -= details.delta.dy / _cachedViewHeight;
    _sheetPosition = _sheetPosition.clamp(widget.minExtent, widget.maxExtent);
    _sheetController.jumpTo(_sheetPosition);
    widget.onExtentChanged?.call(_sheetPosition);
  }

  @override
  Widget build(BuildContext context) {
    final minSheetHeight = _cachedViewHeight * widget.minExtent;
    final availableGridHeight =
        minSheetHeight -
        VibePickerSheet.kHandleHeight -
        VibePickerSheet.kFooterBaseHeight -
        _cachedSafeAreaBottom;

    _ensureGridDelegate(availableGridHeight);
    final gridDelegate = _gridDelegate!;
    final iconSize = _gridIconSize;
    final tileScale = _gridTileScale;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _sheetPosition,
      minChildSize: widget.minExtent,
      maxChildSize: widget.maxExtent,
      builder: (context, scrollController) {
        return AnimatedContainer(
          duration: kVibeTransitionDuration,
          curve: kVibeTransitionCurve,
          decoration: BoxDecoration(
            color: widget.drawerBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(VibePickerSheet.kSheetTopBorderRadius),
            ),
          ),
          child: Column(
            children: [
              _DragHandle(
                backgroundColor: widget.drawerBackground,
                onVerticalDragUpdate: _onHandleDrag,
                // No snap on drag end — sheet stays at current position.
                onVerticalDragEnd: (_) {},
              ),
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
                      controller: scrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VibePickerSheet.kGridHorizontalPadding,
                          ),
                          sliver: SliverGrid(
                            gridDelegate: gridDelegate,
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return VibeOptionTile(
                                vibe: widget.vibes[index],
                                isSelected: widget.selectedIndex == index,
                                onTap: () => widget.onSelected(index),
                                iconSize: iconSize,
                                scale: tileScale,
                              );
                            }, childCount: widget.vibes.length),
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
  }
}

// Pill indicator dimensions inside _DragHandle.
const _kHandlePillWidth = 36.0;
const _kHandlePillHeight = 4.0;
const _kHandlePillRadius = 2.0;

/// The pill-shaped drag indicator at the top of the sheet.
/// Accepts vertical drag gestures to drive the sheet position.
class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.backgroundColor,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final Color backgroundColor;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: AnimatedContainer(
        duration: kVibeTransitionDuration,
        curve: kVibeTransitionCurve,
        height: VibePickerSheet.kHandleHeight,
        color: backgroundColor,
        alignment: Alignment.center,
        child: Container(
          width: _kHandlePillWidth,
          height: _kHandlePillHeight,
          decoration: BoxDecoration(
            color: Colors.white38,
            borderRadius: BorderRadius.circular(_kHandlePillRadius),
          ),
        ),
      ),
    );
  }
}
