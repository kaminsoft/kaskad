import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Tasks/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskList.dart';

class TaskHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Задачи'),
        builder: (ctx) => TaskList()));
  }

  static void openItem(BuildContext context, String guid) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Задача'),
        builder: (ctx) => ItemWidget(guid: guid,)));
  }
}