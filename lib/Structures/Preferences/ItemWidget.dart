import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Logger.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/News/news.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemWidget extends StatefulWidget {
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Настройки"),
        ),
        body: StoreConnector<AppState,AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return ListView(
              children: <Widget>[
                SettingsSection(
                  title: 'ВНЕШНИЙ ВИД',
                  tiles: [
                    SettingsTile(
                      title: 'Тема',
                      subtitle: '${state.settings.theme}',
                      leading: Icon(Icons.settings_brightness),
                      onTap: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              var list = ["Системная", "Светлая", "Темная"];
                              return CupertinoActionSheet(
                                actions: <Widget>[
                                  for (var item in list)
                                    CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          StoreProvider.dispatchFuture(context, SetTheme(item));
                                        },
                                        child: Text(item)),
                                ],
                              );
                            });
                      },
                    ),
                    SettingsTile.switchTile(
                      title: 'Панель почты',
                      subtitle: 'Видимость панели почты на рабочем столе',
                      leading: Icon(FontAwesomeIcons.inbox),
                      switchValue: state.settings.bottomBar,
                      onToggle: (bool value) {
                        StoreProvider.dispatchFuture(context, SetBottomBar(value));
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'ПРОЧЕЕ',
                  tiles: [
                    SettingsTile(
                      title: 'Написать разработчику',
                      subtitle: 'Сообщить об ошибке или пожеланиям',
                      leading: Icon(Icons.mobile_screen_share),
                      onTap: () => Post.newItem(context,
                          title: "Мобильный КАСКАД",
                          text: Logger.getLog(),
                          to: Recipient.getDevs()),
                    ),
                    SettingsTile(
                      title: 'Что нового',
                      subtitle: 'Версия ${Data.version}',
                      leading: Icon(Icons.fiber_new),
                      onTap: () => News.openItem(context),
                    ),
                     SettingsTile(
                      title: 'Что дальше',
                      subtitle: 'Что планируется добить и исправить',
                      leading: Icon(FontAwesomeIcons.solidQuestionCircle),
                      onTap: () => openURL('https://share.clickup.com/b/h/6-17239186-2/b9931596581d02b'),
                    ),
                  ],
                ),
              ],
            );
          }
        ));
  }
}
