import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chan_viewer/bloc/chan_event.dart';
import 'package:flutter_chan_viewer/bloc/chan_state.dart';

abstract class BaseBloc<E extends ChanEvent, S extends ChanState> extends Bloc<E, S> {
  BaseBloc(ChanState state) : super(state as S);

  bool _showSearchBar = false;
  String searchQuery = "";

  get showSearchBar => _showSearchBar;

  @override
  Stream<S> mapEventToState(E event) async* {
    if (event is ChanEventSearch) {
      searchQuery = event.query;
    } else if (event is ChanEventShowSearch) {
      _showSearchBar = true;
    } else if (event is ChanEventCloseSearch) {
      searchQuery = "";
      _showSearchBar = false;
    }
  }
}
