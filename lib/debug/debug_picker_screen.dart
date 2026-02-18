import 'package:flutter/material.dart';

/// A list item representing a single debug test screen.
class _DebugEntry {
  const _DebugEntry({
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String route;
}

/// All available debug test screens.
///
/// To add a new test, just append a [_DebugEntry] here and register
/// the route in [main.dart].
const _kDebugEntries = [
  _DebugEntry(
    title: 'Bird Positioning',
    subtitle: 'Test bird anchor + speech bubble alignment',
    route: '/debug/bird',
  ),
  _DebugEntry(
    title: 'Draggable Sheet',
    subtitle: 'Test drag behavior and extent values',
    route: '/debug/sheet',
  ),
  _DebugEntry(
    title: 'Grid Scaling',
    subtitle: 'Test adaptive grid sizing at various screen heights',
    route: '/debug/grid',
  ),
];

/// Picker screen that lists all available debug test widgets.
class DebugPickerScreen extends StatelessWidget {
  const DebugPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Testing')),
      body: ListView.separated(
        itemCount: _kDebugEntries.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _kDebugEntries[index];
          return _DebugListTile(entry: entry);
        },
      ),
    );
  }
}

class _DebugListTile extends StatelessWidget {
  const _DebugListTile({required this.entry});

  final _DebugEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.title),
      subtitle: Text(entry.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, entry.route),
    );
  }
}
