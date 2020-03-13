import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Structures/Kontragent/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Kontragent/KontragentList.dart';

class Kontr {
  static void openItem(BuildContext context, Kontragent kontragent) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контрагент',),
        builder: (ctx) => ItemWidget(
              kontragent: kontragent,
            )));
  }

  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контрагенты'),
        builder: (ctx) => KontragentList()));
  }
}
