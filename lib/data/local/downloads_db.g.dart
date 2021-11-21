// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloads_db.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class DownloadsTableData extends DataClass
    implements Insertable<DownloadsTableData> {
  final String mediaId;
  final String url;
  final String path;
  final String filename;
  final int status;
  final int progress;
  final int timestamp;
  DownloadsTableData(
      {required this.mediaId,
      required this.url,
      required this.path,
      required this.filename,
      required this.status,
      required this.progress,
      required this.timestamp});
  factory DownloadsTableData.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return DownloadsTableData(
      mediaId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}media_id'])!,
      url: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}url'])!,
      path: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}path'])!,
      filename: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}filename'])!,
      status: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}status'])!,
      progress: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}progress'])!,
      timestamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}timestamp'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['url'] = Variable<String>(url);
    map['path'] = Variable<String>(path);
    map['filename'] = Variable<String>(filename);
    map['status'] = Variable<int>(status);
    map['progress'] = Variable<int>(progress);
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  DownloadsTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadsTableCompanion(
      mediaId: Value(mediaId),
      url: Value(url),
      path: Value(path),
      filename: Value(filename),
      status: Value(status),
      progress: Value(progress),
      timestamp: Value(timestamp),
    );
  }

  factory DownloadsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadsTableData(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      url: serializer.fromJson<String>(json['url']),
      path: serializer.fromJson<String>(json['path']),
      filename: serializer.fromJson<String>(json['filename']),
      status: serializer.fromJson<int>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'url': serializer.toJson<String>(url),
      'path': serializer.toJson<String>(path),
      'filename': serializer.toJson<String>(filename),
      'status': serializer.toJson<int>(status),
      'progress': serializer.toJson<int>(progress),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  DownloadsTableData copyWith(
          {String? mediaId,
          String? url,
          String? path,
          String? filename,
          int? status,
          int? progress,
          int? timestamp}) =>
      DownloadsTableData(
        mediaId: mediaId ?? this.mediaId,
        url: url ?? this.url,
        path: path ?? this.path,
        filename: filename ?? this.filename,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        timestamp: timestamp ?? this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('DownloadsTableData(')
          ..write('mediaId: $mediaId, ')
          ..write('url: $url, ')
          ..write('path: $path, ')
          ..write('filename: $filename, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mediaId, url, path, filename, status, progress, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadsTableData &&
          other.mediaId == this.mediaId &&
          other.url == this.url &&
          other.path == this.path &&
          other.filename == this.filename &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.timestamp == this.timestamp);
}

class DownloadsTableCompanion extends UpdateCompanion<DownloadsTableData> {
  final Value<String> mediaId;
  final Value<String> url;
  final Value<String> path;
  final Value<String> filename;
  final Value<int> status;
  final Value<int> progress;
  final Value<int> timestamp;
  const DownloadsTableCompanion({
    this.mediaId = const Value.absent(),
    this.url = const Value.absent(),
    this.path = const Value.absent(),
    this.filename = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  DownloadsTableCompanion.insert({
    required String mediaId,
    required String url,
    required String path,
    required String filename,
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.timestamp = const Value.absent(),
  })  : mediaId = Value(mediaId),
        url = Value(url),
        path = Value(path),
        filename = Value(filename);
  static Insertable<DownloadsTableData> custom({
    Expression<String>? mediaId,
    Expression<String>? url,
    Expression<String>? path,
    Expression<String>? filename,
    Expression<int>? status,
    Expression<int>? progress,
    Expression<int>? timestamp,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (url != null) 'url': url,
      if (path != null) 'path': path,
      if (filename != null) 'filename': filename,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  DownloadsTableCompanion copyWith(
      {Value<String>? mediaId,
      Value<String>? url,
      Value<String>? path,
      Value<String>? filename,
      Value<int>? status,
      Value<int>? progress,
      Value<int>? timestamp}) {
    return DownloadsTableCompanion(
      mediaId: mediaId ?? this.mediaId,
      url: url ?? this.url,
      path: path ?? this.path,
      filename: filename ?? this.filename,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsTableCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('url: $url, ')
          ..write('path: $path, ')
          ..write('filename: $filename, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTableTable extends DownloadsTable
    with TableInfo<$DownloadsTableTable, DownloadsTableData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $DownloadsTableTable(this._db, [this._alias]);
  final VerificationMeta _mediaIdMeta = const VerificationMeta('mediaId');
  late final GeneratedColumn<String?> mediaId = GeneratedColumn<String?>(
      'media_id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _urlMeta = const VerificationMeta('url');
  late final GeneratedColumn<String?> url = GeneratedColumn<String?>(
      'url', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _pathMeta = const VerificationMeta('path');
  late final GeneratedColumn<String?> path = GeneratedColumn<String?>(
      'path', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _filenameMeta = const VerificationMeta('filename');
  late final GeneratedColumn<String?> filename = GeneratedColumn<String?>(
      'filename', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<int?> status = GeneratedColumn<int?>(
      'status', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _progressMeta = const VerificationMeta('progress');
  late final GeneratedColumn<int?> progress = GeneratedColumn<int?>(
      'progress', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _timestampMeta = const VerificationMeta('timestamp');
  late final GeneratedColumn<int?> timestamp = GeneratedColumn<int?>(
      'timestamp', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [mediaId, url, path, filename, status, progress, timestamp];
  @override
  String get aliasedName => _alias ?? 'downloads_table';
  @override
  String get actualTableName => 'downloads_table';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  DownloadsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return DownloadsTableData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $DownloadsTableTable createAlias(String alias) {
    return $DownloadsTableTable(_db, alias);
  }
}

abstract class _$DownloadsDB extends GeneratedDatabase {
  _$DownloadsDB(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  _$DownloadsDB.connect(DatabaseConnection c) : super.connect(c);
  late final $DownloadsTableTable downloadsTable = $DownloadsTableTable(this);
  late final DownloadsDao downloadsDao = DownloadsDao(this as DownloadsDB);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [downloadsTable];
}
