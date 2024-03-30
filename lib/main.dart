import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nostr_app/models/deep_links_model.dart';
import 'package:nostr_app/models/nostr_user_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:provider/provider.dart';
import 'generated/l10n.dart';
import 'package:nostr_app/router.dart';

import 'models/realm_model.dart';

void main(){

  runApp(const MyApp());
  if(Platform.isAndroid){
    //设置Android头部的导航栏透明
    SystemUiOverlayStyle systemUiOverlayStyle =
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeepLinksModel>(
          lazy: false,
          create: (_) => DeepLinksModel(),
        ),
        ChangeNotifierProvider<RelayPoolModel>(
          lazy: false,
          create: (_) => RelayPoolModel(),
        ),
        ChangeNotifierProvider<RealmToolModel>(
          lazy: false,
          create: (_) => RealmToolModel(),
        ),
        Provider(
            lazy: false,
            create: (context) => AppRouter(nostrUserModel: NostrUserModel(context)),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final router = Provider.of<AppRouter>(context, listen: false).router;
          return MaterialApp.router(
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            routerDelegate: router.routerDelegate,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            title: 'Nostr',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
              primaryColor: Colors.blue,
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                unselectedIconTheme: IconThemeData(color: Colors.black45),
                selectedIconTheme: IconThemeData(color: Colors.blue),
                // selectedItemColor: Colors.indigoAccent,
                // unselectedItemColor: Colors.lightBlueAccent,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
              )
              // primaryIconTheme: const IconThemeData(color: Colors.blue),
            ),
          );
        }
      ),
    );
  }
}
