import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/cupertino.dart';
import 'package:nostr_app/models/realm_model.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:provider/provider.dart';

import '../router.dart';
import 'nostr_filter.dart';

class ChatListModel extends ChangeNotifier {
  late final EasyRefreshController _controller;
  late final BuildContext _context;

  String? userId;
  String? channelId;

  StreamSubscription? currentSubscription;

  ChatListModel(this._context, this._controller, {this.userId, this.channelId}){
    _loadMessage();
  }

  final int _limit = 10;
  int _readCount = 0;
  late List<DBMessage> _messageList;
  List<DBMessage> get messageList => _messageList;

  void _loadMessage(){
    if(currentSubscription!=null){
      currentSubscription!.cancel();
    }
    RealmModel realmModel = Provider.of<RealmModel>(_context, listen: false);
    if(userId!=null){
      AppRouter router = Provider.of<AppRouter>(_context, listen: false);

      String selfPubKey = router.nostrUserModel.currentUserSync!.publicKey;
      List<String> tmpIds =[selfPubKey, userId!];
      tmpIds.sort();

      String dbChannelId = md5.convert(utf8.encode(tmpIds.join(""))).toString();

      final dbResults = realmModel.realm.query<DBMessage>("dbChannelId == '$dbChannelId' SORT(created DESC) LIMIT($_readCount)");
      currentSubscription = dbResults.changes.listen((event) {
        _messageList = event.results.toList().reversed.toList();
        _readCount = _messageList.length;
        notifyListeners();
      });
      _messageList = dbResults.toList().reversed.toList();
      _readCount = _messageList.length;
    }

    if(channelId!=null){
      final dbResults = realmModel.realm.query<DBMessage>("channelId == '$channelId' SORT(created DESC) LIMIT($_readCount)");
      currentSubscription = dbResults.changes.listen((event) {
        _messageList = event.results.toList().reversed.toList();
        _readCount = _messageList.length;
        notifyListeners();
      });
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
}