import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:hd_wallet/hd_wallet.dart';
import 'package:nostr/nostr.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('profile'),
          ElevatedButton(
            onPressed: () {
              final m = BIP39(count: 12);
              debugPrint('m: ${m.mnemonic}');
              final node = BIP32.fromSeed(Uint8List.fromList(hexToBytes(m.seed)));
              debugPrint('node pri: ${bytesToHex(node.privateKey!)}');
              debugPrint('node pub: ${bytesToHex(node.publicKey)}');

              final hdNode = node.derivePath("m/44'/1237'/0'/0/0");
              final pk = bytesToHex(hdNode.privateKey!);
              debugPrint('hd_node pri: $pk');
              debugPrint('hd_node pub: ${bytesToHex(hdNode.publicKey)}');

              final nostrNode = Keychain(pk);
              debugPrint('nostr_node pri len: ${nostrNode.private.length}');
//3aa0f58c99b09d5edc618b4321c0a31463e61644ac53b416de8560182253fb80
              debugPrint('nostr_node pri: ${nostrNode.private}');
              debugPrint('nostr_node pub: ${nostrNode.public}');

              debugPrint('nostr_node pri: ${Nip19.encodePrivkey(nostrNode.private)}');
              debugPrint('nostr_node pub: ${Nip19.encodePubkey(nostrNode.public)}');

              final wallet = Wallet.createNew(EthPrivateKey.fromHex(pk), '123456', Random());
              debugPrint('keystore: ${wallet.toJson()}');
              try{
                final newWallet = Wallet.fromJson("{\"crypto\":{\"cipher\":\"aes-128-ctr\",\"cipherparams\":{\"iv\":\"9e0ed4c9a9c58943b828129642bcb98a\"},\"ciphertext\":\"254eb0ce5912cae819c9076834d2763e70b4d534e40cf13495d0f3fb6c098ec9\",\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":8192,\"r\":8,\"p\":1,\"salt\":\"cab6108eb6ce2303938c722068a0ba17517b00b3b893438854c052881aff12ab\"},\"mac\":\"37e6ca8a5225e45b4a2ca9ecb44aa9c3004053e352b810cffe236036555bfb86\"},\"id\":\"a3d09d70-7ccb-4a04-8ab6-c3ca12aff01b\",\"version\":3}", '123456');
                debugPrint('keystore pk: ${bytesToHex(newWallet.privateKey.privateKey)}');
              } on Exception catch (exception) {
                debugPrint(exception.toString());
              } catch (error) {
                debugPrint(error.toString());
              }

            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return Colors.red;
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.green;
                    }
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.red;
                    }
                    return Colors.brown;
                  }
              ),
            ),
            child: const Text('data'),
          )
        ],
      )
    );
  }
}