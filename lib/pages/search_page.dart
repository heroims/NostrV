import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/components/user_item_card.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:nostr_app/models/search_model.dart';
import 'package:nostr_app/models/user_follow_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

import '../components/feed_item_card.dart';
import '../generated/l10n.dart';
import '../models/feed_list_model.dart';


class SearchPage extends StatelessWidget {
  final String? keyword;
  const SearchPage({super.key,this.keyword});

  @override
  Widget build(BuildContext context) {
    final feedController = EasyRefreshController(
      controlFinishRefresh: false,
      controlFinishLoad: true,
    );
    final userController = EasyRefreshController(
      controlFinishRefresh: false,
      controlFinishLoad: true,
    );
    final editController = TextEditingController();
    final feedListModel = FeedListModel(feedController, context);
    final userListModel = EventListModel(userController, context, kinds: [0]);
    final searchListModel = SearchModel(feedListModel: feedListModel, userListModel: userListModel,editingController: editController);
    if(keyword!=null&&keyword!=""){
      editController.text = keyword!;
      searchListModel.setSearchKey(editController.text);
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_)=>feedListModel,
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_)=>userListModel,
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_)=>searchListModel,
          lazy: false,
        )
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title:Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 1,
                        spreadRadius: 1,
                      )
                    ]
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.search,color: Colors.black45,),
                    ),
                    Expanded(
                      child: Consumer<SearchModel>(
                        builder: (context,searchModel,child){
                          return TextField(
                            controller: searchModel.editingController,
                            style: const TextStyle(
                                fontSize: 18
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your search query',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchModel.clearSearchKey();
                                },
                              ),
                            ),
                            onSubmitted: (value) {
                              searchModel.setSearchKey(value);
                            },
                          );
                        }
                      )
                    ),
                    // 其他内容
                  ],
                ),
              ),
            ),
          ),
          body: DefaultTabController(length: 2,
            child: Column(
              children: [
                TabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          S.of(context).searchTabByPost,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold
                          ),
                          selectionColor: Colors.cyan,
                        ),
                      ),
                      Tab(
                        child: Text(
                          S.of(context).searchTabByUser,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold
                          ),
                          selectionColor: Colors.cyan,
                        ),
                      )
                    ]
                ),
                Consumer<SearchModel>(
                    builder: (context,searchModel,child){
                      return Expanded(
                          child: TabBarView(children: [
                            EasyRefresh(
                              controller: feedController,
                              footer: const ClassicFooter(),
                              onLoad: () => searchModel.loadMoreFeed(),
                              child: Consumer<FeedListModel>(
                                  builder:(context, model, child) {
                                    return CustomScrollView(
                                      slivers: [
                                        SliverList.builder(
                                            itemCount: model.feedList.length,
                                            itemBuilder: (context, index) {
                                              return FeedItemCard(feedListModel: model, itemIndex: index, cardType: FeedItemCardType.normal,);
                                            }
                                        ),
                                      ],
                                    );
                                  }
                              ),
                            ),
                            EasyRefresh(
                              controller: userController,
                              footer: const ClassicFooter(),
                              onLoad: () => searchModel.loadMoreUser(),
                              child: Consumer<EventListModel>(
                                  builder:(context, model, child) {
                                    return CustomScrollView(
                                      slivers: [
                                        SliverList.builder(
                                            itemCount: model.eventList.length,
                                            itemBuilder: (context, index) {
                                              final event = model.eventList[index];
                                              UserInfo user = UserInfo.fromJson(jsonDecode(event.content));
                                              UserFollowModel followModel = UserFollowModel(UserInfoModel(context, event.pubkey));
                                              return ChangeNotifierProvider(
                                                create: (_)=>followModel,
                                                builder: (context, child){
                                                  return Consumer<UserFollowModel>(builder: (context, model, child){
                                                    return UserItemCard(userInfo: user,userFollowModel: model,);
                                                  });
                                                },
                                              );
                                            }
                                        ),
                                      ],
                                    );
                                  }
                              ),
                            )
                          ],
                          )


                      );
                    }
                ),
              ],
            ),

          ),

        );
      },
    );
  }
}