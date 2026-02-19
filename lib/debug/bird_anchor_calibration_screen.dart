import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/bird_anchor_data.dart';

enum _TapMode { mouth, safeArea }

class BirdAnchorCalibrationScreen extends StatefulWidget {
  const BirdAnchorCalibrationScreen({super.key});

  @override
  State<BirdAnchorCalibrationScreen> createState() =>
      _BirdAnchorCalibrationScreenState();
}

class _BirdAnchorCalibrationScreenState
    extends State<BirdAnchorCalibrationScreen> {
  static const _assetPaths = [
    'assets/bird-pose-smart-book_ADULT.svg',
    'assets/bird-pose-smart-book_BABY.svg',
    'assets/bird-pose-celebrate-confetti_ADULT.svg',
    'assets/bird-pose-celebrate-confetti_BABY.svg',
  ];

  int _selectedAssetIndex = 0;
  _TapMode _tapMode = _TapMode.mouth;
  Offset? _lastTapNormalized;

  String get _currentAsset => _assetPaths[_selectedAssetIndex];
  BirdAnchor? get _currentAnchor => kBirdAnchors[_currentAsset];

  void _onTapDown(TapDownDetails details, Size renderSize) {
    final normalized = Offset(
      (details.localPosition.dx / renderSize.width).clamp(0.0, 1.0),
      (details.localPosition.dy / renderSize.height).clamp(0.0, 1.0),
    );
    setState(() => _lastTapNormalized = normalized);
  }

  String get _tapReadout {
    if (_lastTapNormalized == null) return 'Tap the bird to get coordinates';
    final x = _lastTapNormalized!.dx.toStringAsFixed(4);
    final y = _lastTapNormalized!.dy.toStringAsFixed(4);
    if (_tapMode == _TapMode.mouth) {
      return 'mouthX: $x, mouthY: $y';
    }
    return 'safeAreaTopY: $y';
  }

  String get _anchorLiteral {
    if (_lastTapNormalized == null) return '';
    final x = _lastTapNormalized!.dx.toStringAsFixed(4);
    final y = _lastTapNormalized!.dy.toStringAsFixed(4);
    final anchor = _currentAnchor;
    if (_tapMode == _TapMode.mouth) {
      return 'BirdAnchor(\n'
          '  mouthX: $x,\n'
          '  mouthY: $y,\n'
          '  safeAreaTopY: ${anchor?.safeAreaTopY.toStringAsFixed(4) ?? "0.20"},\n'
          ')';
    }
    return 'BirdAnchor(\n'
        '  mouthX: ${anchor?.mouthX.toStringAsFixed(4) ?? "0.50"},\n'
        '  mouthY: ${anchor?.mouthY.toStringAsFixed(4) ?? "0.30"},\n'
        '  safeAreaTopY: $y,\n'
        ')';
  }

  @override
  Widget build(BuildContext context) {
    final anchor = _currentAnchor;

    return Scaffold(
      appBar: AppBar(title: const Text('Bird Anchor Calibration')),
      body: Column(
        children: [
          // Asset dropdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<int>(
              value: _selectedAssetIndex,
              isExpanded: true,
              items: [
                for (int i = 0; i < _assetPaths.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(
                      _assetPaths[i].split('/').last,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              onChanged: (v) => setState(() {
                _selectedAssetIndex = v!;
                _lastTapNormalized = null;
              }),
            ),
          ),

          // Mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<_TapMode>(
              segments: const [
                ButtonSegment(value: _TapMode.mouth, label: Text('Mouth')),
                ButtonSegment(
                  value: _TapMode.safeArea,
                  label: Text('Safe Area Top'),
                ),
              ],
              selected: {_tapMode},
              onSelectionChanged: (s) => setState(() => _tapMode = s.first),
            ),
          ),
          const SizedBox(height: 12),

          // Bird render area — renders SVG identically to BirdViewArea:
          // explicit width/height on SvgPicture (default BoxFit.contain).
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final birdSize = constraints.biggest.shortestSide.clamp(
                    250.0,
                    400.0,
                  );

                  return SizedBox(
                    width: birdSize,
                    height: birdSize,
                    child: GestureDetector(
                      onTapDown: (d) => _onTapDown(d, Size(birdSize, birdSize)),
                      child: Stack(
                        children: [
                          // Bird SVG — same as BirdViewArea: explicit
                          // width/height, default BoxFit.contain.
                          SvgPicture.asset(
                            _currentAsset,
                            width: birdSize,
                            height: birdSize,
                          ),

                          // Compiled safe area line (blue)
                          if (anchor != null)
                            Positioned(
                              top: anchor.safeAreaTopY * birdSize,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.blue.withValues(alpha: 0.7),
                              ),
                            ),

                          // Compiled mouth dot (red)
                          if (anchor != null)
                            Positioned(
                              left: anchor.mouthX * birdSize - 6,
                              top: anchor.mouthY * birdSize - 6,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                          // Tapped position (green crosshair)
                          if (_lastTapNormalized != null) ...[
                            Positioned(
                              left: _lastTapNormalized!.dx * birdSize,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 1,
                                color: Colors.green.withValues(alpha: 0.5),
                              ),
                            ),
                            Positioned(
                              top: _lastTapNormalized!.dy * birdSize,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 1,
                                color: Colors.green.withValues(alpha: 0.5),
                              ),
                            ),
                            Positioned(
                              left: _lastTapNormalized!.dx * birdSize - 5,
                              top: _lastTapNormalized!.dy * birdSize - 5,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Readout
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Legend
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Compiled mouth',
                      style: TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 10, height: 2, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text(
                      'Compiled safeAreaTopY',
                      style: TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Last tap', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _tapReadout,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _anchorLiteral.isNotEmpty
                      ? _anchorLiteral
                      : 'BirdAnchor(\n'
                            '  mouthX: —,\n'
                            '  mouthY: —,\n'
                            '  safeAreaTopY: —,\n'
                            ')',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: _anchorLiteral.isNotEmpty ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
