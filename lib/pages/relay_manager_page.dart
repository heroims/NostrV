import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/components/relay_item_card.dart';
import 'package:nostr_app/models/relay_info_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

import '../components/sliver_header.dart';
import '../generated/l10n.dart';
import '../models/relay_manager_model.dart';
import '../models/relay_pool_model.dart';

class RelayManagerPage extends StatelessWidget {
  final UserInfoModel userInfoModel;
  const RelayManagerPage({super.key,required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    TextEditingController editController = TextEditingController();
    final relayManagerModel = RelayManagerModel();
    final relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>relayManagerModel, lazy: false,),
        ],
        builder: (context, child){
          relayManagerModel.getRecommendRelays();
          return Scaffold(
            appBar: AppBar(
              title:Text(S.of(context).avatarCardByRelays),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text(S.of(context).dialogByTitle),
                          content: Column(
                            children: [
                              const SizedBox(height: 10,),
                              CupertinoTextField(
                                controller: editController,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  if(editController.text.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(S.of(context).dialogByInputFailed),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                    return;
                                  }
                                  relayPoolModel.addRelayWithUrl(editController.text).then((value){
                                    relayManagerModel.refreshRelays();
                                    editController.clear();
                                    Navigator.pop(context);
                                  },onError: (){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(S.of(context).dialogByAddFailed),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  });
                                },
                                child: Text(S.of(context).dialogByDone)
                            ),
                            TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: Text(S.of(context).createByCancel)
                            )
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
            body: Consumer<RelayManagerModel>(
                builder: (context, listModel, child){
                  final relayWss = relayPoolModel.relayWss.keys.toList();
                  return CustomScrollView(
                    slivers: [
                      SliverList.builder(
                          itemCount: relayWss.length,
                          itemBuilder: (context, index) {
                            final relayKey = relayWss[index];
                            RelayInfoModel relayInfoModel = RelayInfoModel(context,relayUrl: relayKey, relayManager: relayManagerModel);
                            return ChangeNotifierProvider(
                              create: (_)=>relayInfoModel,
                              builder: (context, child){
                                return Consumer<RelayInfoModel>(builder: (context, model, child){
                                  return RelayItemCard(relayModel: model,);
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
                              S.of(context).tipRecommendRelay,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        )
                      ),
                      SliverList.builder(
                          itemCount: listModel.recommendedRelays.length,
                          itemBuilder: (context, index) {
                            final relayKey = listModel.recommendedRelays[index];
                            RelayInfoModel relayInfoModel = RelayInfoModel(context,relayUrl: relayKey,relayManager: relayManagerModel);
                            return ChangeNotifierProvider(
                              create: (_)=>relayInfoModel,
                              builder: (context, child){
                                return Consumer<RelayInfoModel>(builder: (context, model, child){
                                  return RelayItemCard(relayModel: model,);
                                });
                              },
                            );
                          }
                      ),
                    ],
                  );
                }
            ),
          );
        }
    );
  }
}