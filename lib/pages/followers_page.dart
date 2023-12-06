import 'package:flutter/material.dart';
import 'package:nostr_app/components/user_item_card.dart';
import 'package:nostr_app/models/user_follow_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';


class FollowersPage extends StatelessWidget {
  final UserInfoModel userInfoModel;
  const FollowersPage({super.key,required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>userInfoModel, lazy: false,),
        ],
        builder: (context, child){
          return Scaffold(
            appBar: AppBar(
              title:Text(S.of(context).avatarCardByFollowers),
            ),
            body: Consumer<UserInfoModel>(
                builder: (context, userModel, child){

                  if(userModel.followers.isEmpty){
                    userModel.getUserFollower();
                  }

                  return ListView.builder(
                      itemCount: userModel.followers.length,
                      itemBuilder: (context, index) {
                        final profileKey = userModel.followers[index];
                        UserFollowModel followModel = UserFollowModel(UserInfoModel(context, profileKey));
                        return ChangeNotifierProvider(
                          create: (_)=>followModel,
                          builder: (context, child){
                            return Consumer<UserFollowModel>(builder: (context, model, child){
                              return UserItemCard(userFollowModel: model,);
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