import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/globals/storage_setting.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

class UserInfo{
  final String website;
  final String lud06;
  final String displayName;
  final String about;
  final String name;
  final String picture;
  final String banner;

  UserInfo.fromJson(Map<String, dynamic> json)
      : website = json['website'],
        banner = json['banner'],
        lud06 = json['lud06'],
        picture = json['picture'],
        displayName = json['display_name'],
        about = json['about'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
    'website': website,
    'banner': banner,
    'lud06': lud06,
    'picture': picture,
    'display_name': displayName,
    'about': about,
    'name': name,
  };
}

class UserFollowings {
  late final Map<String, Profile> profiles = {};
  late final Map<String, dynamic> relaysState = {};

  void setUserFollowings(UserFollowings userFollowings){
    profiles.addAll(userFollowings.profiles);
    relaysState.addAll(userFollowings.relaysState);
  }
}

class UserInfoModel extends ChangeNotifier {
  late final BuildContext _context;
  late final String publicKey;
  late final UserInfo userInfo;

  final UserFollowings followings = UserFollowings();

  final Map<String,UserFollowings> followers = {};

  final followersLimit = 100;
  final followersLastTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String _lastFollowersRequestUUID = '';

  UserInfoModel(this._context, this.publicKey);

  void getUserInfo(){
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        authors: [publicKey],
        kinds: [0],
      )
    ]);
    relayPoolModel.addRequest(defaultRelayUrls.first, requestWithFilter, (events){
      if(events.isNotEmpty) {
        userInfo=UserInfo.fromJson(jsonDecode(events.first.content));
        notifyListeners();
      }
    });
  }

  void stopGetUserFollowing(){
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID = _lastFollowersRequestUUID;
    if(requestUUID!=''){
      relayPoolModel.relayWss.forEach((key, value) {
        final relayUrl = key;
        if(value!=null){
          relayPoolModel.stopRequestSingle(relayUrl, requestUUID);
        }
      });
    }
  }
  void getUserFollowing(){
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    _lastFollowersRequestUUID = requestUUID;
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        authors: [publicKey],
        kinds: [3],
      )
    ]);

    relayPoolModel.relayWss.forEach((key, value) {
      final relayUrl = key;
      if(value!=null){
        relayPoolModel.addRequest(relayUrl, requestWithFilter, (events){
          if(events.isNotEmpty) {
            followings.relaysState.addAll(jsonDecode(events.first.content));
            for (var element in events.first.tags) {
              if(element.isNotEmpty && element.first=='p') {
                followings.profiles[element[1]]=Profile(element[1], element.length>2?element[2]: relayUrl, element.length>3?element[3]:'');
              }
            }
            notifyListeners();
          }
        });
      }
    });
  }

  void getUserFollower(){
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        kinds: [3],
        p:[publicKey],
      )
    ]);

    relayPoolModel.relayWss.forEach((key, value) {
      final relayUrl = key;
      if(value!=null){
        relayPoolModel.addRequestSingle(relayUrl, requestWithFilter, (event){
          final tmpFollowings = UserFollowings();
          try {
            if(event.content.isNotEmpty){
              tmpFollowings.relaysState.addAll(jsonDecode(event.content));
            }
          }
          catch(_){
          }
          for (var tagElement in event.tags) {
            if(tagElement.isNotEmpty && tagElement.first=='p') {
              tmpFollowings.profiles[tagElement[1]]=Profile(tagElement[1], tagElement.length>2?tagElement[2]: relayUrl, tagElement.length>3?tagElement[3]:'');
            }
          }
          followers[event.pubkey] = tmpFollowings;
          notifyListeners();
        });
      }
    });
  }

  @override
  void dispose() {
    stopGetUserFollowing();
    super.dispose();
  }
}