# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter (Dart 3.x) implementation of Finch's "Send Good Vibes" screen. Two switchable themes (Magic/Books and New Years/Balloon), a bird character anchored above a draggable bottom sheet, a speech bubble, and a vibe picker grid. No backend.

## Commands

```bash
# Run the app (web or linux desktop)
flutter run -d chrome
flutter run -d linux

# Static analysis
flutter analyze

# Run tests
flutter test
flutter test test/some_test.dart          # single test file

# Get dependencies
flutter pub get

# Format code
dart format lib/
```

## Architecture

**State management:** Plain `StatefulWidget` — no Riverpod, Bloc, or Provider. All state lives in `_VibeSelectionScreenState` (`lib/screens/vibe_selection_screen.dart`) and is passed down via constructor params and callbacks.

**File structure:**
- `lib/main.dart` — `main()` entry point only (DevicePreview + GoogleFonts config)
- `lib/screens/vibes_screen.dart` — `VibesScreen` (MaterialApp, theme, route table)
- `lib/screens/vibe_selection_screen.dart` — `VibeSelectionScreen` + state
- `lib/widgets/` — `bird_view_area`, `vibe_picker_sheet`, `speech_bubble`, `animated_typed_text`, `vibe_option_tile`, `footer`, `adaptive_grid_delegate`
- `lib/models/` — `vibe_data` (VibeOption, VibeType, BirdAge, VibeTheme, kDefaultVibes), `bird_anchor_data` (per-asset mouth/bubble anchor points)
- `lib/theme/` — `colors` (VibeColors), `animation` (shared transition duration/curve)
- `lib/debug/` — isolated test screens (bird positioning, sheet behavior, grid scaling, anchor calibration)

**Screen layout (`VibeSelectionScreen`):** A `Stack` with three layers:
1. `BirdViewArea` — full-screen bird SVG + speech bubble, background color
2. `VibePickerSheet` — draggable bottom sheet containing the vibe grid + footer
3. Transparent app bar — close button (opens debug menu) + baby/adult toggle

**Bird anchoring:** `BirdViewArea` uses `LayoutBuilder` + `Positioned` to pin the bird's feet above the sheet (`bottom: availableHeight * sheetExtent + gap`). A parallax gap compresses from `restGap` (centered) to 4px as the sheet drags to max extent. The speech bubble sits in a `Column` above the bird so text reflow doesn't shift the feet.

**Draggable sheet:** `VibePickerSheet` uses `DraggableScrollableSheet` but the drag handle is driven by a manual `GestureDetector`, not the sheet's built-in scroll controller. Min/max extents are computed dynamically based on screen size (no snapping — the sheet stays wherever the user releases it). The vibe grid scrolls via the sheet's built-in scroll controller.

**Data model (`lib/models/vibe_data.dart`):**
- `VibeOption` — single selectable vibe (label, `VibeType`)
- `VibeType` enum — `magic` or `newYears`
- `BirdAge` enum — `baby` or `adult` (with size constants)
- `VibeTheme` — maps a `VibeType` to colors, speech text, bird/background/icon SVG asset paths, and sky color
- `kDefaultVibes` — the 18-item constant list powering the grid

**Theme colors:** Centralized in `lib/theme/colors.dart` (`VibeColors`).

**Font:** Rubik via `google_fonts` package, configured in `lib/screens/vibes_screen.dart` theme.

## Key Design Constraints (from requirements)

- Speech bubble text changes must NOT reposition the bird
- Baby/adult bird toggle must keep feet in the same anchored position
- 2nd row of vibes must always be visible, even on iPhone SE (verify with `device_preview`)

## Debug Infrastructure

The close button navigates to `/debug` which shows `DebugPickerScreen` — a menu of isolated test screens:
- `/debug/bird` — bird SVG positioning tester
- `/debug/sheet` — draggable sheet behavior tester
- `/debug/grid` — adaptive grid sizing tester
- `/debug/anchor` — bird anchor calibration tool

New debug screens: add to `_kDebugEntries` in `debug_picker_screen.dart` and register the route in `lib/screens/vibes_screen.dart`.

## Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_svg` | SVG rendering for bird poses, icons, speech bubble tail |
| `device_preview` | Simulate different device sizes (iPhone SE verification) |
| `google_fonts` | Rubik font |
| `fading_edge_scrollview` | Gradient fade on vibe grid edges |
