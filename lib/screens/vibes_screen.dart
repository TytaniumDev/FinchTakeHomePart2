import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../debug/bird_anchor_calibration_screen.dart';
import '../debug/bird_position_test_screen.dart';
import '../debug/debug_picker_screen.dart';
import '../debug/draggable_sheet_test_screen.dart';
import '../debug/grid_scaling_test_screen.dart';
import 'vibe_selection_screen.dart';

class VibesScreen extends StatelessWidget {
  const VibesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finch UI Exercise',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.rubikTextTheme()
            .apply(bodyColor: Colors.black, displayColor: Colors.black)
            .copyWith(
              bodyMedium: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const VibeSelectionScreen(),
        '/debug': (_) => const DebugPickerScreen(),
        '/debug/bird': (_) => const BirdPositionTestScreen(),
        '/debug/sheet': (_) => const DraggableSheetTestScreen(),
        '/debug/grid': (_) => const GridScalingTestScreen(),
        '/debug/anchor': (_) => const BirdAnchorCalibrationScreen(),
      },
    );
  }
}
