// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_follower.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class DBFollower extends _DBFollower
    with RealmEntity, RealmObjectBase, RealmObject {
  DBFollower(
    String id,
    String publicKey,
    String follower,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'public_key', publicKey);
    RealmObjectBase.set(this, 'follower', follower);
  }

  DBFollower._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get publicKey =>
      RealmObjectBase.get<String>(this, 'public_key') as String;
  @override
  set publicKey(String value) => RealmObjectBase.set(this, 'public_key', value);

  @override
  String get follower =>
      RealmObjectBase.get<String>(this, 'follower') as String;
  @override
  set follower(String value) => RealmObjectBase.set(this, 'follower', value);

  @override
  Stream<RealmObjectChanges<DBFollower>> get changes =>
      RealmObjectBase.getChanges<DBFollower>(this);

  @override
  DBFollower freeze() => RealmObjectBase.freezeObject<DBFollower>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(DBFollower._);
    return const SchemaObject(
        ObjectType.realmObject, DBFollower, 'DBFollower', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('publicKey', RealmPropertyType.string,
          mapTo: 'public_key'),
      SchemaProperty('follower', RealmPropertyType.string),
    ]);
  }
}
