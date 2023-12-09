// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_message.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class DBMessage extends _DBMessage
    with RealmEntity, RealmObjectBase, RealmObject {
  DBMessage(
    String id,
    String from,
    String content,
    DateTime created,
    String channelId,
    String replyId,
    String to,
    String meta,
    String dbChannelId,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'from', from);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'created', created);
    RealmObjectBase.set(this, 'channel_id', channelId);
    RealmObjectBase.set(this, 'reply_id', replyId);
    RealmObjectBase.set(this, 'to', to);
    RealmObjectBase.set(this, 'meta', meta);
    RealmObjectBase.set(this, 'db_channel_id', dbChannelId);
  }

  DBMessage._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get from => RealmObjectBase.get<String>(this, 'from') as String;
  @override
  set from(String value) => RealmObjectBase.set(this, 'from', value);

  @override
  String get content => RealmObjectBase.get<String>(this, 'content') as String;
  @override
  set content(String value) => RealmObjectBase.set(this, 'content', value);

  @override
  DateTime get created =>
      RealmObjectBase.get<DateTime>(this, 'created') as DateTime;
  @override
  set created(DateTime value) => RealmObjectBase.set(this, 'created', value);

  @override
  String get channelId =>
      RealmObjectBase.get<String>(this, 'channel_id') as String;
  @override
  set channelId(String value) => RealmObjectBase.set(this, 'channel_id', value);

  @override
  String get replyId => RealmObjectBase.get<String>(this, 'reply_id') as String;
  @override
  set replyId(String value) => RealmObjectBase.set(this, 'reply_id', value);

  @override
  String get to => RealmObjectBase.get<String>(this, 'to') as String;
  @override
  set to(String value) => RealmObjectBase.set(this, 'to', value);

  @override
  String get meta => RealmObjectBase.get<String>(this, 'meta') as String;
  @override
  set meta(String value) => RealmObjectBase.set(this, 'meta', value);

  @override
  String get dbChannelId =>
      RealmObjectBase.get<String>(this, 'db_channel_id') as String;
  @override
  set dbChannelId(String value) =>
      RealmObjectBase.set(this, 'db_channel_id', value);

  @override
  Stream<RealmObjectChanges<DBMessage>> get changes =>
      RealmObjectBase.getChanges<DBMessage>(this);

  @override
  DBMessage freeze() => RealmObjectBase.freezeObject<DBMessage>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(DBMessage._);
    return const SchemaObject(ObjectType.realmObject, DBMessage, 'DBMessage', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('from', RealmPropertyType.string),
      SchemaProperty('content', RealmPropertyType.string),
      SchemaProperty('created', RealmPropertyType.timestamp),
      SchemaProperty('channelId', RealmPropertyType.string,
          mapTo: 'channel_id'),
      SchemaProperty('replyId', RealmPropertyType.string, mapTo: 'reply_id'),
      SchemaProperty('to', RealmPropertyType.string),
      SchemaProperty('meta', RealmPropertyType.string),
      SchemaProperty('dbChannelId', RealmPropertyType.string,
          mapTo: 'db_channel_id'),
    ]);
  }
}
