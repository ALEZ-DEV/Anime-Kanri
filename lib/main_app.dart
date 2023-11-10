import 'package:flutter/material.dart';

import 'package:anime_kanri/theme/theme.dart' as AnimeKanri;
import 'package:anime_kanri/screens/screens.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndexPage = 0;

  void _changeDestination(int index) {
    setState(() {
      _selectedIndexPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AnimeKanri.Theme.light,
      darkTheme: AnimeKanri.Theme.dark,
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndexPage,
              destinations: Screens.pagesRailDestinations,
              onDestinationSelected: _changeDestination,
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                child: Screens.pages[_selectedIndexPage],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
