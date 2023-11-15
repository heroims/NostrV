import 'package:flutter/material.dart';
import 'package:nostr_app/components/user_item_card.dart';
import 'package:nostr_app/models/user_header_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';


class FollowingsPage extends StatelessWidget {
  final UserInfoModel userInfoModel;
  const FollowingsPage({super.key,required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>userInfoModel, lazy: false,),
        ],
        builder: (context, child){
          return Scaffold(
            appBar: AppBar(
              title:Text(S.of(context).avatarCardByFollowing),
            ),
            body: Consumer<UserInfoModel>(
                builder: (context, userModel, child){

                  if(userModel.followings.profiles.isEmpty){
                    userModel.getUserFollowing();
                  }

                  return ListView.builder(
                      itemCount: userModel.followings.profiles.values.length,
                      itemBuilder: (context, index) {
                        final profile = userModel.followings.profiles.values.elementAt(index);
                        UserFollowModel followModel = UserFollowModel(UserInfoModel(context, profile.key));
                        return ChangeNotifierProvider(
                          create: (_)=>followModel,
                          builder: (context, child){
                            return Consumer<UserFollowModel>(builder: (context, model, child){
                              return UserItemCard(userFollowModel: model,);
                            });
                          },
                        );
                      }
                  );;
                }
            ),

          );
        }
    );
  }
}