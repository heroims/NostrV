import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_info_model.dart';

import '../generated/l10n.dart';
import '../models/user_follow_model.dart';
import '../router.dart';

class UserItemCard extends StatelessWidget {
  final UserFollowModel userFollowModel;

  const UserItemCard({super.key, required this.userFollowModel});

  @override
  Widget build(BuildContext context) {
    UserFollowModel model = userFollowModel;
    UserInfo? user = model.userInfo;
    if(user==null){
      userFollowModel.getUserInfo();
    }
    String userId = model.userInfoModel.publicKey;
    try {
      String encodePubKey = Nip19.encodePubkey(model.userInfoModel.publicKey);
      userId = encodePubKey.toString().replaceRange(8, 57, ':');
    }
    catch(_){}

    String userName = user?.name??'';
    if(userName==''){
      userName = user?.userName??'';
    }
    if(userName==''){
      userName == user?.displayName;
    }

    if(userName==''){
      userName = userId;
    }

    String userAvatar = user?.picture??'';
    Widget defaultImageWidget = const Image(
      image: AssetImage("assets/img/avatar.png"),
    );
    Widget imageWidget = defaultImageWidget;
    if(userAvatar.isNotEmpty && userAvatar!=''){
      imageWidget =CachedNetworkImage(
        imageUrl: userAvatar,
        placeholder: (context , url){
          return defaultImageWidget;
        },
        errorWidget: (context, url, _) {
          return defaultImageWidget;
        },
      );
    }

    bool isFollow = model.followed;

    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10,),
                SizedBox(
                    width: 50,
                    height: 50,
                    child: imageWidget
                ),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: Text(
                        userName,
                      ),
                    ),
                  ],
                )),
                Container(
                  width: 100,
                  padding: const EdgeInsets.only(right: 15),
                  child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: isFollow?Colors.black26:Colors.blue,
                      onPressed: (){
                        model.following(!isFollow);
                      },
                      child: Text(isFollow?S.of(context).avatarCardByFollowed:S.of(context).avatarCardByFollow)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
      onTap: (){
        context.pushNamed(Routers.profile.value,queryParameters: {'id':Nip19.encodePubkey(model.userInfoModel.publicKey)});
      },
    );
  }

}