import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hd_wallet/hd_wallet.dart';
import 'package:nostr/nostr.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class NostrUser{
  final String publicKey;
  final String privateKey;

  NostrUser(this.publicKey,this.privateKey);

  NostrUser.fromJson(Map<String, dynamic> json)
      : publicKey = json['pub_key'],
        privateKey = json['pri_key'];

  Map<String, dynamic> toJson() => {
    'pub_key': publicKey,
    'pri_key': privateKey,
  };
}

class NostrUserModel extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  final iosOptions = const IOSOptions(accessibility: KeychainAccessibility.unlocked);
  final androidOptions = const AndroidOptions(encryptedSharedPreferences: true);

  NostrUser? _currentUser;
  Future<NostrUser?> get currentUser async{
    if(_currentUser==null){
      String? json = await storage.read(key: 'nostr_user',iOptions: iosOptions,aOptions: androidOptions);
      if(json!=null){
        Map<String, dynamic> userMap = jsonDecode(json);
        _currentUser = NostrUser.fromJson(userMap);
        notifyListeners();
      }
    }
    return _currentUser;
  }

  set currentUser(value){
    _currentUser = value;
    notifyListeners();
  }

  late List<NostrUser>? _userList;
  Future<List<NostrUser>> get userList async{
    if(_userList==null){
      String? json = await storage.read(key: 'nostr_user_list',iOptions: iosOptions,aOptions: androidOptions);
      if(json!=null){
        List<Map<String, dynamic>> userListMap = jsonDecode(json);
        _userList = userListMap.map((item) => NostrUser.fromJson(item)).toList();
        notifyListeners();
      }
    }
    _userList??=[];
    return _userList!;
  }

  Future<void> loadCurrentNostrUser() async{
    String? json = await storage.read(key: 'nostr_user',iOptions: iosOptions,aOptions: androidOptions);
    if(_currentUser==null){
      if(json!=null){
        Map<String, dynamic> userMap = jsonDecode(json);
        _currentUser = NostrUser.fromJson(userMap);
        notifyListeners();
      }
    }
  }

  Future<void> saveCurrentNostrUser(String userKey,dynamic userValue) async {
    String json =jsonEncode(userValue);
    await storage.write(key:userKey, value: json,iOptions: iosOptions,aOptions: androidOptions);
  }

  Future<void> checkoutNostrUser(int index) async{

  }

  Future<void> addNostrUser(dynamic userValue) async {
    String json = JsonEncoder(userValue) as String;
    (await userList).add(userValue);
    await storage.write(key:'nostr_user_list', value: json, iOptions: iosOptions,aOptions: androidOptions);

  }

  Future<void> createNormalAccount() async {
    final randomKeys = Keychain.generate();
    final nostrUser = NostrUser(Nip19.encodePubkey(randomKeys.public), Nip19.encodePrivkey(randomKeys.private));
    currentUser = nostrUser;
    await saveCurrentNostrUser('nostr_user', await currentUser);
  }

  Future<List<String>> createHDAccount() async {
    final m = BIP39(count: 12);
    await storage.write(key:'mnemonic', value: m.mnemonic.join(' '), iOptions: iosOptions,aOptions: androidOptions);
    return m.mnemonic;
  }

  Future<void> removeMnemonic() async {
    final mnemonic = await storage.read(key: 'mnemonic', iOptions: iosOptions,aOptions: androidOptions);

    final m = BIP39.fromMnemonic(mnemonic!);
    final node = BIP32.fromSeed(Uint8List.fromList(hexToBytes(m.seed)));
    final hdNode = node.derivePath("m/44'/1237'/0'/0/0");
    final pk = bytesToHex(hdNode.privateKey!);

    final nostrNode = Keychain(pk);

    final nostrUser = NostrUser(Nip19.encodePubkey(nostrNode.public), Nip19.encodePrivkey(nostrNode.private));
    currentUser = nostrUser;
    await saveCurrentNostrUser('nostr_user', await currentUser);
    await storage.delete(key: 'mnemonic', iOptions: iosOptions,aOptions: androidOptions);
  }

  String exportNostrPrivateKey(NostrUser user){
    return user.privateKey;
  }

  String exportHDPrivateKey(NostrUser user){
    return Nip19.decodePrivkey(user.privateKey);
  }

  String exportKeystore(NostrUser user, String password){
    final wallet = Wallet.createNew(EthPrivateKey.fromHex(user.privateKey), password, Random());
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