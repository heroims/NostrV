import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/tab_select_model.dart';
import 'package:nostr_app/pages/feed_page.dart';
import 'package:nostr_app/pages/notify_page.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
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
           leading: Consumer<TabSelectModel>(
             builder: (context, model, child) {
               return IconButton(
                 icon: const Icon(Icons.account_circle_outlined),
                 onPressed: (){
                   context.pushNamed(Routers.profile.value);
                 },
               );
             },
           ),
           actions: [
             Consumer<TabSelectModel>(
               builder: (context, model, child) {
                 final addNavBtnKey = GlobalKey();

                 switch (model.selectIndex) {
                   case 0:
                   case 1:
                     return IconButton(
                       key: addNavBtnKey,
                       icon: const Icon(Icons.add),
                       onPressed: () {
                         if (model.selectIndex == 0){
                           context.pushNamed(Routers.feedPost.value);
                         }
                         else{
                           final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                           final RenderBox button = addNavBtnKey.currentContext!.findRenderObject() as RenderBox;
                           final RelativeRect position = RelativeRect.fromRect(
                             Rect.fromPoints(
                               button.localToGlobal(button.size.center(Offset.zero), ancestor: overlay),
                               button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                             ),
                             Offset.zero & overlay.size,
                           );
                           showMenu(
                             context: context,
                             position: position,
                             items: [
                               PopupMenuItem<String>(
                                 child: Text(S.of(context).navByPrivateChat),
                                 onTap: () {
                                 },
                               ),
                               PopupMenuItem<String>(
                                 child: Text(S.of(context).navByPublicChat),
                                 onTap: () {
                                 },
                               ),
                             ],
                           );
                         }
                       },
                     );
                   default:
                     return const SizedBox();
                 }
               },
             ),
             Consumer<TabSelectModel>(
               builder: (context, model, child) {
                 switch (model.selectIndex) {
                   case 0:
                     return IconButton(
                       icon: const Icon(Icons.search),
                       onPressed: () {
                         context.pushNamed(Routers.search.value);
                       },
                     );
                   default:
                     return const SizedBox();
                 }
               },
             ),
           ],
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