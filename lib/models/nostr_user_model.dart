import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hd_wallet/hd_wallet.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/models/user_info_model.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:nostr_app/globals/storage_setting.dart';

class NostrUser{
  final String publicKey;
  final String privateKey;

  bool notifyReply = true;
  bool notifyFollow = true;
  bool notifyUpvote = true;
  bool notifyRepost = true;

  NostrUser(this.publicKey,this.privateKey);

  NostrUser.fromJson(Map<String, dynamic> json)
      : publicKey = json['pub_key'],
        privateKey = json['pri_key'],
        notifyReply = json['notify_reply'] ?? true,
        notifyFollow = json['notify_follow'] ?? true,
        notifyUpvote = json['notify_upvote'] ?? true,
        notifyRepost = json['notify_repost'] ?? true;


  Map<String, dynamic> toJson() => {
    'pub_key': publicKey,
    'pri_key': privateKey,
    'notify_reply': notifyReply,
    'notify_follow': notifyFollow,
    'notify_upvote': notifyUpvote,
    'notify_repost': notifyRepost,
  };
}

class NostrUserModel extends ChangeNotifier {
  final BuildContext _context;

  NostrUserModel(this._context);

  final storage = const FlutterSecureStorage();

  NostrUser? _currentUser;
  Future<NostrUser?> get currentUser async{
    if(_currentUser==null){
      String? json = await storage.read(key: 'nostr_user',iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
      if(json!=null){
        Map<String, dynamic> userMap = jsonDecode(json);
        _currentUser = NostrUser.fromJson(userMap);
        notifyListeners();
      }
    }
    return _currentUser;
  }

  NostrUser? get currentUserSync{
    return _currentUser;
  }

  UserInfoModel? _currentUserInfo;
  UserInfoModel? get currentUserInfo {
    if(_currentUserInfo==null){
      NostrUser? tmpUser=_currentUser;
      if(tmpUser!=null){
        _currentUserInfo = UserInfoModel(_context, Nip19.decodePubkey(tmpUser.publicKey));
      }
    }
    return _currentUserInfo;
  }

  set currentUser(value){
    _currentUser = value;
    notifyListeners();
  }

  // late List<NostrUser>? _userList;
  // Future<List<NostrUser>> get userList async{
  //   if(_userList==null){
  //     String? json = await storage.read(key: 'nostr_user_list',iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
  //     if(json!=null){
  //       List<Map<String, dynamic>> userListMap = jsonDecode(json);
  //       _userList = userListMap.map((item) => NostrUser.fromJson(item)).toList();
  //       notifyListeners();
  //     }
  //   }
  //   _userList??=[];
  //   return _userList!;
  // }

  // Future<void> loadCurrentNostrUser() async{
  //   String? json = await storage.read(key: 'nostr_user',iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
  //   if(_currentUser==null){
  //     if(json!=null){
  //       Map<String, dynamic> userMap = jsonDecode(json);
  //       _currentUser = NostrUser.fromJson(userMap);
  //       notifyListeners();
  //     }
  //   }
  // }

  Future<void> saveCurrentNostrUser(String userKey,dynamic userValue) async {
    String json =jsonEncode(userValue);
    await storage.write(key:userKey, value: json,iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
  }

  Future<void> removeCurrentNostrUser() async {
    await storage.delete(key:'nostr_user', iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
    _currentUser=null;
    _currentUserInfo=null;
  }
  // Future<void> checkoutNostrUser(int index) async{
  //
  // }

  // Future<void> addNostrUser(dynamic userValue) async {
  //   String json = JsonEncoder(userValue) as String;
  //   (await userList).add(userValue);
  //   await storage.write(key:'nostr_user_list', value: json, iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
  //
  // }

  Future<void> createNormalAccount() async {
    final randomKeys = Keychain.generate();
    final nostrUser = NostrUser(Nip19.encodePubkey(randomKeys.public), Nip19.encodePrivkey(randomKeys.private));
    currentUser = nostrUser;
    await saveCurrentNostrUser('nostr_user', await currentUser);
  }

  Future<List<String>> createHDAccount() async {
    final m = BIP39(count: 12);
    await storage.write(key:'mnemonic', value: m.mnemonic.join(' '), iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
    return m.mnemonic;
  }

  Future<void> removeMnemonic() async {
    final mnemonic = await storage.read(key: 'mnemonic', iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);

    final m = BIP39.fromMnemonic(mnemonic!);
    final node = BIP32.fromSeed(Uint8List.fromList(hexToBytes(m.seed)));
    final hdNode = node.derivePath("m/44'/1237'/0'/0/0");
    final pk = bytesToHex(hdNode.privateKey!);

    final nostrNode = Keychain(pk);

    final nostrUser = NostrUser(Nip19.encodePubkey(nostrNode.public), Nip19.encodePrivkey(nostrNode.private));
    currentUser = nostrUser;
    await saveCurrentNostrUser('nostr_user', await currentUser);
    await storage.delete(key: 'mnemonic', iOptions: iosSecureStorageOptions,aOptions: androidSecureStorageOptions);
  }

  String exportNostrPrivateKey(NostrUser user){
    return user.privateKey;
  }

  String exportHDPrivateKey(NostrUser user){
    return Nip19.decodePrivkey(user.privateKey);
  }

  String exportKeystore(NostrUser user, String password){
    final wallet = Wallet.createNew(EthPrivateKey.fromHex(Nip19.decodePrivkey(user.privateKey)), password, Random());
    return wallet.toJson();
  }

  void importNostrPrivateKey(String nostrPrivateKey){
    final pk = Nip19.decodePrivkey(nostrPrivateKey);
    final nostrNode = Keychain(pk);
    currentUser = NostrUser(nostrNode.public, nostrNode.private);
  }

  void importHDPrivateKey(String hdPrivateKey){
    final node = BIP32.fromPrivateKey(hexToBytes(hdPrivateKey), intToBytes(BigInt.from(1237)));
    final hdNode = node.derivePath("m/44'/1237'/0'/0/0");
    final pk = bytesToHex(hdNode.privateKey!);

    final nostrNode = Keychain(pk);

    final nostrUser = NostrUser(Nip19.encodePubkey(nostrNode.public), Nip19.encodePrivkey(nostrNode.private));
    currentUser = nostrUser;
  }

  void importMnemonic(String mnemonic){
    final m = BIP39.fromMnemonic(mnemonic);

    final node = BIP32.fromSeed(Uint8List.fromList(hexToBytes(m.seed)));
    final hdNode = node.derivePath("m/44'/1237'/0'/0/0");
    final pk = bytesToHex(hdNode.privateKey!);

    final nostrNode = Keychain(pk);

    final nostrUser = NostrUser(Nip19.encodePubkey(nostrNode.public), Nip19.encodePrivkey(nostrNode.private));
    currentUser = nostrUser;
  }

  void importKeystore(String keystore,String password){
    final wallet = Wallet.fromJson(keystore, password);

    final pk = bytesToHex(wallet.privateKey.privateKey);
    final nostrNode = Keychain(pk);

    final nostrUser = NostrUser(Nip19.encodePubkey(nostrNode.public), Nip19.encodePrivkey(nostrNode.private));
    currentUser = nostrUser;
  }
}