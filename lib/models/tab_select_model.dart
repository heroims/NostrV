import 'package:flutter/cupertino.dart';

class TabSelectModel extends ChangeNotifier {
  int selectIndex = 0;

  TabSelectModel(String tab){
    if(tab == 'feed') {
      selectIndex = 0;
    }
    if(tab == 'search') {
      selectIndex = 1;
    }
    if(tab == 'profile') {
      selectIndex = 2;
    }
  }
  void setIndex(int index){
    selectIndex = index;
    notifyListeners();
  }
}