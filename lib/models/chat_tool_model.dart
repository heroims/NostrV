import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/realm_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatToolModel extends ChangeNotifier {
  final TextEditingController _textEditingController;
  final BuildContext  _context;
  final ScrollController _scrollController;

  late RealmToolModel realmModel;
  late RelayPoolModel pool;

  String? userId;
  String? channelId;
  DBMessage? publicMessage;
  final void Function()? refreshChannel;

  ChatToolModel(this._context, this._textEditingController, this._scrollController,{this.userId, this.channelId,this.publicMessage,this.refreshChannel}){
    realmModel = Provider.of<RealmToolModel>(_context, listen: false);
    pool = Provider.of<RelayPoolModel>(_context, listen: false);
  }

  void clearInput(){
    _textEditingController.text = '';
    notifyListeners();

  }

  void sendMessage(String privateKey){
    if(_textEditingController.text != ''){
      _sendText(_textEditingController.text, privateKey);
    }
  }

  void _sendText(String content, String privateKey) {
    if(userId != null) {
      EncryptedDirectMessage event =
      EncryptedDirectMessage.redact(privateKey, userId!, content);

      pool.addEventSingle(event, (data) {
        clearInput();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }

    if(channelId != null) {
      Event event = Event.from(kind: 42, content: content, privkey: privateKey);
      String relayUrl = "";

      for (var entry in pool.relayWss.entries) {
        if (entry.value != null) {
          relayUrl = entry.key;
          break;
        }
      }

      event.tags=[['e', channelId!, relayUrl, 'root']];
      if(publicMessage!=null) {
        event.tags.add(['e', publicMessage!.id, relayUrl, 'reply']);
        event.tags.add(['p', publicMessage!.from, relayUrl]);
      }
      event.id = event.getEventId();
      event.sig = event.getSignature(privateKey);
      pool.addEventSingle(event, (data) {
        clearInput();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendImage(String imgPath, String privateKey) async{
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
      _sendText(tmpImgUrl, privateKey);
    }
  }

  Future<void> cameraAddImage(String privateKey) async{
    bool isGranted = await Permission.camera.request().isGranted;if(isGranted){
      final picker = ImagePicker();
      final cameraImg = await picker.pickImage(source: ImageSource.camera);
      if(cameraImg!=null){
        _sendImage(cameraImg.path, privateKey);
      }
    }
    else{
      openAppSettings();
    }
  }

  Future<void> photosAddImage(String privateKey) async{
    final picker = ImagePicker();

    if(Platform.isIOS){
      final status = await Permission.photos.request();
      if(status == PermissionStatus.granted
          || status == PermissionStatus.limited){
        final photoImg = await picker.pickMedia();
        if(photoImg!=null){
          _sendImage(photoImg.path, privateKey);
        }
      }
      else{
        openAppSettings();
      }
    }
    else if(Platform.isAndroid){
      final photoImg = await picker.pickMedia();
      if(photoImg!=null){
        _sendImage(photoImg.path, privateKey);
      }
    }
  }
}