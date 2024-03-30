import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/router.dart';


class DeepLinksModel extends ChangeNotifier {

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  LightningWallet? lightningWallet;
  late BuildContext context;
  DeepLinksModel(){
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      debugPrint('getInitialAppLink: $appLink');
      openAppLink(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    final currentRouteName = (GoRouter.of(context).routerDelegate.currentConfiguration.last.route as GoRoute).name;

    if(uri.scheme == 'nostr+walletconnect' || uri.scheme == 'nostrwalletconnect'){
      lightningWallet = LightningWallet(url: uri.toString());
      if(currentRouteName != Routers.lightning.value){
        context.pushNamed(Routers.lightning.value);
      }
    }
    notifyListeners();
  }
}