import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Structures/Preferences/ItemWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<Settings> getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Settings(
      timeOut: prefs.getInt("timeOut") ?? 5,
      useProductionServer: prefs.getBool("useProductionServer") ?? false
    );
  }

  static void saveSettings(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("timeOut", settings.timeOut);
    prefs.setBool("useProductionServer", settings.useProductionServer);
  }

  static void openItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
          name: 'Настройки',
        ),
        builder: (ctx) => ItemWidget()));
  }
}
