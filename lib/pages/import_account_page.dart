import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../router.dart';

class ImportAccountPage extends StatelessWidget {
  const ImportAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = Provider.of<AppRouter>(context, listen: false);
    final nostrController = TextEditingController();
    final hdWalletController = TextEditingController();
    final mnemonicController = TextEditingController();
    final mnemonicPasswordController = TextEditingController();
    final keystoreController = TextEditingController();
    final keystorePasswordController = TextEditingController();


    return Scaffold(
      appBar: AppBar(
        title:Text(S.of(context).pageWelcomeImport),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      S.of(context).navByNostr,
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold
                      ),
                      selectionColor: Colors.cyan,
                    ),
                  ),
                  Tab(
                    child: Text(
                      S.of(context).navByHDWallet,
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold
                      ),
                      selectionColor: Colors.cyan,
                    ),
                  ),
                  Tab(
                    child: Text(
                      S.of(context).placeholderByMnemonic,
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold
                      ),
                      selectionColor: Colors.cyan,
                    ),
                  ),
                  Tab(
                    child: Text(
                      S.of(context).placeholderByKeystore,
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold
                      ),
                      selectionColor: Colors.cyan,
                    ),
                  )
                ]
            ),
            Expanded(
                child: TabBarView(children: [
                  Column(
                    children: [
                      Container(
                        height: 80,
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                        child: CupertinoTextField(
                          placeholder: S.of(context).placeholderByNostrPK,
                          obscureText: true,
                          controller: nostrController,
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 200,
                        padding: const EdgeInsets.only(top: 50,left: 10,right: 10),
                        child: ElevatedButton(onPressed: (){
                          try{
                            appRouter.nostrUserModel.importNostrPrivateKey(nostrController.text);
                            context.goNamed(Routers.feed.value);
                          }
                          catch(e){
                            showCupertinoDialog(context: context, builder: (context){
                              return CupertinoAlertDialog(
                                title: Text(S.of(context).dialogByTitle),
                                content: Text(S.of(context).tipByImportError),
                                actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text(S.of(context).dialogByDone))],
                              );
                            });
                          }
                        }, child: Text(S.of(context).pageWelcomeImport),),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 80,
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                        child: CupertinoTextField(
                          placeholder: S.of(context).placeholderByHDWalletPK,
                          obscureText: true,
                          controller: hdWalletController,
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 200,
                        padding: const EdgeInsets.only(top: 50,left: 10,right: 10),
                        child: ElevatedButton(onPressed: (){
                          try{
                            appRouter.nostrUserModel.importHDPrivateKey(hdWalletController.text);
                            context.goNamed(Routers.feed.value);
                          }
                          catch(e){
                            showCupertinoDialog(context: context, builder: (context){
                              return CupertinoAlertDialog(
                                title: Text(S.of(context).dialogByTitle),
                                content: Text(S.of(context).tipByImportError),
                                actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text(S.of(context).dialogByDone))],
                              );
                            });
                          }
                        }, child: Text(S.of(context).pageWelcomeImport),),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 160,
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                          child: CupertinoTextField(
                            maxLines: null,
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.top,
                            placeholder: S.of(context).placeholderByMnemonic,
                            controller: mnemonicController,
                          ),
                        ),
                        Container(
                          height: 70,
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: CupertinoTextField(
                            placeholder: S.of(context).placeholderByMnemonicPassphrase,
                            obscureText: true,
                            controller: mnemonicPasswordController,
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 200,
                          padding: const EdgeInsets.only(top: 50,left: 10,right: 10),
                          child: ElevatedButton(onPressed: (){
                            try{
                              appRouter.nostrUserModel.importMnemonic(mnemonicController.text, passphrase: mnemonicPasswordController.text);
                              context.goNamed(Routers.feed.value);
                            }
                            catch(e){
                              showCupertinoDialog(context: context, builder: (context){
                                return CupertinoAlertDialog(
                                  title: Text(S.of(context).dialogByTitle),
                                  content: Text(S.of(context).tipByImportError),
                                  actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text(S.of(context).dialogByDone))],
                                );
                              });
                            }
                          }, child: Text(S.of(context).pageWelcomeImport),),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 260,
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                          child: CupertinoTextField(
                            maxLines: null,
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.top,
                            placeholder: S.of(context).placeholderByKeystore,
                            controller: mnemonicController,
                          ),
                        ),
                        Container(
                          height: 70,
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: CupertinoTextField(
                            placeholder: S.of(context).placeholderByPassword,
                            obscureText: true,
                            controller: mnemonicPasswordController,
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 200,
                          padding: const EdgeInsets.only(top: 50,left: 10,right: 10),
                          child: ElevatedButton(onPressed: (){
                            try{
                              appRouter.nostrUserModel.importKeystore(keystoreController.text, keystorePasswordController.text);
                              context.goNamed(Routers.feed.value);
                            }
                            catch(e){
                              showCupertinoDialog(context: context, builder: (context){
                                return CupertinoAlertDialog(
                                  title: Text(S.of(context).dialogByTitle),
                                  content: Text(S.of(context).tipByImportError),
                                  actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text(S.of(context).dialogByDone))],
                                );
                              });
                            }
                          }, child: Text(S.of(context).pageWelcomeImport),),
                        ),
                      ],
                    ),
                  ),
                ],
                )
            ),
          ],
        ),
      ),
    );

  }
}