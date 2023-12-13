import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/chat_listen_model.dart';
import 'package:nostr_app/realm/db_message.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/user_info_model.dart';
import '../router.dart';

class MessageItemCard extends StatelessWidget {
  final ChatListenModel chatListenModel;
  final int itemIndex;

  const MessageItemCard({super.key,required this.chatListenModel,required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    final DBMessage dbMessage = chatListenModel.channelLists[itemIndex];
    Event feed = Message.deserialize(dbMessage.meta).message;
    UserInfo? user = chatListenModel.getUser(feed.pubkey);
    final selfPublicKey = Nip19.decodePubkey(appRouter.nostrUserModel.currentUserSync!.publicKey);
    bool isMine = false;
    if(feed.pubkey == selfPublicKey){
      isMine = true;
    }

    String tmpContent = feed.content;
    if(feed.kind == 4){
      if(isMine){
        for (var pTag in feed.tags) {
          if(pTag.first=='p'){
            (feed as EncryptedDirectMessage).pubkey = pTag[1];
            break;
          }
        }
      }
      final priKey = Nip19.decodePrivkey(appRouter.nostrUserModel.currentUserSync!.privateKey);
      tmpContent = (feed as EncryptedDirectMessage).getPlaintext(priKey);
      if(isMine){
        (feed as EncryptedDirectMessage).pubkey = selfPublicKey;
      }
    }
    String replacedText = tmpContent;
    String userId = Nip19.encodePubkey(feed.pubkey).toString().replaceRange(8, 57, ':');
    String userName = user?.name ?? '';
    if(userName==''){
      userName = user?.userName ?? '';
    }
    if(userName==''){
      userName == user?.displayName;
    }

    if(userName==''){
      userName = userId;
    }

    String userAvatar = user?.picture ?? '';
    Widget defaultImageWidget = const Image(
      image: AssetImage("assets/img/avatar.png"),
    );
    Widget imageWidget = defaultImageWidget;
    if(userAvatar.isNotEmpty){
      imageWidget =CachedNetworkImage(
        imageUrl: userAvatar,
        placeholder: (context , url){
          return defaultImageWidget;
        },
        errorWidget: (context, url, _) {
          return defaultImageWidget;
        },
      );
    }
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(feed.createdAt*1000));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10,),
              SizedBox(
                  width: 50,
                  height: 50,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: (){
                      final pageState = GoRouterState.of(context);

                      if(pageState.name.toString() == Routers.profile.value){
                        String? pubKey = pageState.uri.queryParameters['id'];
                        if(pubKey!=null){
                          pubKey = Nip19.decodePubkey(pubKey);
                        }
                        else {
                          if(pageState.extra!=null){
                            pubKey = (pageState.extra as UserInfoModel).publicKey;
                          }
                        }
                        if(
                        pubKey!=null
                            &&pubKey==feed.pubkey
                        ){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).tipByOnThisUser),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                        return;
                      }

                      context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, feed.pubkey));
                    },
                    child: imageWidget,
                  )
              ),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userName,
                        ),
                        Text(
                            formattedDate
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Text(
                      replacedText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 10,),
          const Divider(
            height: 0.5,
          ),
        ],
      ),
      onTap: (){
        if(feed.kind==4){
          context.pushNamed(
              Routers.chat.value,
              extra: {
                'publicKey': isMine?dbMessage.to:feed.pubkey,
                'refreshChannel': (){
                  chatListenModel.refreshList();
                }
              });
        }
        else if(feed.kind==42){
        }
      },
    );
  }
}
