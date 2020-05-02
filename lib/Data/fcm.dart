import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Store/Actions.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;
  bool _isConfigured = false;

  void setUpFirebase(BuildContext context) {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners(context);
  }

  getMessageData(message) {
    var msg = message;
    if (Platform.isAndroid) {
      msg = message['data'];
    }
    return {
      'text': msg['text'],
      'title': msg['title'],
      'id': msg['id'],
      'action': jsonDecode(msg['action'])
    };
  }

  void firebaseCloudMessagingListeners(BuildContext context) async {
    if (Platform.isIOS) iOSPermission();

    Data.token = await _firebaseMessaging.getToken();
    await Connection.sendToken();

    if (!_isConfigured) {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          processMessage(message, context, 'onMessage');
        },
        onResume: (Map<String, dynamic> message) async {
          processMessage(message, context, 'onResume');
        },
        onLaunch: (Map<String, dynamic> message) async {
          processMessage(message, context, 'onLaunch');
        },
      );
      _isConfigured = true;
    }
  }

  void processMessage(Map<String, dynamic> message, BuildContext context, String event) {
    var msgData = getMessageData(message);
    if (msgData['action']['type'] == "new_message") {
      var eventEm = event == "onResume" ? "OpenInMessage" : "ShowSnakBarNewMessage";
      StoreProvider.dispatchFuture(context, UpdateMessageCount());
      EventEmitter.publishSync(eventEm,  msgData);
    }
    if (msgData['action']['type'] == "birthday_reminder") {
      var eventEm = event == "onResume" ? "OpenBirthday" : "ShowSnakBarBirthday";
      EventEmitter.publishSync(eventEm,  msgData['action']['data']);
    }
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
