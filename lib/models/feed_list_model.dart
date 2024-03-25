import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/nostr_filter.dart';
import 'package:nostr_app/models/realm_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

import '../realm/db_user.dart';

class FeedListModel extends ChangeNotifier {
  late final EasyRefreshController _controller;
  late final BuildContext _context;
  String? pubKey;
  String? noteId;
  String? atUserId;
  String? searchKey;

  Event? _noteFeed;
  Event? get noteFeed{
    return _noteFeed;
  }

  Event? _rootNoteFeed;
  Event? get rootNoteFeed{
    return _rootNoteFeed;
  }

  final List<Event> previousFeedList = [];
  final Map<String, bool> upvoteFeedMap = {};

  FeedListModel(this._controller,this._context, {this.pubKey, this.noteId, this.atUserId, this.searchKey});

  int _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int _limit = 10;

  final List<Event> feedList = [];

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

  void getRootNoteFeed(String rootNoteId){
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
      kinds: [1],
      ids: [rootNoteId],
      limit: 1,
    );
    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    for(int i=0;i<relayPoolModel.relayWss.keys.length;i++){
      relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
        if (response.isNotEmpty){
          _rootNoteFeed=response.first;
          notifyListeners();
        }
      });
    }

  }

  void _getPreviousNoteFeeds(List<String> noteIds){
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
      kinds: [1],
      ids: noteIds,
      limit: noteIds.length
    );
    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    for(int i=0;i<relayPoolModel.relayWss.keys.length;i++){
      relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
        previousFeedList.addAll(response.where((event2) => !(previousFeedList.any((event1) => event1.id == event2.id) || appRouter.nostrUserModel.currentUserInfo!.muteEvents.any((muteEventId) => event2.id == muteEventId)  || appRouter.nostrUserModel.currentUserInfo!.muteUsers.any((mutePubKey) => event2.pubkey == mutePubKey))));
        previousFeedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        notifyListeners();

      });
    }
  }

  void getNoteFeed(Function? callback){
    if(noteId==null) return;
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
      kinds: [1],
      ids: [noteId!],
      limit: 1,
    );
    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    for(int i=0;i<relayPoolModel.relayWss.keys.length;i++){
      relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
        if (response.isNotEmpty){
          _noteFeed=response.first;
          notifyListeners();
          List<String> previousFeedIds = [];
          for (var element in _noteFeed!.tags) {
            if(element.length>3&&element.first=='e'&&element[3]=='root'){
              getRootNoteFeed(element[1]);
            }
            else if(element.first=='e'){
              previousFeedIds.add(element[1]);
            }
          }
          _getPreviousNoteFeeds(previousFeedIds);
        }

        if(callback!=null){
          callback();
        }
      });
    }
  }

  void clearFeed(){
    feedList.clear();
    notifyListeners();
  }

  void refreshFeedFromIds(List<String>? eventIds){
    if(eventIds==null || eventIds.isEmpty){
      return;
    }
    final requestUUID =generate64RandomHexChars();
    NostrFilter filter = NostrFilter(
      ids: eventIds,
    );

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    feedList.clear();
    relayPoolModel.addRequest(relayPoolModel.relayWss.keys.first, requestWithFilter, (response){
      feedList.addAll(response.where((event2) => !(feedList.any((event1) => event1.id == event2.id))));
      feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (feedList.isNotEmpty){
        _lastCreatedAt=feedList.last.createdAt;
      }
      notifyListeners();
      for(int i=1;i<relayPoolModel.relayWss.keys.length;i++){
        relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
          feedList.addAll(response.where((event2) => !(feedList.any((event1) => event1.id == event2.id))));
          feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (feedList.isNotEmpty){
            _lastCreatedAt=feedList.last.createdAt;
          }
          notifyListeners();
        });
      }
    });
  }

  void refreshFeed(){
    _lastCreatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final requestUUID =generate64RandomHexChars();
    NostrFilter filter = NostrFilter(
      kinds: [1],
      until: _lastCreatedAt,
      limit: _limit,
    );
    List<String> tmpAuthors = [];
    List<String> tmpE = [];
    List<String> tmpP = [];
    List<String> tmpT = [];
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

    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    feedList.clear();
    relayPoolModel.addRequest(relayPoolModel.relayWss.keys.first, requestWithFilter, (response){
      feedList.addAll(response.where((event2) => !(feedList.any((event1) => event1.id == event2.id) || appRouter.nostrUserModel.currentUserInfo!.muteEvents.any((muteEventId) => event2.id == muteEventId)  || appRouter.nostrUserModel.currentUserInfo!.muteUsers.any((mutePubKey) => event2.pubkey == mutePubKey))));
      feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (feedList.isNotEmpty){
        _lastCreatedAt=feedList.last.createdAt;
      }
      notifyListeners();
      if(_controller.controlFinishRefresh){
        _controller.finishRefresh();
        _controller.resetFooter();
      }

      for(int i=1;i<relayPoolModel.relayWss.keys.length;i++){
        relayPoolModel.addRequest(relayPoolModel.relayWss.keys.elementAt(i), requestWithFilter, (response){
          feedList.addAll(response.where((event2) => !(feedList.any((event1) => event1.id == event2.id)  || appRouter.nostrUserModel.currentUserInfo!.muteEvents.any((muteEventId) => event2.id == muteEventId)  || appRouter.nostrUserModel.currentUserInfo!.muteUsers.any((mutePubKey) => event2.pubkey == mutePubKey))));
          feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (feedList.isNotEmpty){
            _lastCreatedAt=feedList.last.createdAt;
          }
          notifyListeners();
          _controller.finishLoad(IndicatorResult.success);
        });
      }
    });
  }

  void loadMoreFeed(){
    final requestUUID =generate64RandomHexChars();
    NostrFilter filter = NostrFilter(
      kinds: [1],
      until: _lastCreatedAt,
      limit: _limit,
    );
    List<String> tmpAuthors = [];
    List<String> tmpE = [];
    List<String> tmpP = [];
    List<String> tmpT = [];
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
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        feedList.addAll(response.where((event2) => !(feedList.any((event1) => event1.id == event2.id)  || appRouter.nostrUserModel.currentUserInfo!.muteEvents.any((muteEventId) => event2.id == muteEventId)  || appRouter.nostrUserModel.currentUserInfo!.muteUsers.any((mutePubKey) => event2.pubkey == mutePubKey))));
        feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (feedList.isNotEmpty){
          _lastCreatedAt=feedList.last.createdAt;
        }
        notifyListeners();
        _controller.finishLoad(IndicatorResult.success);
        notifyListeners();
      });
    });
  }

  void reportFeed(String reportId, String reportType) {
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);
    Event event = Event.from(kind: 1984, content: '', tags: [['e', reportId, reportType]], privkey: Nip19.decodePrivkey((appRouter.nostrUserModel.currentUserSync)!.privateKey));

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.addEventSingle(event, (_){});
  }

  void isReportFeed(String reportId, String pubKey, Function(bool) callback) {
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [1984],
        authors: [pubKey],
        e: [reportId],
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

  void upvoteFeed(Event feed, bool upvote){
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);
    Event event = Event.from(
        kind: 7,
        content: upvote?'+':'',
        tags: [['e', feed.id],['p', feed.pubkey]],
        privkey: Nip19.decodePrivkey((appRouter.nostrUserModel.currentUserSync)!.privateKey)
    );
    upvoteFeedMap[feed.id]=upvote;
    notifyListeners();
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.addEventSingle(event, (_){});
  }

  void isUpvoteFeed(String upvoteId, String pubKey, Function(bool) callback) {
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [7],
        authors: [pubKey],
        e: [upvoteId],
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    bool isUpvote = false;
    int tryCount = 0;
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        tryCount += 1;
        if(response.isNotEmpty && response.first.content == '+') {
          isUpvote = true;
          callback(isUpvote);
        }
        if(tryCount>=relayPoolModel.relayWss.length){
          callback(isUpvote);
        }
      });
      if (isUpvote) {
        return;
      }

    });
  }

  void getUpvoteFeed(String upvoteId, String pubKey) {
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [7],
        authors: [pubKey],
        e: [upvoteId],
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    bool isUpvote = false;
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        if(response.isNotEmpty){
          upvoteFeedMap[upvoteId]=response.first.content=='+';
          notifyListeners();
        }
        if(response.isNotEmpty && response.first.content == '+') {
          isUpvote = true;
        }
      });
      if (isUpvote) {
        return;
      }
    });
  }

  void repostFeed(Event feed){
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);
    Event event1 = Event.from(
        kind: 6,
        content: feed.serialize(),
        tags: [['e', feed.id],['p', feed.pubkey]],
        privkey: Nip19.decodePrivkey((appRouter.nostrUserModel.currentUserSync)!.privateKey)
    );
    // Event event2 = Event.from(
    //     kind: 16,
    //     content: feed.serialize(),
    //     tags: [['e', feed.id], ['k', feed.kind.toString()],['p', feed.pubkey]],
    //     privkey: Nip19.decodePrivkey((appRouter.nostrUserModel.currentUserSync)!.privateKey)
    // );
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.addEventSingle(event1, (_){});
    // relayPoolModel.addEventSingle(event2, (_){});
  }

  void isRepostFeed(String repostId, String pubKey, Function(bool) callback) {
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [6],
        authors: [pubKey],
        e: [repostId],
      )
    ]);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    bool isRepost = false;
    int tryCount = 0;
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequest(key, requestWithFilter, (response){
        tryCount += 1;
        if(response.isNotEmpty) {
          isRepost = true;
          callback(isRepost);
        }
        if(tryCount>=relayPoolModel.relayWss.length){
          callback(isRepost);
        }
      });
      if (isRepost) {
        return;
      }

    });
  }
}