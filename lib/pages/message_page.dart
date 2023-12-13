import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/components/message_item_card.dart';
import 'package:nostr_app/models/chat_listen_model.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatelessWidget{
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    ChatListenModel chatListenModel=ChatListenModel(context);
    chatListenModel.listenMessage();
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => chatListenModel,
        builder: (context, child){
          return Consumer<ChatListenModel>(
              builder: (context, model, child){
                return ListView.builder(
                    itemCount: model.channelLists.length,
                    itemBuilder: (context, index) {
                      return MessageItemCard(chatListenModel: model, itemIndex: index,);
                    }
                );
              });
        },
      ),
    );
  }

}