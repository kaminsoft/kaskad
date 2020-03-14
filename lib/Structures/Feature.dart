
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_kaskad/Pages/underConstruction.dart';
import 'package:mobile_kaskad/Structures/Kontragent/Kontragent.dart';
import 'package:mobile_kaskad/Structures/Woker/Woker.dart';

typedef PressCallback = void Function(BuildContext context, {String feature});

class Feature {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String image;
  bool enabled;
  bool isNew;

  final PressCallback onPressed;

  Feature(
      {this.name,
      this.description,
      this.icon,
      this.color,
      this.onPressed,
      this.image,
      this.enabled = true,
      this.isNew = false});

  Map<String, dynamic> toJson() => {
        "name": name,
        "enabled": enabled ? 1 : 0,
      };

  bool operator ==(other) => other.name == name;
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
        name: 'Контрагенты',
        icon: CupertinoIcons.group_solid,
        color: Color(0xff5972F3),
        image: 'assets/img/cards/kontragent.png',
        onPressed: (ctx, {feature}) => Kontr.openList(ctx)),
    Feature(
        name: 'Сотрудники',
        icon: CupertinoIcons.person_solid,
        color: Color(0xff5972F3),
        image: 'assets/img/cards/sotrudnik.png',
        onPressed: (ctx, {feature}) => Wkr.openList(ctx)),
    Feature(
        name: 'Задачи',
        icon: Icons.playlist_add_check,
        color: Color(0xff5972F3),
        image: 'assets/img/cards/task.png',
        onPressed: _wip),
    Feature(
        name: 'Контакты',
        icon: Icons.playlist_add_check,
        color: Color(0xff5972F3),
        image: 'assets/img/cards/contact.png',
        onPressed: _wip),
    Feature(
        name: 'Проекты',
        icon: Icons.playlist_add_check,
        color: Color(0xff5972F3),
        image: 'assets/img/cards/project.png',
        onPressed: _wip),
  ];
}
