import 'package:flutter/material.dart';

import 'package:rinf/rinf.dart';
import 'package:anime_kanri/messages/librqbit_torrent.pb.dart' as librqbit;

class TorrentQueueScreen extends StatelessWidget {
  const TorrentQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torrent queue'),
        centerTitle: true,
      ),
      body: Center(
        child: StreamBuilder<RustSignal>(
          stream: rustBroadcaster.stream
              .where((rustSignal) => rustSignal.resource == librqbit.ID),
          builder: (context, snapshot) {
            final rustSignal = snapshot.data;
            if (rustSignal == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Loading'),
                      SizedBox(
                        height: 15.0,
                      ),
                      LinearProgressIndicator(),
                    ],
                  ),
                ),
              );
            } else {
              final signal = librqbit.CurrentTorrentDownloadInfo.fromBuffer(
                rustSignal.message!,
              );

              if (signal.torrentsState.isEmpty) {
                return const Center(
                  child: Text('There is no download for now'),
                );
              } else {
                return ListView.builder(
                  itemCount: signal.torrentsState.length,
                  itemBuilder: (context, index) => TorrentQueueItem(
                    torrentState: signal.torrentsState[index],
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class TorrentQueueItem extends StatelessWidget {
  const TorrentQueueItem({required this.torrentState, super.key});

  final librqbit.TorrentState torrentState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: SizedBox(
            width: double.infinity,
            child: ExpansionTile(
              title: Text(
                torrentState.name,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: torrentState.pourcent / 100,
                  ),
                  Text('${torrentState.downspeed.toStringAsFixed(2)} Mbps/s'),
                ],
              ),
              children: [
                ListTile(
                  title: Text(
                    'State : ${torrentState.state.toString()}',
                  ),
                ),
                ListTile(
                  title: Text(
                    'Progress : ${torrentState.pourcent.toStringAsFixed(1)}%',
                  ),
                ),
                ListTile(
                  title: Text(
                    'Progress : ${torrentState.pourcent.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
