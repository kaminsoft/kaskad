import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Structures/Preferences/ItemWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<Settings> getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Settings(
      bottomBar: prefs.getBool("hideButtomBar") ?? true,
      theme: prefs.getString("theme") ?? "Системная",
    );
  }

  static void saveSettings(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("hideButtomBar", settings.bottomBar);
    prefs.setString("theme", settings.theme);
  }

  static void openItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
          name: 'Настройки',
        ),
        builder: (ctx) => ItemWidget()));
  }
}
