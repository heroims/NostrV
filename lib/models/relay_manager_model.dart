import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';


class RelayManagerModel extends ChangeNotifier {
  List<dynamic> recommendedRelays = [];

  Future<void> getRecommendRelays() async{
    Dio dio = Dio();
    try{
      Response response = await dio.get(
        'https://api.nostr.watch/v1/online',
      );
      if(response.statusCode == 200){
        recommendedRelays = response.data;
        notifyListeners();
      }
    }
    catch(e){
      debugPrint(e.toString());
    }
  }

  void refreshRelays(){
    notifyListeners();
  }

  void addRelay(){
    notifyListeners();
  }

}