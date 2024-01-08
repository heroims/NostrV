import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostr_app/models/user_edit_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/relay_pool_model.dart';
import '../models/user_info_model.dart';
import '../router.dart';

class ProfileEditPage extends StatelessWidget {
  final UserInfoModel userInfoModel;
  const ProfileEditPage({super.key,required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    List<TextEditingController> editControllers = [
      TextEditingController(text: userInfoModel.userInfo?.picture),
      TextEditingController(text: userInfoModel.userInfo?.banner),
      TextEditingController(text: userInfoModel.userInfo?.displayName),
      TextEditingController(text: userInfoModel.userInfo?.about),
      TextEditingController(text: userInfoModel.userInfo?.website),
      TextEditingController(text: userInfoModel.userInfo?.nip05),
      TextEditingController(text: userInfoModel.userInfo?.lud16),
    ];
    AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);
    RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);

    UserEditModel  userEditModel = UserEditModel(userInfoModel, editControllers);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserInfoModel>(
            lazy: false,
            create: (_) => userInfoModel,
          ),
          ChangeNotifierProvider<UserEditModel>(
            lazy: false,
            create: (_) => userEditModel,
          ),
        ],
        builder: (context ,child){

          void showImageSheet(Function(String path) callback){
            showCupertinoModalPopup(context: context, builder: (context){
              return CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: (){
                        Permission.camera.request().isGranted.then((isGranted){
                          if(isGranted){
                            final picker = ImagePicker();
                            picker.pickImage(source: ImageSource.camera).then((cameraImg){
                              if(cameraImg!=null){
                                callback(cameraImg.path);
                              }
                            });
                          }
                          else{
                            openAppSettings();
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Text(S.of(context).profileEditByCamera),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: (){
                        final picker = ImagePicker();

                        if(Platform.isIOS){
                          Permission.photos.request().then((status){
                            if(status == PermissionStatus.granted
                                || status == PermissionStatus.limited){
                              picker.pickMedia().then((photoImg){
                                if(photoImg!=null){
                                  callback(photoImg.path);
                                }
                              });
                            }
                            else{
                              openAppSettings();
                            }
                          });
                        }
                        else if(Platform.isAndroid){
                          picker.pickMedia().then((photoImg){
                            if(photoImg!=null){
                              callback(photoImg.path);
                            }
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: Text(S.of(context).profileEditByAlbum),
                    ),
                    CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).createByCancel)
                    ),
                  ]
              );
            });

          }

          return Scaffold(
            backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
            appBar: AppBar(
              title:Text(S.of(context).navByRelay),
              actions: [
                MaterialButton(
                    onPressed: (){

                      String jsonEvent = jsonEncode(
                          {
                            "picture": userEditModel.editControllers[0].text,
                            "banner": userEditModel.editControllers[1].text,
                            "displayName": userEditModel.editControllers[2].text,
                            "about": userEditModel.editControllers[3].text,
                            "website": userEditModel.editControllers[4].text,
                            "nip05": userEditModel.editControllers[5].text,
                            "lud16": userEditModel.editControllers[6].text,
                          });

                      if(userInfoModel.userInfo!= null){
                        jsonEvent = jsonEncode(
                            userInfoModel.userInfo!.toJson()
                        );
                      }
                      userEditModel
                          .postUserInfo(
                          jsonEvent, context,
                          appRouter,
                          relayPoolModel).then((value) => Navigator.pop(context),onError: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).tipUpdateUserFailed),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      });
                    },
                    child: const Icon(Icons.save_rounded)
                )
              ],
            ),
            body: Consumer<UserInfoModel>(
                builder: (context, model, child){
                  UserInfo? user = model.userInfo;
                  if(user==null){
                    model.getUserInfo();
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
                  List<String> editTags=[
                    S.of(context).profileEditByAvatar,
                    S.of(context).profileEditByBanner,
                    S.of(context).profileEditByName,
                    S.of(context).profileEditByAbout,
                    S.of(context).profileEditByWebsite,
                    S.of(context).profileEditByNip05,
                    S.of(context).profileEditByLud16];

                  if(user!=null){
                    editControllers[0].text=user.picture;
                    editControllers[1].text=user.banner;
                    editControllers[2].text=user.displayName;
                    editControllers[3].text=user.about;
                    editControllers[4].text=user.website;
                    editControllers[5].text=user.nip05;
                    editControllers[6].text=user.lud16;
                  }

                  return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                            child: CupertinoButton(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              onPressed: () {
                                showImageSheet((path) {
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
                                  userEditModel
                                      .postAvatar(
                                      path, context,
                                      appRouter,
                                      relayPoolModel).then((value) => Navigator.pop(context),onError: (_) => Navigator.pop(context));
                                });
                              },
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: imageWidget,
                              ),
                            )
                        ),
                        SliverList.builder(
                            itemCount: editTags.length,
                            itemBuilder: (context, index){

                              return Container(
                                padding: const EdgeInsets.only(left: 10,right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          minHeight: 45,
                                          maxWidth: MediaQuery.of(context).size.width,
                                          minWidth: MediaQuery.of(context).size.width
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white, // 设置背景颜色
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child:  Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextField(
                                            controller: editControllers[index],
                                            decoration: InputDecoration(
                                                hintText: editTags[index],
                                                border: InputBorder.none,
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                                prefixIcon: index == 1 ? IconButton(
                                                  icon: const Icon(Icons.image),
                                                  onPressed: () {
                                                    showImageSheet((path) {
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
                                                      userEditModel
                                                          .postBanner(
                                                          path, context,
                                                          appRouter,
                                                          relayPoolModel).then((value) => Navigator.pop(context),onError: (_) => Navigator.pop(context));
                                                    });
                                                  },
                                                ):null,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            onChanged: (changeText){
                                              if(userInfoModel.userInfo!=null){
                                                switch(index){
                                                  case 0:
                                                    userInfoModel.userInfo?.picture = changeText;
                                                    break;
                                                  case 1:
                                                    userInfoModel.userInfo?.banner = changeText;
                                                    break;
                                                  case 2:
                                                    userInfoModel.userInfo?.displayName = changeText;
                                                    break;
                                                  case 3:
                                                    userInfoModel.userInfo?.about = changeText;
                                                    break;
                                                  case 4:
                                                    userInfoModel.userInfo?.website = changeText;
                                                    break;
                                                  case 5:
                                                    userInfoModel.userInfo?.nip05 = changeText;
                                                    break;
                                                  case 6:
                                                    userInfoModel.userInfo?.lud16 = changeText;
                                                    break;
                                                  default:
                                                    break;
                                                }
                                              }
                                            },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,)
                                  ],
                                ),
                              );
                            }
                        )
                      ]
                  );
                }
            ),
          );
        },
    );
  }
}