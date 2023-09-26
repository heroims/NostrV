import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/login_info_model.dart';
import 'package:nostr_app/pages/home_page.dart';
import 'package:nostr_app/pages/mnemonic_verify_page.dart';
import 'package:nostr_app/pages/welcome_page.dart';

enum Routers {
  mnemonicVerify(1, 'mnemonic_verify'),
  home(2, 'home'),
  feed(3, 'feed'),
  search(4, 'search'),
  profile(5, 'profile');

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
              name: Routers.mnemonicVerify.value,
              path: 'mnemonic/verify',
              pageBuilder: (context, state) => const MaterialPage(child: MnemonicVerifyPage()),
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