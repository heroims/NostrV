import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/router.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/mnemonic_verify_model.dart';



class MnemonicVerifyPage extends StatelessWidget {
  final List<String> mnemonicList;
  const MnemonicVerifyPage({required List<String> mnemonic, super.key}):mnemonicList=mnemonic;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MnemonicVerifyModel(mnemonicList),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).pageMnemonicTitle),
          ),
          body: Consumer<MnemonicVerifyModel>(
            builder: (context, model, child) {
              return Column(
                children: [
                  Expanded(child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Container(
                                padding: const EdgeInsets.only(left: 15,right: 15,top: 30,bottom: 20),
                                child: Text(S.of(context).pageMnemonicVerifyTip, style: const TextStyle(fontSize: 18),)
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 15,right: 15,top: 0,bottom: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black,width: 1),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                height: 230,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 120, crossAxisSpacing: 10,mainAxisSpacing: 10,childAspectRatio: 5/2),
                                  itemCount: model.mnemonicSetList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Stack(
                                      children: [
                                        Card(
                                            shape: model.selectMnemonicState(index)?null:RoundedRectangleBorder(
                                                side: const BorderSide(color: Colors.red),
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Center(
                                              child: Text(model.mnemonicSetList[index],
                                                style: const TextStyle(
                                                    fontSize: 16
                                                ),
                                              ),
                                            )
                                        ),
                                        Visibility(
                                          visible: !model.selectMnemonicState(index),
                                          child:Positioned(
                                              right:-33,
                                              top:-27,
                                              child: MaterialButton(
                                                  onPressed: () {
                                                    model.unselectMnemonic(index);
                                                  },
                                                  materialTapTargetSize: MaterialTapTargetSize.padded,
                                                  shape: const CircleBorder(),
                                                  height: 80,
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    width: 20,
                                                    height: 20,
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  )
                                              )
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 15,right: 15,top: 20,bottom: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 120, crossAxisSpacing: 10,mainAxisSpacing: 10,childAspectRatio: 5/2,),
                          delegate: SliverChildBuilderDelegate(
                                (context,index){
                              return InkWell(
                                onTap: model.selectShowMnemonicState(index)?null:(){
                                  model.selectMnemonicShow(index);
                                },
                                enableFeedback: true,
                                child: Opacity(
                                  opacity: model.selectShowMnemonicState(index)?0.5:1,
                                  child: Card(
                                      child: Center(
                                        child: Text('${index+1}.${model.mnemonicShowList[index]}',
                                          style: const TextStyle(
                                              fontSize: 16
                                          ),
                                        ),
                                      )
                                  ),
                                )
                              );
                            },
                            childCount: model.mnemonicShowList.length,
                          ),
                        ),
                      ),
                    ],
                  )),
                  Container(
                    width: MediaQuery.of(context).size.width*0.5,
                    padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
                    child: ElevatedButton(
                        onPressed: model.mnemonicSetList.join(' ')==mnemonicList.join(' ')?(){
                          if(model.mnemonicSetList.join(' ')==mnemonicList.join(' ')){
                            Provider.of<AppRouter>(context, listen: false).nostrUserModel.removeMnemonic().then((value) {
                              context.goNamed(Routers.feed.value);
                            });
                          }
                          else{

                          }
                        }:null,
                        child: Text(S.of(context).pageMnemonicNext)
                    ),
                  )
                ],
              );
            },
          )
        );
      },
    );
  }
}