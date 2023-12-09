import 'package:realm/realm.dart';
part 'db_message.g.dart';

@RealmModel()
class _DBMessage {
  @PrimaryKey()
  late String id;
  late String from;
  late String content;
  late DateTime created;
  @MapTo("channel_id")
  late String channelId;
  @MapTo("reply_id")
  late String replyId;
  late String to;
  late String meta;
  @MapTo("db_channel_id")
  late String dbChannelId;
}