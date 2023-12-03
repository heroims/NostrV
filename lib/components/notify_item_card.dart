import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../models/user_follow_model.dart';
import '../router.dart';
import 'html_image_factory.dart';

class NotifyItemCard extends StatelessWidget {
  final UserInfo? userInfo;
  final UserFollowModel userFollowModel;
  final Event event;
  const NotifyItemCard({super.key, this.userInfo, required this.userFollowModel, required this.event});

  String getReplacedText(String postContent){
    RegExp linkRegex = RegExp(r"(https?://\S+)");
    String replacedText = postContent.replaceAllMapped(
      linkRegex, (match) {
      String link = match.group(0)!;

      if (link.toLowerCase().endsWith('.jpg')
          || link.toLowerCase().endsWith('.png')
          || link.toLowerCase().endsWith('.gif')
          || link.toLowerCase().endsWith('.bmp')
          || link.toLowerCase().endsWith('.jpeg')
          || link.toLowerCase().endsWith('.webp')
      ) {
        return "<img src='$link' />";
      } else if (link.endsWith('.mp4')) {
        return """
                              <video controls>
                                <source src='$link' type="video/mp4">
                                <code>VIDEO</code> support is not enabled.
                                <a href='$link'>$link</a>
                              </video>
                          """;
      } else if (link.endsWith('.mp3')) {
        return """
                              <audio controls>
                                <source src='$link'>
                                <code>AUDIO</code> support is not enabled.
                                <a href='$link'>$link</a>
                              </audio>
                          """;
      } else {
        String replacedLink = "<a href='$link'>$link</a>"; // 替换为带有 <a> 标签的链接
        return replacedLink;
      }
    },
    );

    RegExp tagRegex = RegExp(r"(#\S+)");
    replacedText = replacedText.replaceAllMapped(
      tagRegex, (match) {
      String tag = match.group(0)!;
      String link = "nostr://search?keyword=${Uri.encodeComponent(tag)}";
      String replacedLink = "<a href='$link' style='text-decoration: none'>$tag</a>"; // 替换为带有 <a> 标签的链接
      return replacedLink;
    },
    );

    RegExp atRegex = RegExp(r"(nostr:\S+)");
    replacedText = replacedText.replaceAllMapped(
      atRegex, (match) {
      String atText = match.group(0)!;
      try {
        if(atText.startsWith("nostr:npub")){
          atText=atText.replaceAll("nostr:", "");
          String atUserName = atText.replaceRange(8, 57, ':');

          String link = "nostr://${Routers.profile.value}?id=$atText";
          String replacedLink = "<a href='$link' style='text-decoration: none'>@$atUserName</a>"; // 替换为带有 <a> 标签的链接
          return replacedLink;
        }
      }
      catch(_) {}
      return atText;
    },
    );

    return replacedText;
  }

  void onTapContentLink(String url,  BuildContext context){
    if (url.startsWith(RegExp(r"(nostr://\S+)"))) {

      final pageState = GoRouterState.of(context);

      if(pageState.name.toString() == Routers.profile.value){
        String? pubKey = pageState.uri.queryParameters['id'];
        if(pubKey!=null){
          pubKey = Nip19.decodePubkey(pubKey);
        }
        else {
          if(pageState.extra!=null){
            pubKey = (pageState.extra as UserInfoModel).publicKey;
          }
        }
        if(
        pubKey!=null
            &&pubKey==url.replaceAll("nostr://${Routers.profile.value}?id=", "")
        ){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).tipByOnThisUser),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }

      context.push(url.replaceAll("nostr:/", ""));
    }
    else {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserFollowModel model = userFollowModel;
    UserInfo? user = userInfo;
    if(user==null){
      // userFollowModel.getUserInfo();
    }
    String userId = Nip19.encodePubkey(model.userInfoModel.publicKey).toString().replaceRange(8, 57, ':');
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
    Widget typeIcon = const Icon(Icons.person_outline);
    String tmpContent = "关注了您";
    String subContent = "";
    if(event.kind == 7){
      typeIcon = const Icon(Icons.thumb_up_off_alt);

      tmpContent = "点赞了";

      for (var element in event.tags) {
        if(element.first == 'e' && element.length > 1 && element[1].trim() != ''){
          final nodeID = Nip19.encodeNote(element[1]).toString();
          final replaceLink = "<a href='nostr://feed/detail?id=$nodeID'>${nodeID.replaceRange(8, nodeID.length-6, ':')}</a>";
          tmpContent = "$tmpContent $replaceLink";
          break;
        }
      }

      tmpContent = "$tmpContent ${event.content}";
    }
    if(event.kind == 6 || event.kind == 16){
      typeIcon = const Icon(Icons.autorenew_outlined);

      tmpContent = "转发了";

      for (var element in event.tags) {
        if(element.first == 'e' && element.length > 1 && element[1].trim() != ''){
          final nodeID = Nip19.encodeNote(element[1]).toString();
          final replaceLink = "<a href='nostr://feed/detail?id=$nodeID'>${nodeID.replaceRange(8, nodeID.length-6, ':')}</a>";
          tmpContent = "$tmpContent $replaceLink";
          break;
        }
      }

      if(event.content.trim()!=''){
        try {
          subContent = jsonDecode(event.content)['content'];
        }
        catch (_){
          subContent = event.content;
        }
      }
    }
    if(event.kind == 1){
      typeIcon = const Icon(Icons.chat_bubble_outline_rounded);

      tmpContent = "回复了";

      for (var element in event.tags) {
        if(element.first == 'e' && element.length > 1 && element[1].trim() != ''){
          final nodeID = Nip19.encodeNote(element[1]).toString();
          final replaceLink = "<a href='nostr://feed/detail?id=$nodeID'>${nodeID.replaceRange(8, nodeID.length-6, ':')}</a>";
          tmpContent = "$tmpContent $replaceLink";
          break;
        }
      }

      subContent = event.content;
    }

    String mainText = getReplacedText(tmpContent);
    subContent = getReplacedText(subContent);

    return Card(
      child: Column(
        children: [
          const SizedBox(height: 10,),
          GestureDetector(
            child: Row(
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
            onTap: (){
              context.pushNamed(Routers.profile.value,queryParameters: {'id':Nip19.encodePubkey(model.userInfoModel.publicKey)});
            },
          ),
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10,),
              SizedBox(
                height: 20,
                width: 20,
                child: typeIcon,
              ),
              Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: HtmlWidget(
                      mainText,
                      enableCaching: true,
                      factoryBuilder: ()=>PopupPhotoViewWidgetFactory(),
                      onTapUrl: (url) {
                        onTapContentLink(url, context);
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
                  )
              )
            ],
          ),
          const SizedBox(height: 10,),
          Visibility(
              visible: subContent != "",
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Container(
                    constraints: const BoxConstraints(
                        minWidth: double.infinity
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // 白底
                      borderRadius: BorderRadius.circular(10.0), // 圆角
                      border: Border.all(color: Colors.black, width: 1.0), // 黑框
                    ),
                    padding: const EdgeInsets.all(10),
                    child: HtmlWidget(
                      subContent,
                      enableCaching: true,
                      factoryBuilder: ()=>PopupPhotoViewWidgetFactory(),
                      onTapUrl: (url) {
                        onTapContentLink(url, context);
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
                  ),
                ),
                onTap: (){
                  context.pushNamed(Routers.feedDetail.value, extra: event.id);
                },
              )
          ),
          Visibility(
              visible: subContent != "",
              child: const SizedBox(height: 10,)
          ),
        ],
      ),
    );
  }

}