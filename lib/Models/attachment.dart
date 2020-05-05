import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Structures/CustomLink.dart';
import 'package:mobile_kaskad/Structures/Kontragent/Kontragent.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Woker/Woker.dart';

class Attachment {
  String type;
  String name;
  String value;
  
Attachment({this.value, this.name, this.type});

  factory Attachment.fromJSON(Map<String, dynamic> json) {
    return Attachment(
      value: json["value"],
      name: json['name'],
      type: json['type'],
    );
  }


  Map<String, dynamic> toJson() => {
        "value": value,
        "name": name,
        "type": type,
    };

  void open(BuildContext context) async{
    
    if (type == "HTTP") {
      openURL(value);
    } else if (avalibaleTypes.contains(type)) {
      _openAvaliableType(context);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Прикрепляемая ссылка'),
        builder: (ctx) => CustomLink(type: type, id: value,)));
    }
  }

  var avalibaleTypes = ["Справочник.Контрагенты","Документ.Сообщение","Справочник.Пользователи"];
  
  void _openAvaliableType(BuildContext context) async {
    switch (type) {
      case "Справочник.Контрагенты":
        Kontr.openItem(context, Kontragent(guid: value, name: name));
        break;
      case "Документ.Сообщение":
        Post.openItem(context, value);
        break;
      case "Справочник.Пользователи":
        Wkr.openItem(context, await DBProvider.db.getWorker(value));
        break;
      default:
    }
  }

}

