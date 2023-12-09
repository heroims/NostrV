import 'package:flutter/material.dart';
import 'package:nostr_app/models/chat_tool_model.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget{
  final String? publicKey;
  const ChatPage({super.key, this.publicKey});

  @override
  Widget build(BuildContext context) {
    final editController = TextEditingController();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context)=> ChatToolModel(editController),
          lazy: false,
        )
,      ],
      builder: (context, child){
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat'),
          ),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.grey[200],
                  child: Consumer<ChatToolModel>(
                      builder:(context, model, child){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {

                                  },
                                  icon: const Icon(Icons.camera_alt_outlined),
                                ),
                                const SizedBox(width: 5),
                                IconButton(
                                  onPressed: () {

                                  },
                                  icon: const Icon(Icons.photo_outlined),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10,bottom: 10),
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.only(left: 10),
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                    maxHeight: 150,
                                  ),
                                  child: TextField(
                                      controller: editController,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            model.clearInput();
                                          },
                                        ),
                                      )
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: (){

                                },
                                icon: const Icon(Icons.send)
                            ),
                          ],
                        );
                      }
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}