import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

class FeedListModel extends ChangeNotifier {
  late final EasyRefreshController _controller;
  late final BuildContext _context;
  FeedListModel(this._controller,this._context);

  int _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int _limit = 10;

  final List<Event> feedList = [];

  void refreshFeed(){
    _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [1, 23],
        until: _lastCreatedAt,
        limit: _limit,
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    feedList.clear();
    relayPoolModel.addRequest(relayPoolModel.relayWss.keys.first, requestWithFilter, (response){
      feedList.addAll(response);
      _lastCreatedAt=feedList.last.createdAt;
      notifyListeners();
      _controller.finishRefresh();
      _controller.resetFooter();
      for(int i=1;i<relayPoolModel.relayWss.keys.length;i++){
        relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
          feedList.addAll(response);
          _lastCreatedAt=feedList.last.createdAt;
          notifyListeners();
          _controller.finishLoad(response.isEmpty?IndicatorResult.noMore:IndicatorResult.success);
        });
      }
    });
  }

  void loadMoreFeed(){
    _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [1, 23],
        until: _lastCreatedAt,
        limit: _limit,
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        feedList.addAll(response);
        _lastCreatedAt=feedList.last.createdAt;
        notifyListeners();
        _controller.finishLoad(response.isEmpty?IndicatorResult.noMore:IndicatorResult.success);
      });
    });
  }
}