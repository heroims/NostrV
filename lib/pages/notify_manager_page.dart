import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../router.dart';

class NotifyManagerPage extends StatefulWidget {
  const NotifyManagerPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return NotifyManagerState();
  }
}

class NotifyManagerState extends State{
  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);

    final nostrUser = appRouter.nostrUserModel.currentUserSync;

    List<String> titleList =[S.of(context).notifyByReply,S.of(context).notifyByFollow,S.of(context).notifyByUpvote,S.of(context).notifyByRepost];
    bool getNotifySetting(int index){
      switch(index){
        case 0:
          return nostrUser!=null ? nostrUser.notifyReply : true;
        case 1:
          return nostrUser!=null ? nostrUser.notifyFollow : true;
        case 2:
          return nostrUser!=null ? nostrUser.notifyUpvote : true;
        case 3:
          return nostrUser!=null ? nostrUser.notifyRepost : true;
        default:
          return true;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title:Text(S.of(context).settingByNotify),
      ),
      body: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Card(
              child: Container(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titleList[index]),
                    Switch(value: getNotifySetting(index), onChanged: (value){
                      setState(() {
                        if(nostrUser!=null){
                          switch(index){
                            case 0:
                              nostrUser.notifyReply = value;
                              break;
                            case 1:
                              nostrUser.notifyFollow = value;
                              break;
                            case 2:
                              nostrUser.notifyUpvote = value;
                              break;
                            case 3:
                              nostrUser.notifyRepost = value;
                              break;
                            default:
                              return;
                          }
                          appRouter.nostrUserModel.saveCurrentNostrUser('nostr_user', nostrUser);
                        }
                      });
                    })
                  ],
                ),
              ),
            );
          }
      ),
    );

  }

}