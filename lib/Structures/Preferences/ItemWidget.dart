import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/News/news.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Profile/Profile.dart';
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
        body: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return ListView(
                children: <Widget>[
                  userTopWidget(context, state),
                  SettingsSection(
                    title: 'ОСНОВНЫЕ',
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
                                            StoreProvider.dispatchFuture(
                                                context, SetTheme(item));
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
                          StoreProvider.dispatchFuture(
                              context, SetBottomBar(value));
                        },
                      ),
                      SettingsTile.switchTile(
                        title: 'Уведомлять о днях рождения',
                        leading: Icon(FontAwesomeIcons.birthdayCake),
                        switchValue: state.settings.remindOnBirthday,
                        onToggle: (bool value) {
                          StoreProvider.dispatchFuture(
                              context, SetRemindOnBirthday(value));
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'ПРОЧЕЕ',
                    tiles: [
                      SettingsTile(
                        title: 'Написать разработчику',
                        subtitle: Platform.isAndroid
                            ? 'Сообщить об ошибке или пожеланиям'
                            : "",
                        leading: Icon(Icons.mobile_screen_share),
                        onTap: () {
                          Post.newItem(context,
                              title: "Мобильный КАСКАД",
                              text: "",
                              to: Recipient.getDevs());
                        },
                      ),
                      SettingsTile(
                        title: 'Что нового',
                        subtitle: 'Версия ${Data.version}',
                        leading: Icon(Icons.fiber_new),
                        onTap: () {
                          News.openItem(context);
                        },
                      ),
                      SettingsTile(
                        title: 'Что дальше',
                        subtitle: Platform.isAndroid
                            ? 'Что планируется добавить и исправить'
                            : "",
                        leading: Icon(FontAwesomeIcons.solidQuestionCircle),
                        onTap: () {
                          openURL(
                              'https://share.clickup.com/b/h/6-17239186-2/b9931596581d02b');
                        },
                      ),
                    ],
                  ),
                ],
              );
            }));
  }

  Widget userTopWidget(BuildContext context, AppState state) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        child: Text(
            getAvatarLetter("${state.user.lastname} ${state.user.firstname}")),
      ),
      title: Text("${state.user.lastname} ${state.user.firstname}"),
      subtitle: Text("${state.user.position}"),
      trailing: IconButton(
          icon: Icon(
            Icons.exit_to_app,
            color: Colors.red.withAlpha(200),
          ),
          onPressed: () {
            if (Platform.isAndroid) {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      content: Text("Выйти из приложения?"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () => Profile.logOut(context),
                            child: Text("Да")),
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Нет")),
                      ],
                    );
                  });
            } else {
              showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      content: Text("Выйти из приложения?"),
                      actions: <Widget>[
                        CupertinoDialogAction(
                            onPressed: () => Profile.logOut(context),
                            child: Text("Да")),
                        CupertinoDialogAction(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Нет"))
                      ],
                    );
                  });
            }
          }),
    );
  }
}
