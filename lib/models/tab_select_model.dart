import 'package:flutter/cupertino.dart';
import 'package:nostr_app/router.dart';

class TabSelectModel extends ChangeNotifier {
  int selectIndex = 0;

  TabSelectModel(String tab){
    if(tab == Routers.feed.value) {
      selectIndex = 0;
    }
    if(tab == Routers.message.value) {
      selectIndex = 1;
    }
    if(tab == Routers.notify.value) {
      selectIndex = 2;
    }
  }
  void setIndex(int index){
    selectIndex = index;
    notifyListeners();
  }
}