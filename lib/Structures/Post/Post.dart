import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Structures/Post/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Post/MessageList.dart';
import 'package:mobile_kaskad/Structures/Post/NewItemWidget.dart';
import 'package:toast/toast.dart';

class Post {
  static void openItem(BuildContext context, String id) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
          name: 'Сообщение',
        ),
        builder: (ctx) => ItemWidget(
              id: id,
            )));
  }

  static void openList(BuildContext context, bool isPublicate) {
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(
          name: isPublicate ? 'Объявления' : 'Сообщения',
        ),
        builder: (ctx) => MessageList(
              isPublicate: isPublicate,
            )));
  }

  static void newItem(BuildContext context,
      {String title,
      String text,
      List<Recipient> to,
      bool reSend,
      bool isPublicate}) {
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(
          name: 'Новое сообщение',
        ),
        builder: (ctx) => NewItemWidget(
            title: title,
            text: text,
            to: to,
            reSend: reSend,
            isPublicate: isPublicate)));
  }

  static void msgSent(BuildContext context, Message msg) {
    Navigator.of(context).pop();
    var type = msg.isPublicite ? 'Объявление' : 'Сообщение';
    Toast.show('$type отправлено', context,
        backgroundColor: Colors.green, gravity: Toast.BOTTOM, duration: 5);
    //EventEmitter.publishSync("MessageSent", null);
  }

  static Future showContextMenu(BuildContext context, Message msg) {
    return showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Отмена")),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    String text =
                        '\n\n=== Пересылаемое сообщение === \n${msg.text}';
                    String title = 'FW: ${msg.title}';
                    Navigator.of(context).pop();
                    newItem(context,
                        text: text,
                        title: title,
                        reSend: true,
                        isPublicate: msg.isPublicite);
                  },
                  child: Text("Переслать")),
              CupertinoActionSheetAction(
                  onPressed: () {
                    String text =
                        '\n\n=== Пересылаемое сообщение === \n${msg.text}';
                    String title = 'RE: ${msg.title}';
                    List<Recipient> to = List<Recipient>();
                    to.add(msg.from.toRecipient());
                    Navigator.of(context).pop();
                    newItem(context,
                        text: text,
                        title: title,
                        to: to,
                        isPublicate: msg.isPublicite);
                  },
                  child: Text("Ответить")),
              msg.to.length > 0
                  ? CupertinoActionSheetAction(
                      onPressed: () async {
                        String text =
                            '\n\n=== Пересылаемое сообщение === \n${msg.text}';
                        String title = 'RE: ${msg.title}';
                        List<Recipient> to =
                            msg.to.map((e) => e.toRecipient()).toList();
                        to.add(msg.from.toRecipient());
                        Navigator.of(context).pop();
                        newItem(context,
                            text: text,
                            title: title,
                            to: to,
                            isPublicate: msg.isPublicite);
                      },
                      child: Text("Ответить всем"))
                  : Container(),
            ],
          );
        });
  }
}
