import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/realm_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

import '../realm/db_user.dart';

class ChatListenModel extends ChangeNotifier {
  late final BuildContext _context;

  ChatListenModel(this._context,){
    RealmModel realmModel = Provider.of<RealmModel>(_context, listen: false);
    final dbResults = realmModel.realm.query<DBMessage>("TRUEPREDICATE SORT(created DESC) DISTINCT(dbChannelId)");
    _channelLists = dbResults.toList();
    dbResults.changes.listen((event) {
      _channelLists = event.results.toList();
      notifyListeners();
    });
  }

  late List<DBMessage> _channelLists=[];
  List<DBMessage> get channelLists => _channelLists;

  void refreshList(){
    RealmModel realmModel = Provider.of<RealmModel>(_context, listen: false);

    final dbResults = realmModel.realm.query<DBMessage>("TRUEPREDICATE SORT(created DESC) DISTINCT(dbChannelId)");
    _channelLists = dbResults.toList();
    notifyListeners();
  }

  void listenMessage() {
    RealmModel realmModel = Provider.of<RealmModel>(_context, listen: false);

    final dbDMResults = realmModel.realm.query<DBMessage>('TRUEPREDICATE SORT(created DESC) LIMIT(1)');
    final dbPubResults = realmModel.realm.query<DBMessage>("channelId != '' SORT(created DESC) DISTINCT(channelId)");
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);
    DBMessage? dbMessage = dbDMResults.isNotEmpty?dbDMResults.first:null;
    final publicKey = Nip19.decodePubkey(appRouter.nostrUserModel.currentUserSync!.publicKey);
    Filter filter1 = Filter(
      kinds: [4],
      p: [publicKey],
    );
    Filter filter2 = Filter(
      kinds: [4],
      authors: [publicKey],
    );
    if(dbMessage!=null) {
      filter1.since = dbMessage.created.millisecondsSinceEpoch~/ 1000;
      filter2.since = dbMessage.created.millisecondsSinceEpoch~/ 1000;
    }


    Filter? filter3;
    List<String> channelIds = [];
    if(dbPubResults.isNotEmpty){
      for(DBMessage dbPubMessage in dbPubResults){
        channelIds.add(dbPubMessage.channelId);
      }
    }
    if(channelIds.isNotEmpty){
      filter3 = Filter(
        kinds: [42],
        e: channelIds
      );
    }

    List<Filter> filters = [filter1, filter2];
    if(filter3!=null){
      filters.add(filter3);
    }

    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, filters);

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);

    relayPoolModel.getConnectSockets().then((websockets){
      websockets.forEach((key, value) {
        if(value!=null){
          value.add(requestWithFilter.serialize());
          value.listen((metaData) {
            final messageData = Message.deserialize(metaData);
            if (messageData.type == 'EVENT') {
              Event element = messageData.message as Event;
              String tmpChannelId = '';
              String replyId = '';
              String to = '';
              for (var tag in element.tags) {
                if(
                    element.kind == 42
                    && tag.first == 'e'
                    && tag[3] == 'root'
                ){
                  tmpChannelId = tag[1];
                }
                if(
                    element.kind == 42
                    && tag.first == 'e'
                    && tag[3] == 'reply'
                ){
                  replyId = tag[1];
                }
                if(
                    element.kind == 4
                    && tag.first == 'e'
                ){
                  replyId = tag[1];
                }
                if(tag.first == 'p'){
                  to = tag[1];
                }
              }

              String messageChannelId = '';
              if(element.kind == 4){
                List<String> tmpIds =[element.pubkey, to];
                tmpIds.sort();

                messageChannelId = md5.convert(utf8.encode(tmpIds.join(""))).toString();
              }
              if(element.kind == 42){
                messageChannelId = tmpChannelId;
              }

              DBMessage message =DBMessage(element.id, element.pubkey, element.content, DateTime.fromMillisecondsSinceEpoch(element.createdAt.toInt()*1000), tmpChannelId, replyId, to, element.serialize(), messageChannelId);
              realmModel.realm.writeAsync(() {
                realmModel.realm.add(message, update: true);
              }).then((value){
                refreshList();
              });

            }
          });
        }
      });
    });
  }

  UserInfo? getUser(String publicKey){
    RealmModel realmModel = Provider.of<RealmModel>(_context, listen: false);

    final findUser = realmModel.realm.find<DBUser>(publicKey);
    if(findUser!=null){
      return UserInfo.fromDBUser(findUser);
    }
    else{
      UserInfoModel(_context, publicKey).getUserInfo(refreshCallback: ()=>notifyListeners());
    }
    return null;
  }
}

