import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:nostr_app/models/user_info_model.dart';

import '../router.dart';
import 'nostr_user_model.dart';

class UserEditModel extends ChangeNotifier {
  final UserInfoModel userInfoModel;
  final List<TextEditingController> editControllers;

  UserEditModel(this.userInfoModel,this.editControllers);

  Future<String?> _postImage(String imgPath,BuildContext context,AppRouter appRouter,RelayPoolModel relayPoolModel) async{
    try{
      Dio dio = Dio();
      final formData = FormData();
      final tmpFile = await MultipartFile.fromFile(
          imgPath,
          contentType: MediaType.parse('image/jpeg')
      );
      formData.files.add(MapEntry('image', tmpFile));
      Response response = await dio.post(
        'https://nostrimg.com/api/upload',
        data: formData,
      );
      if(response.statusCode == 200){
        String  tmpImgUrl = response.data['data']['link'];
        return tmpImgUrl;
      }
    }
    catch(_){
      return null;
    }
  }


  Future<void> postAvatar(String imgPath,BuildContext context,AppRouter appRouter,RelayPoolModel relayPoolModel) async{
    String? tmpImgUrl = await _postImage(imgPath,context,appRouter,relayPoolModel);
    if(tmpImgUrl!=null){
      if(userInfoModel.userInfo!=null){
        userInfoModel.userInfo?.picture = tmpImgUrl;
      }
      else{
        editControllers[0].text = tmpImgUrl;
      }
      notifyListeners();
    }
  }

  Future<void> postBanner(String imgPath,BuildContext context,AppRouter appRouter,RelayPoolModel relayPoolModel) async{
    String? tmpImgUrl = await _postImage(imgPath,context,appRouter,relayPoolModel);
    if(tmpImgUrl!=null){
      if(userInfoModel.userInfo!=null){
        userInfoModel.userInfo?.banner = tmpImgUrl;
      }
      else{
        editControllers[1].text = tmpImgUrl;
      }
      notifyListeners();
    }
  }

  Future<void> postUserInfo(String jsonContent,BuildContext context,AppRouter appRouter,RelayPoolModel relayPoolModel) async{
    Completer<void> completer = Completer<void>();
    NostrUser? tmpUser = await appRouter.nostrUserModel.currentUser;
    if(tmpUser!=null){
      String decodeKey = Nip19.decodePrivkey(tmpUser.privateKey);
      Event tmpEvent = Event.from(kind: 0, content: jsonContent, privkey: decodeKey);
      relayPoolModel.addEventSingle(tmpEvent, (_) {
        completer.complete();
      });
    }
    return completer.future;
  }
}