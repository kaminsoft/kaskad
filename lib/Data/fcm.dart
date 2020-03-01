import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  void firebaseCloudMessagingListeners(BuildContext context) async {
    if (Platform.isIOS) iOSPermission();

    var token = await _firebaseMessaging.getToken();
    await Connection.sendToken(token);
    print(token);

    if (!_isConfigured) {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          StoreProvider.dispatchFuture(context, UpdateMessageCount());
          if(message['action'] != null) {
            var action = json.decode(message['action']);
            EventEmitter.publishSync(action['type'] ,action['data']);
          }
          
          Data.messageId = message['id'];
          var data = {'text': message['text'], 'title': message['title'], 'id': message['id']};
          EventEmitter.publishSync("ShowSnakBarNewMessage",data);
          
        },
        onResume: (Map<String, dynamic> message) async {
          StoreProvider.dispatchFuture(context, UpdateMessageCount());
          Data.messageId = message['id'];
          var data = {'text': message['text'], 'title': message['title'], 'id': message['id']};
          EventEmitter.publishSync("OpenInMessage", data);
        },
        onLaunch: (Map<String, dynamic> message) async {
          StoreProvider.dispatchFuture(context, UpdateMessageCount());
          var data = {'text': message['data']['text'], 'title': message['data']['title'], 'id': message['data']['id']};
          EventEmitter.publishSync("ShowSnakBarNewMessage",data);
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

class LocalNotifications {

  static FlutterLocalNotificationsPlugin localNotificationsPlugin;
  
  static Future onSelectNotification(String payload) async{
    print(payload);
  }

  static void setUpLocalNotifications() async {

    var androidSettings = AndroidInitializationSettings('app_icon');
    var iOSSettings = IOSInitializationSettings();
    var settings = InitializationSettings(androidSettings, iOSSettings);

    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    bool res = await localNotificationsPlugin.initialize(settings,onSelectNotification: onSelectNotification);
    print(res);
  }

  static void showNotification(String title, String text, {Message msg}) async{
    var android = AndroidNotificationDetails('channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var details = NotificationDetails(android, iOS);
    await localNotificationsPlugin.show(0, title, text, details);
  }

}