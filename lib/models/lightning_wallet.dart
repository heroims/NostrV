import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';

class LightningWallet {
  final String url;
  String publicKey = '';
  String secret = '';
  List<String> relayUrls = [];
  String lud16 = '';
  String nip19PublicKey = '';
  bool connect = false;
  Map<String,List<String>> relaySupportMethods = {};

  LightningWallet({required this.url}){
    final walletUrl = Uri.parse(url);
    if(walletUrl.scheme =='nostrwalletconnect' || walletUrl.scheme =='nostr+walletconnect'){
      connect = true;
      if(walletUrl.host.trim()!=''){
        publicKey = walletUrl.host;
      }
      else if(walletUrl.path.trim()!=''){
        publicKey = walletUrl.path;
      }
      else{}
      nip19PublicKey = publicKey.trim()!='' ? Nip19.encodePubkey(publicKey) : '';
      secret = walletUrl.queryParameters['secret']??'';
      relayUrls = walletUrl.queryParameters['relay']?.split(',')??[];
      lud16 = walletUrl.queryParameters['lud16']??'';
    }
  }

  Future<List<dynamic>> _lightningRelayRequest(dynamic request) async {
    List<Completer> completes = [];

    for(int i = 0;i<relayUrls.length;i++){
      final relayUrl = relayUrls[i];
      final complete = Completer();
      completes.add(complete);
      try{
        WebSocket tmpSocket = await WebSocket.connect(relayUrl);
        tmpSocket.add(request.serialize());
        tmpSocket.listen((event) {
          if(!complete.isCompleted){
            complete.complete((relayUrl, event));
          }
          tmpSocket.close();
        });
      }
      catch(_){

      }
    }
    return await Future.wait(completes.map((c) => c.future));
  }

  Future<Map<String,List<String>>> getInfoEvent() async {
    final requestUUID =generate64RandomHexChars();
    Filter filter = Filter(
        kinds: [13194],
        limit: 1
    );
    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    final result = await _lightningRelayRequest(requestWithFilter);
    Map<String,List<String>> relaySupportMethods = {};

    for (var element in result) {
      String relayUrl;
      String response;
      (relayUrl, response) = element;
      final message = Message.deserialize(response);
      if(message.type == 'EVENT') {
        Event event = message.message;
        List<String> methods = event.content.split(' ');
        relaySupportMethods[relayUrl] = methods;
      }
    }
    return relaySupportMethods;
  }

  Future<void> payInvoiceEvent(Function(String,dynamic) payInvoiceResponse, {required String invoiceCode,}) async {
    String payInvoiceJson = jsonEncode(
        {
          'method':'pay_invoice',
          'params':{
            'invoice': invoiceCode
          }
        }
    );
    EncryptedDirectMessage event =
    EncryptedDirectMessage.redact(secret, publicKey, payInvoiceJson);
    event.kind = 23194;
    event.id = event.getEventId();
    event.sig = event.getSignature(secret);

    Filter filter = Filter(
        kinds: [23195],
        since: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        limit: 1
    );
    await _lightningRelayRequest(event);

    final requestUUID =generate64RandomHexChars();

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);
    final result = await _lightningRelayRequest(requestWithFilter);
    for (var element in result) {
      String response;
      String relayUrl;
      (relayUrl, response) = element;
      final message = Message.deserialize(response);
      if(message.type == 'EVENT') {
        try{
          EncryptedDirectMessage event =  EncryptedDirectMessage(message.message,verify: false);
          String decodeString = event.getPlaintext(secret);
          final jsonResponse = jsonDecode(decodeString);
          payInvoiceResponse(relayUrl, jsonResponse);
        }
        catch(e){
          debugPrint(e.toString());
        }
      }
    }
  }

  Future<double> getBalanceEvent() async {
    String payInvoiceJson = jsonEncode(
        {
          'method':'get_balance',
          'params':{
          }
        }
    );
    EncryptedDirectMessage event =
    EncryptedDirectMessage.redact(secret, publicKey, payInvoiceJson);
    event.kind = 23194;
    event.id = event.getEventId();
    event.sig = event.getSignature(secret);

    Filter filter = Filter(
        kinds: [23195],
        since: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        limit: 1
    );
    await _lightningRelayRequest(event);

    final requestUUID =generate64RandomHexChars();

    Request requestWithFilter = Request(requestUUID, [
      filter
    ]);

    final result = await _lightningRelayRequest(requestWithFilter);
    double balance = 0;
    for (var element in result) {
      String response;
      (_, response) = element;
      final message = Message.deserialize(response);
      if(message.type == 'EVENT') {
        try{
          EncryptedDirectMessage event =  EncryptedDirectMessage(message.message,verify: false);
          String decodeString = event.getPlaintext(secret);
          final jsonResponse = jsonDecode(decodeString);
          balance = jsonResponse['result']['balance']/1000.0;
        }
        catch(e){
          debugPrint(e.toString());
        }
      }
    }
    return balance;
  }

}
