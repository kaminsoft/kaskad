import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Project/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Project/ProjectList.dart';

class ProjectHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Проекты'),
        builder: (ctx) => ProjectList()));
  }

  static void openItem(BuildContext context, String guid) async {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Проекты'),
        builder: (ctx) => ItemWidget(
              guid: guid,
            )));
  }
}
