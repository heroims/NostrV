
import 'package:flutter/cupertino.dart';

class MnemonicVerifyModel extends ChangeNotifier{
  List<String> _mnemonicList = [];

  List<String> _mnemonicShowList = [];

  List<String> get mnemonicShowList => _mnemonicShowList;

  set mnemonicShowList(List<String> value) {
    _mnemonicShowList = value;
    _mnemonicShowList.shuffle();
    notifyListeners();
  }

  final List<String> _mnemonicSetList = [];

  List<String> get mnemonicSetList => _mnemonicSetList;

  final Map<int,bool> _mnemonicShowSelect={};
  final List<int> _mnemonicToSetShow=[];

  MnemonicVerifyModel(List<String> mnemonic){
    _mnemonicList=mnemonic;
    mnemonicShowList=List.from(_mnemonicList);
  }

  bool selectMnemonicState(int index){
    if(_mnemonicSetList.length > index && _mnemonicList.length > index) {
      return _mnemonicSetList[index] == _mnemonicList[index];
    }
    return false;
  }

  bool selectShowMnemonicState(int index){
    return mnemonicShowList.length > index && (_mnemonicShowSelect.containsKey(index) ? (_mnemonicShowSelect[index]!) : false);
  }

  void selectMnemonicShow(int index) {
    if(mnemonicShowList.length>index){
      _mnemonicToSetShow.add(index);
      _mnemonicSetList.add(mnemonicShowList[index]);
      _mnemonicShowSelect[index]=true;
      notifyListeners();
    }
  }

  void unselectMnemonic(int index) {
    if(_mnemonicSetList.length>index && _mnemonicToSetShow.length>index){
      _mnemonicShowSelect[_mnemonicToSetShow[index]!]=false;
      _mnemonicSetList.removeAt(index);
      _mnemonicToSetShow.removeAt(index);
      notifyListeners();
    }
  }

}