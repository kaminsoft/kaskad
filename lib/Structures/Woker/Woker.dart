import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Structures/Woker/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Woker/ListWidget.dart';
import 'package:mobile_kaskad/Models/woker.dart';

class Wkr {
  static void openItem(BuildContext context, Woker woker) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
          name: 'Сотрудник',
        ),
        builder: (ctx) => ItemWidget(
              woker: woker,
            )));
  }

  static void openItemById(BuildContext context, String id) {
    DBProvider.db
        .getWorker(id)
        .then((woker) => Navigator.of(context).push(MaterialPageRoute(
            settings: RouteSettings(
              name: 'Сотрудник',
            ),
            builder: (ctx) => ItemWidget(
                  woker: woker,
                ))));
  }

  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Сотрудники'),
        builder: (ctx) => ListWidget()));
  }
}
