import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

import 'package:anime_kanri/messages/nyaa_search.pb.dart' as nyaa_search;
import 'package:rinf/rinf.dart';

part 'get_torrents_event.dart';
part 'get_torrents_state.dart';

class GetTorrentsBloc extends Bloc<GetTorrentsEvent, GetTorrentsState> {
  GetTorrentsBloc() : super(GetTorrentsInitial()) {
    on<GetTorrents>((event, emit) async {
      emit(GetTorrentsLoading());
      dev.log('start loading');
      try {
        if (event.search.isNotEmpty) {
          final requestMessage = nyaa_search.ReadRequest(
            searchInput: event.search,
            pageInput: Int64(event.page),
          );
          final rustRequest = RustRequest(
            resource: nyaa_search.ID,
            operation: RustOperation.Read,
            message: requestMessage.writeToBuffer(),
          );

          final rustResponse = await requestToRust(rustRequest);

          if (rustResponse.message == null) {
            emit(GetTorrentsFailure('Rust Message is null'));
            return;
          }

          final responseMessage = nyaa_search.ReadResponse.fromBuffer(
            rustResponse.message!,
          );

          dev.log('successfully load');
          emit(GetTorrentsSuccess(responseMessage));
        } else {
          emit(GetTorrentsInitial());
        }
      } catch (e) {
        dev.log(e.toString());
        emit(GetTorrentsFailure(e.toString()));
        rethrow;
      }
    });
  }
}
