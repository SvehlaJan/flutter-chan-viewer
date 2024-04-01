import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chan_viewer/models/helper/moor_db_overview.dart';
import 'package:flutter_chan_viewer/repositories/chan_storage.dart';
import 'package:flutter_chan_viewer/utils/constants.dart';

@immutable
sealed class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

@immutable
class SettingsStateLoading extends SettingsState {}

@immutable
class SettingsStateError extends SettingsState {
  final String message;

  SettingsStateError(this.message);

  @override
  List<Object?> get props => [message];
}

@immutable
class SettingsStateContent extends SettingsState {
  final AppTheme? theme;
  final List<DownloadFolderInfo>? downloads;
  final bool showNsfw;
  final bool biometricLock;
  final MoorDbOverview moorDbOverview;

  SettingsStateContent(
    this.theme,
    this.downloads,
    this.showNsfw,
    this.biometricLock,
    this.moorDbOverview,
  );

  @override
  List<Object?> get props => [theme, downloads, showNsfw, biometricLock];
}
