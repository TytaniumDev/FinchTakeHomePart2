import 'dart:ui' show PointerDeviceKind;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

import '../models/vibe_data.dart';
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
    this.onExtentChanged,
    this.onDone,
  });

  static const double kMinExtent = 0.38;
  static const double kMaxExtent = 0.65;

  final List<VibeOption> vibes;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final Color drawerBackground;
  final Color footerBackground;
  final ValueChanged<double>? onExtentChanged;
  final VoidCallback? onDone;

  @override
  State<VibePickerSheet> createState() => _VibePickerSheetState();
}

class _VibePickerSheetState extends State<VibePickerSheet> {
  double _sheetPosition = VibePickerSheet.kMinExtent;
  final _gridScrollController = ScrollController();

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  void _onHandleDrag(DragUpdateDetails details, double viewHeight) {
    setState(() {
      _sheetPosition -= details.delta.dy / viewHeight;
      _sheetPosition = _sheetPosition.clamp(
        VibePickerSheet.kMinExtent,
        VibePickerSheet.kMaxExtent,
      );
    });
    widget.onExtentChanged?.call(_sheetPosition);
  }

  void _onHandleDragEnd(DragEndDetails details) {
    // Snap to the nearest extent.
    final mid =
        (VibePickerSheet.kMinExtent + VibePickerSheet.kMaxExtent) / 2;
    final target = _sheetPosition > mid
        ? VibePickerSheet.kMaxExtent
        : VibePickerSheet.kMinExtent;
    setState(() => _sheetPosition = target);
    widget.onExtentChanged?.call(_sheetPosition);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewHeight = constraints.maxHeight;

        return DraggableScrollableSheet(
          initialChildSize: _sheetPosition,
          minChildSize: VibePickerSheet.kMinExtent,
          maxChildSize: VibePickerSheet.kMaxExtent,
          snap: true,
          snapSizes: const [
            VibePickerSheet.kMinExtent,
            VibePickerSheet.kMaxExtent,
          ],
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
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 0.85,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return VibeOptionTile(
                                      vibe: widget.vibes[index],
                                      isSelected:
                                          widget.selectedIndex == index,
                                      onTap: () =>
                                          widget.onSelected(index),
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
