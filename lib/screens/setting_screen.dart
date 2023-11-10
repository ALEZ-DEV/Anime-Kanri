import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static NavigationRailDestination navigationDestination =
      const NavigationRailDestination(
    icon: Icon(Icons.settings),
    label: Text('Settings'),
  );

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('There will be the settings'),
    );
  }
}
