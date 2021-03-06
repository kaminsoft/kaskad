import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_kaskad/Models/intro.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:vibrate/vibrate.dart';

class Data {
  static User curUser;
  static String messageId;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static String version = '';
  static int dbVersion = 1;
  static bool showNews = false;
  static String token = "";
  static List<AssetProvider> cachedAssets = [
  AssetFlare(bundle: rootBundle, name: 'assets/img/etc/sparks.flr'),
  AssetFlare(bundle: rootBundle, name: 'assets/img/etc/sparks2.flr'),
  AssetFlare(bundle: rootBundle, name: 'assets/img/etc/cakes.flr')
];
}

int getDBVersion() {
  var nums = Data.version.split(".");
  String tmp = "";
  for (var item in nums) {
    if (item != "0") {
      tmp += item;
    }
  }
  return int.parse(tmp);
}

const Color ColorGray = Color(0xFFEEEEEE);
const Color ColorMiddle = Color(0xFF232227);
const Color ColorDark = Color(0xFF303135);
const Color ColorMain = Color(0xFF5167DC);
const Color ColorMainLight = Color(0xFF9FB0FE);

const BorderSide kDefaultRoundedBorderSideError = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Colors.red,
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);

const BorderSide kDefaultRoundedBorderSideSuccess = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);

String getAvatarLetter(String name) {
  if (name.isEmpty) {
    return "ХЗ";
  }
  var ret = name.split(" ");
  if (ret.length >= 2) {
    return "${ret[0][0]}${ret[1][0]}";
  }
  return "ХЗ";
}

void vibrate() async {
  // bool canVibrate = await Vibrate.canVibrate;
  // canVibrate ? Vibrate.feedback(FeedbackType.medium) : null;
}

List<Intro> introList = [
  Intro(
      title: 'Почта',
      description:
          'Теперь почта КАСКАДа всегда вместе с вами. Получайте уведомления о новых сообщениях, отправляйте сообщения и объявления',
      image: 'assets/img/intro01.svg'),
  Intro(
      title: 'Контрагенты',
      description:
          'Просматривайте информацию по контрагентам: контактная информация, контакты, продукты и многое другое всегда под рукой',
      image: 'assets/img/intro02.svg'),
  Intro(
      title: 'Сотрудники',
      description:
          'Просматривайте информацию по сотрудникам, отдел, телефон, теперь всегда можно связаться с нужным человеком',
      image: 'assets/img/intro03.svg'),
  Intro(
      title: 'Задачи',
      description:
          'Получайте и выполняйте поставленные задачи, не заходя в основной КАСКАД',
      image: 'assets/img/intro04.svg'),
];

void call(String phone) {
  if (phone != null && phone.isNotEmpty) {
    var num = phone.replaceAll('-', '');
    num = num.replaceAll('(', '');
    num = num.replaceAll(')', '');
    num = num.replaceAll(' ', '');
    launch("tel:$num");
  }
}

void mailto(String mail) {
  if (mail != null && mail.isNotEmpty) {
    launch("mailto:$mail");
  }
}

void openURL(String url) {
  launch(url);
}

GlobalKey<ScaffoldState> mainWidgetKey = GlobalKey();

class OnMessageEvent {
  dynamic data;

  OnMessageEvent(this.data);
}
