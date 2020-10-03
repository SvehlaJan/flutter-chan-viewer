// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_db.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class PostsTableData extends DataClass implements Insertable<PostsTableData> {
  final int timestamp;
  final String subtitle;
  final String content;
  final String filename;
  final String imageId;
  final String extension;
  final String boardId;
  final int threadId;
  final int postId;
  final bool isHidden;
  PostsTableData(
      {@required this.timestamp,
      this.subtitle,
      this.content,
      this.filename,
      this.imageId,
      this.extension,
      @required this.boardId,
      @required this.threadId,
      @required this.postId,
      @required this.isHidden});
  factory PostsTableData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return PostsTableData(
      timestamp:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}timestamp']),
      subtitle: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}subtitle']),
      content:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}content']),
      filename: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}filename']),
      imageId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}image_id']),
      extension: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}extension']),
      boardId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}board_id']),
      threadId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}thread_id']),
      postId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}post_id']),
      isHidden:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_hidden']),
    );
  }
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
    if (!nullToAbsent || boardId != null) {
      map['board_id'] = Variable<String>(boardId);
    }
    if (!nullToAbsent || threadId != null) {
      map['thread_id'] = Variable<int>(threadId);
    }
    if (!nullToAbsent || postId != null) {
      map['post_id'] = Variable<int>(postId);
    }
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
      boardId: boardId == null && nullToAbsent
          ? const Value.absent()
          : Value(boardId),
      threadId: threadId == null && nullToAbsent
          ? const Value.absent()
          : Value(threadId),
      postId:
          postId == null && nullToAbsent ? const Value.absent() : Value(postId),
      isHidden: isHidden == null && nullToAbsent
          ? const Value.absent()
          : Value(isHidden),
    );
  }

  factory PostsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PostsTableData(
      timestamp: serializer.fromJson<int>(json['timestamp']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      content: serializer.fromJson<String>(json['content']),
      filename: serializer.fromJson<String>(json['filename']),
      imageId: serializer.fromJson<String>(json['imageId']),
      extension: serializer.fromJson<String>(json['extension']),
      boardId: serializer.fromJson<String>(json['boardId']),
      threadId: serializer.fromJson<int>(json['threadId']),
      postId: serializer.fromJson<int>(json['postId']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timestamp': serializer.toJson<int>(timestamp),
      'subtitle': serializer.toJson<String>(subtitle),
      'content': serializer.toJson<String>(content),
      'filename': serializer.toJson<String>(filename),
      'imageId': serializer.toJson<String>(imageId),
      'extension': serializer.toJson<String>(extension),
      'boardId': serializer.toJson<String>(boardId),
      'threadId': serializer.toJson<int>(threadId),
      'postId': serializer.toJson<int>(postId),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  PostsTableData copyWith(
          {int timestamp,
          String subtitle,
          String content,
          String filename,
          String imageId,
          String extension,
          String boardId,
          int threadId,
          int postId,
          bool isHidden}) =>
      PostsTableData(
        timestamp: timestamp ?? this.timestamp,
        subtitle: subtitle ?? this.subtitle,
        content: content ?? this.content,
        filename: filename ?? this.filename,
        imageId: imageId ?? this.imageId,
        extension: extension ?? this.extension,
        boardId: boardId ?? this.boardId,
        threadId: threadId ?? this.threadId,
        postId: postId ?? this.postId,
        isHidden: isHidden ?? this.isHidden,
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
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      timestamp.hashCode,
      $mrjc(
          subtitle.hashCode,
          $mrjc(
              content.hashCode,
              $mrjc(
                  filename.hashCode,
                  $mrjc(
                      imageId.hashCode,
                      $mrjc(
                          extension.hashCode,
                          $mrjc(
                              boardId.hashCode,
                              $mrjc(
                                  threadId.hashCode,
                                  $mrjc(postId.hashCode,
                                      isHidden.hashCode))))))))));
  @override
  bool operator ==(dynamic other) =>
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
          other.isHidden == this.isHidden);
}

