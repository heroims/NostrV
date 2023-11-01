

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/feed_item_card.dart';
import '../generated/l10n.dart';
import '../models/feed_list_model.dart';

class FeedDetailPage extends StatelessWidget {
  final String noteId;

  const FeedDetailPage({super.key,required this.noteId});
  @override
  Widget build(BuildContext context) {
    final controller = EasyRefreshController(
      controlFinishRefresh: false,
      controlFinishLoad: true,
    );
    final feedListModel = FeedListModel(controller,context,noteId: noteId);

    feedListModel.getNoteFeed((){
      feedListModel.refreshFeed();
    });

    return ChangeNotifierProvider(
      create: (_) => feedListModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).userReplies),
          ),
          body: EasyRefresh(
            controller: controller,
            footer: const ClassicFooter(),
            onLoad: () => feedListModel.loadMoreFeed(),
            child:Consumer<FeedListModel>(
                builder:(context, model, child) {
                  List<Widget> slivers = [];
                  if (model.rootNoteFeed!=null){
                    slivers.add(
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              S.of(context).postDetailByRoot,
                              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                    );
                    slivers.add(
                        SliverToBoxAdapter(
                          child: FeedItemCard(feedListModel: model, itemIndex: 0, cardType: FeedItemCardType.root,),
                        )
                    );
                  }
                  if (model.previousFeedList.isNotEmpty){
                    slivers.add(
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              S.of(context).postDetailByPrevious,
                              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                    );
                    slivers.add(
                        SliverList.builder(
                            itemCount: model.previousFeedList.length,
                            itemBuilder: (context, index) {
                              return FeedItemCard(feedListModel: model, itemIndex: index, cardType: FeedItemCardType.previous,);
                            })
                    );
                  }
                  if (model.noteFeed!=null){
                    slivers.add(
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              S.of(context).postDetailByMain,
                              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                    );
                    slivers.add(
                        SliverToBoxAdapter(
                          child: FeedItemCard(feedListModel: model, itemIndex: 0, cardType: FeedItemCardType.main,),
                        )
                    );
                  }
                  if (model.feedList.isNotEmpty){
                    slivers.add(
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              S.of(context).postDetailByComment,
                              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                    );
                  }
                  slivers.add(
                      SliverList.builder(
                          itemCount: model.feedList.length,
                          itemBuilder: (context, index) {
                            return FeedItemCard(feedListModel: model, itemIndex: index, cardType: FeedItemCardType.normal,);
                          })
                  );
                  return CustomScrollView(
                    slivers: slivers,
                  );
                }
            ),
          ),
        );
      },
    );
  }
}
