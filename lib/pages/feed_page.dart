import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/models/feed_list_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return Card(

                  );
                }),
          ),
        );
      },
    );
  }
}