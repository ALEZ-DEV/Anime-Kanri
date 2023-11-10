import 'package:flutter/material.dart';

class TorrentSearchScreen extends StatelessWidget {
  const TorrentSearchScreen({super.key});

  static NavigationRailDestination navigationDestination =
      const NavigationRailDestination(
    icon: Icon(Icons.search),
    label: Text('Search for Torrents'),
  );

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('there will be torrents'),
    );
  }
}
