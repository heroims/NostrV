import 'package:flutter/cupertino.dart';
import 'package:nostr_app/models/user_info_model.dart';

class UserFollowModel extends ChangeNotifier {
  final UserInfoModel userInfoModel;

  UserFollowModel(this.userInfoModel);

  bool followersDownloaded = false;
  bool _disposed = false;
  UserInfo? get userInfo{
    return userInfoModel.userInfo;
  }

  bool get followed {
    return userInfoModel.followed;
  }

  bool get supportLightning {
    return userInfoModel.supportLightning;
  }

  UserFollowings get followings{
    return userInfoModel.followings;
  }

  List<String> get followers{
    return userInfoModel.followers;
  }

  void following(bool followed){
    userInfoModel.following(followed);
    notifyListeners();
  }

  void getUserInfo(){
    userInfoModel.getUserInfo(refreshCallback: (){
      if(!_disposed) {
        notifyListeners();
      }
    });
  }

  void getUserFollowing(){
    userInfoModel.getUserFollowing(refreshCallback: (){
      if(!_disposed) {
        notifyListeners();
      }
    });
  }

  void getUserFollower(){
    followersDownloaded=true;
    notifyListeners();
    userInfoModel.getUserFollower(refreshCallback: (){
      if(!_disposed) {
        notifyListeners();
      }
    });
  }

  void getUserRelay(){
    userInfoModel.getUserRelay(refreshCallback: (){
      if(!_disposed){
        notifyListeners();
      }
    });
  }

  void getLightningInfo(){
    userInfoModel.getLightningInfo(refreshCallback: (){
      if(!_disposed){
        notifyListeners();
      }
    });
  }
  @override
  void dispose() {
    _disposed = true;
    userInfoModel.dispose();
    super.dispose();
  }

}