class PostsTableCompanion extends UpdateCompanion<PostsTableData> {
  final Value<int> timestamp;
  final Value<String> subtitle;
  final Value<String> content;
  final Value<String> filename;
  final Value<String> imageId;
  final Value<String> extension;
  final Value<String> boardId;
  final Value<int> threadId;
  final Value<int> postId;
  final Value<bool> isHidden;
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
    this.isHidden = const Value.absent(),
  });
  PostsTableCompanion.insert({
    @required int timestamp,
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    @required String boardId,
    @required int threadId,
    @required int postId,
    @required bool isHidden,
  })  : timestamp = Value(timestamp),
        boardId = Value(boardId),
        threadId = Value(threadId),
        postId = Value(postId),
        isHidden = Value(isHidden);
  static Insertable<PostsTableData> custom({
    Expression<int> timestamp,
    Expression<String> subtitle,
    Expression<String> content,
    Expression<String> filename,
    Expression<String> imageId,
    Expression<String> extension,
    Expression<String> boardId,
    Expression<int> threadId,
    Expression<int> postId,
    Expression<bool> isHidden,
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
      if (isHidden != null) 'is_hidden': isHidden,
    });
  }

  PostsTableCompanion copyWith(
      {Value<int> timestamp,
      Value<String> subtitle,
      Value<String> content,
      Value<String> filename,
      Value<String> imageId,
      Value<String> extension,
      Value<String> boardId,
      Value<int> threadId,
      Value<int> postId,
      Value<bool> isHidden}) {
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
      isHidden: isHidden ?? this.isHidden,
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
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
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
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }
}

