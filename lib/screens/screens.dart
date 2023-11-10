import 'package:anime_kanri/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'torrent_search_screen.dart';

class Screens {
  static final List<Widget> pages = [
    const TorrentSearchScreen(),
    const SettingScreen(),
  ];

  static final List<NavigationRailDestination> pagesRailDestinations = [
    TorrentSearchScreen.navigationDestination,
    SettingScreen.navigationDestination,
  ];
}
