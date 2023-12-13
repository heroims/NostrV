import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/components/chat_item_card.dart';
import 'package:nostr_app/models/chat_list_model.dart';
import 'package:nostr_app/models/chat_tool_model.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget{
  final String? publicKey;
  final String? channelId;
  final void Function()? refreshChannel;
  const ChatPage({super.key, this.publicKey, this.channelId, this.refreshChannel});

  @override
  Widget build(BuildContext context) {
    final editController = TextEditingController();
    final controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: false,
    );
    final chatListModel = ChatListModel(context, controller, userId: publicKey, channelId: channelId);


    AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context)=> chatListModel,
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context)=> ChatToolModel(context,editController,userId: publicKey,channelId: channelId,refreshChannel: refreshChannel),
          lazy: false,
        )
,      ],
      builder: (context, child){
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat'),
          ),
          body: EasyRefresh(
            controller: controller,
            header: const BezierHeader(),
            onRefresh: () => chatListModel.loadMoreMessage(),
            child: Column(
              children: [
                Expanded(child: Consumer<ChatListModel>(
                    builder:(context, model, child) {
                      return ListView.builder(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: model.messageList.length,
                          itemBuilder: (context, index) {
                            return ChatItemCard(chatListModel: model, itemIndex: index,);
                          }
                      );
                    }
                ),),
                Container(
                  color: Colors.grey[200],
                  child: Consumer<ChatToolModel>(
                      builder:(context, model, child){
                        final privateKey = Nip19.decodePrivkey(appRouter.nostrUserModel.currentUserSync!.privateKey);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    model.cameraAddImage(privateKey);
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined),
                                ),
                                const SizedBox(width: 5),
                                IconButton(
                                  onPressed: () {
                                    model.photosAddImage(privateKey);
                                  },
                                  icon: const Icon(Icons.photo_outlined),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10,bottom: 10),
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.only(left: 10),
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                    maxHeight: 150,
                                  ),
                                  child: TextField(
                                      controller: editController,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            model.clearInput();
                                          },
                                        ),
                                      )
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: (){
                                  model.sendMessage(privateKey);
                                },
                                icon: const Icon(Icons.send)
                            ),
                          ],
                        );
                      }
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}