import 'package:anime_kanri/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:anime_kanri/messages/librqbit_torrent.pb.dart'
    as librqbit_torrent;
import 'package:rinf/rinf.dart';

class DownloadsSettingsScreen extends StatelessWidget {
  const DownloadsSettingsScreen({super.key});

  void onDownloadDirectoyPathChanged(String value, BuildContext context) async {
    Provider.of<SettingsProvider>(context, listen: false).setDownloadDirectory =
        value;

    final requestMessage = librqbit_torrent.newSessionInfo(
      directoryPath: value,
    );
    final rustRequest = RustRequest(
      resource: librqbit_torrent.ID,
      operation: RustOperation.Update,
      message: requestMessage.writeToBuffer(),
    );

    final rustResponse = await requestToRust(rustRequest);

    print('sucess ? : ${rustResponse.successful}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SettingsTextField(
            initValue: Provider.of<SettingsProvider>(context).downloadDirectory,
            onChanged: (value) => onDownloadDirectoyPathChanged(value, context),
          ),
        ],
      ),
    );
  }
}

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    required this.onChanged,
    this.initValue = '',
    super.key,
  });

  final Function(String) onChanged;
  final String initValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 75,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Downloads directory :',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: initValue,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
