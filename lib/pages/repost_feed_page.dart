import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

import '../components/feed_item_card.dart';
import '../generated/l10n.dart';
import '../models/feed_list_model.dart';
import '../router.dart';


class RepostFeedPage extends StatelessWidget {
  final String publicKey;
  const RepostFeedPage({super.key, required this.publicKey});

  @override
  Widget build(BuildContext context) {
    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);



    final eventListModel = EventListModel(controller,context,kinds: [6], pubKeys: [publicKey]);
    final feedListModel = FeedListModel(EasyRefreshController(),context);

    void subRefreshFeed(List<Event> response,bool isRefresh){
      feedListModel.feedList.addAll(response.map((e) => Event.fromJson(jsonDecode(e.content))).where((event2) => !(feedListModel.feedList.any((event1) => event1.id == event2.id) || appRouter.nostrUserModel.currentUserInfo!.muteEvents.any((muteEventId) => event2.id == muteEventId)  || appRouter.nostrUserModel.currentUserInfo!.muteUsers.any((mutePubKey) => event2.pubkey == mutePubKey))));
      feedListModel.feedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      feedListModel.refreshFeed();
    }
    eventListModel.refreshEvent(refreshCallback: (response ,isRefresh)=>subRefreshFeed(response ,isRefresh));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> eventListModel),
        ChangeNotifierProvider(create: (_)=> feedListModel),
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).userRepostsList),
          ),
          body: EasyRefresh(
            controller: controller,
            header: const BezierHeader(),
            footer: const ClassicFooter(),
            onRefresh: () => eventListModel.refreshEvent(
                refreshCallback: (response ,isRefresh){
                  subRefreshFeed(response,isRefresh);
                }
            ),
            onLoad: () => eventListModel.loadMoreEvent(
              refreshCallback: (response){
                subRefreshFeed(response,false);
              }
            ),
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
      },
    );
  }
}