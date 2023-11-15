import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_header_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../models/user_info_model.dart';
import '../router.dart';

class UserHeaderCard extends StatelessWidget {
  final UserFollowModel userFollowModel;

  const UserHeaderCard({super.key,required this.userFollowModel});

  @override
  Widget build(BuildContext context) {
    UserFollowModel model = userFollowModel;
    UserInfo? user = model.userInfo;
    String originUserId = Nip19.encodePubkey(model.userInfoModel.publicKey).toString();
    String userId = originUserId.replaceRange(8, 57, ':');
    String userName = user?.name ?? '';
    if(userName==''){
      userName = user?.userName ?? '';
    }
    if(userName==''){
      userName == user?.displayName;
    }

    if(userName==''){
      userName = userId;
    }
    String userAvatar = user?.picture ?? '';
    Widget defaultImageWidget = const Image(
      image: AssetImage("assets/img/avatar.png"),
    );
    Widget imageWidget = defaultImageWidget;
    if(userAvatar.isNotEmpty){
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

    String tmpAbout = user?.about ?? '';
    RegExp linkRegex = RegExp(r"(https?://\S+)");
    String replacedText = tmpAbout.replaceAllMapped(
      linkRegex, (match) {
      String link = match.group(0)!;
      String replacedLink = "<a href='$link'>$link</a>"; // 替换为带有 <a> 标签的链接
      return replacedLink;
    },
    );

    RegExp tagRegex = RegExp(r"(#\S+)");
    replacedText = replacedText.replaceAllMapped(
      tagRegex, (match) {
      String tag = match.group(0)!;
      String link = "nostr://search/$tag";
      String replacedLink = "<a href='$link' style='text-decoration: none'>$tag</a>"; // 替换为带有 <a> 标签的链接
      return replacedLink;
    },
    );

    AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: imageWidget,
                ),
                if (originUserId != appRouter.nostrUserModel.currentUserSync!.publicKey) Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: CupertinoButton(
                          color: model.followed?Colors.black26:Colors.blue,
                          onPressed: (){
                            model.following(!model.followed);
                          },
                          child: Text(model.followed?S.of(context).avatarCardByFollowed:S.of(context).avatarCardByFollow)
                      ),
                    ),
                    const SizedBox(width: 10,),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          color: Colors.blue,
                          onPressed: (){},
                          child: const Icon(Icons.messenger)
                      ),
                    )
                  ],
                ) else SizedBox(
                  height: 50,
                  width: 120,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    color: Colors.blue,
                    onPressed: (){},
                    child: Text(S.of(context).avatarCardByEdit),
                  ),
                )
              ]
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Text(
                '@$userName',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                ),
              ),
              IconButton(
                  onPressed: (){
                    Clipboard.setData(ClipboardData(text: Nip19.encodePubkey(model.userInfoModel.publicKey))).then((value){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).copyToClipboard),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.copy))
            ],
          ),
          const SizedBox(height: 10,),
          HtmlWidget(
            replacedText,
            enableCaching: true,
            onTapUrl: (url) {
              if (url.startsWith(RegExp(r"(nostr://\S+)"))) {

              }
              else {
                launchUrl(Uri.parse(url));
              }
              return true;
            },
            customStylesBuilder: (element) {
              switch (element.localName) {
                case 'a':
                  return {'text-decoration': 'none'};
              }
              return null;
            },
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(child: CupertinoButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          model.followings.profiles.length.toString(),
                          style: const TextStyle(fontSize: 25)
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        S.of(context).avatarCardByFollowing,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  onPressed: (){
                    UserInfoModel pushUserModel= UserInfoModel(context, model.userInfoModel.publicKey,userInfoModel: model.userInfoModel);
                    context.pushNamed(Routers.followings.value,extra: pushUserModel);
                  })),
              Expanded(child: CupertinoButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      model.followersDownloaded?Text(
                          model.followers.length.toString(),
                          style: const TextStyle(fontSize: 25)
                      ):const Icon(Icons.download),
                      const SizedBox(height: 5,),
                      Text(
                        S.of(context).avatarCardByFollowers,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  onPressed: (){
                    if(model.followersDownloaded){
                      UserInfoModel pushUserModel= UserInfoModel(context, model.userInfoModel.publicKey,userInfoModel: model.userInfoModel);
                      context.pushNamed(Routers.followers.value,extra: pushUserModel);
                    }
                    else{
                      model.getUserFollower();
                    }
                  })),
              Expanded(child: CupertinoButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          model.followings.relaysState.length.toString(),
                          style: const TextStyle(fontSize: 25)
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        S.of(context).avatarCardByRelays,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  onPressed: (){

                  })),
            ],
          ),
        ],
      ),
    );
  }

}