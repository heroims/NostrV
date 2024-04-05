import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/router.dart';
import 'package:bech32/bech32.dart';

class ZapLightningModel extends ChangeNotifier {

  double _zapAmount = 0;

  ZapLightningModel();

  double get zapAmount => _zapAmount;
  set zapAmount(double value) {
    _zapAmount = value;
    notifyListeners();
  }

  Future<String?> getInvoiceCodeByLightning({required String callback,required String pubKey, required AppRouter appRouter, List<String>? relays}) async {

    try {
      String privkey = Nip19.decodePrivkey(appRouter.nostrUserModel.currentUserSync!.privateKey);

      Event event = Event.from(kind: 9734, content: '', privkey: privkey);

      Bech32Codec codec = Bech32Codec();
      Bech32 newBech = Bech32('lnurl', convertBits(utf8.encode(callback), 8, 5, true));
      String lnurl = codec.encode(newBech,1500);
      double realAmount = zapAmount*1000;
      event.tags = [
        ['amount', realAmount.toString()],
        ['p', pubKey],
        ['lnurl', lnurl],
      ];
      if(relays!=null){
        event.tags.add(['relays', ...relays]);
      }
      event.id = event.getEventId();
      event.sig = event.getSignature(privkey);

      Dio dio =Dio();
      final response = await dio.get('${callback}?amount=${realAmount}&nostr=${Uri.encodeFull(event.serialize())}&lnurl=${lnurl}');
      if(response.statusCode == 200){
        notifyListeners();
        return response.data['pr'];
      }
    }
    catch(_){

    }
    finally{
      notifyListeners();
    }
    return null;
  }

  Future<void> payInvoice({required String callback,required String invoice,required AppRouter appRouter,required String pubKey}
  ) async {

  }
}