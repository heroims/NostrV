import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_app/models/feed_post_model.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/relay_pool_model.dart';
import '../router.dart';

class FeedPostPage extends StatelessWidget{
  final String? noteId;

  const FeedPostPage({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    final editController = TextEditingController();
    final feedPostModel = FeedPostModel(editController, noteId: noteId);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            if(feedPostModel.imageUrls.isNotEmpty
                ||feedPostModel.textEditingController.text.isNotEmpty
                ||feedPostModel.textEditingController.text.trim()!=''
            ) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(S.of(context).dialogByTitle),
                      content: Text(S.of(context).dialogByEditPop),
                      actions: [
                        TextButton(
                            onPressed: (){
                              Navigator.pop(context);
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
                  }
              );
            }
            else {
              Navigator.pop(context);
            }
          },
        ),
        title:Text(S.of(context).navByPost),
        actions: [
          MaterialButton(
              onPressed: (){
                AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);
                RelayPoolModel relayPoolModel = Provider.of<RelayPoolModel>(context, listen: false);
                if((editController.text.trim()==''||editController.text.isEmpty)&&feedPostModel.imageUrls.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).tipNoFeedToPost),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  return;
                }
                feedPostModel.postFeed(context, appRouter, relayPoolModel).then((value){
                  Navigator.pop(context);
                });
              },
              child: const Icon(Icons.send_outlined)
          )
        ],
      ),
      body: SafeArea(
        child:ChangeNotifierProvider(
          create:(_)=> feedPostModel,
          builder: (context, child){
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Consumer<FeedPostModel>(
                    builder: (context, model, child){
                      return Column(
                        children: [
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            constraints: BoxConstraints(
                                minHeight: 200,
                                maxWidth: MediaQuery.of(context).size.width,
                                minWidth: MediaQuery.of(context).size.width
                            ),
                            child: TextField(
                                controller: editController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                )
                            ),
                          ),
                          Expanded(
                              child: GridView.builder(
                                  itemCount: model.imageUrls.length,
                                  padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio:1,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5
                                  ),
                                  itemBuilder: (context, index){
                                    return Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1.0,
                                          child: ClipRect(
                                            child: Image(
                                              image: FileImage(File(model.imageUrls[index])),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        ),
                                        Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                            )
                                        ),
                                        Positioned(
                                          width: 48,
                                          height: 48,
                                          top: -2,
                                          right: -2,
                                          child: IconButton(
                                            onPressed: () {
                                              model.deleteImage(index);
                                            },
                                            padding: const EdgeInsets.all(0),
                                            icon: const Icon(Icons.delete,color: Colors.red,),
                                          ) ,
                                        )
                                      ],
                                    );
                                  }
                              ))
                        ],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 56,
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                feedPostModel.cameraAddImage();
                              },
                              icon: const Icon(Icons.camera_alt_outlined),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              onPressed: () {
                                feedPostModel.photosAddImage();
                              },
                              icon: const Icon(Icons.photo_outlined),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 100,
                          child: CupertinoButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                            },
                            child: Text(S.of(context).dialogByDone),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        )
      ),

    );
  }
}