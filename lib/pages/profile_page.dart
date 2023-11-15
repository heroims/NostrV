import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_header_model.dart';
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
                    PopupMenuItem<String>(
                      child: Text(S.of(context).userReplies),
                      onTap: () {
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Text(S.of(context).userUpvote),
                      onTap: () {
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Text(S.of(context).userReposts),
                      onTap: () {
                      },
                    ),
                  ];
                  if(pubKey!=Nip19.decodePubkey(appRouter.nostrUserModel.currentUserSync!.publicKey)){
                    menuItem.addAll([
                      PopupMenuItem<String>(
                        child: Text(S.of(context).reportUser),
                      ),
                      PopupMenuItem<String>(
                        child: Text(S.of(context).muteUser),
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
                      }
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