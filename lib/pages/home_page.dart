import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/tab_select_model.dart';
import 'package:nostr_app/pages/feed_page.dart';
import 'package:nostr_app/pages/notify_page.dart';
import 'package:nostr_app/pages/search_page.dart';
import 'package:provider/provider.dart';

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
                 BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                 BottomNavigationBarItem(icon: Icon(Icons.account_box), label: 'Profile'),
               ],
               currentIndex: model.selectIndex,
               onTap: (index){
                 model.setIndex(index);
                 switch(index){
                   case 0:
                     context.go('/feed');
                     break;
                   case 1:
                     context.go('/search');
                     break;
                   case 2:
                     context.go('/profile');
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
                 SearchPage(),
                 NotifyPage()
               ],
             );
           },)
       );
      }
    );
  }

}