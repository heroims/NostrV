import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/tab_select_model.dart';
import 'package:nostr_app/pages/feed_page.dart';
import 'package:nostr_app/pages/notify_page.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

import 'message_page.dart';

class HomePage extends StatelessWidget{
  final String tabStr;

  const HomePage({required String tab,super.key}):tabStr=tab;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TabSelectModel(tabStr),
      builder: (context, child){
       return Scaffold(
         appBar: AppBar(
           title: const Text("Nostr"),
           centerTitle: true,
         ),
         bottomNavigationBar: Consumer<TabSelectModel>(
           builder: (context, model, child){
             return BottomNavigationBar(
               items: const [
                 BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
                 BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Message'),
                 BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
               ],
               currentIndex: model.selectIndex,
               onTap: (index){
                 model.setIndex(index);
                 switch(index){
                   case 0:
                     context.goNamed(Routers.feed.value);
                     break;
                   case 1:
                     context.goNamed(Routers.message.value);
                     break;
                   case 2:
                     context.goNamed(Routers.notify.value);
                     break;
                 }
               },
             );
           },
         ),
         body: Consumer<TabSelectModel>(
           builder: (context, model , child) {
             return IndexedStack(
               index: model.selectIndex,
               children: const [
                 FeedPage(),
                 MessagePage(),
                 NotifyPage()
               ],
             );
           },)
       );
      }
    );
  }

}