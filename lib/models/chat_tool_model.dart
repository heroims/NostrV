import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatToolModel extends ChangeNotifier {
  late TextEditingController textEditingController;

  String? userId;
  String? channelId;
  DBMessage? publicMessage;

  ChatToolModel(this.textEditingController,{this.userId, this.channelId,this.publicMessage});

  void clearInput(){
    textEditingController.text = '';
    notifyListeners();

  }

  void sendMessage(String privateKey, RelayPoolModel pool){
    if(textEditingController.text == ''){
      _sendText(textEditingController.text, privateKey, pool);
    }
  }

  void _sendText(String content, String privateKey, RelayPoolModel pool) {
    if(userId != null) {
      EncryptedDirectMessage event =
      EncryptedDirectMessage.redact(privateKey, userId!, content);

      pool.addEventSingle(event, (data) {
        notifyListeners();
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
        notifyListeners();
      });
    }
  }

  Future<void> _sendImage(String imgPath, String privateKey, RelayPoolModel pool) async{
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
      _sendText(tmpImgUrl, privateKey, pool);
    }
  }

  Future<void> cameraAddImage(String privateKey, RelayPoolModel pool) async{
    bool isGranted = await Permission.camera.request().isGranted;if(isGranted){
      final picker = ImagePicker();
      final cameraImg = await picker.pickImage(source: ImageSource.camera);
      if(cameraImg!=null){
        _sendImage(cameraImg.path, privateKey, pool);
      }
    }
    else{
      openAppSettings();
    }
  }

  Future<void> photosAddImage(String privateKey, RelayPoolModel pool) async{
    final picker = ImagePicker();

    if(Platform.isIOS){
      final status = await Permission.photos.request();
      if(status == PermissionStatus.granted
          || status == PermissionStatus.limited){
        final photoImg = await picker.pickMedia();
        if(photoImg!=null){
          _sendImage(photoImg.path, privateKey, pool);
        }
      }
      else{
        openAppSettings();
      }
    }
    else if(Platform.isAndroid){
      final photoImg = await picker.pickMedia();
      if(photoImg!=null){
        _sendImage(photoImg.path, privateKey, pool);
      }
    }
  }
}