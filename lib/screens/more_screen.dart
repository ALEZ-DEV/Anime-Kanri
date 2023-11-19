import 'package:anime_kanri/screens/more_screens.dart/settings_screen.dart';
import 'package:anime_kanri/screens/more_screens.dart/torrent_queue_screen.dart';
import 'package:anime_kanri/widget/simple_icon_button.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static NavigationRailDestination navigationDestination =
      const NavigationRailDestination(
    icon: Icon(Icons.more_horiz),
    label: Text('More'),
  );

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SimpleIconButton(
          icon: Icons.download,
          label: 'Torrent queue',
          page: TorrentQueueScreen(),
        ),
        SimpleIconButton(
          icon: Icons.settings,
          label: 'Settings',
          page: SettingsScreen(),
        ),
      ],
    );
  }
}
