import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/News/ItemWidget.dart';

class News {

   static void openItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
          name: 'Что нового',
        ),
        builder: (ctx) => ItemWidget()));
  }

}