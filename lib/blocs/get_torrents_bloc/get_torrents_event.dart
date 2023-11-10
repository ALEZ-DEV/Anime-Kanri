part of 'get_torrents_bloc.dart';

@immutable
sealed class GetTorrentsEvent {}

class GetTorrents extends GetTorrentsEvent {
  GetTorrents(this.search, this.page);

  final String search;
  final int page;
}
