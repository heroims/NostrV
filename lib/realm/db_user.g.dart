// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_user.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class DBUser extends _DBUser with RealmEntity, RealmObjectBase, RealmObject {
  DBUser(
    String publicKey, {
    String? website,
    String? lud06,
    String? lud16,
    String? nip05,
    String? displayName,
    String? userName,
    String? about,
    String? name,
    String? picture,
    String? banner,
  }) {
    RealmObjectBase.set(this, 'public_key', publicKey);
    RealmObjectBase.set(this, 'website', website);
    RealmObjectBase.set(this, 'lud06', lud06);
    RealmObjectBase.set(this, 'lud16', lud16);
    RealmObjectBase.set(this, 'nip05', nip05);
    RealmObjectBase.set(this, 'display_name', displayName);
    RealmObjectBase.set(this, 'user_name', userName);
    RealmObjectBase.set(this, 'about', about);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'banner', banner);
  }

  DBUser._();

  @override
  String get publicKey =>
      RealmObjectBase.get<String>(this, 'public_key') as String;
  @override
  set publicKey(String value) => RealmObjectBase.set(this, 'public_key', value);

  @override
  String? get website =>
      RealmObjectBase.get<String>(this, 'website') as String?;
  @override
  set website(String? value) => RealmObjectBase.set(this, 'website', value);

  @override
  String? get lud06 => RealmObjectBase.get<String>(this, 'lud06') as String?;
  @override
  set lud06(String? value) => RealmObjectBase.set(this, 'lud06', value);

  @override
  String? get lud16 => RealmObjectBase.get<String>(this, 'lud16') as String?;
  @override
  set lud16(String? value) => RealmObjectBase.set(this, 'lud16', value);

  @override
  String? get nip05 => RealmObjectBase.get<String>(this, 'nip05') as String?;
  @override
  set nip05(String? value) => RealmObjectBase.set(this, 'nip05', value);

  @override
  String? get displayName =>
      RealmObjectBase.get<String>(this, 'display_name') as String?;
  @override
  set displayName(String? value) =>
      RealmObjectBase.set(this, 'display_name', value);

  @override
  String? get userName =>
      RealmObjectBase.get<String>(this, 'user_name') as String?;
  @override
  set userName(String? value) => RealmObjectBase.set(this, 'user_name', value);

  @override
  String? get about => RealmObjectBase.get<String>(this, 'about') as String?;
  @override
  set about(String? value) => RealmObjectBase.set(this, 'about', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get banner => RealmObjectBase.get<String>(this, 'banner') as String?;
  @override
  set banner(String? value) => RealmObjectBase.set(this, 'banner', value);

  @override
  Stream<RealmObjectChanges<DBUser>> get changes =>
      RealmObjectBase.getChanges<DBUser>(this);

  @override
  DBUser freeze() => RealmObjectBase.freezeObject<DBUser>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(DBUser._);
    return const SchemaObject(ObjectType.realmObject, DBUser, 'DBUser', [
      SchemaProperty('publicKey', RealmPropertyType.string,
          mapTo: 'public_key', primaryKey: true),
      SchemaProperty('website', RealmPropertyType.string, optional: true),
      SchemaProperty('lud06', RealmPropertyType.string, optional: true),
      SchemaProperty('lud16', RealmPropertyType.string, optional: true),
      SchemaProperty('nip05', RealmPropertyType.string, optional: true),
      SchemaProperty('displayName', RealmPropertyType.string,
          mapTo: 'display_name', optional: true),
      SchemaProperty('userName', RealmPropertyType.string,
          mapTo: 'user_name', optional: true),
      SchemaProperty('about', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
      SchemaProperty('banner', RealmPropertyType.string, optional: true),
    ]);
  }
}
