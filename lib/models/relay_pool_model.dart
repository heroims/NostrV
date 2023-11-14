
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nostr/nostr.dart';
import 'package:nostr_app/globals/storage_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RelayPoolModel extends ChangeNotifier {
  SharedPreferences? _prefs;
  final relaysSaveKey = 'relays';
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  final Map<String, WebSocket?> _relayWss = {};
  Map<String, WebSocket?> get relayWss => _relayWss;
  final Map<String, List> _relayResponses = {};
  final Map<String, Function(dynamic)> _relaySingleResponses = {};
  final Map<String, Queue<String>> _relaySubscriptionId = {};

  Future<void> startRelayPool() async {
    final relays = (await prefs).getStringList(relaysSaveKey) ?? defaultRelayUrls;
    for (var element in relays) {
      _relayWss[element] = null;
    }
    for (String url in relays) {
      await addRelayWithUrl(url);
    }
  }

  void addRequest(String url, dynamic requestWithFilter, Function(List<Event>) response){
    if(relayWss.containsKey(url)&&relayWss[url]!=null){
      relayWss[url]!.add(requestWithFilter.serialize());
      _relayResponses['$url/${requestWithFilter.subscriptionId}'] = [[], response];

      if(_relaySubscriptionId.containsKey(url)){
        _relaySubscriptionId[url]!.add(requestWithFilter.subscriptionId);
      }
      else {
        _relaySubscriptionId[url] = Queue<String>();
      }
    }
    else{
      response([]);
    }
  }

  void addRequestSingle(String url, dynamic requestWithFilter, Function(dynamic) response){
    if(relayWss.containsKey(url)&&relayWss[url]!=null){
      relayWss[url]!.add(requestWithFilter.serialize());
      _relaySingleResponses['$url/${requestWithFilter.subscriptionId}'] = response;

      if(_relaySubscriptionId.containsKey(url)){
        _relaySubscriptionId[url]!.add(requestWithFilter.subscriptionId);
      }
      else {
        _relaySubscriptionId[url] = Queue<String>();
      }
    }
  }

  void stopRequestSingle(String url, String subscriptionId){
    if(relayWss.containsKey(url)&&relayWss[url]!=null){
      relayWss[url]!.add(Close(subscriptionId));
    }
  }

  Future<void> addRelayWithUrl (String url) async {

    relayWss[url]= null;

    notifyListeners();
    try {
      WebSocket socket = await WebSocket.connect(url);
      socket.listen((event) {
        final message = Message.deserialize(event);

        switch (message.type){
          case 'EOSE':
            final subscriptionId = jsonDecode(message.message)[0];
            final key = '$url/$subscriptionId';
            socket.add(Close(subscriptionId).serialize());
            if(_relayResponses.containsKey(key)){
              List tmpList = (_relayResponses[key])![0];
              List<Event> eventList = List.generate(tmpList.length, (index) => tmpList[index]);
              (_relayResponses[key])![1](eventList);
              _relayResponses.remove(key);
            }
            if(_relaySingleResponses.containsKey(key)){
              _relaySingleResponses.remove(key);
            }
            if(_relaySubscriptionId.containsKey(url)&&_relaySubscriptionId[url]!.isNotEmpty){
              _relaySubscriptionId[url]!.removeFirst();
            }
            break;
          case 'EVENT':
            final key = '$url/${(message.message as Event).subscriptionId}';
            if(_relayResponses.containsKey(key)){
              ((_relayResponses[key])![0] as List).add(message.message);
            }
            if(_relaySingleResponses.containsKey(key)){
              _relaySingleResponses[key]!(message.message);
            }
            break;
          case 'OK':
            if(_relaySubscriptionId.containsKey(url)&&_relaySubscriptionId[url]!.isNotEmpty){
              final subscriptionId = _relaySubscriptionId[url]!.removeFirst();
              final key = '$url/$subscriptionId';
              if(_relayResponses.containsKey(key)){
                List tmpList = (_relayResponses[key])![0];
                List<Event> eventList = List.generate(tmpList.length, (index) => tmpList[index]);
                (_relayResponses[key])![1](eventList);
                _relayResponses.remove(key);
              }
              if(_relaySingleResponses.containsKey(key)){
                _relaySingleResponses.remove(key);
              }
            }
            break;
          case 'NOTICE':
            if(_relaySubscriptionId.containsKey(url)&&_relaySubscriptionId[url]!.isNotEmpty){
              final subscriptionId = _relaySubscriptionId[url]!.removeFirst();
              final key = '$url/$subscriptionId';
              if(_relayResponses.containsKey(key)){
                List tmpList = (_relayResponses[key])![0];
                List<Event> eventList = List.generate(tmpList.length, (index) => tmpList[index]);
                (_relayResponses[key])![1](eventList);
                _relayResponses.remove(key);
              }
              if(_relaySingleResponses.containsKey(key)){
                _relaySingleResponses[key]!(Exception(jsonDecode(message.message)[0]));
                _relaySingleResponses.remove(key);
              }
            }
            break;
          default:
            break;
        }

      });
      relayWss[url] = socket;
    }
    catch(_) {
      relayWss[url]= null;
    }
    finally {
      await (await prefs).setStringList(relaysSaveKey, relayWss.keys.toList());
      notifyListeners();
    }
  }

  Future<void> deleteRelayWithUrl (String url) async {
    if(relayWss.containsKey(url)) {
      try {
        if(relayWss[url]!=null){
          await relayWss[url]!.close();
        }
        relayWss.remove(url);

        notifyListeners();

        if(_relayResponses.containsKey(url)){
          _relayResponses.remove(url);
        }
      }
      catch (_) {}
      finally{
        final relaysList = (await prefs).getStringList(relaysSaveKey);
        if(relaysList!=null){
          relaysList.remove(url);
          await (await prefs).setStringList(relaysSaveKey, relaysList);
        }
      }
    }
  }
}