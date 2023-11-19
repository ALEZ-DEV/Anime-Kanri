import 'package:anime_kanri/screens/more_screens.dart/settings_screens/downloads_settings_screen.dart';
import 'package:anime_kanri/widget/simple_icon_button.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
        ),
        body: const Column(
          children: [
            SimpleIconButton(
              icon: Icons.download,
              label: 'Downloads',
              page: DownloadsSettingsScreen(),
            ),
          ],
        ));
  }
}
