import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/nostr_user_model.dart';
import 'package:nostr_app/models/realm_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/realm/db_follower.dart';
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
        nip05 = (json['nip05']!=null&&(json['nip05'] is String))?json['nip05']:'',
        userName = json['username']??'',
        picture = json['picture']??'',
        displayName = json['display_name']??'',
        about = json['about']??'',
        name = json['name']??'';

  UserInfo.fromDBUser(DBUser user)
      : website = user.website??'',
        banner = user.banner??'',
        lud06 = user.lud06??'',
        lud16 = user.lud16??'',
        nip05 = user.nip05??'',
        userName = user.userName??'',
        picture = user.picture??'',
        displayName = user.displayName??'',
        about = user.about??'',
        name = user.name??'';

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

  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;

  UserFollowings _followings = UserFollowings();
  UserFollowings get followings => _followings;

  List<String> get followers {
    final dbFollowers =realmModel.realm.query<DBFollower>("publicKey == \$0", [publicKey]);
    if(dbFollowers.isNotEmpty){
      return dbFollowers.map((e) => e.follower).toList();
    }
    return [];
  }

  final followersLimit = 100;
  final followersLastTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  late RealmModel realmModel;

  String _lastFollowersRequestUUID = '';
  Map<String, WebSocket?> _privateSockets = {};
  bool _isDisposed = false;
  UserInfoModel(this._context, this.publicKey, {UserInfoModel? userInfoModel}){
    if(userInfoModel!=null){
      _followings = userInfoModel.followings;
      _userInfo = userInfoModel.userInfo;
    }
    realmModel = Provider.of<RealmModel>(_context, listen: false);

    final findUser = realmModel.realm.find<DBUser>(publicKey);
    if(findUser!=null){
      _userInfo = UserInfo.fromDBUser(findUser);
    }
  }

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
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    Request requestWithFilter = Request(requestUUID, [
      Filter(
        authors: [publicKey],
        kinds: [0],
      )
    ]);
    relayPoolModel.relayWss.forEach((key, value) {
      relayPoolModel.addRequestSingle(key, requestWithFilter, (event){
        if(event!=null) {
          if(!_isDisposed){
            _userInfo=UserInfo.fromJson(jsonDecode(event.content));

            realmModel.realm.write(() => realmModel.realm.add(DBUser(
                publicKey,
                name: userInfo?.name,
                userName: userInfo?.userName,
                displayName: userInfo?.displayName,
                website: userInfo?.website,
                lud06: userInfo?.lud06,
                lud16: userInfo?.lud16,
                nip05: userInfo?.nip05,
                about: userInfo?.about,
                picture: userInfo?.picture,
                banner: userInfo?.banner
            ),update: true));
            if(refreshCallback!=null){
              refreshCallback();
            }

            notifyListeners();
          }
        }
      });
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
  void stopGetUserFollower(){
    final requestUUID = _lastFollowersRequestUUID;
    if(requestUUID!=''){
      _privateSockets.forEach((key, value) {
        if(value!=null){
          value.add(Close(requestUUID).serialize());
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
            if(!_isDisposed) {
              try {
                Map<String, dynamic> relayInfo = jsonDecode(events.first.content);
                followings.relaysState.addAll(relayInfo);
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
            if(!_isDisposed) {
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
          }
        });
      }
    });


  }

  void getUserFollower({Function? refreshCallback}){
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(_context, listen: false);
    final requestUUID =generate64RandomHexChars();
    _lastFollowersRequestUUID = requestUUID;
    relayPoolModel.getConnectSockets().then((sockets){

      _privateSockets = sockets;

      Request requestWithFilter = Request(requestUUID, [
        Filter(
          kinds: [3],
          p:[publicKey],
        )
      ]);

      sockets.forEach((key, value) {
        final relayUrl = key;
        if(value!=null) {
          value.add(requestWithFilter.serialize());
          value.listen((eventData) {
            if(!_isDisposed){
              final message = Message.deserialize(eventData);

              if(message.type=='EOSE'){
                value.add(Close(requestUUID).serialize());
              }

              if(message.type=='EVENT'){
                final event =message.message;
                if(event is Event){
                  realmModel.realm.writeAsync((){
                    final tmpFollowings = UserFollowings();
                    try {
                      if(event.content.isNotEmpty){
                        final relayInfo = jsonDecode(event.content);
                        tmpFollowings.relaysState.addAll(relayInfo);
                      }
                    }
                    catch(_){
                    }
                    for (var tagElement in event.tags) {
                      if(tagElement.isNotEmpty && tagElement.first=='p') {
                        tmpFollowings.profiles[tagElement[1]]=Profile(tagElement[1], tagElement.length>2?tagElement[2]: relayUrl, tagElement.length>3?tagElement[3]:'');
                      }
                    }

                    followers.add(event.pubkey);
                    realmModel.realm.add(
                        DBFollower(
                            md5.convert(utf8.encode(publicKey+event.pubkey)).toString(),
                            publicKey,
                            event.pubkey
                        ),
                        update: true
                    );
                  });

                  if(refreshCallback!=null){
                    refreshCallback();
                  }
                  notifyListeners();
                }
              }

            }

          });
        }
      });
    });
  }

  @override
  void dispose() {
    stopGetUserFollower();
    _isDisposed = true;
    super.dispose();
  }
}