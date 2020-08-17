import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Structures/Project/ItemWidget.dart';
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
}
