import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../router.dart';

enum CreateUserType{
  hdNode,
  normal
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.of(context).pageWelcomeTitle,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  inherit: false,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.5,
                height: 50,
                child: ElevatedButton(
                  // color: Color.fromARGB(255, 11, 221, 33),
                  // style: ButtonStyle(backgroundColor:MaterialStateProperty.resolveWith<Color?>(
                  //         (Set<MaterialState> states) {
                  //       if (states.contains(MaterialState.focused)) {
                  //         return Colors.red;
                  //       }
                  //       if (states.contains(MaterialState.hovered)) {
                  //         return Colors.green;
                  //       }
                  //       if (states.contains(MaterialState.pressed)) {
                  //         return Colors.red;
                  //       }
                  //       return Colors.brown; // Defer to the widget's default.
                  //     }),),
                  onPressed: () {
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text(S.of(context).dialogByTitle,textAlign: TextAlign.center,),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                height: 80,
                                alignment: Alignment.center,
                                child: Text(S.of(context).dialogByCreate),
                              ),
                              TextButton(child: Text(S.of(context).createByNormal),onPressed: (){
                                Navigator.of(context).pop(CreateUserType.normal);
                              },),
                              TextButton(child: Text(S.of(context).createByHDNode),onPressed: (){
                                Navigator.of(context).pop(CreateUserType.hdNode);
                              },),

                              TextButton(child: Text(S.of(context).createByCancel),onPressed: (){
                                Navigator.of(context).pop();
                              },),
                            ],
                          );
                        }).then((value) {
                          if(value!=null){
                            final nostrUserModel = Provider.of<AppRouter>(context, listen: false).nostrUserModel;

                            switch (value as CreateUserType){
                              case CreateUserType.hdNode:{
                                nostrUserModel.createHDAccount().then((mnemonic){
                                  context.pushNamed(Routers.mnemonicShow.value, extra: mnemonic);
                                });
                                break;
                              }
                              case CreateUserType.normal:{
                                nostrUserModel.createNormalAccount().then((value){
                                  debugPrint('created');
                                  context.goNamed(Routers.feed.value);
                                },onError: (err){
                                  debugPrint('err');
                                  debugPrint(err);
                                });
                                break;
                              }
                            }
                          }
                    });

                  },
                  child: Text(S.of(context).pageWelcomeGo),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width*0.06),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.5,
                height: 50,
                child: ElevatedButton(
                  // color: Color.fromARGB(255, 11, 221, 33),
                  // style: ButtonStyle(backgroundColor:MaterialStateProperty.resolveWith<Color?>(
                  //         (Set<MaterialState> states) {
                  //       if (states.contains(MaterialState.focused)) {
                  //         return Colors.red;
                  //       }
                  //       if (states.contains(MaterialState.hovered)) {
                  //         return Colors.green;
                  //       }
                  //       if (states.contains(MaterialState.pressed)) {
                  //         return Colors.red;
                  //       }
                  //       return Colors.brown; // Defer to the widget's default.
                  //     }),),
                  onPressed: (){
                    context.pushNamed(Routers.importAccount.value,);
                  },
                  child: Text(S.of(context).pageWelcomeImport),
                ),
              ),
            ],
          )
      ),
    );
  }
  
}