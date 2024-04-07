import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/nostr_user_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/pages/account_manager_page.dart';
import 'package:nostr_app/pages/chat_page.dart';
import 'package:nostr_app/pages/contract_page.dart';
import 'package:nostr_app/pages/feed_post_page.dart';
import 'package:nostr_app/pages/followers_page.dart';
import 'package:nostr_app/pages/followings_page.dart';
import 'package:nostr_app/pages/home_page.dart';
import 'package:nostr_app/pages/import_account_page.dart';
import 'package:nostr_app/pages/key_manager_page.dart';
import 'package:nostr_app/pages/lightning_page.dart';
import 'package:nostr_app/pages/mnemonic_verify_page.dart';
import 'package:nostr_app/pages/mnemonic_show_page.dart';
import 'package:nostr_app/pages/mute_manager_page.dart';
import 'package:nostr_app/pages/notify_manager_page.dart';
import 'package:nostr_app/pages/photo_page.dart';
import 'package:nostr_app/pages/profile_edit_page.dart';
import 'package:nostr_app/pages/profile_page.dart';
import 'package:nostr_app/pages/feed_detail_page.dart';
import 'package:nostr_app/pages/relay_info_page.dart';
import 'package:nostr_app/pages/relays_page.dart';
import 'package:nostr_app/pages/repost_feed_page.dart';
import 'package:nostr_app/pages/search_page.dart';
import 'package:nostr_app/pages/upvote_feed_page.dart';
import 'package:nostr_app/pages/welcome_page.dart';
import 'package:nostr_app/pages/relay_manager_page.dart';
import 'package:nostr_app/pages/zap_list_page.dart';
import 'package:provider/provider.dart';

import 'models/deep_links_model.dart';

enum Routers {
  zapList(29, 'zap_list'),
  importAccount(28, 'import_account'),
  accountManager(27, 'account_manager'),
  lightning(26, 'lightning'),
  notifyManager(25, 'notify_manager'),
  repostFeed(24, 'repost_feed'),
  upvoteFeed(23, 'upvote_feed'),
  muteManager(22, 'mute_manager'),
  keyManager(21, 'key_manager'),
  relayManager(20, 'relay_manager'),
  profileEdit(19, 'profile_edit'),
  contract(18, 'contract'),
  chat(17, 'chat'),
  setting(16, 'setting'),
  photoView(15, 'photo_view'),
  feedPost(14, 'feed_post'),
  relayInfo(13, 'relay_info'),
  relays(12, 'relays'),
  followers(11, 'followers'),
  followings(10, 'followings'),
  feedDetail(9, 'feed_detail'),
  profile(8, 'profile'),
  search(7, 'search'),
  mnemonicVerify(6, 'mnemonic_verify'),
  mnemonicShow(5, 'mnemonic_show'),
  notify(4, 'notify'),
  message(3, 'message'),
  feed(2, 'feed'),
  home(1, 'home');

  const Routers(this.number, this.value);

  final int number;
  final String value;
}

class AppRouter {
  final NostrUserModel nostrUserModel;

  AppRouter({required this.nostrUserModel});

