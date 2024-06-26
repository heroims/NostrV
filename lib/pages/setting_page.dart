import 'dart:convert';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:bech32/bech32.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../generated/l10n.dart';
import '../models/nip19_extension.dart';
import '../models/user_info_model.dart';
import '../router.dart';
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lblTitles = [S.of(context).settingByAccount,S.of(context).settingByRelay, S.of(context).settingByKey, S.of(context).settingByMute, S.of(context).settingByNotify, S.of(context).settingByLightning, S.of(context).settingByScan, S.of(context).settingByVersion];
    PackageInfo.fromPlatform().then((value) => value.version);
    return Scaffold(
      body: ListView.builder(
          itemCount: lblTitles.length,
          itemBuilder: (context, index){
            return GestureDetector(
              child: Container(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:index == lblTitles.length-1 ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lblTitles[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  PackageInfo? packageInfo = snapshot.data;
                                  return Text(
                                    packageInfo==null?'':packageInfo.version,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return const Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              },
                            ),

                          ],
                        ):
                        Text(
                          lblTitles[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: (){
                switch (index) {
                  case 0:
                    context.pushNamed(Routers.accountManager.value);
                    break;
                  case 1:
                    context.pushNamed(Routers.relayManager.value);
                    break;
                  case 2:
                    context.pushNamed(Routers.keyManager.value);
                    break;
                  case 3:
                    context.pushNamed(Routers.muteManager.value);
                    break;
                  case 4:
                    context.pushNamed(Routers.notifyManager.value);
                    break;
                  case 5:
                    context.pushNamed(Routers.lightning.value);
                    break;
                  case 6:
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
                      String urlString = value;
                      String nostrString = urlString;
                      if(urlString.startsWith('nostr://')){
                        nostrString = urlString.replaceAll('nostr://', '');
                      }
                      try{
                        if(nostrString.startsWith('npub')){
                          final pubKey = Nip19.decodePubkey(nostrString);
                          context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, pubKey));
                        }
                        if(nostrString.startsWith('nprofile')){
                          final pubKey = Nip19Extension.decode(nostrString)['data']['pubkey'];
                          context.pushNamed(Routers.profile.value,extra: UserInfoModel(context, pubKey));
                        }
                        if(nostrString.startsWith('nevent')){
                          final eventId =  Nip19Extension.decode(nostrString)['data']['id'];
                          context.pushNamed(Routers.feedDetail.value,extra: eventId);
                        }
                      }
                      catch(_){}
                    });
                    break;
                  default:
                    break;
                }
              },
            );
          }
      ),
    );
  }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//           children: [
