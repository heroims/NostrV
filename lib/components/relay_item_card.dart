import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_app/models/relay_info_model.dart';

import '../generated/l10n.dart';
import '../router.dart';

class RelayItemCard extends StatelessWidget {
  final RelayInfoModel relayModel;
  const RelayItemCard({super.key,required this.relayModel});

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10,),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: Text(
                        relayModel.relayUrl,
                        style: const TextStyle(
                          fontSize:18,
                        ),
                      ),
                    ),
                  ],
                )),
                Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                    icon: relayModel.addStatus ? const Icon(Icons.remove_circle_outline_outlined) : const Icon(Icons.add_circle_outlined),
                    onPressed: () {
                      if(relayModel.addStatus){
                        relayModel.removeRelay();
                      }
                      else{
                        relayModel.addRelay();
                      }
                    },
                  )
                ),
              ],
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
      onTap: (){
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

        Dio dio = Dio();
        dio.get(relayModel.relayUrl.replaceAll('wss', 'https'),
          options: Options(
            sendTimeout: const Duration(seconds: 2),
            receiveTimeout: const Duration(seconds: 2),
            headers: {"Accept": "application/nostr+json"},
          )
        ).then((value){
          Navigator.pop(context);
          print(value.data);
          Map<String, dynamic> mapData = value.data;
          mapData['address']=relayModel.relayUrl;
          context.pushNamed(Routers.relayInfo.value, extra:mapData );
        }).catchError((err){
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).tipByUnSupportNip11),
              duration: const Duration(seconds: 1),
            ),
          );
        });
      },
    );
  }

}