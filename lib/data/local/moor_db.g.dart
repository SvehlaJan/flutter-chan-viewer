// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_db.dart';

// ignore_for_file: type=lint
class $PostsTableTable extends PostsTable
    with TableInfo<$PostsTableTable, PostsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extensionMeta =
      const VerificationMeta('extension');
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
      'extension', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boardIdMeta =
      const VerificationMeta('boardId');
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
      'board_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _threadIdMeta =
      const VerificationMeta('threadId');
  @override
  late final GeneratedColumn<int> threadId = GeneratedColumn<int>(
      'thread_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints:
          'REFERENCES threads_table(threadId) ON DELETE CASCADE');
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<int> postId = GeneratedColumn<int>(
      'post_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downloadProgressMeta =
      const VerificationMeta('downloadProgress');
  @override
  late final GeneratedColumn<int> downloadProgress = GeneratedColumn<int>(
      'download_progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  @override
  late final GeneratedColumn<bool> isHidden =
      GeneratedColumn<bool>('is_hidden', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_hidden" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  @override
  List<GeneratedColumn> get $columns => [
        timestamp,
        subtitle,
        content,
        filename,
        imageId,
        extension,
        boardId,
        threadId,
        postId,
        downloadProgress,
        isHidden
      ];
  @override
  String get aliasedName => _alias ?? 'posts_table';
  @override
  String get actualTableName => 'posts_table';
  @override
  VerificationContext validateIntegrity(Insertable<PostsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    }
    if (data.containsKey('extension')) {
      context.handle(_extensionMeta,
          extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta,
          boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta));
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(_postIdMeta,
          postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta));
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('download_progress')) {
      context.handle(
          _downloadProgressMeta,
          downloadProgress.isAcceptableOrUnknown(
              data['download_progress']!, _downloadProgressMeta));
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postId, threadId, boardId};
  @override
  PostsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostsTableData(
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp']),
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename']),
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id']),
      extension: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extension']),
      boardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}board_id'])!,
      threadId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}thread_id'])!,
      postId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}post_id'])!,
      downloadProgress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}download_progress'])!,
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hidden']),
    );
  }

  @override
  $PostsTableTable createAlias(String alias) {
    return $PostsTableTable(attachedDatabase, alias);
  }
}

