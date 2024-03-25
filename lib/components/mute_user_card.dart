import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_info_model.dart';

import '../generated/l10n.dart';
import '../models/user_follow_model.dart';
import '../router.dart';

class MuteUserCard extends StatelessWidget {
  final UserInfoModel userInfoModel;

  final void Function(String publicKey) ? customOnTap;

  const MuteUserCard({super.key, this.customOnTap, required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    UserInfoModel model = userInfoModel;
    UserInfo? user = model.userInfo;
    if(user==null){
      model.getUserInfo();
    }
    String userId = model.publicKey;
    try {
      String encodePubKey = Nip19.encodePubkey(model.publicKey);
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
                    width: 45,
                    height: 45,
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(
                      icon: model.isMute ? const Icon(Icons.remove_circle_outline_outlined) : const Icon(Icons.add_circle_outlined),
                      onPressed: () {
                        if(model.isMute){
                          model.muting(context,false);
                        }
                        else{
                          model.muting(context,true);
                        }
                      },
                    )
                ),
              ],
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
      onTap: (){
        if(customOnTap!=null){
          customOnTap!(model.publicKey);
        }
        else{
          context.pushNamed(Routers.profile.value,queryParameters: {'id':Nip19.encodePubkey(model.publicKey)});
        }
      },
    );
  }

}