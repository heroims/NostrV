import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/event_list_model.dart';

import '../generated/l10n.dart';
import '../models/user_info_model.dart';
import '../router.dart';

import 'package:decimal/decimal.dart';

enum ZapItemCardType {
  send,
  receive,
}

class ZapItemCard extends StatelessWidget {
  final ZapItemCardType cardType;
  final EventListModel eventListModel;
  final int itemIndex;

  const ZapItemCard({super.key,required this.eventListModel,required this.itemIndex,required this.cardType});

  @override
  Widget build(BuildContext context) {
    Event event = eventListModel.eventList[itemIndex];
    String senderPubKey = '';
    String recipientPubKey = '';
    String bolt11 = '';
    for (var tag in event.tags) {
      if(tag.first == 'p') {
        recipientPubKey = tag[1];
      }
      if(tag.first == 'P') {
        senderPubKey = tag[1];
      }
      if(tag.first == 'bolt11') {
        bolt11 = tag[1];
      }
    }

    final bolt11Payment = Bolt11PaymentRequest(bolt11);
    final realAmount = bolt11Payment.amount * Decimal.parse('100000000');

    String userPubKey = recipientPubKey;

    switch (cardType) {
      case ZapItemCardType.send:
        userPubKey = recipientPubKey;
        break;
      case ZapItemCardType.receive:
        userPubKey = senderPubKey == '' ? recipientPubKey : senderPubKey;
        break;
      default:
        break;
    }

    UserInfo? user = eventListModel.getUser(userPubKey);

    String userId = Nip19.encodePubkey(userPubKey).toString().replaceRange(8, 57, ':');
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

    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(event.createdAt*1000));

    return Card(
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
                            &&pubKey==userPubKey
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

                      context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, userPubKey));
                    },
                    child: imageWidget,
                  )
              ),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                    child: Text(
                      userName,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight:  FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                    child: Text('amount:${realAmount.toStringAsFixed(2)}sats'),
                  ),
                ],
              ))
            ],
          )
        ],
      ),
    );
  }

}