class PostsTableData extends DataClass implements Insertable<PostsTableData> {
  final int? timestamp;
  final String? subtitle;
  final String? content;
  final String? filename;
  final String? imageId;
  final String? extension;
  final String boardId;
  final int threadId;
  final int postId;
  final int downloadProgress;
  final bool? isHidden;
  const PostsTableData(
      {this.timestamp,
      this.subtitle,
      this.content,
      this.filename,
      this.imageId,
      this.extension,
      required this.boardId,
      required this.threadId,
      required this.postId,
      required this.downloadProgress,
      this.isHidden});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<int>(timestamp);
    }
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
    }
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<String>(imageId);
    }
    if (!nullToAbsent || extension != null) {
      map['extension'] = Variable<String>(extension);
    }
    map['board_id'] = Variable<String>(boardId);
    map['thread_id'] = Variable<int>(threadId);
    map['post_id'] = Variable<int>(postId);
    map['download_progress'] = Variable<int>(downloadProgress);
    if (!nullToAbsent || isHidden != null) {
      map['is_hidden'] = Variable<bool>(isHidden);
    }
    return map;
  }

  PostsTableCompanion toCompanion(bool nullToAbsent) {
    return PostsTableCompanion(
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
      extension: extension == null && nullToAbsent
          ? const Value.absent()
          : Value(extension),
      boardId: Value(boardId),
      threadId: Value(threadId),
      postId: Value(postId),
      downloadProgress: Value(downloadProgress),
      isHidden: isHidden == null && nullToAbsent
          ? const Value.absent()
          : Value(isHidden),
    );
  }

  factory PostsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostsTableData(
      timestamp: serializer.fromJson<int?>(json['timestamp']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      content: serializer.fromJson<String?>(json['content']),
      filename: serializer.fromJson<String?>(json['filename']),
      imageId: serializer.fromJson<String?>(json['imageId']),
      extension: serializer.fromJson<String?>(json['extension']),
      boardId: serializer.fromJson<String>(json['boardId']),
      threadId: serializer.fromJson<int>(json['threadId']),
      postId: serializer.fromJson<int>(json['postId']),
      downloadProgress: serializer.fromJson<int>(json['downloadProgress']),
      isHidden: serializer.fromJson<bool?>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timestamp': serializer.toJson<int?>(timestamp),
      'subtitle': serializer.toJson<String?>(subtitle),
      'content': serializer.toJson<String?>(content),
      'filename': serializer.toJson<String?>(filename),
      'imageId': serializer.toJson<String?>(imageId),
      'extension': serializer.toJson<String?>(extension),
      'boardId': serializer.toJson<String>(boardId),
      'threadId': serializer.toJson<int>(threadId),
      'postId': serializer.toJson<int>(postId),
      'downloadProgress': serializer.toJson<int>(downloadProgress),
      'isHidden': serializer.toJson<bool?>(isHidden),
    };
  }

  PostsTableData copyWith(
          {Value<int?> timestamp = const Value.absent(),
          Value<String?> subtitle = const Value.absent(),
          Value<String?> content = const Value.absent(),
          Value<String?> filename = const Value.absent(),
          Value<String?> imageId = const Value.absent(),
          Value<String?> extension = const Value.absent(),
          String? boardId,
          int? threadId,
          int? postId,
          int? downloadProgress,
          Value<bool?> isHidden = const Value.absent()}) =>
      PostsTableData(
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        subtitle: subtitle.present ? subtitle.value : this.subtitle,
        content: content.present ? content.value : this.content,
        filename: filename.present ? filename.value : this.filename,
        imageId: imageId.present ? imageId.value : this.imageId,
        extension: extension.present ? extension.value : this.extension,
        boardId: boardId ?? this.boardId,
        threadId: threadId ?? this.threadId,
        postId: postId ?? this.postId,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        isHidden: isHidden.present ? isHidden.value : this.isHidden,
      );
  @override
  String toString() {
    return (StringBuffer('PostsTableData(')
          ..write('timestamp: $timestamp, ')
          ..write('subtitle: $subtitle, ')
          ..write('content: $content, ')
          ..write('filename: $filename, ')
          ..write('imageId: $imageId, ')
          ..write('extension: $extension, ')
          ..write('boardId: $boardId, ')
          ..write('threadId: $threadId, ')
          ..write('postId: $postId, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      timestamp,
      subtitle,
      content,
      filename,
      imageId,
      extension,
      boardId,
      threadId,
      postId,
      downloadProgress,
      isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostsTableData &&
          other.timestamp == this.timestamp &&
          other.subtitle == this.subtitle &&
          other.content == this.content &&
          other.filename == this.filename &&
          other.imageId == this.imageId &&
          other.extension == this.extension &&
          other.boardId == this.boardId &&
          other.threadId == this.threadId &&
          other.postId == this.postId &&
          other.downloadProgress == this.downloadProgress &&
          other.isHidden == this.isHidden);
}

class PostsTableCompanion extends UpdateCompanion<PostsTableData> {
  final Value<int?> timestamp;
  final Value<String?> subtitle;
  final Value<String?> content;
  final Value<String?> filename;
  final Value<String?> imageId;
  final Value<String?> extension;
  final Value<String> boardId;
  final Value<int> threadId;
  final Value<int> postId;
  final Value<int> downloadProgress;
  final Value<bool?> isHidden;
  final Value<int> rowid;
  const PostsTableCompanion({
    this.timestamp = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    this.boardId = const Value.absent(),
    this.threadId = const Value.absent(),
    this.postId = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsTableCompanion.insert({
    this.timestamp = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    required String boardId,
    required int threadId,
    required int postId,
    this.downloadProgress = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : boardId = Value(boardId),
        threadId = Value(threadId),
        postId = Value(postId);
  static Insertable<PostsTableData> custom({
    Expression<int>? timestamp,
    Expression<String>? subtitle,
    Expression<String>? content,
    Expression<String>? filename,
    Expression<String>? imageId,
    Expression<String>? extension,
    Expression<String>? boardId,
    Expression<int>? threadId,
    Expression<int>? postId,
    Expression<int>? downloadProgress,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (timestamp != null) 'timestamp': timestamp,
      if (subtitle != null) 'subtitle': subtitle,
      if (content != null) 'content': content,
      if (filename != null) 'filename': filename,
      if (imageId != null) 'image_id': imageId,
      if (extension != null) 'extension': extension,
      if (boardId != null) 'board_id': boardId,
      if (threadId != null) 'thread_id': threadId,
      if (postId != null) 'post_id': postId,
      if (downloadProgress != null) 'download_progress': downloadProgress,
      if (isHidden != null) 'is_hidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsTableCompanion copyWith(
      {Value<int?>? timestamp,
      Value<String?>? subtitle,
      Value<String?>? content,
      Value<String?>? filename,
      Value<String?>? imageId,
      Value<String?>? extension,
      Value<String>? boardId,
      Value<int>? threadId,
      Value<int>? postId,
      Value<int>? downloadProgress,
      Value<bool?>? isHidden,
      Value<int>? rowid}) {
    return PostsTableCompanion(
      timestamp: timestamp ?? this.timestamp,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      filename: filename ?? this.filename,
      imageId: imageId ?? this.imageId,
      extension: extension ?? this.extension,
      boardId: boardId ?? this.boardId,
      threadId: threadId ?? this.threadId,
      postId: postId ?? this.postId,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<int>(threadId.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<int>(postId.value);
    }
    if (downloadProgress.present) {
      map['download_progress'] = Variable<int>(downloadProgress.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsTableCompanion(')
          ..write('timestamp: $timestamp, ')
          ..write('subtitle: $subtitle, ')
          ..write('content: $content, ')
          ..write('filename: $filename, ')
          ..write('imageId: $imageId, ')
          ..write('extension: $extension, ')
          ..write('boardId: $boardId, ')
          ..write('threadId: $threadId, ')
          ..write('postId: $postId, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThreadsTableTable extends ThreadsTable
    with TableInfo<$ThreadsTableTable, ThreadsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThreadsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extensionMeta =
      const VerificationMeta('extension');
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
      'extension', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boardIdMeta =
      const VerificationMeta('boardId');
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
      'board_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES boards_table(boardId) ON DELETE CASCADE');
  static const VerificationMeta _threadIdMeta =
      const VerificationMeta('threadId');
  @override
  late final GeneratedColumn<int> threadId = GeneratedColumn<int>(
      'thread_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<int> lastModified = GeneratedColumn<int>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _selectedPostIdMeta =
      const VerificationMeta('selectedPostId');
  @override
  late final GeneratedColumn<int> selectedPostId = GeneratedColumn<int>(
      'selected_post_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(-1));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite =
      GeneratedColumn<bool>('is_favorite', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_favorite" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _onlineStateMeta =
      const VerificationMeta('onlineState');
  @override
  late final GeneratedColumn<int> onlineState = GeneratedColumn<int>(
      'online_state', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _replyCountMeta =
      const VerificationMeta('replyCount');
  @override
  late final GeneratedColumn<int> replyCount = GeneratedColumn<int>(
      'reply_count', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(-1));
  static const VerificationMeta _imageCountMeta =
      const VerificationMeta('imageCount');
  @override
  late final GeneratedColumn<int> imageCount = GeneratedColumn<int>(
      'image_count', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(-1));
  static const VerificationMeta _lastSeenPostIndexMeta =
      const VerificationMeta('lastSeenPostIndex');
  @override
  late final GeneratedColumn<int> lastSeenPostIndex = GeneratedColumn<int>(
      'last_seen_post_index', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(-1));
  @override
  List<GeneratedColumn> get $columns => [
        timestamp,
        subtitle,
        content,
        filename,
        imageId,
        extension,
        boardId,
        threadId,
        lastModified,
        selectedPostId,
        isFavorite,
        onlineState,
        replyCount,
        imageCount,
        lastSeenPostIndex
      ];
  @override
  String get aliasedName => _alias ?? 'threads_table';
  @override
  String get actualTableName => 'threads_table';
  @override
  VerificationContext validateIntegrity(Insertable<ThreadsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    }
    if (data.containsKey('extension')) {
      context.handle(_extensionMeta,
          extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta,
          boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta));
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('selected_post_id')) {
      context.handle(
          _selectedPostIdMeta,
          selectedPostId.isAcceptableOrUnknown(
              data['selected_post_id']!, _selectedPostIdMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('online_state')) {
      context.handle(
          _onlineStateMeta,
          onlineState.isAcceptableOrUnknown(
              data['online_state']!, _onlineStateMeta));
    }
    if (data.containsKey('reply_count')) {
      context.handle(
          _replyCountMeta,
          replyCount.isAcceptableOrUnknown(
              data['reply_count']!, _replyCountMeta));
    }
    if (data.containsKey('image_count')) {
      context.handle(
          _imageCountMeta,
          imageCount.isAcceptableOrUnknown(
              data['image_count']!, _imageCountMeta));
    }
    if (data.containsKey('last_seen_post_index')) {
      context.handle(
          _lastSeenPostIndexMeta,
          lastSeenPostIndex.isAcceptableOrUnknown(
              data['last_seen_post_index']!, _lastSeenPostIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {threadId, boardId};
  @override
  ThreadsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThreadsTableData(
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp']),
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename']),
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id']),
      extension: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extension']),
      boardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}board_id'])!,
      threadId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}thread_id'])!,
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_modified']),
      selectedPostId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}selected_post_id']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite']),
      onlineState: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}online_state']),
      replyCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reply_count']),
      imageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}image_count']),
      lastSeenPostIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_seen_post_index']),
    );
  }

  @override
  $ThreadsTableTable createAlias(String alias) {
    return $ThreadsTableTable(attachedDatabase, alias);
  }
}

class ThreadsTableData extends DataClass
    implements Insertable<ThreadsTableData> {
  final int? timestamp;
  final String? subtitle;
  final String? content;
  final String? filename;
  final String? imageId;
  final String? extension;
  final String boardId;
  final int threadId;
  final int? lastModified;
  final int? selectedPostId;
  final bool? isFavorite;
  final int? onlineState;
  final int? replyCount;
  final int? imageCount;
  final int? lastSeenPostIndex;
  const ThreadsTableData(
      {this.timestamp,
      this.subtitle,
      this.content,
      this.filename,
      this.imageId,
      this.extension,
      required this.boardId,
      required this.threadId,
      this.lastModified,
      this.selectedPostId,
      this.isFavorite,
      this.onlineState,
      this.replyCount,
      this.imageCount,
      this.lastSeenPostIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<int>(timestamp);
    }
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
    }
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<String>(imageId);
    }
    if (!nullToAbsent || extension != null) {
      map['extension'] = Variable<String>(extension);
    }
    map['board_id'] = Variable<String>(boardId);
    map['thread_id'] = Variable<int>(threadId);
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<int>(lastModified);
    }
    if (!nullToAbsent || selectedPostId != null) {
      map['selected_post_id'] = Variable<int>(selectedPostId);
    }
    if (!nullToAbsent || isFavorite != null) {
      map['is_favorite'] = Variable<bool>(isFavorite);
    }
    if (!nullToAbsent || onlineState != null) {
      map['online_state'] = Variable<int>(onlineState);
    }
    if (!nullToAbsent || replyCount != null) {
      map['reply_count'] = Variable<int>(replyCount);
    }
    if (!nullToAbsent || imageCount != null) {
      map['image_count'] = Variable<int>(imageCount);
    }
    if (!nullToAbsent || lastSeenPostIndex != null) {
      map['last_seen_post_index'] = Variable<int>(lastSeenPostIndex);
    }
    return map;
  }

  ThreadsTableCompanion toCompanion(bool nullToAbsent) {
    return ThreadsTableCompanion(
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
      extension: extension == null && nullToAbsent
          ? const Value.absent()
          : Value(extension),
      boardId: Value(boardId),
      threadId: Value(threadId),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      selectedPostId: selectedPostId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedPostId),
      isFavorite: isFavorite == null && nullToAbsent
          ? const Value.absent()
          : Value(isFavorite),
      onlineState: onlineState == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineState),
      replyCount: replyCount == null && nullToAbsent
          ? const Value.absent()
          : Value(replyCount),
      imageCount: imageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(imageCount),
      lastSeenPostIndex: lastSeenPostIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenPostIndex),
    );
  }

  factory ThreadsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThreadsTableData(
      timestamp: serializer.fromJson<int?>(json['timestamp']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      content: serializer.fromJson<String?>(json['content']),
      filename: serializer.fromJson<String?>(json['filename']),
      imageId: serializer.fromJson<String?>(json['imageId']),
      extension: serializer.fromJson<String?>(json['extension']),
      boardId: serializer.fromJson<String>(json['boardId']),
      threadId: serializer.fromJson<int>(json['threadId']),
      lastModified: serializer.fromJson<int?>(json['lastModified']),
      selectedPostId: serializer.fromJson<int?>(json['selectedPostId']),
      isFavorite: serializer.fromJson<bool?>(json['isFavorite']),
      onlineState: serializer.fromJson<int?>(json['onlineState']),
      replyCount: serializer.fromJson<int?>(json['replyCount']),
      imageCount: serializer.fromJson<int?>(json['imageCount']),
      lastSeenPostIndex: serializer.fromJson<int?>(json['lastSeenPostIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timestamp': serializer.toJson<int?>(timestamp),
      'subtitle': serializer.toJson<String?>(subtitle),
      'content': serializer.toJson<String?>(content),
      'filename': serializer.toJson<String?>(filename),
      'imageId': serializer.toJson<String?>(imageId),
      'extension': serializer.toJson<String?>(extension),
      'boardId': serializer.toJson<String>(boardId),
      'threadId': serializer.toJson<int>(threadId),
      'lastModified': serializer.toJson<int?>(lastModified),
      'selectedPostId': serializer.toJson<int?>(selectedPostId),
      'isFavorite': serializer.toJson<bool?>(isFavorite),
      'onlineState': serializer.toJson<int?>(onlineState),
      'replyCount': serializer.toJson<int?>(replyCount),
      'imageCount': serializer.toJson<int?>(imageCount),
      'lastSeenPostIndex': serializer.toJson<int?>(lastSeenPostIndex),
    };
  }

  ThreadsTableData copyWith(
          {Value<int?> timestamp = const Value.absent(),
          Value<String?> subtitle = const Value.absent(),
          Value<String?> content = const Value.absent(),
          Value<String?> filename = const Value.absent(),
          Value<String?> imageId = const Value.absent(),
          Value<String?> extension = const Value.absent(),
          String? boardId,
          int? threadId,
          Value<int?> lastModified = const Value.absent(),
          Value<int?> selectedPostId = const Value.absent(),
          Value<bool?> isFavorite = const Value.absent(),
          Value<int?> onlineState = const Value.absent(),
          Value<int?> replyCount = const Value.absent(),
          Value<int?> imageCount = const Value.absent(),
          Value<int?> lastSeenPostIndex = const Value.absent()}) =>
      ThreadsTableData(
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        subtitle: subtitle.present ? subtitle.value : this.subtitle,
        content: content.present ? content.value : this.content,
        filename: filename.present ? filename.value : this.filename,
        imageId: imageId.present ? imageId.value : this.imageId,
        extension: extension.present ? extension.value : this.extension,
        boardId: boardId ?? this.boardId,
        threadId: threadId ?? this.threadId,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        selectedPostId:
            selectedPostId.present ? selectedPostId.value : this.selectedPostId,
        isFavorite: isFavorite.present ? isFavorite.value : this.isFavorite,
        onlineState: onlineState.present ? onlineState.value : this.onlineState,
        replyCount: replyCount.present ? replyCount.value : this.replyCount,
        imageCount: imageCount.present ? imageCount.value : this.imageCount,
        lastSeenPostIndex: lastSeenPostIndex.present
            ? lastSeenPostIndex.value
            : this.lastSeenPostIndex,
      );
  @override
  String toString() {
    return (StringBuffer('ThreadsTableData(')
          ..write('timestamp: $timestamp, ')
          ..write('subtitle: $subtitle, ')
          ..write('content: $content, ')
          ..write('filename: $filename, ')
          ..write('imageId: $imageId, ')
          ..write('extension: $extension, ')
          ..write('boardId: $boardId, ')
          ..write('threadId: $threadId, ')
          ..write('lastModified: $lastModified, ')
          ..write('selectedPostId: $selectedPostId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('onlineState: $onlineState, ')
          ..write('replyCount: $replyCount, ')
          ..write('imageCount: $imageCount, ')
          ..write('lastSeenPostIndex: $lastSeenPostIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      timestamp,
      subtitle,
      content,
      filename,
      imageId,
      extension,
      boardId,
      threadId,
      lastModified,
      selectedPostId,
      isFavorite,
      onlineState,
      replyCount,
      imageCount,
      lastSeenPostIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThreadsTableData &&
          other.timestamp == this.timestamp &&
          other.subtitle == this.subtitle &&
          other.content == this.content &&
          other.filename == this.filename &&
          other.imageId == this.imageId &&
          other.extension == this.extension &&
          other.boardId == this.boardId &&
          other.threadId == this.threadId &&
          other.lastModified == this.lastModified &&
          other.selectedPostId == this.selectedPostId &&
          other.isFavorite == this.isFavorite &&
          other.onlineState == this.onlineState &&
          other.replyCount == this.replyCount &&
          other.imageCount == this.imageCount &&
          other.lastSeenPostIndex == this.lastSeenPostIndex);
}

class ThreadsTableCompanion extends UpdateCompanion<ThreadsTableData> {
  final Value<int?> timestamp;
  final Value<String?> subtitle;
  final Value<String?> content;
  final Value<String?> filename;
  final Value<String?> imageId;
  final Value<String?> extension;
  final Value<String> boardId;
  final Value<int> threadId;
  final Value<int?> lastModified;
  final Value<int?> selectedPostId;
  final Value<bool?> isFavorite;
  final Value<int?> onlineState;
  final Value<int?> replyCount;
  final Value<int?> imageCount;
  final Value<int?> lastSeenPostIndex;
  final Value<int> rowid;
  const ThreadsTableCompanion({
    this.timestamp = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    this.boardId = const Value.absent(),
    this.threadId = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.selectedPostId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.onlineState = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.imageCount = const Value.absent(),
    this.lastSeenPostIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThreadsTableCompanion.insert({
    this.timestamp = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    required String boardId,
    required int threadId,
    this.lastModified = const Value.absent(),
    this.selectedPostId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.onlineState = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.imageCount = const Value.absent(),
    this.lastSeenPostIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : boardId = Value(boardId),
        threadId = Value(threadId);
  static Insertable<ThreadsTableData> custom({
    Expression<int>? timestamp,
    Expression<String>? subtitle,
    Expression<String>? content,
    Expression<String>? filename,
    Expression<String>? imageId,
    Expression<String>? extension,
    Expression<String>? boardId,
    Expression<int>? threadId,
    Expression<int>? lastModified,
    Expression<int>? selectedPostId,
    Expression<bool>? isFavorite,
    Expression<int>? onlineState,
    Expression<int>? replyCount,
    Expression<int>? imageCount,
    Expression<int>? lastSeenPostIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (timestamp != null) 'timestamp': timestamp,
      if (subtitle != null) 'subtitle': subtitle,
      if (content != null) 'content': content,
      if (filename != null) 'filename': filename,
      if (imageId != null) 'image_id': imageId,
      if (extension != null) 'extension': extension,
      if (boardId != null) 'board_id': boardId,
      if (threadId != null) 'thread_id': threadId,
      if (lastModified != null) 'last_modified': lastModified,
      if (selectedPostId != null) 'selected_post_id': selectedPostId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (onlineState != null) 'online_state': onlineState,
      if (replyCount != null) 'reply_count': replyCount,
      if (imageCount != null) 'image_count': imageCount,
      if (lastSeenPostIndex != null) 'last_seen_post_index': lastSeenPostIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThreadsTableCompanion copyWith(
      {Value<int?>? timestamp,
      Value<String?>? subtitle,
      Value<String?>? content,
      Value<String?>? filename,
      Value<String?>? imageId,
      Value<String?>? extension,
      Value<String>? boardId,
      Value<int>? threadId,
      Value<int?>? lastModified,
      Value<int?>? selectedPostId,
      Value<bool?>? isFavorite,
      Value<int?>? onlineState,
      Value<int?>? replyCount,
      Value<int?>? imageCount,
      Value<int?>? lastSeenPostIndex,
      Value<int>? rowid}) {
    return ThreadsTableCompanion(
      timestamp: timestamp ?? this.timestamp,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      filename: filename ?? this.filename,
      imageId: imageId ?? this.imageId,
      extension: extension ?? this.extension,
      boardId: boardId ?? this.boardId,
      threadId: threadId ?? this.threadId,
      lastModified: lastModified ?? this.lastModified,
      selectedPostId: selectedPostId ?? this.selectedPostId,
      isFavorite: isFavorite ?? this.isFavorite,
      onlineState: onlineState ?? this.onlineState,
      replyCount: replyCount ?? this.replyCount,
      imageCount: imageCount ?? this.imageCount,
      lastSeenPostIndex: lastSeenPostIndex ?? this.lastSeenPostIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<int>(threadId.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<int>(lastModified.value);
    }
    if (selectedPostId.present) {
      map['selected_post_id'] = Variable<int>(selectedPostId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (onlineState.present) {
      map['online_state'] = Variable<int>(onlineState.value);
    }
    if (replyCount.present) {
      map['reply_count'] = Variable<int>(replyCount.value);
    }
    if (imageCount.present) {
      map['image_count'] = Variable<int>(imageCount.value);
    }
    if (lastSeenPostIndex.present) {
      map['last_seen_post_index'] = Variable<int>(lastSeenPostIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThreadsTableCompanion(')
          ..write('timestamp: $timestamp, ')
          ..write('subtitle: $subtitle, ')
          ..write('content: $content, ')
          ..write('filename: $filename, ')
          ..write('imageId: $imageId, ')
          ..write('extension: $extension, ')
          ..write('boardId: $boardId, ')
          ..write('threadId: $threadId, ')
          ..write('lastModified: $lastModified, ')
          ..write('selectedPostId: $selectedPostId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('onlineState: $onlineState, ')
          ..write('replyCount: $replyCount, ')
          ..write('imageCount: $imageCount, ')
          ..write('lastSeenPostIndex: $lastSeenPostIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoardsTableTable extends BoardsTable
    with TableInfo<$BoardsTableTable, BoardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardIdMeta =
      const VerificationMeta('boardId');
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
      'board_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workSafeMeta =
      const VerificationMeta('workSafe');
  @override
  late final GeneratedColumn<bool> workSafe =
      GeneratedColumn<bool>('work_safe', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("work_safe" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  @override
  List<GeneratedColumn> get $columns => [boardId, title, workSafe];
  @override
  String get aliasedName => _alias ?? 'boards_table';
  @override
  String get actualTableName => 'boards_table';
  @override
  VerificationContext validateIntegrity(Insertable<BoardsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta,
          boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('work_safe')) {
      context.handle(_workSafeMeta,
          workSafe.isAcceptableOrUnknown(data['work_safe']!, _workSafeMeta));
    } else if (isInserting) {
      context.missing(_workSafeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId};
  @override
  BoardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardsTableData(
      boardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}board_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      workSafe: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}work_safe'])!,
    );
  }

  @override
  $BoardsTableTable createAlias(String alias) {
    return $BoardsTableTable(attachedDatabase, alias);
  }
}

class BoardsTableData extends DataClass implements Insertable<BoardsTableData> {
  final String boardId;
  final String title;
  final bool workSafe;
  const BoardsTableData(
      {required this.boardId, required this.title, required this.workSafe});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_id'] = Variable<String>(boardId);
    map['title'] = Variable<String>(title);
    map['work_safe'] = Variable<bool>(workSafe);
    return map;
  }

  BoardsTableCompanion toCompanion(bool nullToAbsent) {
    return BoardsTableCompanion(
      boardId: Value(boardId),
      title: Value(title),
      workSafe: Value(workSafe),
    );
  }

  factory BoardsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardsTableData(
      boardId: serializer.fromJson<String>(json['boardId']),
      title: serializer.fromJson<String>(json['title']),
      workSafe: serializer.fromJson<bool>(json['workSafe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<String>(boardId),
      'title': serializer.toJson<String>(title),
      'workSafe': serializer.toJson<bool>(workSafe),
    };
  }

  BoardsTableData copyWith({String? boardId, String? title, bool? workSafe}) =>
      BoardsTableData(
        boardId: boardId ?? this.boardId,
        title: title ?? this.title,
        workSafe: workSafe ?? this.workSafe,
      );
  @override
  String toString() {
    return (StringBuffer('BoardsTableData(')
          ..write('boardId: $boardId, ')
          ..write('title: $title, ')
          ..write('workSafe: $workSafe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(boardId, title, workSafe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardsTableData &&
          other.boardId == this.boardId &&
          other.title == this.title &&
          other.workSafe == this.workSafe);
}

class BoardsTableCompanion extends UpdateCompanion<BoardsTableData> {
  final Value<String> boardId;
  final Value<String> title;
  final Value<bool> workSafe;
  final Value<int> rowid;
  const BoardsTableCompanion({
    this.boardId = const Value.absent(),
    this.title = const Value.absent(),
    this.workSafe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoardsTableCompanion.insert({
    required String boardId,
    required String title,
    required bool workSafe,
    this.rowid = const Value.absent(),
  })  : boardId = Value(boardId),
        title = Value(title),
        workSafe = Value(workSafe);
  static Insertable<BoardsTableData> custom({
    Expression<String>? boardId,
    Expression<String>? title,
    Expression<bool>? workSafe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (title != null) 'title': title,
      if (workSafe != null) 'work_safe': workSafe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoardsTableCompanion copyWith(
      {Value<String>? boardId,
      Value<String>? title,
      Value<bool>? workSafe,
      Value<int>? rowid}) {
    return BoardsTableCompanion(
      boardId: boardId ?? this.boardId,
      title: title ?? this.title,
      workSafe: workSafe ?? this.workSafe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (workSafe.present) {
      map['work_safe'] = Variable<bool>(workSafe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardsTableCompanion(')
          ..write('boardId: $boardId, ')
          ..write('title: $title, ')
          ..write('workSafe: $workSafe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ChanDB extends GeneratedDatabase {
  _$ChanDB(QueryExecutor e) : super(e);
  _$ChanDB.connect(DatabaseConnection c) : super.connect(c);
  late final $PostsTableTable postsTable = $PostsTableTable(this);
  late final $ThreadsTableTable threadsTable = $ThreadsTableTable(this);
  late final $BoardsTableTable boardsTable = $BoardsTableTable(this);
  late final PostsDao postsDao = PostsDao(this as ChanDB);
  late final ThreadsDao threadsDao = ThreadsDao(this as ChanDB);
  late final BoardsDao boardsDao = BoardsDao(this as ChanDB);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [postsTable, threadsTable, boardsTable];
}