//             const Text('profile'),
//             ElevatedButton(
//               onPressed: () {
//                 RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);
//                 relayPoolModel.addRelayWithUrl('wss://relay.nostr.au');
//                 relayPoolModel.deleteRelayWithUrl('wss://relay.guggero.org');
//
//                 // Map map = bech32Decode('nevent1qqs2jcrcwj052esfg769ars7y2d6wyzafxa8ruxtgr4vhppx8sf2gnspz3mhxue69uhkummnw3ezummcw3ezuer9wcqs7amnwvaz7tmwdaehgu3wd4hk67qljca');
//                 // final decodedData = bech32.decode('nevent1qqs2jcrcwj052esfg769ars7y2d6wyzafxa8ruxtgr4vhppx8sf2gnspz3mhxue69uhkummnw3ezummcw3ezuer9wcqs7amnwvaz7tmwdaehgu3wd4hk67qljca',200);
//                 // final convertedData = convertBits(decodedData.data, 5, 8, false);
//                 // final hexData = hex.encode(convertedData);
//                 // print(hexData);
// //               final m = BIP39(count: 12);
// //               debugPrint('m: ${m.mnemonic}');
// //               final node = BIP32.fromSeed(Uint8List.fromList(hexToBytes(m.seed)));
// //               debugPrint('node pri: ${bytesToHex(node.privateKey!)}');
// //               debugPrint('node pub: ${bytesToHex(node.publicKey)}');
// //
// //               final hdNode = node.derivePath("m/44'/1237'/0'/0/0");
// //               final pk = bytesToHex(hdNode.privateKey!);
// //               debugPrint('hd_node pri: $pk');
// //               debugPrint('hd_node pub: ${bytesToHex(hdNode.publicKey)}');
// //
// //               final nostrNode = Keychain(pk);
// //               debugPrint('nostr_node pri len: ${nostrNode.private.length}');
// // //3aa0f58c99b09d5edc618b4321c0a31463e61644ac53b416de8560182253fb80
// //               debugPrint('nostr_node pri: ${nostrNode.private}');
// //               debugPrint('nostr_node pub: ${nostrNode.public}');
// //
// //               debugPrint('nostr_node pri: ${Nip19.encodePrivkey(nostrNode.private)}');
// //               debugPrint('nostr_node pub: ${Nip19.encodePubkey(nostrNode.public)}');
// //
// //               final wallet = Wallet.createNew(EthPrivateKey.fromHex(pk), '123456', Random());
// //               debugPrint('keystore: ${wallet.toJson()}');
// //               try{
// //                 final newWallet = Wallet.fromJson("{\"crypto\":{\"cipher\":\"aes-128-ctr\",\"cipherparams\":{\"iv\":\"9e0ed4c9a9c58943b828129642bcb98a\"},\"ciphertext\":\"254eb0ce5912cae819c9076834d2763e70b4d534e40cf13495d0f3fb6c098ec9\",\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":8192,\"r\":8,\"p\":1,\"salt\":\"cab6108eb6ce2303938c722068a0ba17517b00b3b893438854c052881aff12ab\"},\"mac\":\"37e6ca8a5225e45b4a2ca9ecb44aa9c3004053e352b810cffe236036555bfb86\"},\"id\":\"a3d09d70-7ccb-4a04-8ab6-c3ca12aff01b\",\"version\":3}", '123456');
// //                 debugPrint('keystore pk: ${bytesToHex(newWallet.privateKey.privateKey)}');
// //               } on Exception catch (exception) {
// //                 debugPrint(exception.toString());
// //               } catch (error) {
// //                 debugPrint(error.toString());
// //               }
//
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                         (Set<MaterialState> states) {
//                       if (states.contains(MaterialState.focused)) {
//                         return Colors.red;
//                       }
//                       if (states.contains(MaterialState.hovered)) {
//                         return Colors.green;
//                       }
//                       if (states.contains(MaterialState.pressed)) {
//                         return Colors.red;
//                       }
//                       return Colors.brown;
//                     }
//                 ),
//               ),
//               child: const Text('data'),
//             ),
//             Container(
//               width: MediaQuery.of(context).size.width*0.5,
//               padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
//               child: ElevatedButton(
//                   onPressed: () async{
//
//                     debugPrint(Nip19.encodePubkey('fea400befeb5bf115b16575e2176bfbd8fb8ab9985ac170adb402bf8c89b9d0a'));
//                     // Provider.of<RelayPoolModel>(context).deleteRelayWithUrl('wss://relay.plebstr.com');
//                     // final model = UserInfoModel(context,Nip19.decodePubkey('npub1jac0kj928psa6wf7hpt7ws8jmah33c826sa668fsce09cxvzqznqprc8yd'));
//                     // model.getUserFollower();
//
//                     final requestUUID =generate64RandomHexChars();
//                     Request requestWithFilter = Request(requestUUID, [
//                       Filter(
//                         authors: [Nip19.decodePubkey('npub1j35wr3uerzml6qvm9ym5ys6p2mka2eeturjrzvpeawd2r55ku0gsypxn6y')],
//                         kinds: [
//                           4,
//                           // 42,
//                         ],
//
//                         // limit: 50
//                         p: [Nip19.decodePubkey('npub10lgg9fa7cqfwqyk0amde4l08llpceudltwyqvzsltxg9mc9mx00sxvxpgc')]
//                       ),
//                       Filter(
//                           p: [Nip19.decodePubkey('npub1j35wr3uerzml6qvm9ym5ys6p2mka2eeturjrzvpeawd2r55ku0gsypxn6y')],
//                           kinds: [4],
//                           authors: [Nip19.decodePubkey('npub10lgg9fa7cqfwqyk0amde4l08llpceudltwyqvzsltxg9mc9mx00sxvxpgc')]
//                       )
//                       // NostrFilter(
//                       //   kinds: [1],
//                       //   limit: 10,
//                       //   // search: "hero"
//                       // ),
//                       // Filter(
//                       //   // authors: [Nip19.decodePubkey('npub1dpna3xwwddnhhzg9ycpvlcz2ze0jdwm2rf3eqd2lf9leaewtq7tqhw0ef2')],
//                       //   kinds: [
//                       //     1,
//                       //     // 6,//转发
//                       //     // 7,//点赞
//                       //     // 16,//转发
//                       //     30023,//长文
//                       //   ],
//                       //   ids: [
//                       //     Nip19.decodeNote('note16rfef46z3km30yv4hp6zac0l3adk2judfxa40fteu7r43x8zqzcq64pltk')
//                       //     // '4d6821e62110484fed39dc3207641ea812aa93586f9d290b7e339700fb966f3d'
//                       //   ],
//                       //   // e: [Nip19.decodeNote('note13j4ueqs2syq9lrr8muvawntv9d5praa0zw97073xjla62rrpc9jqdd5xnn')],
//                       //   // p:[Nip19.decodePubkey('npub1jac0kj928psa6wf7hpt7ws8jmah33c826sa668fsce09cxvzqznqprc8yd')],
//                       //   // until: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//                       //   limit: 10,
//                       // ),
//                       // Filter(
//                       //   authors: [Nip19.decodePubkey('npub1j35wr3uerzml6qvm9ym5ys6p2mka2eeturjrzvpeawd2r55ku0gsypxn6y')],
//                       //   kinds: [
//                       //     // 1,
//                       //     // 6,//转发
//                       //     // 7,//点赞
//                       //     // 4,
//                       //     // 16,23
//                       //   ],
//                       //   // e: [],
//                       //   // ids: [Nip19.decodeNote('note1lhehqkq969jwla49s5qr30a8xq96t6slq6nuazpwwxn9ajqvn6psq0p24n')],
//                       //   // e: [Nip19.decodeNote('note13j4ueqs2syq9lrr8muvawntv9d5praa0zw97073xjla62rrpc9jqdd5xnn')],
//                       //   // p:[Nip19.decodePubkey('npub1jac0kj928psa6wf7hpt7ws8jmah33c826sa668fsce09cxvzqznqprc8yd')],
//                       //   // until: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//                       //   limit: 10,
//                       // )
//                     ]);
//                     debugPrint('requestUUID: $requestUUID');
//
//                     // Connecting to a nostr relay using websocket
//                     WebSocket webSocket = await WebSocket.connect(
//                       //'wss://relay.guggero.org',
//                       // 'wss://offchain.pub',
//                       'wss://relay.plebstr.com',
//                       // 'wss://relayable.org',
//                       // or any nostr relay
//                     );
//                     // if the current socket fail try another one
//                     // wss://nostr.sandwich.farm
//                     // wss://relay.damus.io
//                     // Send a request message to the WebSocket server
//                     webSocket.add(requestWithFilter.serialize());
//                     int i=0;
//                     // Listen for events from the WebSocket server
//                     // await Future.delayed(Duration(seconds: 1));
//                     webSocket.listen((eventPayload) {
//                       i++;
//                       debugPrint('$i.Received event: $eventPayload');
//
//                       final message = Message.deserialize(eventPayload);
//
//                       if(message.type=='EOSE'){
//                         webSocket.add(Close(jsonDecode(message.message)[0]).serialize());
//                       }
//                       else{
//                         String priK=Nip19.decodePrivkey('nsec1gmgr08t84fpw5kxccxpmef4p6lt08qxevtpg8uf0dnt5h2yzmreszlcllr');
//                         (message.message as EncryptedDirectMessage).pubkey = Nip19.decodePubkey('npub10lgg9fa7cqfwqyk0amde4l08llpceudltwyqvzsltxg9mc9mx00sxvxpgc');
//                         String content =
//                         (message.message as EncryptedDirectMessage).getPlaintext(priK);
//                         debugPrint('--------$content');
//
//                         String result = (message.message as Event).content.replaceAll(r'^https?://([\w-]+\.)+[\w-]+(/\S+)*$', '');
//                         List<String> urls = [];
//                         const urlRegex = r"https?://[^\s]+[\w/]";
//                         final urlRegExp = RegExp(
//                             urlRegex,
//                             caseSensitive: false,
//                             multiLine: true
//                         );
//                         final matches = urlRegExp.allMatches(result);
//                         for (var match in matches) {
//                           debugPrint('--------');
//
//                           print(match.group(0));
//                           print(match.groupCount);
//                           debugPrint('--------');
//
//                           // urls.add(match.group(0)!);
//                           // result = result.replaceRange(match.start, match.end, "");
//                         }
//                         // debugPrint('reslut: $result');
//                       }
//                     });
//
//                     // Close the WebSocket connection
//                     // await webSocket.close();
//                   },
//                   child: Text('ssss')
//               ),
//             ),
//
//           ],
//         )
//     );
//   }
}