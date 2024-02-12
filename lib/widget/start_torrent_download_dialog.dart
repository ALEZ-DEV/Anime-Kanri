import 'package:flutter/material.dart';

import 'package:rinf/rinf.dart';
import 'package:provider/provider.dart';

import 'package:anime_kanri/messages/nyaa_search.pb.dart' as nyaa_rsearch;
import 'package:anime_kanri/messages/librqbit_torrent.pb.dart'
    as librqbit_torrent;

import 'package:anime_kanri/widget/simple_text_field.dart';
import 'package:anime_kanri/providers/settings_provider.dart';

class StartTorrentDownloadDialog extends StatefulWidget {
  const StartTorrentDownloadDialog({
    required this.torrent,
    super.key,
  });

  final nyaa_rsearch.Torrent torrent;

  @override
  State<StartTorrentDownloadDialog> createState() =>
      _StartTorrentDownloadDialogState();
}

class _StartTorrentDownloadDialogState
    extends State<StartTorrentDownloadDialog> {
  final TextEditingController controller = TextEditingController();

  bool isTorrentLoading = false;

  void startTorrentDownload(BuildContext context) async {
    setState(() {
      isTorrentLoading = true;
    });

    final requestMessage = librqbit_torrent.TorrentAddInfo(
      magnetLink: widget.torrent.magnetLink,
      outputFolder: controller.text,
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

      Navigator.of(context).pop();
    } else {
      setState(() {
        isTorrentLoading = false;
      });

      snackBar = const SnackBar(
        content: Text('Failed to start the torrent download'),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    controller.text = Provider.of<SettingsProvider>(context).downloadDirectory;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleTextField(
                name: 'Output folder : ',
                controller: controller,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  isTorrentLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : TextButton(
                          onPressed: () => startTorrentDownload(context),
                          child: const Text('Start download'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
