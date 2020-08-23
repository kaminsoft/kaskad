import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerWidget.dart';

class Picker {
  static Map<String, String> _commonFields = {
    "Контрагенты": "ИНН",
    "Проекты": "Менеджер,ТехническийРуководитель"
  };

  static String getObjectFields(String name) {
    return _commonFields[name] ?? "";
  }

  static Future<LinkItem> pickElement(BuildContext context, String type,
      {LinkItem owner}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PickerWidget(
                type: type,
                owner: owner,
              )),
    );
  }
}

class PikerController extends ValueNotifier<LinkItem> {
  final String type;
  final String label;
  PikerController _owner;

  PikerController get owner => _owner;

  PikerController({@required this.type, @required this.label, LinkItem value})
      : super(value == null ? LinkItem() : value);

  void setOwner(PikerController owner) {
    _owner = owner;
  }
}
