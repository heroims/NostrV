import 'package:flutter/cupertino.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:realm/realm.dart';

import '../realm/db_follower.dart';
import '../realm/db_user.dart';

class RealmModel extends ChangeNotifier {
  late Realm realm;

  RealmModel(){
    final config = Configuration.local(
        [
          DBUser.schema,
          DBFollower.schema,
          DBMessage.schema,
        ],
        schemaVersion: 1
    );
    realm =
        Realm(config);
  }
}