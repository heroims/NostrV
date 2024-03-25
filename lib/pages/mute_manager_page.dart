import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_app/components/feed_item_card.dart';
import 'package:nostr_app/components/mute_user_card.dart';
import 'package:nostr_app/models/feed_list_model.dart';
import 'package:nostr_app/models/user_info_model.dart';

import 'package:provider/provider.dart';

import '../components/sliver_header.dart';
import '../generated/l10n.dart';
import '../router.dart';

class MuteManagerPage extends StatelessWidget {
  const MuteManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);

    final feedListModel = FeedListModel(EasyRefreshController(), context);
    feedListModel.refreshFeedFromIds(appRouter.nostrUserModel.currentUserInfo?.muteEvents.toList());
    final muteUsers = appRouter.nostrUserModel.currentUserInfo?.muteUsers.toList()??[];
    return Scaffold(
      appBar: AppBar(
        title:Text(S.of(context).settingByMute),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList.builder(
              itemCount: muteUsers.length,
              itemBuilder: (context, index) {
                final pubKey = muteUsers[index];
                UserInfoModel userInfoModel = UserInfoModel(context, pubKey);
                return ChangeNotifierProvider(
                  create: (_)=>userInfoModel,
                  builder: (context, child){
                    return Consumer<UserInfoModel>(builder: (context, model, child){
                      return MuteUserCard(userInfoModel: model,);
                    });
                  },
                );
              }
          ),
          SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate.fixedHeight(
                  height:  50,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      S.of(context).mutePost,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
              )
          ),
          ChangeNotifierProvider(
            create: (_)=> feedListModel,
            builder: (context, child){
              return Consumer<FeedListModel>(builder: (context, model, child){
                return SliverList.builder(
                    itemCount: model.feedList.length,
                    itemBuilder: (context, index) {
                      return FeedItemCard(feedListModel: model,itemIndex: index,cardType: FeedItemCardType.normal,);
                    }
                );
              });
            },
          ),
        ],
      ),
    );

  }
}