import 'package:anime_kanri/screens/setting_screens/torrent_queue_screen.dart';
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
    return Column(
      children: [
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TorrentQueueScreen(),
            ),
          ),
          icon: const Icon(Icons.download),
          label: const Text('Torrent queue'),
        ),
      ],
    );
  }
}
