import 'package:device_preview/device_preview.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/vibes_screen.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    DevicePreview(enabled: true, builder: (context) => const VibesScreen()),
  );
}