class $PostsTableTable extends PostsTable
    with TableInfo<$PostsTableTable, PostsTableData> {
  final GeneratedDatabase _db;
  final String _alias;
  $PostsTableTable(this._db, [this._alias]);
  final VerificationMeta _timestampMeta = const VerificationMeta('timestamp');
  GeneratedIntColumn _timestamp;
  @override
  GeneratedIntColumn get timestamp => _timestamp ??= _constructTimestamp();
  GeneratedIntColumn _constructTimestamp() {
    return GeneratedIntColumn(
      'timestamp',
      $tableName,
      false,
    );
  }

  final VerificationMeta _subtitleMeta = const VerificationMeta('subtitle');
  GeneratedTextColumn _subtitle;
  @override
  GeneratedTextColumn get subtitle => _subtitle ??= _constructSubtitle();
  GeneratedTextColumn _constructSubtitle() {
    return GeneratedTextColumn(
      'subtitle',
      $tableName,
      true,
    );
  }

  final VerificationMeta _contentMeta = const VerificationMeta('content');
  GeneratedTextColumn _content;
  @override
  GeneratedTextColumn get content => _content ??= _constructContent();
  GeneratedTextColumn _constructContent() {
    return GeneratedTextColumn(
      'content',
      $tableName,
      true,
    );
  }

  final VerificationMeta _filenameMeta = const VerificationMeta('filename');
  GeneratedTextColumn _filename;
  @override
  GeneratedTextColumn get filename => _filename ??= _constructFilename();
  GeneratedTextColumn _constructFilename() {
    return GeneratedTextColumn(
      'filename',
      $tableName,
      true,
    );
  }

  final VerificationMeta _imageIdMeta = const VerificationMeta('imageId');
  GeneratedTextColumn _imageId;
  @override
  GeneratedTextColumn get imageId => _imageId ??= _constructImageId();
  GeneratedTextColumn _constructImageId() {
    return GeneratedTextColumn(
      'image_id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _extensionMeta = const VerificationMeta('extension');
  GeneratedTextColumn _extension;
  @override
  GeneratedTextColumn get extension => _extension ??= _constructExtension();
  GeneratedTextColumn _constructExtension() {
    return GeneratedTextColumn(
      'extension',
      $tableName,
      true,
    );
  }

  final VerificationMeta _boardIdMeta = const VerificationMeta('boardId');
  GeneratedTextColumn _boardId;
  @override
  GeneratedTextColumn get boardId => _boardId ??= _constructBoardId();
  GeneratedTextColumn _constructBoardId() {
    return GeneratedTextColumn(
      'board_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _threadIdMeta = const VerificationMeta('threadId');
  GeneratedIntColumn _threadId;
  @override
  GeneratedIntColumn get threadId => _threadId ??= _constructThreadId();
  GeneratedIntColumn _constructThreadId() {
    return GeneratedIntColumn('thread_id', $tableName, false,
        $customConstraints:
            'REFERENCES threads_table(threadId) ON DELETE CASCADE');
  }

  final VerificationMeta _postIdMeta = const VerificationMeta('postId');
  GeneratedIntColumn _postId;
  @override
  GeneratedIntColumn get postId => _postId ??= _constructPostId();
  GeneratedIntColumn _constructPostId() {
    return GeneratedIntColumn(
      'post_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isHiddenMeta = const VerificationMeta('isHidden');
  GeneratedBoolColumn _isHidden;
  @override
  GeneratedBoolColumn get isHidden => _isHidden ??= _constructIsHidden();
  GeneratedBoolColumn _constructIsHidden() {
    return GeneratedBoolColumn(
      'is_hidden',
      $tableName,
      false,
    );
  }

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
        isHidden
      ];
  @override
  $PostsTableTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'posts_table';
  @override
  final String actualTableName = 'posts_table';
  @override
  VerificationContext validateIntegrity(Insertable<PostsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp'], _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle'], _subtitleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content'], _contentMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename'], _filenameMeta));
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id'], _imageIdMeta));
    }
    if (data.containsKey('extension')) {
      context.handle(_extensionMeta,
          extension.isAcceptableOrUnknown(data['extension'], _extensionMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta,
          boardId.isAcceptableOrUnknown(data['board_id'], _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id'], _threadIdMeta));
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(_postIdMeta,
          postId.isAcceptableOrUnknown(data['post_id'], _postIdMeta));
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden'], _isHiddenMeta));
    } else if (isInserting) {
      context.missing(_isHiddenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postId, threadId, boardId};
  @override
  PostsTableData map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return PostsTableData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $PostsTableTable createAlias(String alias) {
    return $PostsTableTable(_db, alias);
  }
}

class ThreadsTableData extends DataClass
    implements Insertable<ThreadsTableData> {
  final int timestamp;
  final String subtitle;
  final String content;
  final String filename;
  final String imageId;
  final String extension;
  final String boardId;
  final int threadId;
  final int selectedPostId;
  final bool isFavorite;
  final OnlineState onlineState;
  final int replyCount;
  final int imageCount;
  final int unreadRepliesCount;
  ThreadsTableData(
      {@required this.timestamp,
      this.subtitle,
      this.content,
      this.filename,
      this.imageId,
      this.extension,
      @required this.boardId,
      @required this.threadId,
      @required this.selectedPostId,
      @required this.isFavorite,
      @required this.onlineState,
      this.replyCount,
      this.imageCount,
      this.unreadRepliesCount});
  factory ThreadsTableData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return ThreadsTableData(
      timestamp:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}timestamp']),
      subtitle: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}subtitle']),
      content:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}content']),
      filename: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}filename']),
      imageId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}image_id']),
      extension: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}extension']),
      boardId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}board_id']),
      threadId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}thread_id']),
      selectedPostId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}selected_post_id']),
      isFavorite: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}is_favorite']),
      onlineState: $ThreadsTableTable.$converter0.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}online_state'])),
      replyCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}reply_count']),
      imageCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}image_count']),
      unreadRepliesCount: intType.mapFromDatabaseResponse(
          data['${effectivePrefix}unread_replies_count']),
    );
  }
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
    if (!nullToAbsent || boardId != null) {
      map['board_id'] = Variable<String>(boardId);
    }
    if (!nullToAbsent || threadId != null) {
      map['thread_id'] = Variable<int>(threadId);
    }
    if (!nullToAbsent || selectedPostId != null) {
      map['selected_post_id'] = Variable<int>(selectedPostId);
    }
    if (!nullToAbsent || isFavorite != null) {
      map['is_favorite'] = Variable<bool>(isFavorite);
    }
    if (!nullToAbsent || onlineState != null) {
      final converter = $ThreadsTableTable.$converter0;
      map['online_state'] = Variable<int>(converter.mapToSql(onlineState));
    }
    if (!nullToAbsent || replyCount != null) {
      map['reply_count'] = Variable<int>(replyCount);
    }
    if (!nullToAbsent || imageCount != null) {
      map['image_count'] = Variable<int>(imageCount);
    }
    if (!nullToAbsent || unreadRepliesCount != null) {
      map['unread_replies_count'] = Variable<int>(unreadRepliesCount);
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
      boardId: boardId == null && nullToAbsent
          ? const Value.absent()
          : Value(boardId),
      threadId: threadId == null && nullToAbsent
          ? const Value.absent()
          : Value(threadId),
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
      unreadRepliesCount: unreadRepliesCount == null && nullToAbsent
          ? const Value.absent()
          : Value(unreadRepliesCount),
    );
  }

  factory ThreadsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return ThreadsTableData(
      timestamp: serializer.fromJson<int>(json['timestamp']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      content: serializer.fromJson<String>(json['content']),
      filename: serializer.fromJson<String>(json['filename']),
      imageId: serializer.fromJson<String>(json['imageId']),
      extension: serializer.fromJson<String>(json['extension']),
      boardId: serializer.fromJson<String>(json['boardId']),
      threadId: serializer.fromJson<int>(json['threadId']),
      selectedPostId: serializer.fromJson<int>(json['selectedPostId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      onlineState: serializer.fromJson<OnlineState>(json['onlineState']),
      replyCount: serializer.fromJson<int>(json['replyCount']),
      imageCount: serializer.fromJson<int>(json['imageCount']),
      unreadRepliesCount: serializer.fromJson<int>(json['unreadRepliesCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timestamp': serializer.toJson<int>(timestamp),
      'subtitle': serializer.toJson<String>(subtitle),
      'content': serializer.toJson<String>(content),
      'filename': serializer.toJson<String>(filename),
      'imageId': serializer.toJson<String>(imageId),
      'extension': serializer.toJson<String>(extension),
      'boardId': serializer.toJson<String>(boardId),
      'threadId': serializer.toJson<int>(threadId),
      'selectedPostId': serializer.toJson<int>(selectedPostId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'onlineState': serializer.toJson<OnlineState>(onlineState),
      'replyCount': serializer.toJson<int>(replyCount),
      'imageCount': serializer.toJson<int>(imageCount),
      'unreadRepliesCount': serializer.toJson<int>(unreadRepliesCount),
    };
  }

  ThreadsTableData copyWith(
          {int timestamp,
          String subtitle,
          String content,
          String filename,
          String imageId,
          String extension,
          String boardId,
          int threadId,
          int selectedPostId,
          bool isFavorite,
          OnlineState onlineState,
          int replyCount,
          int imageCount,
          int unreadRepliesCount}) =>
      ThreadsTableData(
        timestamp: timestamp ?? this.timestamp,
        subtitle: subtitle ?? this.subtitle,
        content: content ?? this.content,
        filename: filename ?? this.filename,
        imageId: imageId ?? this.imageId,
        extension: extension ?? this.extension,
        boardId: boardId ?? this.boardId,
        threadId: threadId ?? this.threadId,
        selectedPostId: selectedPostId ?? this.selectedPostId,
        isFavorite: isFavorite ?? this.isFavorite,
        onlineState: onlineState ?? this.onlineState,
        replyCount: replyCount ?? this.replyCount,
        imageCount: imageCount ?? this.imageCount,
        unreadRepliesCount: unreadRepliesCount ?? this.unreadRepliesCount,
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
          ..write('selectedPostId: $selectedPostId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('onlineState: $onlineState, ')
          ..write('replyCount: $replyCount, ')
          ..write('imageCount: $imageCount, ')
          ..write('unreadRepliesCount: $unreadRepliesCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      timestamp.hashCode,
      $mrjc(
          subtitle.hashCode,
          $mrjc(
              content.hashCode,
              $mrjc(
                  filename.hashCode,
                  $mrjc(
                      imageId.hashCode,
                      $mrjc(
                          extension.hashCode,
                          $mrjc(
                              boardId.hashCode,
                              $mrjc(
                                  threadId.hashCode,
                                  $mrjc(
                                      selectedPostId.hashCode,
                                      $mrjc(
                                          isFavorite.hashCode,
                                          $mrjc(
                                              onlineState.hashCode,
                                              $mrjc(
                                                  replyCount.hashCode,
                                                  $mrjc(
                                                      imageCount.hashCode,
                                                      unreadRepliesCount
                                                          .hashCode))))))))))))));
  @override
  bool operator ==(dynamic other) =>
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
          other.selectedPostId == this.selectedPostId &&
          other.isFavorite == this.isFavorite &&
          other.onlineState == this.onlineState &&
          other.replyCount == this.replyCount &&
          other.imageCount == this.imageCount &&
          other.unreadRepliesCount == this.unreadRepliesCount);
}

class ThreadsTableCompanion extends UpdateCompanion<ThreadsTableData> {
  final Value<int> timestamp;
  final Value<String> subtitle;
  final Value<String> content;
  final Value<String> filename;
  final Value<String> imageId;
  final Value<String> extension;
  final Value<String> boardId;
  final Value<int> threadId;
  final Value<int> selectedPostId;
  final Value<bool> isFavorite;
  final Value<OnlineState> onlineState;
  final Value<int> replyCount;
  final Value<int> imageCount;
  final Value<int> unreadRepliesCount;
  const ThreadsTableCompanion({
    this.timestamp = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    this.boardId = const Value.absent(),
    this.threadId = const Value.absent(),
    this.selectedPostId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.onlineState = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.imageCount = const Value.absent(),
    this.unreadRepliesCount = const Value.absent(),
  });
  ThreadsTableCompanion.insert({
    @required int timestamp,
    this.subtitle = const Value.absent(),
    this.content = const Value.absent(),
    this.filename = const Value.absent(),
    this.imageId = const Value.absent(),
    this.extension = const Value.absent(),
    @required String boardId,
    @required int threadId,
    @required int selectedPostId,
    @required bool isFavorite,
    @required OnlineState onlineState,
    this.replyCount = const Value.absent(),
    this.imageCount = const Value.absent(),
    this.unreadRepliesCount = const Value.absent(),
  })  : timestamp = Value(timestamp),
        boardId = Value(boardId),
        threadId = Value(threadId),
        selectedPostId = Value(selectedPostId),
        isFavorite = Value(isFavorite),
        onlineState = Value(onlineState);
  static Insertable<ThreadsTableData> custom({
    Expression<int> timestamp,
    Expression<String> subtitle,
    Expression<String> content,
    Expression<String> filename,
    Expression<String> imageId,
    Expression<String> extension,
    Expression<String> boardId,
    Expression<int> threadId,
    Expression<int> selectedPostId,
    Expression<bool> isFavorite,
    Expression<int> onlineState,
    Expression<int> replyCount,
    Expression<int> imageCount,
    Expression<int> unreadRepliesCount,
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
      if (selectedPostId != null) 'selected_post_id': selectedPostId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (onlineState != null) 'online_state': onlineState,
      if (replyCount != null) 'reply_count': replyCount,
      if (imageCount != null) 'image_count': imageCount,
      if (unreadRepliesCount != null)
        'unread_replies_count': unreadRepliesCount,
    });
  }

  ThreadsTableCompanion copyWith(
      {Value<int> timestamp,
      Value<String> subtitle,
      Value<String> content,
      Value<String> filename,
      Value<String> imageId,
      Value<String> extension,
      Value<String> boardId,
      Value<int> threadId,
      Value<int> selectedPostId,
      Value<bool> isFavorite,
      Value<OnlineState> onlineState,
      Value<int> replyCount,
      Value<int> imageCount,
      Value<int> unreadRepliesCount}) {
    return ThreadsTableCompanion(
      timestamp: timestamp ?? this.timestamp,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      filename: filename ?? this.filename,
      imageId: imageId ?? this.imageId,
      extension: extension ?? this.extension,
      boardId: boardId ?? this.boardId,
      threadId: threadId ?? this.threadId,
      selectedPostId: selectedPostId ?? this.selectedPostId,
      isFavorite: isFavorite ?? this.isFavorite,
      onlineState: onlineState ?? this.onlineState,
      replyCount: replyCount ?? this.replyCount,
      imageCount: imageCount ?? this.imageCount,
      unreadRepliesCount: unreadRepliesCount ?? this.unreadRepliesCount,
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
    if (selectedPostId.present) {
      map['selected_post_id'] = Variable<int>(selectedPostId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (onlineState.present) {
      final converter = $ThreadsTableTable.$converter0;
      map['online_state'] =
          Variable<int>(converter.mapToSql(onlineState.value));
    }
    if (replyCount.present) {
      map['reply_count'] = Variable<int>(replyCount.value);
    }
    if (imageCount.present) {
      map['image_count'] = Variable<int>(imageCount.value);
    }
    if (unreadRepliesCount.present) {
      map['unread_replies_count'] = Variable<int>(unreadRepliesCount.value);
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
          ..write('selectedPostId: $selectedPostId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('onlineState: $onlineState, ')
          ..write('replyCount: $replyCount, ')
          ..write('imageCount: $imageCount, ')
          ..write('unreadRepliesCount: $unreadRepliesCount')
          ..write(')'))
        .toString();
  }
}

class $ThreadsTableTable extends ThreadsTable
    with TableInfo<$ThreadsTableTable, ThreadsTableData> {
  final GeneratedDatabase _db;
  final String _alias;
  $ThreadsTableTable(this._db, [this._alias]);
  final VerificationMeta _timestampMeta = const VerificationMeta('timestamp');
  GeneratedIntColumn _timestamp;
  @override
  GeneratedIntColumn get timestamp => _timestamp ??= _constructTimestamp();
  GeneratedIntColumn _constructTimestamp() {
    return GeneratedIntColumn(
      'timestamp',
      $tableName,
      false,
    );
  }

  final VerificationMeta _subtitleMeta = const VerificationMeta('subtitle');
  GeneratedTextColumn _subtitle;
  @override
  GeneratedTextColumn get subtitle => _subtitle ??= _constructSubtitle();
  GeneratedTextColumn _constructSubtitle() {
    return GeneratedTextColumn(
      'subtitle',
      $tableName,
      true,
    );
  }

  final VerificationMeta _contentMeta = const VerificationMeta('content');
  GeneratedTextColumn _content;
  @override
  GeneratedTextColumn get content => _content ??= _constructContent();
  GeneratedTextColumn _constructContent() {
    return GeneratedTextColumn(
      'content',
      $tableName,
      true,
    );
  }

  final VerificationMeta _filenameMeta = const VerificationMeta('filename');
  GeneratedTextColumn _filename;
  @override
  GeneratedTextColumn get filename => _filename ??= _constructFilename();
  GeneratedTextColumn _constructFilename() {
    return GeneratedTextColumn(
      'filename',
      $tableName,
      true,
    );
  }

  final VerificationMeta _imageIdMeta = const VerificationMeta('imageId');
  GeneratedTextColumn _imageId;
  @override
  GeneratedTextColumn get imageId => _imageId ??= _constructImageId();
  GeneratedTextColumn _constructImageId() {
    return GeneratedTextColumn(
      'image_id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _extensionMeta = const VerificationMeta('extension');
  GeneratedTextColumn _extension;
  @override
  GeneratedTextColumn get extension => _extension ??= _constructExtension();
  GeneratedTextColumn _constructExtension() {
    return GeneratedTextColumn(
      'extension',
      $tableName,
      true,
    );
  }

  final VerificationMeta _boardIdMeta = const VerificationMeta('boardId');
  GeneratedTextColumn _boardId;
  @override
  GeneratedTextColumn get boardId => _boardId ??= _constructBoardId();
  GeneratedTextColumn _constructBoardId() {
    return GeneratedTextColumn('board_id', $tableName, false,
        $customConstraints:
            'REFERENCES boards_table(boardId) ON DELETE CASCADE');
  }

  final VerificationMeta _threadIdMeta = const VerificationMeta('threadId');
  GeneratedIntColumn _threadId;
  @override
  GeneratedIntColumn get threadId => _threadId ??= _constructThreadId();
  GeneratedIntColumn _constructThreadId() {
    return GeneratedIntColumn(
      'thread_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _selectedPostIdMeta =
      const VerificationMeta('selectedPostId');
  GeneratedIntColumn _selectedPostId;
  @override
  GeneratedIntColumn get selectedPostId =>
      _selectedPostId ??= _constructSelectedPostId();
  GeneratedIntColumn _constructSelectedPostId() {
    return GeneratedIntColumn(
      'selected_post_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isFavoriteMeta = const VerificationMeta('isFavorite');
  GeneratedBoolColumn _isFavorite;
  @override
  GeneratedBoolColumn get isFavorite => _isFavorite ??= _constructIsFavorite();
  GeneratedBoolColumn _constructIsFavorite() {
    return GeneratedBoolColumn(
      'is_favorite',
      $tableName,
      false,
    );
  }

  final VerificationMeta _onlineStateMeta =
      const VerificationMeta('onlineState');
  GeneratedIntColumn _onlineState;
  @override
  GeneratedIntColumn get onlineState =>
      _onlineState ??= _constructOnlineState();
  GeneratedIntColumn _constructOnlineState() {
    return GeneratedIntColumn(
      'online_state',
      $tableName,
      false,
    );
  }

  final VerificationMeta _replyCountMeta = const VerificationMeta('replyCount');
  GeneratedIntColumn _replyCount;
  @override
  GeneratedIntColumn get replyCount => _replyCount ??= _constructReplyCount();
  GeneratedIntColumn _constructReplyCount() {
    return GeneratedIntColumn(
      'reply_count',
      $tableName,
      true,
    );
  }

  final VerificationMeta _imageCountMeta = const VerificationMeta('imageCount');
  GeneratedIntColumn _imageCount;
  @override
  GeneratedIntColumn get imageCount => _imageCount ??= _constructImageCount();
  GeneratedIntColumn _constructImageCount() {
    return GeneratedIntColumn(
      'image_count',
      $tableName,
      true,
    );
  }

  final VerificationMeta _unreadRepliesCountMeta =
      const VerificationMeta('unreadRepliesCount');
  GeneratedIntColumn _unreadRepliesCount;
  @override
  GeneratedIntColumn get unreadRepliesCount =>
      _unreadRepliesCount ??= _constructUnreadRepliesCount();
  GeneratedIntColumn _constructUnreadRepliesCount() {
    return GeneratedIntColumn(
      'unread_replies_count',
      $tableName,
      true,
    );
  }

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
        selectedPostId,
        isFavorite,
        onlineState,
        replyCount,
        imageCount,
        unreadRepliesCount
      ];
  @override
  $ThreadsTableTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'threads_table';
  @override
  final String actualTableName = 'threads_table';
  @override
  VerificationContext validateIntegrity(Insertable<ThreadsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp'], _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle'], _subtitleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content'], _contentMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename'], _filenameMeta));
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id'], _imageIdMeta));
    }
    if (data.containsKey('extension')) {
      context.handle(_extensionMeta,
          extension.isAcceptableOrUnknown(data['extension'], _extensionMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta,
          boardId.isAcceptableOrUnknown(data['board_id'], _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id'], _threadIdMeta));
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('selected_post_id')) {
      context.handle(
          _selectedPostIdMeta,
          selectedPostId.isAcceptableOrUnknown(
              data['selected_post_id'], _selectedPostIdMeta));
    } else if (isInserting) {
      context.missing(_selectedPostIdMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite'], _isFavoriteMeta));
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    context.handle(_onlineStateMeta, const VerificationResult.success());
    if (data.containsKey('reply_count')) {
      context.handle(
          _replyCountMeta,
          replyCount.isAcceptableOrUnknown(
              data['reply_count'], _replyCountMeta));
    }
    if (data.containsKey('image_count')) {
      context.handle(
          _imageCountMeta,
          imageCount.isAcceptableOrUnknown(
              data['image_count'], _imageCountMeta));
    }
    if (data.containsKey('unread_replies_count')) {
      context.handle(
          _unreadRepliesCountMeta,
          unreadRepliesCount.isAcceptableOrUnknown(
              data['unread_replies_count'], _unreadRepliesCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {threadId, boardId};
  @override
  ThreadsTableData map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return ThreadsTableData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $ThreadsTableTable createAlias(String alias) {
    return $ThreadsTableTable(_db, alias);
  }

  static TypeConverter<OnlineState, int> $converter0 =
      const EnumIndexConverter<OnlineState>(OnlineState.values);
}

class BoardsTableData extends DataClass implements Insertable<BoardsTableData> {
  final String boardId;
  final String title;
  final bool workSafe;
  BoardsTableData(
      {@required this.boardId, @required this.title, @required this.workSafe});
  factory BoardsTableData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return BoardsTableData(
      boardId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}board_id']),
      title:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}title']),
      workSafe:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}work_safe']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || boardId != null) {
      map['board_id'] = Variable<String>(boardId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || workSafe != null) {
      map['work_safe'] = Variable<bool>(workSafe);
    }
    return map;
  }

  BoardsTableCompanion toCompanion(bool nullToAbsent) {
    return BoardsTableCompanion(
      boardId: boardId == null && nullToAbsent
          ? const Value.absent()
          : Value(boardId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      workSafe: workSafe == null && nullToAbsent
          ? const Value.absent()
          : Value(workSafe),
    );
  }

  factory BoardsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return BoardsTableData(
      boardId: serializer.fromJson<String>(json['boardId']),
      title: serializer.fromJson<String>(json['title']),
      workSafe: serializer.fromJson<bool>(json['workSafe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<String>(boardId),
      'title': serializer.toJson<String>(title),
      'workSafe': serializer.toJson<bool>(workSafe),
    };
  }

  BoardsTableData copyWith({String boardId, String title, bool workSafe}) =>
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
  int get hashCode =>
      $mrjf($mrjc(boardId.hashCode, $mrjc(title.hashCode, workSafe.hashCode)));
  @override
  bool operator ==(dynamic other) =>
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
  const BoardsTableCompanion({
    this.boardId = const Value.absent(),
    this.title = const Value.absent(),
    this.workSafe = const Value.absent(),
  });
  BoardsTableCompanion.insert({
    @required String boardId,
    @required String title,
    @required bool workSafe,
  })  : boardId = Value(boardId),
        title = Value(title),
        workSafe = Value(workSafe);
  static Insertable<BoardsTableData> custom({
    Expression<String> boardId,
    Expression<String> title,
    Expression<bool> workSafe,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (title != null) 'title': title,
      if (workSafe != null) 'work_safe': workSafe,
    });
  }

  BoardsTableCompanion copyWith(
      {Value<String> boardId, Value<String> title, Value<bool> workSafe}) {
    return BoardsTableCompanion(
      boardId: boardId ?? this.boardId,
      title: title ?? this.title,
      workSafe: workSafe ?? this.workSafe,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardsTableCompanion(')
          ..write('boardId: $boardId, ')
          ..write('title: $title, ')
          ..write('workSafe: $workSafe')
          ..write(')'))
        .toString();
  }
}

class $BoardsTableTable extends BoardsTable
    with TableInfo<$BoardsTableTable, BoardsTableData> {
  final GeneratedDatabase _db;
  final String _alias;
  $BoardsTableTable(this._db, [this._alias]);
  final VerificationMeta _boardIdMeta = const VerificationMeta('boardId');
  GeneratedTextColumn _boardId;
  @override
  GeneratedTextColumn get boardId => _boardId ??= _constructBoardId();
  GeneratedTextColumn _constructBoardId() {
    return GeneratedTextColumn(
      'board_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  GeneratedTextColumn _title;
  @override
  GeneratedTextColumn get title => _title ??= _constructTitle();
  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn(
      'title',
      $tableName,
      false,
    );
  }

  final VerificationMeta _workSafeMeta = const VerificationMeta('workSafe');
  GeneratedBoolColumn _workSafe;
  @override
  GeneratedBoolColumn get workSafe => _workSafe ??= _constructWorkSafe();
  GeneratedBoolColumn _constructWorkSafe() {
    return GeneratedBoolColumn(
      'work_safe',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [boardId, title, workSafe];
  @override
  $BoardsTableTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'boards_table';
  @override
  final String actualTableName = 'boards_table';
  @override
  VerificationContext validateIntegrity(Insertable<BoardsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta,
          boardId.isAcceptableOrUnknown(data['board_id'], _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title'], _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('work_safe')) {
      context.handle(_workSafeMeta,
          workSafe.isAcceptableOrUnknown(data['work_safe'], _workSafeMeta));
    } else if (isInserting) {
      context.missing(_workSafeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId};
  @override
  BoardsTableData map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return BoardsTableData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $BoardsTableTable createAlias(String alias) {
    return $BoardsTableTable(_db, alias);
  }
}

abstract class _$MoorDB extends GeneratedDatabase {
  _$MoorDB(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $PostsTableTable _postsTable;
  $PostsTableTable get postsTable => _postsTable ??= $PostsTableTable(this);
  $ThreadsTableTable _threadsTable;
  $ThreadsTableTable get threadsTable =>
      _threadsTable ??= $ThreadsTableTable(this);
  $BoardsTableTable _boardsTable;
  $BoardsTableTable get boardsTable => _boardsTable ??= $BoardsTableTable(this);
  PostsDao _postsDao;
  PostsDao get postsDao => _postsDao ??= PostsDao(this as MoorDB);
  ThreadsDao _threadsDao;
  ThreadsDao get threadsDao => _threadsDao ??= ThreadsDao(this as MoorDB);
  BoardsDao _boardsDao;
  BoardsDao get boardsDao => _boardsDao ??= BoardsDao(this as MoorDB);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [postsTable, threadsTable, boardsTable];
}
