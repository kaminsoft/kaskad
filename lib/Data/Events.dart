import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/woker.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Woker/Woker.dart';

class Events {
  static void subscribeMessageEvents(context) {
    EventEmitter.subscribe('OpenInMessage', (data) {
      Data.analytics.logEvent(name: 'open_msg_push');
      Post.openItem(context, data['id']);
    });

     EventEmitter.subscribe('OpenBirthday', (data) {
      Data.analytics.logEvent(name: 'open_birthday_push');
      Wkr.openBirthdayWidget(context, workers: Woker.listFromJSONString(data));
    });
    
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

    EventEmitter.subscribe('ShowSnakBarBirthday', (data) {
      List<Woker> workers = Woker.listFromJSONString(data);
      var list = workers.map((e)=> e.shortName);
      
      Flushbar(
        messageText: Text(
          list.toString(),
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        titleText: Text(
          'День рождения!',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        mainButton: FlatButton(
          child: Text(
            'Открыть',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Data.analytics.logEvent(name: 'open_birthday_snak');
            Navigator.of(context).pop();
            Wkr.openBirthdayWidget(context, workers: workers);
          },
        ),
        animationDuration: Duration(milliseconds: 500),
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        icon: Icon(Icons.cake, color: Colors.white),
        // Show it with a cascading operator
      )..show(context);
    });
  }

  static void unSubscribeMessageEvents() {
    EventEmitter.unsubscribe("OpenInMessage");
    EventEmitter.unsubscribe("OpenBirthday");
    EventEmitter.unsubscribe("ShowSnakBarNewMessage");
    EventEmitter.unsubscribe("ShowSnakBarBirthday");
  }
}
