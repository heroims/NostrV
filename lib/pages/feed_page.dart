import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/components/feed_item_card.dart';
import 'package:nostr_app/models/feed_list_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

import '../router.dart';


class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);

    relayPoolModel.startRelayPool();

    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    final feedListModel = FeedListModel(controller,context);

    return ChangeNotifierProvider(
      create: (_) => feedListModel,
      builder: (context, child) {
        return Consumer<RelayPoolModel>(builder: (context, relayPoolModel, child){
          if(relayPoolModel.startedRelaysPool && feedListModel.feedList.isEmpty){
            feedListModel.refreshFeed();

            AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);

            appRouter.nostrUserModel.currentUserInfo?.getUserInfo();
            appRouter.nostrUserModel.currentUserInfo?.getMuteInfo();
            appRouter.nostrUserModel.currentUserInfo?.getUserFollowing();
            appRouter.nostrUserModel.currentUserInfo?.getLightningInfo();
          }
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
                          return FeedItemCard(feedListModel: model, itemIndex: index, cardType: FeedItemCardType.normal,);
                        });
                  }
              ),
            ),
          );
        });
      },
    );
  }
}