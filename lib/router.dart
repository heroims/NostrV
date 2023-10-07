import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/nostr_user_model.dart';
import 'package:nostr_app/pages/home_page.dart';
import 'package:nostr_app/pages/mnemonic_verify_page.dart';
import 'package:nostr_app/pages/mnemonic_show_page.dart';
import 'package:nostr_app/pages/welcome_page.dart';

enum Routers {
  mnemonicVerify(6, 'mnemonic_verify'),
  mnemonicShow(5, 'mnemonic_show'),
  profile(4, 'profile'),
  search(3, 'search'),
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
          path: '/home/:tab(feed|search|profile)',
          pageBuilder: (context, state) {
            final tabStr = state.pathParameters['tab'];
            return MaterialPage(child: HomePage(tab: tabStr ?? 'feed'));
          }
      ),
      GoRoute(
          name: Routers.feed.value,
          path: '/feed',
          redirect: (context, state) {
            return '/home/feed';
          }
      ),
      GoRoute(
          name: Routers.search.value,
          path: '/search',
          redirect: (context, state) {
            return '/home/search';
          }
      ),
      GoRoute(
          name: Routers.profile.value,
          path: '/profile',
          redirect: (context, state) {
            return '/home/profile';
          }
      ),
    ],
    redirect: (context, state) async {
      final user = await nostrUserModel.currentUser;
      if(user!=null){
        return '/home/feed';
      }
      return null;
    },
  );
}