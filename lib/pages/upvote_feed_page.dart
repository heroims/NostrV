import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../router.dart';


class UpvoteFeedPage extends StatelessWidget {
  final String publicKey;
  const UpvoteFeedPage({super.key, required this.publicKey});

  @override
  Widget build(BuildContext context) {
    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    final feedListModel = EventListModel(controller,context,kinds: [7], pubKeys: [publicKey]);
    feedListModel.refreshEvent();

    return ChangeNotifierProvider(
      create: (_) => feedListModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).userUpvoteList),
          ),
          body: EasyRefresh(
            controller: controller,
            header: const BezierHeader(),
            footer: const ClassicFooter(),
            onRefresh: () => feedListModel.refreshEvent(),
            onLoad: () => feedListModel.loadMoreEvent(),
            child: Consumer<EventListModel>(
                builder:(context, model, child) {
                  return ListView.builder(
                      itemCount: model.eventList.length,
                      itemBuilder: (context, index) {
                        final event = model.eventList[index];
                        String feedId = S.of(context).cardOfError;
                        for (var tag in event.tags) {
                          if(tag.first=='e'){
                            feedId = tag[1];
                            break;
                          }
                        }
                        return GestureDetector(
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Text('${S.of(context).searchTabByPost}:$feedId', style: const TextStyle(fontSize: 16),),
                            ),
                          ),
                          onTap: (){
                            if(feedId==S.of(context).cardOfError){
                              return;
                            }
                            context.pushNamed(Routers.feedDetail.value,extra: feedId);
                          },
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