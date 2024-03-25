import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/nostr_filter.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

class EventListModel extends ChangeNotifier {
  late final EasyRefreshController _controller;
  late final BuildContext _context;
  List<String>? pubKeys;
  String? noteId;
  String? atUserId;
  String? searchKey;
  List<int> kinds = [];

  EventListModel(this._controller,this._context, {this.pubKeys, this.noteId, this.atUserId, this.searchKey, List<int>? kinds}){
    if(kinds!=null){
      this.kinds.addAll(kinds);
      this.kinds = this.kinds.toSet().toList();
    }
    else{
      this.kinds.add(0);
    }
  }

  int _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int _limit = 10;

  final List<Event> eventList = [];

  void clearEvent(){
    eventList.clear();
    notifyListeners();
  }

  void refreshEvent({Function(List<Event>,bool)? refreshCallback}){
    _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final requestUUID =generate64RandomHexChars();
    NostrFilter filter = NostrFilter(
      kinds: kinds,
      until: _lastCreatedAt,
      limit: _limit,
    );
    List<String> tmpAuthors = [];
    List<String> tmpE = [];
    List<String> tmpP = [];
    List<String> tmpT = [];
    if(pubKeys != null) {
      tmpAuthors.addAll(pubKeys!);
      filter.authors = tmpAuthors.toSet().toList();
    }
    if(noteId != null) {
      tmpE.add(noteId!);
      filter.e = tmpE;
    }
    if(atUserId != null) {
      tmpP.add(atUserId!);
      filter.p = tmpP;
    }
    if(searchKey!=null){
      String replacedText = searchKey!;
      RegExp tagRegex = RegExp(r"(#\S+)");
      replacedText = replacedText.replaceAllMapped(
        tagRegex, (match) {
        String tag = match.group(0)!;
        tmpT.add(tag.replaceAll('#', ''));
        return '';
      },
      );
      if(replacedText.trim()!=''){
        filter.search=replacedText;
      }
      if(tmpT.isNotEmpty){
        filter.t=tmpT;
      }
    }

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    eventList.clear();
    relayPoolModel.addRequest(relayPoolModel.relayWss.keys.first, requestWithFilter, (response){
      eventList.addAll(response.where((event2) => !eventList.any((event1) => event1.id == event2.id)));
      eventList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (eventList.isNotEmpty){
        _lastCreatedAt=eventList.last.createdAt;
      }
      notifyListeners();
      if(_controller.controlFinishRefresh){
        _controller.finishRefresh();
        _controller.resetFooter();
        if(refreshCallback!=null){
          refreshCallback(response,true);
        }
      }

      for(int i=1;i<relayPoolModel.relayWss.keys.length;i++){
        relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
          eventList.addAll(response.where((event2) => !eventList.any((event1) => event1.id == event2.id)));
          eventList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (eventList.isNotEmpty){
            _lastCreatedAt=eventList.last.createdAt;
          }
          notifyListeners();
          _controller.finishLoad(response.isEmpty?IndicatorResult.noMore:IndicatorResult.success);
          if(refreshCallback!=null){
            refreshCallback(response,false);
          }
        });
      }
    });
  }

  void loadMoreEvent({Function(List<Event>)? refreshCallback}){
    final requestUUID =generate64RandomHexChars();
    NostrFilter filter = NostrFilter(
      kinds: kinds,
      until: _lastCreatedAt,
      limit: _limit,
    );
    List<String> tmpAuthors = [];
    List<String> tmpE = [];
    List<String> tmpP = [];
    List<String> tmpT = [];
    if(pubKeys != null) {
      tmpAuthors.addAll(pubKeys!);
      filter.authors = tmpAuthors.toSet().toList();
    }
    if(noteId != null) {
      tmpE.add(noteId!);
      filter.e = tmpE;
    }
    if(atUserId != null) {
      tmpP.add(atUserId!);
      filter.p = tmpP;
    }
    if(searchKey!=null){
      String replacedText = searchKey!;
      RegExp tagRegex = RegExp(r"(#\S+)");
      replacedText = replacedText.replaceAllMapped(
        tagRegex, (match) {
        String tag = match.group(0)!;
        tmpT.add(tag.replaceAll('#', ''));
        return '';
      },
      );
      if(replacedText.trim()!=''){
        filter.search=replacedText;
      }
      if(tmpT.isNotEmpty){
        filter.t=tmpT;
      }
    }

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        eventList.addAll(response.where((event2) => !eventList.any((event1) => event1.id == event2.id)));
        eventList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (eventList.isNotEmpty){
          _lastCreatedAt=eventList.last.createdAt;
        }
        notifyListeners();
        _controller.finishLoad(response.isEmpty?IndicatorResult.noMore:IndicatorResult.success);
        notifyListeners();
        if(refreshCallback!=null){
          refreshCallback(response);
        }
      });
    });
  }
}