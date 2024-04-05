import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/deep_links_model.dart';
import 'package:nostr_app/models/relay_pool_model.dart';
import 'package:nostr_app/models/user_follow_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../models/user_info_model.dart';
import '../models/zap_lightning_model.dart';
import '../router.dart';
import 'package:image/image.dart' as imglib;

class UserHeaderCard extends StatelessWidget {
  final UserFollowModel userFollowModel;

  const UserHeaderCard({super.key,required this.userFollowModel});

  @override
  Widget build(BuildContext context) {
    UserFollowModel model = userFollowModel;
    UserInfo? user = model.userInfo;
    String originUserId = Nip19.encodePubkey(model.userInfoModel.publicKey).toString();
    String userId = originUserId.replaceRange(8, 57, ':');
    String userName = user?.name ?? '';
    if(userName==''){
      userName = user?.userName ?? '';
    }
    if(userName==''){
      userName == user?.displayName;
    }

    if(userName==''){
      userName = userId;
    }
    String userAvatar = user?.picture ?? '';
    Widget defaultImageWidget = const Image(
      image: AssetImage("assets/img/avatar.png"),
    );
    Widget imageWidget = defaultImageWidget;
    if(userAvatar.isNotEmpty){
      imageWidget =CachedNetworkImage(
        imageUrl: userAvatar,
        placeholder: (context , url){
          return defaultImageWidget;
        },
        errorWidget: (context, url, _) {
          return defaultImageWidget;
        },
      );
    }

    String tmpAbout = user?.about ?? '';
    RegExp linkRegex = RegExp(r"(https?://\S+)");
    String replacedText = tmpAbout.replaceAllMapped(
      linkRegex, (match) {
      String link = match.group(0)!;
      String replacedLink = "<a href='$link'>$link</a>"; // 替换为带有 <a> 标签的链接
      return replacedLink;
    },
    );

    RegExp tagRegex = RegExp(r"(#\S+)");
    replacedText = replacedText.replaceAllMapped(
      tagRegex, (match) {
      String tag = match.group(0)!;
      String link = "nostr://search/$tag";
      String replacedLink = "<a href='$link' style='text-decoration: none'>$tag</a>"; // 替换为带有 <a> 标签的链接
      return replacedLink;
    },
    );

    AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);

