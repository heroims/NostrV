import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/event_list_model.dart';

class ContractModel extends ChangeNotifier {
  final EventListModel userListModel;
  final TextEditingController editingController;
  String _searchKey = '';
  final List<Event> searchUsers = [];

  ContractModel({required this.userListModel,required this.editingController});

  String get searchKey => _searchKey;
  void setSearchKey(String query){
    _searchKey = query;
    if(query.trim()!=''){
      userListModel.searchKey = query;
      userListModel.refreshEvent();
    }
    else{
      userListModel.clearEvent();
    }
    notifyListeners();
  }

  void clearSearchKey(){
    editingController.text = '';
    notifyListeners();
    setSearchKey('');
  }

  void loadMoreUser(){
    if(_searchKey.trim()!='') {
      userListModel.loadMoreEvent();
    }
  }

}