  // GoRouter configuration
  late final router = GoRouter(
    routes: [
      GoRoute(
          name: 'root',
          path: '/',
          redirect: (context, state) {
             return '/welcome';
          }
      ),
      GoRoute(
        name: 'welcome',
        path: '/welcome',
        pageBuilder: (context, state) => const MaterialPage(child: WelcomePage()),
        routes: [
          GoRoute(
              name: Routers.mnemonicShow.value,
              path: 'mnemonic/show',
              pageBuilder: (context, state) => MaterialPage(child: MnemonicShowPage(mnemonic: (state.extra) as List<String>)),
              routes: [
                GoRoute(
                  name: Routers.mnemonicVerify.value,
                  path: 'verify',
                  pageBuilder: (context, state) => MaterialPage(child: MnemonicVerifyPage(mnemonic: (state.extra) as List<String>)),
                )
              ]
          )
        ]
      ),
      GoRoute(
          name: Routers.home.value,
          path: '/${Routers.home.value}/:tab(${Routers.feed.value}|${Routers.message.value}|${Routers.notify.value}|${Routers.setting.value})',
          pageBuilder: (context, state) {
            final deepLinksModel = Provider.of<DeepLinksModel>(context, listen: false);
            deepLinksModel.context = context;
            final tabStr = state.pathParameters['tab'];
            return MaterialPage(child: HomePage(tab: tabStr ?? Routers.feed.value));
          }
      ),
      GoRoute(
          name: Routers.feed.value,
          path: '/${Routers.feed.value}',
          redirect: (context, state) {
            return '/${Routers.home.value}/${Routers.feed.value}';
          }
      ),
      GoRoute(
          name: Routers.search.value,
          path: '/${Routers.search.value}',
          pageBuilder: (context, state) {
            String? keyword = state.uri.queryParameters['keyword'];

            return MaterialPage(child: SearchPage(keyword: keyword,));
          }
      ),
      GoRoute(
          name: Routers.notify.value,
          path: '/${Routers.notify.value}',
          redirect: (context, state) {
            return '/${Routers.home.value}/${Routers.notify.value}';
          }
      ),
      GoRoute(
          name: Routers.setting.value,
          path: '/${Routers.setting.value}',
          redirect: (context, state) {
            return '/${Routers.home.value}/${Routers.setting.value}';
          }
      ),
      GoRoute(
          name: Routers.message.value,
          path: '/${Routers.message.value}',
          redirect: (context, state) {
            return '/${Routers.home.value}/${Routers.message.value}';
          }
      ),
      GoRoute(
          name: Routers.profile.value,
          path: '/${Routers.profile.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            UserInfoModel? userInfoModel;
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
              userInfoModel = UserInfoModel(context,pubKey);
            }
            else {
              if(state.extra!=null){
                userInfoModel = state.extra as UserInfoModel;
              }
              else{
                userInfoModel = UserInfoModel(context,Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey));
              }
            }

            return MaterialPage(child: ProfilePage(userInfoModel: userInfoModel,));
          }
      ),
      GoRoute(
          name: Routers.profileEdit.value,
          path: '/${Routers.profile.value}/edit',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            UserInfoModel? userInfoModel;
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
              userInfoModel = UserInfoModel(context,pubKey);
            }
            else {
              if(state.extra!=null){
                userInfoModel = state.extra as UserInfoModel;
              }
              else{
                userInfoModel = UserInfoModel(context,Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey));
              }
            }

            return MaterialPage(child: ProfileEditPage(userInfoModel: userInfoModel,));
          }
      ),
      GoRoute(
          name: Routers.followings.value,
          path: '/${Routers.followings.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            UserInfoModel? userInfoModel;
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
              userInfoModel = UserInfoModel(context,pubKey);
            }
            else {
              if(state.extra!=null){
                userInfoModel = state.extra as UserInfoModel;
              }
              else{
                userInfoModel = UserInfoModel(context,Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey));
              }
            }

            return MaterialPage(child: FollowingsPage(userInfoModel: userInfoModel,));
          }
      ),
      GoRoute(
          name: Routers.followers.value,
          path: '/${Routers.followers.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            UserInfoModel? userInfoModel;
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
              userInfoModel = UserInfoModel(context,pubKey);
            }
            else {
              if(state.extra!=null){
                userInfoModel = state.extra as UserInfoModel;
              }
              else{
                userInfoModel = UserInfoModel(context,Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey));
              }
            }

            return MaterialPage(child: FollowersPage(userInfoModel: userInfoModel,));
          }
      ),
      GoRoute(
          name: Routers.relays.value,
          path: '/${Routers.relays.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            UserInfoModel? userInfoModel;
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
              userInfoModel = UserInfoModel(context,pubKey);
            }
            else {
              if(state.extra!=null){
                userInfoModel = state.extra as UserInfoModel;
              }
              else{
                userInfoModel = UserInfoModel(context,Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey));
              }
            }

            return MaterialPage(child: RelaysPage(userInfoModel: userInfoModel,));
          }
      ),
      GoRoute(
          name: Routers.relayInfo.value,
          path: '/${Routers.relayInfo.value}',
          pageBuilder: (context, state) {
            Map<String,dynamic> relayMap = {};
            if(state.extra!=null){
              relayMap=state.extra! as Map<String,dynamic>;
            }
            return MaterialPage(child: RelayInfoPage(relayInfo: relayMap,));
          }
      ),
      GoRoute(
          name: Routers.relayManager.value,
          path: '/${Routers.relayManager.value}',
          pageBuilder: (context, state) {
            String? pubKey = state.uri.queryParameters['id'];
            UserInfoModel? userInfoModel;
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
              userInfoModel = UserInfoModel(context,pubKey);
            }
            else {
              if(state.extra!=null){
                userInfoModel = state.extra as UserInfoModel;
              }
              else{
                userInfoModel = UserInfoModel(context,Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey));
              }
            }

            return MaterialPage(child: RelayManagerPage(userInfoModel: userInfoModel,));
          }
      ),
      GoRoute(
          name: Routers.keyManager.value,
          path: '/${Routers.keyManager.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: KeyManagerPage());
          }
      ),
      GoRoute(
          name: Routers.accountManager.value,
          path: '/${Routers.accountManager.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: AccountManagerPage());
          }
      ),
      GoRoute(
          name: Routers.muteManager.value,
          path: '/${Routers.muteManager.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: MuteManagerPage());
          }
      ),
      GoRoute(
          name: Routers.notifyManager.value,
          path: '/${Routers.notifyManager.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: NotifyManagerPage());
          }
      ),
      GoRoute(
          name: Routers.lightning.value,
          path: '/${Routers.lightning.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: LightningPage());
          }
      ),
      GoRoute(
          name: Routers.importAccount.value,
          path: '/${Routers.importAccount.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: ImportAccountPage());
          }
      ),
      GoRoute(
          name: Routers.photoView.value,
          path: '/${Routers.photoView.value}',
          pageBuilder: (context, state) {
            return MaterialPage(child: PhotoPage(imageProvider: state.extra as ImageProvider,));
          }
      ),
      GoRoute(
          name: Routers.contract.value,
          path: '/${Routers.contract.value}',
          pageBuilder: (context, state) {
            return const MaterialPage(child: ContractPage());
          }
      ),
      GoRoute(
          name: Routers.chat.value,
          path: '/${Routers.chat.value}',
          pageBuilder: (context, state) {
            String? userId = state.uri.queryParameters['id'];
            void Function()? refreshChannel;
            if(userId!=null){
              userId = Nip19.decodePubkey(userId);
            }
            else {
              if(state.extra!=null){
                userId = (state.extra! as Map)['publicKey'];
                refreshChannel = (state.extra! as Map)['refreshChannel'];
              }
            }

            return MaterialPage(child: ChatPage(refreshChannel: refreshChannel,publicKey:userId,));
          }
      ),
      GoRoute(
          name: Routers.feedDetail.value,
          path: '/${Routers.feed.value}/detail',
          pageBuilder: (context, state) {

            String? noteId = state.uri.queryParameters['id'];

            if(noteId!=null){
              noteId = Nip19.decodeNote(noteId);
            }
            else {
              if(state.extra!=null){
                noteId = state.extra as String;
              }
            }


            return MaterialPage(child: FeedDetailPage(noteId: noteId!));
          }
      ),
      GoRoute(
          name: Routers.upvoteFeed.value,
          path: '/${Routers.upvoteFeed.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
            }
            else {
              if(state.extra!=null){
                pubKey = state.extra as String;
              }
              else{
                pubKey = Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey);
              }
            }

            return MaterialPage(child: UpvoteFeedPage(publicKey: pubKey,));
          }
      ),
      GoRoute(
          name: Routers.repostFeed.value,
          path: '/${Routers.repostFeed.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
            }
            else {
              if(state.extra!=null){
                pubKey = state.extra as String;
              }
              else{
                pubKey = Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey);
              }
            }

            return MaterialPage(child: RepostFeedPage(publicKey: pubKey,));
          }
      ),
      GoRoute(
          name: Routers.zapList.value,
          path: '/${Routers.zapList.value}',
          pageBuilder: (context, state) {

            String? pubKey = state.uri.queryParameters['id'];
            if(pubKey!=null){
              pubKey = Nip19.decodePubkey(pubKey);
            }
            else {
              if(state.extra!=null){
                pubKey = state.extra as String;
              }
              else{
                pubKey = Nip19.decodePubkey(nostrUserModel.currentUserSync!.publicKey);
              }
            }

            return MaterialPage(child: ZapListPage(publicKey: pubKey,));
          }
      ),
      GoRoute(
          name: Routers.feedPost.value,
          path: '/${Routers.feed.value}/post',
          pageBuilder: (context, state) {

            String? noteId = state.uri.queryParameters['id'];

            if(noteId!=null){
              noteId = Nip19.decodeNote(noteId);
            }
            else {
              if(state.extra!=null){
                noteId = state.extra as String;
              }
            }

            return MaterialPage(child: FeedPostPage(noteId: noteId));
          }
      ),
    ],
    redirect: (context, state) async {
      final user = await nostrUserModel.currentUser;
      if(user!=null&&state.fullPath=='/'){
        return '/${Routers.home.value}/${Routers.feed.value}';
      }

      if(
          user!=null
          && state.uri.path == '/${Routers.profile.value}'
          && !state.uri.queryParameters.containsKey('id')
          && state.extra==null
      ){
        return '/${Routers.profile.value}?id=${user.publicKey}';
      }
      return null;
    },
  );
}