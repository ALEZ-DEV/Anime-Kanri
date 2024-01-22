import 'package:anime_kanri/widget/start_torrent_download_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:anime_kanri/messages/nyaa_search.pb.dart' as nyaa_rsearch;

class TorrentItem extends StatelessWidget {
  const TorrentItem({required this.torrent, super.key});

  final nyaa_rsearch.Torrent torrent;

  void openStartTorrentDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StartTorrentDownloadDialog(
        torrent: torrent,
      ),
    );
  }

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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    torrent.name,
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
            ),
            Flexible(
              child: Column(
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
                  TextButton(
                    onPressed: () => openStartTorrentDownloadDialog(context),
                    child: const Text('Download Torrent'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
