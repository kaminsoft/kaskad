import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Structures/Project/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Project/NewItemWidget.dart';
import 'package:mobile_kaskad/Structures/Project/ProjectTaskList.dart';

class ProjectTaskHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Проекты'),
        builder: (ctx) => ProjectTaskList()));
  }

  static void openItem(BuildContext context, String guid, bool isBug) async {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Проекты'),
        builder: (ctx) => ItemWidget(
              guid: guid,
              isBug: isBug,
            )));
  }

  static void newItem(BuildContext context, bool isBug) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
            name: isBug ? "Новое несоответствие" : "Новое предложение"),
        builder: (ctx) => NewItemWidget(
              isBug: isBug,
            )));
  }
}
