import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/feed_list_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/l10n.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    final relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);
    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    final feedListModel = FeedListModel(controller,context);
    relayPoolModel.startRelayPool().then((value) {
      feedListModel.refreshFeed();
    });
    return ChangeNotifierProvider(
      create: (_) => feedListModel,
      builder: (context, child) {
        return Scaffold(
          body: EasyRefresh(
            controller: controller,
            header: const BezierHeader(),
            footer: const ClassicFooter(),
            onRefresh: () => feedListModel.refreshFeed(),
            onLoad: () => feedListModel.loadMoreFeed(),
            child: Consumer<FeedListModel>(
              builder:(context, model, child) {
                return ListView.builder(
                    itemCount: model.feedList.length,
                    itemBuilder: (context, index) {
                      final feed=model.feedList[index];
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

                      UserInfo? user = model.getUser(feed.pubkey);
                      String userName = user?.name ?? Nip19.encodePubkey(feed.pubkey).toString().replaceRange(8, 57, ':');
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
                      return Card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                  child: Text(
                                    userName,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                  child: HtmlWidget(
                                      replacedText,
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
                                    IconButton(onPressed: (){}, icon: const Icon(Icons.share_outlined)),
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
                                                    feedListModel.isReportFeed(index, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                                      if(!isReport){
                                                        feedListModel.reportFeed(index, 'nudity');
                                                      }
                                                      Navigator.pop(context);
                                                    });
                                                  });
                                                }, child: Text(S.of(context).reportByNudity)),
                                                CupertinoActionSheetAction(onPressed: (){
                                                  appRouter.nostrUserModel.currentUser.then((user) {
                                                    feedListModel.isReportFeed(index, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                                      if(!isReport){
                                                        feedListModel.reportFeed(index, 'profanity');
                                                      }
                                                      Navigator.pop(context);
                                                    });
                                                  });
                                                }, child: Text(S.of(context).reportByProfanity)),
                                                CupertinoActionSheetAction(onPressed: (){
                                                  appRouter.nostrUserModel.currentUser.then((user) {
                                                    feedListModel.isReportFeed(index, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                                      if(!isReport){
                                                        feedListModel.reportFeed(index, 'illegal');
                                                      }
                                                      Navigator.pop(context);
                                                    });
                                                  });
                                                }, child: Text(S.of(context).reportByIllegal)),
                                                CupertinoActionSheetAction(onPressed: (){
                                                  appRouter.nostrUserModel.currentUser.then((user) {
                                                    feedListModel.isReportFeed(index, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                                      if(!isReport){
                                                        feedListModel.reportFeed(index, 'impersonation');
                                                      }
                                                      Navigator.pop(context);
                                                    });
                                                  });
                                                }, child: Text(S.of(context).reportByImpersonation)),
                                                CupertinoActionSheetAction(onPressed: (){
                                                  appRouter.nostrUserModel.currentUser.then((user) {
                                                    feedListModel.isReportFeed(index, Nip19.decodePubkey(user!.publicKey), (isReport) {
                                                      if(!isReport){
                                                        feedListModel.reportFeed(index, 'spam');
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
                                    IconButton(onPressed: (){}, icon: const Icon(Icons.more_horiz_outlined)),
                                  ],
                                )
                              ],
                            ))
                          ],
                        ),
                      );
                    });
              }
            ),
          ),
        );
      },
    );
  }
}