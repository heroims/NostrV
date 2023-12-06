import 'package:realm/realm.dart';
part 'db_follower.g.dart';

@RealmModel()
class _DBFollower {
  @PrimaryKey()
  late String id;
  @MapTo("public_key")
  late String publicKey;
  late String follower;
}