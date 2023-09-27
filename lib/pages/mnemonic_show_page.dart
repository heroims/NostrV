import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/router.dart';

import '../generated/l10n.dart';

class MnemonicShowPage extends StatelessWidget {
  final List<String> mnemonicList;
  const MnemonicShowPage({required List<String> mnemonic, super.key}):mnemonicList=mnemonic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).pageMnemonicTitle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Text(S.of(context).pageMnemonicDescribe,style: const TextStyle(fontSize: 20),),
          Container(
            padding: const EdgeInsets.only(left: 15,right: 15,top: 30,bottom: 40),
            child: Text(S.of(context).pageMnemonicShowTip),),
          Expanded(child: GridView.builder(
            padding: const EdgeInsets.only(left: 15,right: 15,top: 0,bottom: 0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 120, crossAxisSpacing: 10,mainAxisSpacing: 10,childAspectRatio: 5/2),
            itemCount: mnemonicList.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  child: Center(
                    child: Text('${index+1}.${mnemonicList[index]}',
                      style: const TextStyle(
                          fontSize: 16
                      ),
                    ),
                  )
              );
            },
          )),
          Container(
            width: MediaQuery.of(context).size.width*0.5,
            padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
            child: ElevatedButton(
                onPressed: (){
                  context.pushNamed(Routers.mnemonicVerify.value, extra: mnemonicList);
                },
                child: Text(S.of(context).pageMnemonicNext)
            ),
          )
        ],
      ),
    );
  }
}