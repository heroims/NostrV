import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/globals/storage_setting.dart';
import 'package:nostr_app/models/nostr_user_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/realm/db_user.dart';
import 'package:provider/provider.dart';

import '../router.dart';

class UserInfo{
  String website = '';
  String lud06 = '';
  String lud16 = '';
  String nip05 = '';
  String displayName = '';
  String userName = '';
  String about = '';
  String name = '';
  String picture = '';
  String banner = '';

  UserInfo.fromJson(Map<String, dynamic> json)
      : website = json['website']??'',
        banner = json['banner']??'',
        lud06 = json['lud06']??'',
        lud16 = json['lud16']??'',
        nip05 = json['nip05']??'',
        userName = json['username']??'',
        picture = json['picture']??'',
        displayName = json['display_name']??'',
        about = json['about']??'',
        name = json['name']??'';

  Map<String, dynamic> toJson() => {
    'website': website,
    'banner': banner,
    'lud06': lud06,
    'lud16': lud16,
    'nip05': nip05,
    'picture': picture,
    'display_name': displayName,
    'username': userName,
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
  UserInfo? userInfo;

  final UserFollowings followings = UserFollowings();

  final Map<String,UserFollowings> followers = {};

  final followersLimit = 100;
  final followersLastTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String _lastFollowersRequestUUID = '';

  UserInfoModel(this._context, this.publicKey);

  bool get followed {
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);
    if(appRouter.nostrUserModel.currentUserInfo!=null){
      UserInfoModel ownUserInfo = appRouter.nostrUserModel.currentUserInfo!;
      if(ownUserInfo.publicKey == publicKey){
        return true;
      }
      else{
        return ownUserInfo.followings.profiles.containsKey(publicKey);
      }
    }
    return false;
  }

  void following(bool followed) async{
    AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    NostrUser? tmpUser = await appRouter.nostrUserModel.currentUser;
    UserFollowings? tmpFollowings= appRouter.nostrUserModel.currentUserInfo?.followings;
    if(tmpUser!=null){
      String decodeKey = Nip19.decodePrivkey(tmpUser.privateKey);
      Event tmpEvent = Event.from(kind: 3, content: '', privkey: decodeKey);
      relayPoolModel.relayWss.forEach((key, value) {
        List<Profile> tmpProfiles = [];
        Profile tmpProfile = Profile(publicKey, key, userInfo?.userName??'');
        if(tmpFollowings!=null){
          if(followed){
            tmpFollowings.profiles[publicKey]=tmpProfile;
          }
          else{
            tmpFollowings.profiles.remove(publicKey);
          }
          tmpProfiles = tmpFollowings.profiles.values.toList();
        }
        else{
          tmpProfiles.add(tmpProfile);
        }
        notifyListeners();
        tmpEvent.tags=Nip2.toTags(tmpProfiles);
        tmpEvent.id=tmpEvent.getEventId();
        tmpEvent.sig=tmpEvent.getSignature(decodeKey);
        if(value!=null){
          value.add(tmpEvent.serialize());
        }
      });
    }
  }

  void getUserInfo({Function? refreshCallback}){
    // AppRouter appRouter = Provider.of<AppRouter>(_context, listen: false);

    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        authors: [publicKey],
        kinds: [0],
      )
    ]);
    relayPoolModel.addRequestSingle(defaultRelayUrls.first, requestWithFilter, (event){
      if(event!=null) {
        userInfo=UserInfo.fromJson(jsonDecode(event.content));
        // appRouter.realm.write(() => appRouter.realm.add(DBUser(
        //   publicKey,
        //   name: userInfo?.name,
        //   userName: userInfo?.userName,
        //   displayName: userInfo?.displayName,
        //   website: userInfo?.website,
        //   lud06: userInfo?.lud06,
        //   lud16: userInfo?.lud16,
        //   nip05: userInfo?.nip05,
        //   about: userInfo?.about,
        //   picture: userInfo?.picture,
        //   banner: userInfo?.banner
        // )));
        if(refreshCallback!=null){
          refreshCallback();
        }
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
  void getUserFollowing({Function? refreshCallback}){
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
            try {
              followings.relaysState.addAll(jsonDecode(events.first.content));
            }
            catch(_){}
            for (var element in events.first.tags) {
              if(element.isNotEmpty && element.first=='p') {
                followings.profiles[element[1]]=Profile(element[1], element.length>2?element[2]: relayUrl, element.length>3?element[3]:'');
              }
            }
            if(refreshCallback!=null){
              refreshCallback();
            }
            notifyListeners();
          }
        });
      }
    });
  }

  void getUserRelay({Function? refreshCallback}){
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    _lastFollowersRequestUUID = requestUUID;
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        authors: [publicKey],
        kinds: [10002],
      )
    ]);

    relayPoolModel.relayWss.forEach((key, value) {
      final relayUrl = key;
      if(value!=null){
        relayPoolModel.addRequest(relayUrl, requestWithFilter, (events){
          if(events.isNotEmpty) {
            for (var element in events.first.tags) {
              if(element.isNotEmpty && element.first=='r') {
                bool readValue = false;
                bool writeValue = false;
                if(element.length>2){
                  readValue = element[2]=='read';
                  writeValue = element[2]=='write';
                }
                if(element.length>3){
                  readValue = readValue | (element[3]=='read');
                  writeValue = writeValue | (element[3]=='write');
                }
                followings.relaysState[element[1]]={'read':readValue,'write':writeValue};
              }
            }
            if(refreshCallback!=null){
              refreshCallback();
            }
            notifyListeners();
          }
        });
      }
    });
  }

  void getUserFollower({Function? refreshCallback}){
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
          if(refreshCallback!=null){
            refreshCallback();
          }
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