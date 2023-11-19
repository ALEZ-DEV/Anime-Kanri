import 'package:anime_kanri/screens/more_screen.dart';
import 'package:flutter/material.dart';
import 'torrent_search_screen.dart';

class Screens {
  static final List<Widget> pages = [
    const TorrentSearchScreen(),
    const MoreScreen(),
  ];

  static final List<NavigationRailDestination> pagesRailDestinations = [
    TorrentSearchScreen.navigationDestination,
    MoreScreen.navigationDestination,
  ];
}