    final userActionUI = [
      Expanded(child: Text(
        '@$userName',
        style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold
        ),
        softWrap: true,
      )),
      IconButton(
          onPressed: (){
            Clipboard.setData(ClipboardData(text: Nip19.encodePubkey(model.userInfoModel.publicKey))).then((value){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).copyToClipboard),
                  duration: const Duration(seconds: 1),
                ),
              );
            });
          },
          icon: const Icon(Icons.copy)),
      IconButton(
          onPressed: (){
            showCupertinoDialog(context: context, builder: (context){
              final size = MediaQuery.of(context).size;
              double width = 180;//size.width * 3 / 4;

              final Encode result = zx.encodeBarcode(contents: originUserId, params: EncodeParams(
                format: Format.qrCode,
                width: width.toInt(),
                height: width.toInt(),
                margin: 0,
                eccLevel: EccLevel.high,
              ));

              Uint8List imageData = Uint8List(0);
              try {
                final imglib.Image img = imglib.Image.fromBytes(
                  width: width.toInt(),
                  height: width.toInt(),
                  bytes: result.data!.buffer,
                  numChannels: 4,
                );
                final Uint8List encodedBytes = Uint8List.fromList(
                  imglib.encodeJpg(img),
                );
                imageData = encodedBytes;
              } catch (_) {

              }

              return AlertDialog(
                content: Image.memory(
                  imageData,
                  width: size.width * 3 / 4,
                  height: size.width * 3 / 4,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(S.of(context).dialogByDone),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            });
          },
          icon: const Icon(Icons.qr_code)),
    ];
    bool isOwner = appRouter.nostrUserModel.currentUserInfo?.publicKey==userFollowModel.userInfoModel.publicKey;
    if(userFollowModel.supportLightning && !isOwner){
      userActionUI.add(
        IconButton(
          onPressed: (){
            final zapLightningModel = ZapLightningModel();
            zapLightningModel.zapAmount = 1;
            final minMilliSatoshi = userFollowModel.userInfoModel.lightningInfo['minSendable'];
            final maxMilliSatoshi = userFollowModel.userInfoModel.lightningInfo['maxSendable'];

            String contentLeftText = 'lud06';
            String contentRightText = '';

            showDialog(context: context, builder: (context){

              return ChangeNotifierProvider(create:(_)=>zapLightningModel,builder: (context, child){
                return Consumer<ZapLightningModel>(builder: (context, zapModel, _){
                  final textEditController=TextEditingController(text: zapModel.zapAmount.toString());

                  Widget inputWidget = TextField(controller: textEditController,);
                  if(minMilliSatoshi != null && maxMilliSatoshi != null){
                    contentLeftText = 'lud16';//:${zapModel.zapAmount.toStringAsFixed(0)}';
                    contentRightText = '${minMilliSatoshi~/1000}~${maxMilliSatoshi~/1000}sats';
                    // inputWidget = Slider(
                    //     value: zapModel.zapAmount,
                    //     min: double.tryParse((minMilliSatoshi~/1000).toString())??1,
                    //     max: double.tryParse((maxMilliSatoshi~/1000).toString())??100000,
                    //     onChanged: (value){
                    //       zapModel.zapAmount = value;
                    //     });
                  }

                  return AlertDialog(
                    title: Text(S.of(context).navByZap),
                    content: SizedBox(
                      height: 100,
                      child:Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(contentLeftText),
                                Text(contentRightText)
                              ],
                            ),
                          ),
                          inputWidget,
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: (){
                        if(!appRouter.nostrUserModel.currentUserInfo!.supportLightning){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).tipByUnInputLud16),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        final relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) {
                              final proKey = GlobalKey();
                              return Dismissible(
                                onDismissed: (direction) {}, key: proKey,
                                child: const AlertDialog(
                                  content: Center(
                                    widthFactor: 1,
                                    heightFactor: 2,
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        );
                        if(minMilliSatoshi != null && maxMilliSatoshi != null) {
                          if(zapModel.zapAmount>maxMilliSatoshi/1000||zapModel.zapAmount<minMilliSatoshi/1000){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).tipByZapAmountOut),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                          zapModel.getInvoiceCodeByLightning(
                              callback: userFollowModel.userInfoModel.lightningCallback,
                              pubKey: userFollowModel.userInfoModel.publicKey,
                              appRouter: appRouter,
                              relays: relayPoolModel.relayWss.keys.toList(),
                          ).then((value) {
                            DeepLinksModel deepLinksModel = Provider.of<DeepLinksModel>(context, listen: false);

                            if(deepLinksModel?.lightningWallet != null&&value!=null){
                              deepLinksModel?.lightningWallet!.payInvoiceEvent((relay, response) {
                                if(response['error'] == null){
                                  Navigator.pop(context);
                                }
                                else{
                                  Navigator.pop(context, value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['error']['message']),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              }, invoiceCode: value);
                            }
                            else{
                              Navigator.pop(context,);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).tipByUnConnectWallet),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          }, onError: (_){
                            Navigator.pop(context);
                          });
                        }
                        else{
                          zapModel.zapAmount=double.tryParse(textEditController.text)??0;
                          zapModel.getInvoiceCodeByLightning(
                              callback: userFollowModel.userInfoModel.lightningCallback,
                              pubKey: userFollowModel.userInfoModel.publicKey,
                              appRouter: appRouter,
                              relays: relayPoolModel.relayWss.keys.toList(),
                          ).then((value) {
                            Navigator.pop(context, value);
                          }, onError: (_){
                            Navigator.pop(context);
                          });
                        }

                      }, child: Text(S.of(context).navByZap)),
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Text(S.of(context).dialogByCancel))
                    ],
                  );
                },);
              }, );
            }).then((value) {
              if(value!=null){

              }
            });
          },
          icon: const Icon(Icons.bolt, color: Colors.orange,)),
      );
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: imageWidget,
                ),
                if (originUserId != appRouter.nostrUserModel.currentUserSync!.publicKey) Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: CupertinoButton(
                          color: model.followed?Colors.black26:Colors.blue,
                          onPressed: (){
                            model.following(!model.followed);
                          },
                          child: Text(model.followed?S.of(context).avatarCardByFollowed:S.of(context).avatarCardByFollow)
                      ),
                    ),
                    const SizedBox(width: 10,),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          color: Colors.blue,
                          onPressed: (){
                            context.pushNamed(Routers.chat.value,extra:{"publicKey": userFollowModel.userInfoModel.publicKey});
                          },
                          child: const Icon(Icons.messenger)
                      ),
                    )
                  ],
                ) else SizedBox(
                  height: 50,
                  width: 120,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    color: Colors.blue,
                    onPressed: (){
                      context.pushNamed(Routers.profileEdit.value, queryParameters: {'id':Nip19.encodePubkey(userFollowModel.userInfoModel.publicKey)});
                    },
                    child: Text(S.of(context).avatarCardByEdit),
                  ),
                )
              ]
          ),
          const SizedBox(height: 10,),
          Row(
            children: userActionUI,
          ),
          const SizedBox(height: 10,),
          HtmlWidget(
            replacedText,
            enableCaching: true,
            onTapUrl: (url) {
              if (url.startsWith(RegExp(r"(nostr://\S+)"))) {

              }
              else {
                launchUrl(Uri.parse(url));
              }
              return true;
            },
            customStylesBuilder: (element) {
              switch (element.localName) {
                case 'a':
                  return {'text-decoration': 'none'};
              }
              return null;
            },
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(child: CupertinoButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          model.followings.profiles.length.toString(),
                          style: const TextStyle(fontSize: 25)
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        S.of(context).avatarCardByFollowing,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  onPressed: (){
                    UserInfoModel pushUserModel= UserInfoModel(context, model.userInfoModel.publicKey,userInfoModel: model.userInfoModel);
                    context.pushNamed(Routers.followings.value,extra: pushUserModel);
                  })),
              Expanded(child: CupertinoButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      model.followersDownloaded?Text(
                          model.followers.length.toString(),
                          style: const TextStyle(fontSize: 25)
                      ):const Icon(Icons.download),
                      const SizedBox(height: 5,),
                      Text(
                        S.of(context).avatarCardByFollowers,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  onPressed: (){
                    if(model.followersDownloaded){
                      UserInfoModel pushUserModel= UserInfoModel(context, model.userInfoModel.publicKey,userInfoModel: model.userInfoModel);
                      context.pushNamed(Routers.followers.value,extra: pushUserModel);
                    }
                    else{
                      model.getUserFollower();
                    }
                  })),
              Expanded(child: CupertinoButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          model.followings.relaysState.length.toString(),
                          style: const TextStyle(fontSize: 25)
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        S.of(context).avatarCardByRelays,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  onPressed: (){
                    UserInfoModel pushUserModel= UserInfoModel(context, model.userInfoModel.publicKey,userInfoModel: model.userInfoModel);
                    context.pushNamed(Routers.relays.value,extra: pushUserModel);

                  })),
            ],
          ),
        ],
      ),
    );
  }

}