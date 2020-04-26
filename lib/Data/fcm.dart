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
      'id': msg['id']
    };
  }

  void firebaseCloudMessagingListeners(BuildContext context) async {
    if (Platform.isIOS) iOSPermission();

    Data.token = await _firebaseMessaging.getToken();
    await Connection.sendToken();

    if (!_isConfigured) {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          StoreProvider.dispatchFuture(context, UpdateMessageCount());
          EventEmitter.publishSync("ShowSnakBarNewMessage", getMessageData(message));
        },
        onResume: (Map<String, dynamic> message) async {
          StoreProvider.dispatchFuture(context, UpdateMessageCount());
          EventEmitter.publishSync("OpenInMessage",  getMessageData(message));
        },
        onLaunch: (Map<String, dynamic> message) async {
          StoreProvider.dispatchFuture(context, UpdateMessageCount());
          EventEmitter.publishSync("ShowSnakBarNewMessage",  getMessageData(message));
        },
      );
      _isConfigured = true;
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
