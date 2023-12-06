import 'package:realm/realm.dart';
part 'db_user.g.dart';

@RealmModel()
class _DBUser {
  @PrimaryKey()
  @MapTo("public_key")
  late String publicKey;
  late String? website;
  late String? lud06;
  late String? lud16;
  late String? nip05;
  @MapTo("display_name")
  late String? displayName;
  @MapTo("user_name")
  late String? userName;
  late String? about;
  late String? name;
  late String? picture;
  late String? banner;
}