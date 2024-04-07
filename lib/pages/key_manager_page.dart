import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../router.dart';

class KeyManagerPage extends StatelessWidget {
  const KeyManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    final edit1Controller = TextEditingController();
    final edit2Controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title:Text(S.of(context).settingByKey),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50,),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              final nostrPK = appRouter.nostrUserModel.exportNostrPrivateKey(appRouter.nostrUserModel.currentUserSync!);
              showCupertinoDialog(context: context, builder: (context){
                return CupertinoAlertDialog(
                  title: Text(S.of(context).dialogByTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 10,),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Text(nostrPK,),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: nostrPK)).then((value){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).copyToClipboard),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          });

                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).dialogByCopy)
                    )
                  ],
                );
              });
            }, child: Text(S.of(context).exportByNostrKey),),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              final walletPK = appRouter.nostrUserModel.exportHDPrivateKey(appRouter.nostrUserModel.currentUserSync!);
              showCupertinoDialog(context: context, builder: (context){
                return CupertinoAlertDialog(
                  title: Text(S.of(context).dialogByTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 10,),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Text(walletPK,),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: walletPK)).then((value){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).copyToClipboard),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          });

                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).dialogByCopy)
                    )
                  ],
                );
              });
            }, child: Text(S.of(context).exportByWalletKey),),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: CupertinoTextField(
              placeholder: S.of(context).placeholderByEnterPassword,
              obscureText: true,
              controller: edit1Controller,
            ),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: CupertinoTextField(
              placeholder: S.of(context).placeholderByConfirmPassword,
              obscureText: true,
              controller: edit2Controller,
            ),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              if(edit1Controller.text != edit2Controller.text
                  || edit1Controller.text.isEmpty
                  || edit2Controller.text.isEmpty
                  || edit1Controller.text == ""
                  || edit2Controller.text == ""
              ){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).tipByKeystorePwError),
                      duration: const Duration(seconds: 1),
                    ),
                );
                
                return;
              }
              final keystoreName = appRouter.nostrUserModel.exportKeystore(appRouter.nostrUserModel.currentUserSync!, edit2Controller.text);
              showCupertinoDialog(context: context, builder: (context){
                return CupertinoAlertDialog(
                  title: Text(S.of(context).dialogByTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 10,),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Text(keystoreName,),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: keystoreName)).then((value){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).copyToClipboard),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          });

                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).dialogByCopy)
                    )
                  ],
                );
              });
            }, child: Text(S.of(context).exportByKeystore),),
          ),
        ],
      ),
    );

  }
}