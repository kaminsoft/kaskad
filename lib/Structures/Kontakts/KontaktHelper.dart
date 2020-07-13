import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Kontakts/ItemWidget.dart';

import 'KontaktList.dart';

class KontaktHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контакты'),
        builder: (ctx) => KontaktList()));
  }

  static void openItem(BuildContext context, String guid) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контакт'),
        builder: (ctx) => ItemWidget(
              guid: guid,
            )));
  }
}
