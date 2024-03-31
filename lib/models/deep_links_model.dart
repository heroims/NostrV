import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:nostr_app/router.dart';
import 'nip19_extension.dart';


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
    if(uri.scheme == 'nostr'){
      final path = uri.host!=null?uri.host:(uri.path!=null?uri.path:'');
      if(path!=''){
        try{
          if(path.startsWith('npub')){
            final pubKey = Nip19.decodePubkey(path);
            context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, pubKey));
          }
          if(path.startsWith('nprofile')){
            final pubKey = Nip19Extension.decode(path)['data']['pubkey'];
            context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, pubKey));
          }
          if(path.startsWith('nevent')){
            final eventId =  Nip19Extension.decode(path)['data']['id'];
            context.pushNamed(Routers.feedDetail.value,extra: eventId);
          }
        }
        catch(_){}
      }
    }
  }

  void refresh(){
    notifyListeners();
  }
}