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
    return const Column(
      children: [
        SettingButton(
          icon: Icons.download,
          label: 'Torrent queue',
          page: TorrentQueueScreen(),
        ),
      ],
    );
  }
}

class SettingButton extends StatelessWidget {
  const SettingButton({
    required this.icon,
    required this.label,
    required this.page,
    super.key,
  });

  final IconData icon;
  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Icon(
                icon,
                size: 35,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
