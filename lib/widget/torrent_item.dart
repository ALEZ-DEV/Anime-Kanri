import 'package:flutter/material.dart';

import 'package:anime_kanri/messages/nyaa_search.pb.dart' as nyaa_rsearch;
import 'package:anime_kanri/messages/librqbit_torrent.pb.dart'
    as librqbit_torrent;

import 'package:flutter/services.dart';
import 'package:rinf/rinf.dart';

class TorrentItem extends StatelessWidget {
  const TorrentItem({required this.torrent, super.key});

  final nyaa_rsearch.Torrent torrent;

  void startTorrentDownload(BuildContext context) async {
    final requestMessage = librqbit_torrent.TorrentAddInfo(
      magnetLink: torrent.magnetLink,
    );
    final rustRequest = RustRequest(
      resource: librqbit_torrent.ID,
      operation: RustOperation.Read,
      message: requestMessage.writeToBuffer(),
    );

    final rustResponse = await requestToRust(rustRequest);

    final torrentAddedInfo = librqbit_torrent.TorrentAddedInfo.fromBuffer(
      rustResponse.message!,
    );

    late final snackBar;

    if (torrentAddedInfo.hasBeenAdded) {
      snackBar = const SnackBar(
        content: Text('The torrent download is starting...'),
      );
    } else {
      snackBar = const SnackBar(
        content: Text('Failed to start the torrent download'),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    onPressed: () => startTorrentDownload(context),
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
