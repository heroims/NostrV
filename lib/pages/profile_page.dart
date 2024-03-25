import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_follow_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

import '../components/feed_item_card.dart';
import '../components/user_header_card.dart';
import '../generated/l10n.dart';
import '../models/feed_list_model.dart';
import '../router.dart';

class ProfilePage extends StatelessWidget {
  final UserInfoModel userInfoModel;

  const ProfilePage({super.key,required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    String pubKey = userInfoModel.publicKey;
    final feedListModel = FeedListModel(controller,context,pubKey:pubKey);

    feedListModel.refreshFeed();
    final userFollowModel = UserFollowModel(UserInfoModel(context,userInfoModel.publicKey, userInfoModel: userInfoModel));
    if(userFollowModel.userInfo==null){
      userFollowModel.getUserInfo();
    }
    userFollowModel.getUserFollowing();
    userFollowModel.getUserRelay();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedListModel>(
          create: (_) => feedListModel,
        ),
        ChangeNotifierProvider<UserFollowModel>(
          lazy: false,
          create: (_) => userFollowModel,
        )
      ],
      builder: (context, child) {
        final rightNavBtnKey = GlobalKey();
        AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);

        return Scaffold(
          appBar: AppBar(
            title: const Text(''),
            actions: [
              IconButton(
                key: rightNavBtnKey,
                icon: const Icon(Icons.more_horiz_outlined),
                onPressed: () {
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  final RenderBox button = rightNavBtnKey.currentContext!.findRenderObject() as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(button.size.center(Offset.zero), ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );
                  final menuItem = [
                    // PopupMenuItem<String>(
                    //   child: Text(S.of(context).userReplies),
                    //   onTap: () {
                    //   },
                    // ),
                    PopupMenuItem<String>(
                      child: Text(S.of(context).userUpvoteList),
                      onTap: () {
                        context.pushNamed(Routers.upvoteFeed.value, queryParameters: {'id':Nip19.encodePubkey(userFollowModel.userInfoModel.publicKey)});
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Text(S.of(context).userRepostsList),
                      onTap: () {
                        context.pushNamed(Routers.repostFeed.value, queryParameters: {'id':Nip19.encodePubkey(userFollowModel.userInfoModel.publicKey)});
                      },
                    ),
                  ];
                  if(pubKey!=Nip19.decodePubkey(appRouter.nostrUserModel.currentUserSync!.publicKey)){
                    menuItem.addAll([
                      PopupMenuItem<String>(
                        child: Text(S.of(context).reportUser),
                        onTap: (){
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context){
                                void reportFeed(String reportType){
                                  appRouter.nostrUserModel.currentUser.then((user) {
                                    userInfoModel.isReportUser(pubKey, (isReport) {
                                      if(!isReport){
                                        userInfoModel.reportUser(reportType);
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
                        }
                      ),
                      PopupMenuItem<String>(
                        child: Text(userInfoModel.muted?S.of(context).unMuteUser: S.of(context).muteUser),
                        onTap: () {
                          if(userInfoModel.muted){
                            userInfoModel.muting(context,false).then((value){
                              Navigator.pop(context);
                            });
                          }
                          else{
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text(S.of(context).dialogByTitle),
                                  content: Column(
                                    children: [
                                      const SizedBox(height: 10,),
                                      Text(S.of(context).dialogByMuteDescribe),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: (){
                                          userInfoModel.muting(context,true).then((value){
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(S.of(context).dialogByMute)
                                    ),
                                    TextButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        child: Text(S.of(context).createByCancel)
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ]);
                  }
                  showMenu(
                    context: context,
                    position: position,
                    items: menuItem,
                  );
                },
              )
            ],
          ),
          body: EasyRefresh(
            controller: controller,
            header: const BezierHeader(),
            footer: const ClassicFooter(),
            onRefresh: () => feedListModel.refreshFeed(),
            onLoad: () => feedListModel.loadMoreFeed(),
            child: CustomScrollView(
                slivers: [
                  Consumer<UserFollowModel>(
                      builder: (context, model, child){
                        return SliverToBoxAdapter(
                          child: UserHeaderCard(userFollowModel: model,),
                        );
                      },
                  ),
                  Consumer<FeedListModel>(
                      builder:(context, model, child) {
                        return SliverList.builder(
                            itemCount: model.feedList.length,
                            itemBuilder: (context, index) {
                              return FeedItemCard(feedListModel: model, itemIndex: index, cardType: FeedItemCardType.normal,);
                            });
                      }
                  )
                ]
            ),
          ),
        );
      },
    );
  }
}