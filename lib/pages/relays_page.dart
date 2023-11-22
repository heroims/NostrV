import 'package:flutter/material.dart';
import 'package:nostr_app/components/relay_item_card.dart';
import 'package:nostr_app/models/relay_info_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';

class RelaysPage extends StatelessWidget {
  final UserInfoModel userInfoModel;
  const RelaysPage({super.key,required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>userInfoModel, lazy: false,),
        ],
        builder: (context, child){
          return Scaffold(
            appBar: AppBar(
              title:Text(S.of(context).avatarCardByRelays),
            ),
            body: Consumer<UserInfoModel>(
              builder: (context, userModel, child){
                if(userModel.followings.relaysState.isEmpty){
                  userModel.getUserFollowing();
                }

                return ListView.builder(
                    itemCount: userModel.followings.relaysState.values.length,
                    itemBuilder: (context, index) {
                      final relayKey = userModel.followings.relaysState.keys.elementAt(index);
                      RelayInfoModel relayInfoModel = RelayInfoModel(context,relayUrl: relayKey);
                      return ChangeNotifierProvider(
                        create: (_)=>relayInfoModel,
                        builder: (context, child){
                          return Consumer<RelayInfoModel>(builder: (context, model, child){
                            return RelayItemCard(relayModel: model,);
                          });
                        },
                      );
                    }
                );
              }
            ),
          );
        }
    );
  }
}