import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/components/user_item_card.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:nostr_app/models/user_follow_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/contract_model.dart';


class ContractPage extends StatelessWidget {
  final String? keyword;
  const ContractPage({super.key,this.keyword});

  @override
  Widget build(BuildContext context) {

    final userController = EasyRefreshController(
      controlFinishRefresh: false,
      controlFinishLoad: true,
    );
    final editController = TextEditingController();

    final userListModel = EventListModel(userController, context, kinds: [0]);

    if(keyword!=null&&keyword!=""){
      editController.text = keyword!;
    }
    final searchListModel = ContractModel(userListModel: userListModel,editingController: editController);
    if(keyword!=null&&keyword!=""){
      editController.text = keyword!;
      searchListModel.setSearchKey(editController.text);
    }

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => userListModel),
          ChangeNotifierProvider(create: (context) => searchListModel)
        ],
        builder: (context, child){
          return Scaffold(
            appBar: AppBar(
              title:Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  height: 48,
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
                          child: Consumer<ContractModel>(
                              builder: (context,searchModel,child){
                                return TextField(
                                  controller: searchModel.editingController,
                                  style: const TextStyle(
                                      fontSize: 16
                                  ),
                                  decoration: InputDecoration(
                                    hintText: S.of(context).tipBySearchQuery,
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
            body: Consumer<ContractModel>(
                builder: (context,searchModel,child){
                  return EasyRefresh(
                    controller: userController,
                    footer: const ClassicFooter(),
                    onLoad: () => searchModel.loadMoreUser(),
                    child: Consumer<EventListModel>(
                        builder:(context, model, child) {
                          return ListView.builder(
                              itemCount: model.eventList.length,
                              itemBuilder: (context, index) {
                                final event = model.eventList[index];
                                UserFollowModel followModel = UserFollowModel(UserInfoModel(context, event.pubkey));
                                return ChangeNotifierProvider(
                                  create: (_)=>followModel,
                                  builder: (context, child){
                                    return Consumer<UserFollowModel>(builder: (context, model, child){
                                      return UserItemCard(userFollowModel: model, customOnTap: (publicKey){
                                        context.pushNamed(Routers.chat.value,extra:{"publicKey": publicKey});
                                      },);
                                    });
                                  },
                                );
                              }
                          );
                        }
                    ),
                  );
                }
            ),
          );
        },
    );
  }
}