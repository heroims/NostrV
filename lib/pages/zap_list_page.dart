import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/components/zap_item_card.dart';
import 'package:nostr_app/models/event_list_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
class ZapReceiveListModel extends EventListModel{
  ZapReceiveListModel(super.controller, super.context, {super.atUserId, super.kinds});
}

class ZapSendListModel extends EventListModel{
  ZapSendListModel(super.controller, super.context, {super.zapSenderId, super.kinds});
}

class ZapListPage extends StatelessWidget {
  final String publicKey;
  const ZapListPage({super.key, required this.publicKey});

  @override
  Widget build(BuildContext context) {
    final sendController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    final receiveController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    final sendListModel = ZapSendListModel(sendController,context,kinds: [9735], zapSenderId: publicKey);
    final receiveListModel = ZapReceiveListModel(sendController,context,kinds: [9735], atUserId: publicKey);

    sendListModel.refreshEvent(refreshCallback: (response ,isRefresh)=>{});
    receiveListModel.refreshEvent(refreshCallback: (response ,isRefresh)=>{});

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> sendListModel),
        ChangeNotifierProvider(create: (_)=> receiveListModel),
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).userZapsList),
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          S.of(context).navByZapSend,
                          style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold
                          ),
                          selectionColor: Colors.cyan,
                        ),
                      ),
                      Tab(
                        child: Text(
                          S.of(context).navByZapReceive,
                          style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold
                          ),
                          selectionColor: Colors.cyan,
                        ),
                      ),
                    ]
                ),
                Expanded(
                    child: TabBarView(
                      children: [
                        EasyRefresh(
                          controller: sendController,
                          header: const BezierHeader(),
                          footer: const ClassicFooter(),
                          onRefresh: () => sendListModel.refreshEvent(
                              refreshCallback: (response ,isRefresh){
                              }
                          ),
                          onLoad: () => sendListModel.loadMoreEvent(
                              refreshCallback: (response){
                              }
                          ),
                          child: Consumer<ZapSendListModel>(
                            builder: (_,eventListModelBySend,child) {
                              return ListView.builder(
                                  itemCount: eventListModelBySend.eventList.length,
                                  itemBuilder: (context, index) {
                                    return ZapItemCard(eventListModel: eventListModelBySend, itemIndex: index, cardType: ZapItemCardType.send);
                                  });
                            },
                          ),
                        ),
                        EasyRefresh(
                          controller: receiveController,
                          header: const BezierHeader(),
                          footer: const ClassicFooter(),
                          onRefresh: () => receiveListModel.refreshEvent(
                              refreshCallback: (response ,isRefresh){
                              }
                          ),
                          onLoad: () => receiveListModel.loadMoreEvent(
                              refreshCallback: (response){
                              }
                          ),
                          child: Consumer<ZapReceiveListModel>(
                            builder: (_,eventListModelByReceive,child){
                              return ListView.builder(
                                  itemCount: eventListModelByReceive.eventList.length,
                                  itemBuilder: (context, index) {
                                    return ZapItemCard(eventListModel: eventListModelByReceive, itemIndex: index, cardType: ZapItemCardType.receive);
                                  });
                            },
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}