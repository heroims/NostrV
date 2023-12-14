import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/realm_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:provider/provider.dart';

import '../realm/db_user.dart';
import '../router.dart';

class ChatListModel extends ChangeNotifier {
  late final EasyRefreshController _controller;
  late final BuildContext _context;

  String? userId;
  String? channelId;
  late StreamSubscription _subscription;

  ChatListModel(this._context, this._controller, {this.userId, this.channelId}){
    RealmToolModel realmModel = Provider.of<RealmToolModel>(_context, listen: false);

    String dbChannelId = '';
    if(userId!=null){
      AppRouter router = Provider.of<AppRouter>(_context, listen: false);

      String selfPubKey = Nip19.decodePubkey(router.nostrUserModel.currentUserSync!.publicKey);
      List<String> tmpIds =[selfPubKey, userId!];
      tmpIds.sort();
      dbChannelId = md5.convert(utf8.encode(tmpIds.join(""))).toString();
    }
    if(channelId!=null){
      dbChannelId = channelId!;
    }
    final dbResults = realmModel.realm.query<DBMessage>("dbChannelId == '$dbChannelId' SORT(created DESC)");
    _subscription = dbResults.changes.listen((event) {
      if(event.inserted.isNotEmpty){
        for (var eIndex in event.inserted) {
          final insertDM = event.results[eIndex];

          _messageList.add(insertDM);
          _readCount+=1;
          _loadMessage();
        }}
    });

    loadMoreMessage();
  }

  final int _limit = 10;
  int _readCount = 0;
  late List<DBMessage> _messageList;
  List<DBMessage> get messageList => _messageList;

  UserInfo? getUser(String publicKey){
    RealmToolModel realmModel = Provider.of<RealmToolModel>(_context, listen: false);
    final findUser = realmModel.realm.find<DBUser>(publicKey);
    if(findUser!=null){
      return UserInfo.fromDBUser(findUser);
    }
    else{
      UserInfoModel(_context, publicKey).getUserInfo(refreshCallback: ()=>notifyListeners());
    }
    return null;
  }

  void _loadMessage(){

    RealmToolModel realmModel = Provider.of<RealmToolModel>(_context, listen: false);
    if(userId!=null){
      AppRouter router = Provider.of<AppRouter>(_context, listen: false);

      String selfPubKey = Nip19.decodePubkey(router.nostrUserModel.currentUserSync!.publicKey);
      List<String> tmpIds =[selfPubKey, userId!];
      tmpIds.sort();

      String dbChannelId = md5.convert(utf8.encode(tmpIds.join(""))).toString();

      final dbResults = realmModel.realm.query<DBMessage>("dbChannelId == '$dbChannelId' SORT(created DESC) LIMIT($_readCount)");
      _messageList = dbResults.toList().reversed.toList();
      _readCount = _messageList.length;
    }

    if(channelId!=null){
      final dbResults = realmModel.realm.query<DBMessage>("channelId == '$channelId' SORT(created DESC) LIMIT($_readCount)");
      _messageList = dbResults.toList().reversed.toList();
      _readCount = _messageList.length;
    }
    notifyListeners();
  }

  void loadMoreMessage({Function? refreshCallback}) {
    _readCount += _limit;
    _loadMessage();
    _controller.finishRefresh();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}