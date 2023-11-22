import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../generated/l10n.dart';

class RelayInfoPage extends StatelessWidget {
  final Map<String,dynamic> relayInfo;
  const RelayInfoPage({super.key,required this.relayInfo});

  @override
  Widget build(BuildContext context) {
    final lblTitles = ['Address', 'Name', 'Description', 'SupportedNips', 'Version', 'Software', 'Contact'];
    String supportedNips = '';
    if(relayInfo.containsKey('supported_nips')
    && relayInfo['supported_nips'].isNotEmpty
    ){
      supportedNips =  relayInfo['supported_nips'].join(',');
    }

    final lblValues = [relayInfo['address']??'', relayInfo['name']??'', relayInfo['description']??'', supportedNips, relayInfo['version']??'', relayInfo['software']??'', relayInfo['contact']??''];
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        title:Text(S.of(context).nativeByRelay),
      ),
      body: ListView.builder(
        itemCount: lblTitles.length,
        itemBuilder: (context, index){
          return Container(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      lblTitles[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                    child: GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(
                            ClipboardData(text: lblValues[index])
                        ).then((_){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).copyToClipboard),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        });
                      },
                      child: Text(
                          lblValues[index],
                          style: const TextStyle(
                            fontSize: 15,
                          )
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5,)
              ],
            ),
          );
        }
      ),
    );
  }
}