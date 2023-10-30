import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

class FeedListModel extends ChangeNotifier {
  late final EasyRefreshController _controller;
  late final BuildContext _context;
  String? pubKey;
  String? noteId;
  String? atUserId;

  Event? _noteFeed;
  Event? get noteFeed{
    return _noteFeed;
  }

  FeedListModel(this._controller,this._context, [this.pubKey, this.noteId, this.atUserId]);

  int _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int _limit = 10;

  final List<Event> feedList = [];
  final Map<String, UserInfoModel> userMap = {};

  UserInfo? getUser(String publicKey){
    if(userMap.containsKey(publicKey)){
      return userMap[publicKey]!.userInfo;
    }
    else{
      userMap[publicKey] = UserInfoModel(_context, publicKey);
      userMap[publicKey]!.getUserInfo();
      return null;
    }
  }

  void getNoteFeed(){
    if(noteId==null) return;
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
      kinds: [1],
      ids: [noteId!],
    );
    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.addRequest(relayPoolModel.relayWss.keys.first, requestWithFilter, (response){
      for(int i=0;i<relayPoolModel.relayWss.keys.length;i++){
        relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
          if (response.isNotEmpty){
            _noteFeed=response.first;
            notifyListeners();
          }
        });
      }
    });
  }

  void refreshFeed(){
    _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
      kinds: [1],
      until: _lastCreatedAt,
      limit: _limit,
    );
    List<String> tmpAuthors = [];
    List<String> tmpE = [];
    List<String> tmpP = [];
    if(pubKey != null) {
      tmpAuthors.add(pubKey!);
      filter.authors = tmpAuthors;
    }
    if(noteId != null) {
      tmpE.add(noteId!);
      filter.e = tmpE;
    }
    if(atUserId != null) {
      tmpP.add(atUserId!);
      filter.p = tmpP;
    }

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    feedList.clear();
    relayPoolModel.addRequest(relayPoolModel.relayWss.keys.first, requestWithFilter, (response){
      feedList.addAll(response.where((event2) => !feedList.any((event1) => event1.id == event2.id)));
      feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (feedList.isNotEmpty){
        _lastCreatedAt=feedList.last.createdAt;
      }
      notifyListeners();
      _controller.finishRefresh();
      _controller.resetFooter();

      for(int i=1;i<relayPoolModel.relayWss.keys.length;i++){
        relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
          feedList.addAll(response.where((event2) => !feedList.any((event1) => event1.id == event2.id)));
          feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (feedList.isNotEmpty){
            _lastCreatedAt=feedList.last.createdAt;
          }
          notifyListeners();
          _controller.finishLoad(response.isEmpty?IndicatorResult.noMore:IndicatorResult.success);
        });
      }
    });
  }

  void loadMoreFeed(){
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
      kinds: [1],
      until: _lastCreatedAt,
      limit: _limit,
    );
    List<String> tmpAuthors = [];
    List<String> tmpE = [];
    List<String> tmpP = [];
    if(pubKey != null) {
      tmpAuthors.add(pubKey!);
      filter.authors = tmpAuthors;
    }
    if(noteId != null) {
      tmpE.add(noteId!);
      filter.e = tmpE;
    }
    if(atUserId != null) {
      tmpP.add(atUserId!);
      filter.p = tmpP;
    }

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        feedList.addAll(response.where((event2) => !feedList.any((event1) => event1.id == event2.id)));
        feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (feedList.isNotEmpty){
          _lastCreatedAt=feedList.last.createdAt;
        }
        notifyListeners();
        _controller.finishLoad(response.isEmpty?IndicatorResult.noMore:IndicatorResult.success);
        notifyListeners();
      });
    });
  }

  void reportFeed(int index, String reportType) {
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [1984],
        e: [feedList[index].id, reportType],
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequestSingle(key, requestWithFilter, (response){
      });
    });
  }

  void isReportFeed(int index, String pubKey, Function(bool) callback) {
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [1984],
        authors: [pubKey],
        e: [feedList[index].id],
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    bool isReport = false;
    int tryCount = 0;
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        tryCount += 1;
        if(response.isNotEmpty) {
          isReport = true;
          callback(isReport);
        }
        if(tryCount>=relayPoolModel.relayWss.length){
          callback(isReport);
        }
      });
      if (isReport) {
        return;
      }

    });
  }
}