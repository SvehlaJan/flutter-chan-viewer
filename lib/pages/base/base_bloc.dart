import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';

abstract class BaseBloc<E extends ChanEvent, S extends ChanState> extends Bloc<ChanEvent, ChanState> {
  BaseBloc(S state) : super(state) {
    on<ChanEventSearch>((event, emit) {
      searchQuery = event.query;
      emit(buildContentState());
    });

    on<ChanEventShowSearch>((event, emit) {
      _showSearchBar = true;
      emit(buildContentState());
    });

    on<ChanEventCloseSearch>((event, emit) {
      searchQuery = "";
      _showSearchBar = false;
      emit(buildContentState());
    });
  }

  bool _showSearchBar = false;
  String searchQuery = "";

  get showSearchBar => _showSearchBar;

  S buildContentState({bool lazyLoading = false, ChanSingleEvent? event});
}
