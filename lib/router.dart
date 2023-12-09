import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/nostr_user_model.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/pages/chat_page.dart';
import 'package:nostr_app/pages/feed_post_page.dart';
import 'package:nostr_app/pages/followers_page.dart';
import 'package:nostr_app/pages/followings_page.dart';
import 'package:nostr_app/pages/home_page.dart';
import 'package:nostr_app/pages/mnemonic_verify_page.dart';
import 'package:nostr_app/pages/mnemonic_show_page.dart';
import 'package:nostr_app/pages/photo_page.dart';
import 'package:nostr_app/pages/profile_page.dart';
import 'package:nostr_app/pages/feed_detail_page.dart';
import 'package:nostr_app/pages/relay_info_page.dart';
import 'package:nostr_app/pages/relays_page.dart';
import 'package:nostr_app/pages/search_page.dart';
import 'package:nostr_app/pages/welcome_page.dart';

enum Routers {
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
          name: Routers.photoView.value,
          path: '/${Routers.photoView.value}',
          pageBuilder: (context, state) {
            return MaterialPage(child: PhotoPage(imageProvider: state.extra as ImageProvider,));
          }
      ),
      GoRoute(
          name: Routers.chat.value,
          path: '/${Routers.chat.value}',
          pageBuilder: (context, state) {
            String? userId = state.uri.queryParameters['id'];

            if(userId!=null){
              userId = Nip19.decodePubkey(userId);
            }
            else {
              if(state.extra!=null){
                userId = state.extra as String;
              }
            }

            return MaterialPage(child: ChatPage(publicKey:userId));
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