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

enum FeedItemCardType {
  normal,
  previous,
  main,
  root
}

class FeedItemCard extends StatelessWidget {
  final FeedItemCardType cardType;
  final FeedListModel feedListModel;
  final int itemIndex;

  const FeedItemCard({super.key,required this.feedListModel,required this.itemIndex,required this.cardType});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    late final Event feed;
    switch(cardType){
      case FeedItemCardType.normal:
        feed=feedListModel.feedList[itemIndex];
        break;
      case FeedItemCardType.previous:
        feed=feedListModel.previousFeedList[itemIndex];
        break;
      case FeedItemCardType.main:
        feed=feedListModel.noteFeed!;
        break;
      case FeedItemCardType.root:
        feed=feedListModel.rootNoteFeed!;
        break;
    }

    UserInfo? user = feedListModel.getUser(feed.pubkey);

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
    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10,),
                SizedBox(
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
                    Container(
                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight:  FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(visible: replyText != '',child: Container(
                      height: 25,
                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: Text(
                          replyText,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        onPressed: (){
                          final pageState = GoRouterState.of(context);
                          if(
                          pageState.name.toString() == Routers.feedDetail.value
                              &&feedListModel.noteId!=null
                              &&feedListModel.noteId==originAtNodeID
                          ){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).tipByOnThisPost),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          context.pushNamed(Routers.feedDetail.value,extra: originAtNodeID);
                        },
                      ),
                    ),),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: (){
                          context.pushNamed(Routers.feedPost.value,extra: feed.id);
                        }, icon: const Icon(Icons.chat_bubble_outline)),
                        IconButton(onPressed: (){
                          feedListModel.upvoteFeed(feed,!upvote);
                        }, icon: Icon(upvote ? Icons.thumb_up: Icons.thumb_up_off_alt_outlined)),
                        IconButton(onPressed: (){
                          showCupertinoModalPopup(context: context, builder: (context){
                            return CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                    onPressed: (){
                                      feedListModel.repostFeed(feed);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(S.of(context).tipByReposted),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(S.of(context).repostByPostID),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: (){
                                      Share.share(Nip19.encodeNote(feed.id));
                                      Navigator.pop(context);
                                    },
                                    child: Text(S.of(context).shareByPostID),
                                  ),
                                  CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                      child: Text(S.of(context).createByCancel)
                                  ),
                                ]
                            );
                          });

                        }, icon: const Icon(Icons.share_outlined)),
                        IconButton(onPressed: (){
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context){
                                void reportFeed(String reportType){
                                  appRouter.nostrUserModel.currentUser.then((user) {
                                    feedListModel.isReportFeed(feed.id, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                      if(!isReport){
                                        feedListModel.reportFeed(feed.id, reportType);
                                      }
                                      else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(S.of(context).tipReportRepeatedly),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                      Navigator.pop(context);
                                    });
                                  });
                                }

                                return CupertinoActionSheet(
                                  title: Text(S.of(context).dialogByTitle),
                                  message: Text(S.of(context).actionSheetByReport),
                                  actions: [
                                    CupertinoActionSheetAction(onPressed: (){
                                      reportFeed('nudity');
                                    }, child: Text(S.of(context).reportByNudity)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      reportFeed('profanity');
                                    }, child: Text(S.of(context).reportByProfanity)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      reportFeed('illegal');
                                    }, child: Text(S.of(context).reportByIllegal)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      reportFeed('impersonation');
                                    }, child: Text(S.of(context).reportByImpersonation)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      reportFeed('spam');
                                    }, child: Text(S.of(context).reportBySpam)),
                                    CupertinoActionSheetAction(
                                        isDestructiveAction: true,
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        child: Text(S.of(context).createByCancel)),
                                  ],
                                );
                              });
                        }, icon: const Icon(Icons.report_problem_outlined)),
                        IconButton(onPressed: (){
                          showCupertinoModalPopup(context: context, builder: (context){
                            return CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                    onPressed: (){
                                      Clipboard.setData(ClipboardData(text: Nip19.encodeNote(feed.id))).then((value){
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(S.of(context).copyToClipboard),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }).catchError((_) {
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text(S.of(context).copyByPostID),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: (){
                                      Clipboard.setData(ClipboardData(text: Nip19.encodePubkey(feed.pubkey))).then((value){
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(S.of(context).copyToClipboard),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }).catchError((_) {
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text(S.of(context).copyByUserID),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: (){
                                      Clipboard.setData(ClipboardData(text: feed.content)).then((value){
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(S.of(context).copyToClipboard),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }).catchError((_){
                                        Navigator.pop(context);
                                      });

                                    },
                                    child: Text(S.of(context).copyByPost),
                                  ),
                                  CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                      child: Text(S.of(context).createByCancel)
                                  ),
                                ]
                            );
                          });
                        }, icon: const Icon(Icons.more_horiz_outlined)),
                      ],
                    )
                  ],
                ))
              ],
            )
          ],
        ),
      ),
      onTap: (){
        final pageState = GoRouterState.of(context);
        if(
        pageState.name.toString() == Routers.feedDetail.value
            &&feedListModel.noteId!=null
            &&feedListModel.noteId==feed.id
        ){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).tipByOnThisPost),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
        context.pushNamed(Routers.feedDetail.value,extra: feed.id);
      },
    );
  }

}

