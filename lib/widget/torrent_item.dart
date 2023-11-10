import 'package:flutter/material.dart';

import 'package:anime_kanri/messages/nyaa_search.pb.dart' as nyaa_rsearch;
import 'package:flutter/services.dart';

class TorrentItem extends StatelessWidget {
  const TorrentItem({required this.torrent, super.key});

  final nyaa_rsearch.Torrent torrent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  torrent.name,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  'Seeders : ${torrent.seeders.toString()}',
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Leechers : ${torrent.leechers.toString()}',
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Approved : ${torrent.approved.toString()}',
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: torrent.magnetLink),
                    );
                  },
                  child: const Text('Copy Magnetlink'),
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: torrent.torrentFile),
                    );
                  },
                  child: const Text('Copy Torrent link'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
