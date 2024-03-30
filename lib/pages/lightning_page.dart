import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../generated/l10n.dart';
import '../models/deep_links_model.dart';
import '../models/user_info_model.dart';

class LightningPage extends StatelessWidget {
  const LightningPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isConnect = false;
    String publicKey = '';
    String relayUrl = '';
    String lud16 = '';

    return Consumer<DeepLinksModel>(builder: (context, model, child) {
      DeepLinksModel deepLinksModel = Provider.of<DeepLinksModel>(context, listen: false);

      if(deepLinksModel.lightningWallet!=null){
        isConnect=model.lightningWallet!.connect;
        publicKey=model.lightningWallet!.publicKey;
        relayUrl=model.lightningWallet!.relayUrl;
        lud16=model.lightningWallet!.lud16;
      }
      else{
        isConnect = false;
      }

      final controller = TextEditingController();
      final connectUI = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Text('address:$publicKey',textAlign: TextAlign.center, style: const TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Text('relay:$relayUrl',textAlign: TextAlign.center, style: const TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Text('lud16:$lud16',textAlign: TextAlign.center, style: const TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(onPressed: (){
                  showCupertinoDialog(context: context, builder: (context){
                    return CupertinoAlertDialog(
                      title: Text(S.of(context).dialogByTitle),
                      content: Text(S.of(context).dialogByDisconnectTip),
                      actions: [
                        TextButton(
                            onPressed: (){
                              model.lightningWallet=null;
                              model.refresh();
                              Navigator.pop(context);
                            },
                            child: Text(S.of(context).dialogByDone)
                        ),
                        TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text(S.of(context).createByCancel)
                        )
                      ],
                    );
                  });

                }, child: Text(S.of(context).connectByCancel)),
              ),
            ))
          ],
        ),
      ];
      final disConnectUI = [
        Row(
          children: [
            Expanded(child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(onPressed: (){
                  launchUrlString('https://nwc.getalby.com/apps/new?c=NostrApp', mode: LaunchMode.externalApplication);
                }, child: Text(S.of(context).connectByAlby)),
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20, top: 60),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(onPressed: (){
                  launchUrlString('https://app.mutinywallet.com/settings/connections?callbackUri=nostr%2bwalletconnect&name=NostrApp', mode: LaunchMode.externalApplication);
                }, child: Text(S.of(context).connectByMutiny)),
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20, top: 60),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(onPressed: (){
                  showDialog(context: context, barrierDismissible: true, builder: (context){
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(S.of(context).connectByScan),
                      ),
                      body: Center(
                        child: ReaderWidget(
                          onScan: (code){
                            Navigator.pop(context, code.text);
                          },
                          scanDelay: const Duration(milliseconds: 500),
                          resolution: ResolutionPreset.high,
                          lensDirection: CameraLensDirection.back,
                          showFlashlight: true,
                          showGallery: true,
                          showToggleCamera: true,
                          showScannerOverlay: true,
                        ),
                      ),
                    );
                  })
                  .then((value) {
                    final lightWallet = LightningWallet(url: value);
                    model.lightningWallet = lightWallet;
                    model.refresh();
                  });
                }, child: Text(S.of(context).connectByScan)),
              ),
            ))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [

            Expanded(child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20, top: 60),
              child: SizedBox(
                width: 300,
                height: 50,
                child: CupertinoTextField(
                  placeholder: S.of(context).placeholderByConnectAddress,
                  controller: controller,
                ),
              ),
            )),
            Container(
              padding: const EdgeInsets.only(right: 20, top: 60),
              child: SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(onPressed: (){
                  final lightWallet = LightningWallet(url: controller.text);
                  model.lightningWallet = lightWallet;
                  model.refresh();
                }, child: Text(S.of(context).connectByInput)),
              ),
            )

          ],
        )
      ];
      return Scaffold(
        appBar: AppBar(
          title:Text(S.of(context).settingByLightning),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children:isConnect ?
            connectUI :
            disConnectUI
        ),
      );
    });

  }
}

