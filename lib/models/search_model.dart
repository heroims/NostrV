import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:nostr_app/models/feed_list_model.dart';

class SearchModel extends ChangeNotifier {
  final FeedListModel feedListModel;
  final EventListModel userListModel;
  final TextEditingController editingController;
  String _searchKey = '';
  final List<Event> searchUsers = [];

  SearchModel({required this.feedListModel, required this.userListModel,required this.editingController});

  String get searchKey => _searchKey;
  void setSearchKey(String query){
    _searchKey = query;
    if(query.trim()!=''){
      feedListModel.searchKey = query;
      feedListModel.refreshFeed();

      userListModel.searchKey = query;
      userListModel.refreshEvent();
    }
    else{
      feedListModel.clearFeed();
      userListModel.clearEvent();
    }
    notifyListeners();
  }

  void clearSearchKey(){
    editingController.text = '';
    notifyListeners();
    setSearchKey('');
  }

  void loadMoreFeed(){
    if(_searchKey.trim()!='') {
      feedListModel.loadMoreFeed();
    }
  }

  void loadMoreUser(){
    if(_searchKey.trim()!='') {
      userListModel.loadMoreEvent();
    }
  }

}