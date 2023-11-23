import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    showDialog(
        context: _context,
        builder: (context) {
          final proKey = GlobalKey();
          return Dismissible(
            onDismissed: (direction) {}, key: proKey,
            child: const AlertDialog(
              content: Center(
                widthFactor: 1,
                heightFactor: 2,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                  ),
                ),
              ),
            ),
          );
        }
    );
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.addRelayWithUrl(relayUrl).then((value){
      Navigator.pop(_context);
      notifyListeners();
    }, onError: (_){
      Navigator.pop(_context);
    });
  }

  void removeRelay() {
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    relayPoolModel.deleteRelayWithUrl(relayUrl).then((value){
      notifyListeners();
    });
  }
}