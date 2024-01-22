import 'package:anime_kanri/widget/torrent_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anime_kanri/blocs/get_torrents_bloc/get_torrents_bloc.dart';
import 'package:anime_kanri/messages/nyaa_search.pb.dart' as nyaa_rsearch;

class TorrentSearchScreen extends StatefulWidget {
  const TorrentSearchScreen({super.key});

  static NavigationRailDestination navigationDestination =
      const NavigationRailDestination(
    icon: Icon(Icons.search),
    label: Text('Search for Torrents'),
  );

  @override
  State<TorrentSearchScreen> createState() => _TorrentSearchScreenState();
}

class _TorrentSearchScreenState extends State<TorrentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _searchTorrent(String search, int page) {
    context.read<GetTorrentsBloc>().add(GetTorrents(search, page));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).navigationRailTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onSubmitted: (search) {
                _searchTorrent(search, 1);
              },
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<GetTorrentsBloc, GetTorrentsState>(
            bloc: context.read<GetTorrentsBloc>(),
            builder: (context, state) {
              if (state is GetTorrentsFailure) {
                return const Center(
                  child: Text('Somthing goes wrong'),
                );
              } else if (state is GetTorrentsSuccess) {
                final List<nyaa_rsearch.Torrent> torrents =
                    state.searchInfo.torrents;

                if (torrents.isEmpty) {
                  return const Center(
                    child: Text('We found nothing'),
                  );
                }

                return ListView.builder(
                  itemCount: torrents.length,
                  itemBuilder: (context, index) => TorrentItem(
                    torrent: torrents[index],
                  ),
                );
              } else if (state is GetTorrentsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Text('search something'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
