import 'package:flutter/cupertino.dart';
import 'package:nostr_app/models/user_info_model.dart';

class UserFollowModel extends ChangeNotifier {
  final UserInfoModel userInfoModel;

  UserFollowModel(this.userInfoModel);

  bool followersDownloaded = false;

  bool get followed {
    return userInfoModel.followed;
  }

  UserFollowings get followings{
    return userInfoModel.followings;
  }

  Map<String,UserFollowings> get followers{
    return userInfoModel.followers;
  }

  void following(bool followed){
    userInfoModel.following(followed);
    notifyListeners();
  }

  void getUserFollowing(){
    userInfoModel.getUserFollowing(refreshCallback: (){
      notifyListeners();
    });
  }

  void getUserFollower(){
    followersDownloaded=true;
    notifyListeners();
    userInfoModel.getUserFollower(refreshCallback: (){
      notifyListeners();
    });
  }

}