import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/vibe_data.dart';
import '../widgets/bird_view_area.dart';
import '../widgets/speech_bubble.dart';

/// All available bird asset prefixes.
const _kBirdPrefixes = ['bird-pose-smart-book', 'bird-pose-celebrate-confetti'];

// _BirdPreview anchor-line constants.
/// How far the red anchor line extends beyond the bird SVG on each side.
const _kAnchorLineExtraWidth = 40.0;
const _kAnchorLineThickness = 2.0;

/// Distance from the bottom of the preview area to the bird center.
const _kBirdPreviewBottomOffset = 96.0;

/// Isolated test screen for verifying bird SVG positioning and anchor alignment.
///
/// Features:
/// - Dropdown to switch between bird pose prefixes
/// - Baby / Adult toggle
/// - Red anchor line at the bottom edge of the SVG
/// - Speech bubble rendered above the bird
class BirdPositionTestScreen extends StatefulWidget {
  const BirdPositionTestScreen({super.key});

  @override
  State<BirdPositionTestScreen> createState() => _BirdPositionTestScreenState();
}

class _BirdPositionTestScreenState extends State<BirdPositionTestScreen> {
  String _selectedPrefix = _kBirdPrefixes.first;
  BirdAge _birdAge = BirdAge.adult;

  String get _assetPath {
    final ageSuffix = _birdAge == BirdAge.adult ? 'ADULT' : 'BABY';
    return 'assets/${_selectedPrefix}_$ageSuffix.svg';
  }

  double get _birdSize => _birdAge.size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bird Positioning')),
      body: Column(
        children: [
          // ── Controls ──────────────────────────────────────────────────
          _BirdControls(
            selectedPrefix: _selectedPrefix,
            birdAge: _birdAge,
            onPrefixChanged: (prefix) =>
                setState(() => _selectedPrefix = prefix),
            onAgeChanged: (age) => setState(() => _birdAge = age),
          ),
          const Divider(),

          // ── Preview area ──────────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              color: VibeTheme.magic.birdAreaBackground,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _kBirdPreviewBottomOffset,
                    child: Center(
                      child: _BirdPreview(
                        assetPath: _assetPath,
                        birdSize: _birdSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Controls row ──────────────────────────────────────────────────────────────

/// Dropdown + toggle for selecting bird prefix and age. Stateless — state
/// is owned by [BirdPositionTestScreen].
class _BirdControls extends StatelessWidget {
  const _BirdControls({
    required this.selectedPrefix,
    required this.birdAge,
    required this.onPrefixChanged,
    required this.onAgeChanged,
  });

  final String selectedPrefix;
  final BirdAge birdAge;
  final ValueChanged<String> onPrefixChanged;
  final ValueChanged<BirdAge> onAgeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Bird pose dropdown
          Expanded(
            child: DropdownButton<String>(
              value: selectedPrefix,
              isExpanded: true,
              items: _kBirdPrefixes
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onPrefixChanged(value);
              },
            ),
          ),
          const SizedBox(width: 16),

          // Age toggle
          SegmentedButton<BirdAge>(
            segments: const [
              ButtonSegment(value: BirdAge.baby, label: Text('Baby')),
              ButtonSegment(value: BirdAge.adult, label: Text('Adult')),
            ],
            selected: {birdAge},
            onSelectionChanged: (selection) => onAgeChanged(selection.first),
          ),
        ],
      ),
    );
  }
}

// ── Bird preview with anchor line ─────────────────────────────────────────────

/// Renders the bird SVG with a speech bubble above and a red anchor line
/// at the bottom edge of the SVG to verify alignment.
class _BirdPreview extends StatelessWidget {
  const _BirdPreview({required this.assetPath, required this.birdSize});

  final String assetPath;
  final double birdSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SpeechBubble(text: 'Testing positioning, cheep!'),
        const SizedBox(height: 4),
        // Bird SVG + red anchor line stacked together
        SizedBox(
          width: birdSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: BirdViewArea.kBirdContainerHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SvgPicture.asset(
                    assetPath,
                    width: birdSize,
                    height: birdSize,
                  ),
                ),
              ),
              // Red anchor line flush with the bottom of the SVG
              Container(
                width: birdSize + _kAnchorLineExtraWidth,
                height: _kAnchorLineThickness,
                color: Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('Asset: $assetPath', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
