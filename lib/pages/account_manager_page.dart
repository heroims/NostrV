import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/user_info_model.dart';
import '../router.dart';

class AccountManagerPage extends StatelessWidget {
  const AccountManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(S.of(context).settingByKey),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50,),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              showCupertinoDialog(context: context, builder: (context){
                return CupertinoAlertDialog(
                  title: Text(S.of(context).dialogByTitle),
                  content: Text(S.of(context).tipByLogout),
                  actions: [
                    TextButton(
                        onPressed: (){
                          final appRouter = Provider.of<AppRouter>(context, listen: false);
                          appRouter.nostrUserModel.removeCurrentNostrUser().then((_) {
                            context.go('/');
                          });
                        },
                        child: Text(S.of(context).btnByLogout)
                    ),
                    TextButton(
                        isSemanticButton:true,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).dialogByCancel)
                    )
                  ],
                );
              });
            }, child: Text(S.of(context).btnByLogout),),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              showCupertinoDialog(context: context, builder: (context){
                return CupertinoAlertDialog(
                  title: Text(S.of(context).dialogByTitle),
                  content: Text(S.of(context).tipByDeleteAccount),
                  actions: [
                    TextButton(
                        onPressed: (){
                          final relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);
                          final appRouter = Provider.of<AppRouter>(context, listen: false);
                          String privkey = Nip19.decodePrivkey(appRouter.nostrUserModel.currentUserSync!.privateKey);
                          UserInfo deleteUser = UserInfo.fromJson({'name': 'ACCOUNT_DELETED', 'display_name': 'ACCOUNT_DELETED'});
                          Event nip0 = Event.from(kind: 0, content: jsonEncode(deleteUser.toJson()), privkey: privkey);
                          Event nip03 = Event.from(kind: 3, content: '', privkey: privkey);
                          relayPoolModel.addEventSingle(nip0, (_){
                          });
                          relayPoolModel.addEventSingle(nip03, (_){
                          });
                          context.go('/');
                        },
                        child: Text(S.of(context).btnByDeleteAccount)
                    ),
                    TextButton(
                        isSemanticButton:true,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).dialogByCancel)
                    )
                  ],
                );
              });
            }, child: Text(S.of(context).btnByDeleteAccount),),
          ),
        ],
      ),
    );

  }
}