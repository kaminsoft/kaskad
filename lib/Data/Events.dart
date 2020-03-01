import 'package:async_redux/async_redux.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/fcm.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';

class Events {
  static void subscribeMessageEvents(context) {
    EventEmitter.subscribe('OpenInMessage', (data) {
      Data.analytics.logEvent(name: 'open_msg_push');
      Post.openItem(context, data['id']);
    });

    EventEmitter.subscribe('MessageSent', (data) {});

    EventEmitter.subscribe('ShowSnakBarNewMessage', (data) {
      String _title = data['title'];
      _title = _title.length > 65 ? _title.substring(0, 62) + '...' : _title;
      Flushbar(
        messageText: Text(
          _title,
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        titleText: Text(
          'Новое сообщение',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        mainButton: FlatButton(
          child: Text(
            'Открыть',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Data.analytics.logEvent(name: 'open_msg_snak');
            Navigator.of(context).pop();
            Post.openItem(context, data['id']);
          },
        ),
        animationDuration: Duration(milliseconds: 500),
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        icon: Icon(Icons.mail, color: Colors.white),
        // Show it with a cascading operator
      )..show(context);
    });
  }

  static void unSubscribeMessageEvents() {
    EventEmitter.unsubscribe("OpenInMessage");
    EventEmitter.unsubscribe("MessageSent");
    EventEmitter.unsubscribe("ShowSnakBarNewMessage");
  }
}
