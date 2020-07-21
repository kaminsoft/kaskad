import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Kontakts/ItemWidget.dart';

import '../../Models/linkItem.dart';
import 'KontaktList.dart';
import 'NewItemWidget.dart';

class KontaktHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контакты'),
        builder: (ctx) => KontaktList()));
  }

  static void openItem(BuildContext context, String guid) async {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контакт'),
        builder: (ctx) => ItemWidget(
              guid: guid,
            )));
  }

  static void newItem(BuildContext context, {LinkItem kontragent}) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Новый контакт'),
        builder: (ctx) => NewItemWidget(
              kontragent: kontragent,
            )));
  }

  static Color getStatusColor(BuildContext context, String status) {
    if (status == "Состоялся") {
      return Colors.green;
    }

    return Theme.of(context).textTheme.bodyText1.color.withAlpha(150);
  }
}
