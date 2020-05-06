import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskList.dart';

class TaskHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Контрагенты'),
        builder: (ctx) => TaskList()));
  }
}