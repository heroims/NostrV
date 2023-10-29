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
import '../models/user_info_model.dart';
import '../router.dart';

class FeedItemCard extends StatelessWidget {

  final FeedListModel feedListModel;
  final int itemIndex;
  const FeedItemCard({super.key,required this.feedListModel,required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    final feed=feedListModel.feedList[itemIndex];
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
      String link = "nostr://search/$tag";
      String replacedLink = "<a href='$link' style='text-decoration: none'>$tag</a>"; // 替换为带有 <a> 标签的链接
      return replacedLink;
    },
    );
    String userId = Nip19.encodePubkey(feed.pubkey).toString().replaceRange(8, 57, ':');
    String userName = user?.name ?? userId;
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
    for (var element in feed.tags) {
      if(element.first=='e'){
        final nodeID = Nip19.encodeNote(element[1]).toString();
        replyText = "${S.of(context).feedByReply}${nodeID.replaceRange(8, nodeID.length-6, ':')}";
        break;
      }
    }

    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(feed.createdAt*1000));

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
                        context.pushNamed(Routers.userInfo.value,extra: feedListModel.userMap[feed.pubkey]);
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

                        },
                      ),
                    ),),
                    Container(
                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                      child: HtmlWidget(
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: (){}, icon: const Icon(Icons.chat_bubble_outline)),
                        IconButton(onPressed: (){}, icon: const Icon(Icons.thumb_up_off_alt_outlined)),
                        IconButton(onPressed: (){
                          Share.share(Nip19.encodeNote(feed.id));
                        }, icon: const Icon(Icons.share_outlined)),
                        IconButton(onPressed: (){
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context){
                                return CupertinoActionSheet(
                                  title: Text(S.of(context).dialogByTitle),
                                  message: Text(S.of(context).actionSheetByReport),
                                  actions: [
                                    CupertinoActionSheetAction(onPressed: (){
                                      appRouter.nostrUserModel.currentUser.then((user) {
                                        feedListModel.isReportFeed(itemIndex, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                          if(!isReport){
                                            feedListModel.reportFeed(itemIndex, 'nudity');
                                          }
                                          Navigator.pop(context);
                                        });
                                      });
                                    }, child: Text(S.of(context).reportByNudity)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      appRouter.nostrUserModel.currentUser.then((user) {
                                        feedListModel.isReportFeed(itemIndex, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                          if(!isReport){
                                            feedListModel.reportFeed(itemIndex, 'profanity');
                                          }
                                          Navigator.pop(context);
                                        });
                                      });
                                    }, child: Text(S.of(context).reportByProfanity)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      appRouter.nostrUserModel.currentUser.then((user) {
                                        feedListModel.isReportFeed(itemIndex, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                          if(!isReport){
                                            feedListModel.reportFeed(itemIndex, 'illegal');
                                          }
                                          Navigator.pop(context);
                                        });
                                      });
                                    }, child: Text(S.of(context).reportByIllegal)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      appRouter.nostrUserModel.currentUser.then((user) {
                                        feedListModel.isReportFeed(itemIndex, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                          if(!isReport){
                                            feedListModel.reportFeed(itemIndex, 'impersonation');
                                          }
                                          Navigator.pop(context);
                                        });
                                      });
                                    }, child: Text(S.of(context).reportByImpersonation)),
                                    CupertinoActionSheetAction(onPressed: (){
                                      appRouter.nostrUserModel.currentUser.then((user) {
                                        feedListModel.isReportFeed(itemIndex, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                          if(!isReport){
                                            feedListModel.reportFeed(itemIndex, 'spam');
                                          }
                                          Navigator.pop(context);
                                        });
                                      });
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

      },
    );
  }

}