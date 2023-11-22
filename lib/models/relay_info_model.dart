import 'package:flutter/cupertino.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

class RelayInfoModel extends ChangeNotifier{
  final BuildContext _context;
  RelayInfoModel(this._context,{required this.relayUrl});

  String relayUrl = "";
  bool get addStatus {
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    return relayPoolModel.relayWss.containsKey(relayUrl);
  }

  void addRelay() {
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.addRelayWithUrl(relayUrl).then((value){
      notifyListeners();
    });
  }

  void removeRelay() {
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.deleteRelayWithUrl(relayUrl).then((value){
      notifyListeners();
    });
  }
}