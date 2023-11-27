import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../router.dart';
import 'nostr_user_model.dart';
class FeedPostModel extends ChangeNotifier {
  late TextEditingController textEditingController;
  List<String> imageUrls = [];
  String? noteId;

  FeedPostModel(this.textEditingController,{this.noteId});

  Future<void> postFeed(BuildContext context,AppRouter appRouter,RelayPoolModel relayPoolModel) async{
    List<String> postImgUrls = [];
    String postText = textEditingController.text;
    Dio dio = Dio();
    List<List<String>> tmpTag = [];
    for(int i = 0; i < imageUrls.length; i++) {
      final formData = FormData();
      final tmpFile = await MultipartFile.fromFile(
          imageUrls[i],
        contentType: MediaType.parse('image/jpeg')
      );
      formData.files.add(MapEntry('image', tmpFile));
      Response response = await dio.post(
          'https://nostrimg.com/api/upload',
          data: formData,
      );
      if(response.statusCode == 200){
        String  tmpImgUrl = response.data['data']['link'];
        postImgUrls.add(tmpImgUrl);
        tmpTag.add(['r', tmpImgUrl]);
      }
    }
    postText = '$postText\n${postImgUrls.join('\n')}';
    NostrUser? tmpUser = await appRouter.nostrUserModel.currentUser;
    if(tmpUser!=null){
      String decodeKey = Nip19.decodePrivkey(tmpUser.privateKey);
      Event tmpEvent = Event.from(kind: 1, content: postText, privkey: decodeKey);
      if(noteId!=null){
        tmpTag.add(['e', noteId!]);
      }
      if(tmpTag.isNotEmpty){
        tmpEvent.tags=tmpTag;
      }
      tmpEvent.id=tmpEvent.getEventId();
      tmpEvent.sig=tmpEvent.getSignature(decodeKey);
      relayPoolModel.addEventSingle(tmpEvent, (_) {

      });
    }
  }

  Future<void> deleteImage(int index) async{
    if(index < imageUrls.length){
      imageUrls.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> cameraAddImage() async{
    if(imageUrls.length>=9){
      return;
    }
    bool isGranted = await Permission.camera.request().isGranted;if(isGranted){
      final picker = ImagePicker();
      final cameraImg = await picker.pickImage(source: ImageSource.camera);
      if(cameraImg!=null){
        imageUrls.add(cameraImg.path);
        notifyListeners();
      }
    }
    else{
      openAppSettings();
    }
  }

  Future<void> photosAddImage() async{
    if(imageUrls.length>=9){
      return;
    }
    final picker = ImagePicker();

    if(Platform.isIOS){
      final status = await Permission.photos.request();
      if(status == PermissionStatus.granted
          || status == PermissionStatus.limited){
        final photoImg = await picker.pickMedia();
        if(photoImg!=null){
          imageUrls.add(photoImg.path);
          notifyListeners();
        }
      }
      else{
        openAppSettings();
      }
    }
    else if(Platform.isAndroid){
      final photoImg = await picker.pickMedia();
      if(photoImg!=null){
        imageUrls.add(photoImg.path);
        notifyListeners();
      }
    }
  }
}