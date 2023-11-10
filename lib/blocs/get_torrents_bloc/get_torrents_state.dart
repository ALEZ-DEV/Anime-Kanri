part of 'get_torrents_bloc.dart';

@immutable
sealed class GetTorrentsState {}

final class GetTorrentsInitial extends GetTorrentsState {}

final class GetTorrentsLoading extends GetTorrentsState {}

final class GetTorrentsFailure extends GetTorrentsState {
  GetTorrentsFailure(this.errorMsg);

  final String errorMsg;
}

final class GetTorrentsSuccess extends GetTorrentsState {
  GetTorrentsSuccess(this.searchInfo);

  final nyaa_search.ReadResponse searchInfo;
}
