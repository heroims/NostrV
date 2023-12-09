import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/feed_list_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../models/realm_model.dart';
import '../models/user_info_model.dart';
import '../realm/db_user.dart';
import '../router.dart';
import 'html_image_factory.dart';

enum ChatItemCardType {
  normal,
  previous,
  main,
  root
}

class ChatItemCard extends StatelessWidget {
  final ChatItemCardType cardType;
  final FeedListModel feedListModel;
  final int itemIndex;

  const ChatItemCard({super.key,required this.feedListModel,required this.itemIndex,required this.cardType});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    final Event feed = feedListModel.feedList[itemIndex];

    UserInfo? user = feedListModel.getUser(feed.pubkey);

    bool isMine = false;
    if(Nip19.encodePubkey(feed.pubkey) == appRouter.nostrUserModel.currentUserSync!.publicKey){
      isMine = true;
    }

    String tmpContent = feed.content;
    RegExp linkRegex = RegExp(r"(https?://\S+)");
    String replacedText = tmpContent.replaceAllMapped(
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
          final atUserOriginId = Nip19.decodePubkey(atText);

          RealmModel realmModel = Provider.of<RealmModel>(context, listen: false);

          final findUser = realmModel.realm.find<DBUser>(atUserOriginId);
          if(findUser!=null){
            final tmpUserInfo = UserInfo.fromDBUser(findUser);

            atUserName = tmpUserInfo.userName;
            if(atUserName == ''){
              atUserName = tmpUserInfo.displayName;
            }
            if(atUserName == ''){
              atUserName = tmpUserInfo.name;
            }
            if(atUserName == ''){
              atUserName = atText.replaceRange(8, 57, ':');
            }
          }
          else{
            UserInfoModel(context, atUserOriginId).getUserInfo();
          }

          String link = "nostr://${Routers.profile.value}?id=$atText";
          String replacedLink = "<a href='$link' style='text-decoration: none'>@$atUserName</a>"; // 替换为带有 <a> 标签的链接
          return replacedLink;
        }

      }
      catch(_) {}
      return atText;
    },
    );
    String userId = Nip19.encodePubkey(feed.pubkey).toString().replaceRange(8, 57, ':');
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

    String replyText = '';
    String atUserText = '';
    String originAtNodeID = '';
    for (var element in feed.tags) {
      if(element.first=='e' && replyText == '' && element[1]!=feed.id){
        originAtNodeID = element[1];
        final atNodeID = Nip19.encodeNote(originAtNodeID).toString();
        replyText = "${S.of(context).postByReply}${atNodeID.replaceRange(8, atNodeID.length-6, ':')}";
      }

      if(element.first=='p'){
        final atUserOriginId = element[1];
        final atUserID = Nip19.encodePubkey(atUserOriginId).toString();
        String atUserName = atUserID.replaceRange(8, 57, ':');

        RealmModel realmModel = Provider.of<RealmModel>(context, listen: false);

        final findUser = realmModel.realm.find<DBUser>(atUserOriginId);
        if(findUser!=null){
          final tmpUserInfo = UserInfo.fromDBUser(findUser);
          atUserName = tmpUserInfo.userName;
          if(atUserName == ''){
            atUserName = tmpUserInfo.displayName;
          }
          if(atUserName == ''){
            atUserName = tmpUserInfo.name;
          }
          if(atUserName == ''){
            atUserName = atUserID.replaceRange(8, 57, ':');
          }

        }
        else{
          UserInfoModel(context, atUserOriginId).getUserInfo();
        }
        atUserText = "<a href='nostr://${Routers.profile.value}?id=$atUserID' style='text-decoration: none'>@$atUserName</a> $atUserText";
      }
    }
    if(atUserText!=''){
      replacedText ="$replacedText<br/><br/>$atUserText";
    }
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(feed.createdAt*1000));

    bool upvote = false;
    if(feedListModel.upvoteFeedMap.containsKey(feed.id)){
      upvote = feedListModel.upvoteFeedMap[feed.id]?? false;
    }
    else{
      feedListModel.getUpvoteFeed(feed.id, Nip19.decodePubkey(appRouter.nostrUserModel.currentUserSync!.publicKey));
    }

    List<Widget> widgets = [const SizedBox(width: 10,),];
    if(isMine){
      widgets.add(Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: feed.kind!=4,
            child: Container(
              padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
              child: Text(
                userName,
              ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
          //   child: Text(
          //     formattedDate,
          //     style: const TextStyle(
          //       fontSize: 10,
          //       fontWeight:  FontWeight.bold,
          //     ),
          //   ),
          // ),
          // Visibility(visible: replyText != '',child: Container(
          //   height: 25,
          //   padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
          //   child: CupertinoButton(
          //     padding: const EdgeInsets.all(0),
          //     child: Text(
          //       replyText,
          //       style: const TextStyle(
          //         fontSize: 13,
          //       ),
          //     ),
          //     onPressed: (){
          //       final pageState = GoRouterState.of(context);
          //       if(
          //       pageState.name.toString() == Routers.feedDetail.value
          //           &&feedListModel.noteId!=null
          //           &&feedListModel.noteId==originAtNodeID
          //       ){
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text(S.of(context).tipByOnThisPost),
          //             duration: const Duration(seconds: 1),
          //           ),
          //         );
          //         return;
          //       }
          //       context.pushNamed(Routers.feedDetail.value,extra: originAtNodeID);
          //     },
          //   ),
          // ),),
          Container(
            padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
            child: HtmlWidget(
              replacedText,
              enableCaching: true,
              factoryBuilder: ()=>PopupPhotoViewWidgetFactory(),
              onTapUrl: (url) {
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
        ],
      )));
      widgets.add(SizedBox(
          width: 50,
          height: 50,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: (){
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
                    &&pubKey==feed.pubkey
                ){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).tipByOnThisUser),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
                return;
              }

              context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, feed.pubkey));
            },
            child: imageWidget,
          )
      ));
    }
    else{
      widgets.add(SizedBox(
          width: 50,
          height: 50,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: (){
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
                    &&pubKey==feed.pubkey
                ){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).tipByOnThisUser),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
                return;
              }

              context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, feed.pubkey));
            },
            child: imageWidget,
          )
      ));
      widgets.add(Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: feed.kind!=4,
            child: Container(
              padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
              child: Text(
                userName,
              ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
          //   child: Text(
          //     formattedDate,
          //     style: const TextStyle(
          //       fontSize: 10,
          //       fontWeight:  FontWeight.bold,
          //     ),
          //   ),
          // ),
          // Visibility(visible: replyText != '',child: Container(
          //   height: 25,
          //   padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
          //   child: CupertinoButton(
          //     padding: const EdgeInsets.all(0),
          //     child: Text(
          //       replyText,
          //       style: const TextStyle(
          //         fontSize: 13,
          //       ),
          //     ),
          //     onPressed: (){
          //       final pageState = GoRouterState.of(context);
          //       if(
          //       pageState.name.toString() == Routers.feedDetail.value
          //           &&feedListModel.noteId!=null
          //           &&feedListModel.noteId==originAtNodeID
          //       ){
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text(S.of(context).tipByOnThisPost),
          //             duration: const Duration(seconds: 1),
          //           ),
          //         );
          //         return;
          //       }
          //       context.pushNamed(Routers.feedDetail.value,extra: originAtNodeID);
          //     },
          //   ),
          // ),),
          Container(
            padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
            child: HtmlWidget(
              replacedText,
              enableCaching: true,
              factoryBuilder: ()=>PopupPhotoViewWidgetFactory(),
              onTapUrl: (url) {
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
        ],
      )));
    }
    return Card(
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ],
      ),
    );
  }

}

