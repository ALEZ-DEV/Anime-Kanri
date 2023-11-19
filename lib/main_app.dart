import 'package:anime_kanri/blocs/get_torrents_bloc/get_torrents_bloc.dart';
import 'package:anime_kanri/providers/settings_provider.dart';
import 'package:flutter/material.dart';

import 'package:anime_kanri/theme/theme.dart' as AnimeKanri;
import 'package:anime_kanri/screens/screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AnimeKanri.Theme.light,
        darkTheme: AnimeKanri.Theme.dark,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Anime Kanri'),
            centerTitle: true,
          ),
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => GetTorrentsBloc(),
              ),
            ],
            child: Row(
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
        ),
      ),
    );
  }
}
