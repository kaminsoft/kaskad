import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_kaskad/Pages/underConstruction.dart';
import 'package:mobile_kaskad/Structures/Kontragent/Kontragent.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Project/ProjectHelper.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskHelper.dart';
import 'package:mobile_kaskad/Structures/Woker/Woker.dart';
import 'package:mobile_kaskad/Structures/Kontakts/KontaktHelper.dart';

typedef PressCallback = void Function(BuildContext context, {String feature});

enum FeatureRole { none, message, publicate, task }

class Feature {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String image;
  final FeatureRole role;
  bool enabled;

  final PressCallback onPressed;

  Feature(
      {this.name,
      this.description,
      this.icon,
      this.color,
      this.onPressed,
      this.image,
      this.enabled = false,
      this.role = FeatureRole.none});

  Map<String, dynamic> toJson() => {
        "name": name,
        "enabled": enabled ? 1 : 0,
      };

  bool operator ==(other) => other.name == name;

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

_wip(BuildContext context, {String feature}) {
  Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(
        name: feature,
      ),
      builder: (ctx) => UnderConstruction(
            feature: feature,
          )));
}

List<Feature> getInitialFeatureList() {
  return [
    Feature(
        enabled: true,
        name: 'Контрагенты',
        image: 'assets/img/cards/kontragent.png',
        onPressed: (ctx, {feature}) => KontragentHelper.openList(ctx)),
    Feature(
        enabled: true,
        name: 'Сотрудники',
        image: 'assets/img/cards/sotrudnik.png',
        onPressed: (ctx, {feature}) => WorkerHelper.openList(ctx)),
    Feature(
        name: 'Сообщения',
        image: 'assets/img/cards/post01.png',
        role: FeatureRole.message,
        onPressed: (ctx, {feature}) => Post.openList(ctx, false)),
    Feature(
        name: 'Объявления',
        image: 'assets/img/cards/post02.png',
        role: FeatureRole.publicate,
        onPressed: (ctx, {feature}) => Post.openList(
              ctx,
              true,
            )),
    Feature(
        enabled: true,
        name: 'Задачи',
        role: FeatureRole.task,
        image: 'assets/img/cards/task.png',
        onPressed: (ctx, {feature}) => TaskHelper.openList(ctx)),
    Feature(
        enabled: true,
        name: 'Контакты',
        image: 'assets/img/cards/contact.png',
        onPressed: (ctx, {feature}) => KontaktHelper.openList(ctx)),
    Feature(
        enabled: true,
        name: 'Проекты',
        image: 'assets/img/cards/project.png',
        onPressed: (ctx, {feature}) => ProjectHelper.openList(ctx)),
  ];
}
