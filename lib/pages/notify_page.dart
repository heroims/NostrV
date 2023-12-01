import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:nostr/nostr.dart';
import 'package:nostr_app/components/notify_item_card.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

import '../models/user_follow_model.dart';
import '../models/user_info_model.dart';

class NotifyPage extends StatelessWidget {
  const NotifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    final eventListModel = EventListModel(
        controller,
        context,
        atUserId: Nip19.decodePubkey(
          'npub10lgg9fa7cqfwqyk0amde4l08llpceudltwyqvzsltxg9mc9mx00sxvxpgc'
            // appRouter.nostrUserModel.currentUserSync!.publicKey
        ),
        kinds: [1,3,6,7,16],
    );

    return Consumer<RelayPoolModel>(builder: (context, relayPoolModel, child){
      if(relayPoolModel.startedRelaysPool&&eventListModel.eventList.isEmpty) {
        eventListModel.refreshEvent();
      }
      return ChangeNotifierProvider(
        create: (_) => eventListModel,
        builder: (context, child) {
          return Scaffold(
            body: EasyRefresh(
              controller: controller,
              header: const BezierHeader(),
              footer: const ClassicFooter(),
              onRefresh: () => eventListModel.refreshEvent(),
              onLoad: () => eventListModel.loadMoreEvent(),
              child: Consumer<EventListModel>(
                  builder:(context, model, child) {
                    return ListView.builder(
                        itemCount: model.eventList.length,
                        itemBuilder: (context, index) {
                          Event event = model.eventList[index];
                          UserFollowModel followModel = UserFollowModel(UserInfoModel(context, event.pubkey));
                          return NotifyItemCard(event: event, userFollowModel: followModel, );
                        });
                  }
              ),
            ),
          );
        },
      );
    });
  }
}