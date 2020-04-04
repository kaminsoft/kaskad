import 'dart:async';
import 'dart:ui';

import 'package:async_redux/async_redux.dart';
import 'package:badges/badges.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/Logger.dart';
import 'package:mobile_kaskad/Data/fcm.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';
import 'package:mobile_kaskad/Structures/News/news.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Preferences/Preferences.dart';
import 'package:mobile_kaskad/Structures/Profile/Profile.dart';
import 'package:reorderables/reorderables.dart';

import 'Data/Events.dart';
import 'Models/user.dart';
import 'Store/AppState.dart';

enum PopupItems { exit, settings }

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool editMode = false;
  bool subscibed = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      FeatureDiscovery.discoverFeatures(context, mainPageTutt);
    });
    Data.analytics.logLogin();
  }

  @override
  void dispose() {
    Events.unSubscribeMessageEvents();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!subscibed) {
      Events.subscribeMessageEvents(context);
      FirebaseNotifications().setUpFirebase(context);
      StoreProvider.dispatchFuture(context, UpdateMessageCount());
      subscibed = true;
    }
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        StoreProvider.dispatchFuture(context, UpdateMessageCount());
      }
    });
    if (Data.showNews) {
      Timer(Duration(seconds: 1), () => News.openItem(context));
    }
    return StoreConnector<AppState, User>(
        converter: (store) => store.state.user,
        builder: (context, user) {
          return Scaffold(
            key: mainWidgetKey,
            appBar: AppBar(
              centerTitle: true,
              title: editMode
                  ? Text('Режим редактирования')
                  : Text(
                      'Рабочий стол',
                      style: TextStyle(fontSize: 16),
                    ),
              actions: editMode
                  ? []
                  : <Widget>[
                      IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () => _openMenu(context)),
                    ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: StoreConnector<AppState, List<Feature>>(
                    converter: (store) => store.state.features,
                    builder: (BuildContext context, features) {
                      var list = editMode
                          ? features
                          : features.where((f) => f.enabled).toList();
                      if (list.length == 0) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Не выбранно ни одной категории'),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      editMode = true;
                                    });
                                    FeatureDiscovery.discoverFeatures(
                                      context,
                                      <String>{mainPageTutt[1]},
                                    );
                                  },
                                  child: Text('Редактировать'))
                            ],
                          ),
                        );
                      }

                      return Scrollbar(
                        child: ReorderableWrap(
                          maxMainAxisCount: 2,
                          buildDraggableFeedback: (context, box, widget) {
                            return widget;
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            StoreProvider.dispatchFuture(
                                context, ReorderFeatures(oldIndex, newIndex));
                          },
                          needsLongPressDraggable: true,
                          children:
                              List<Widget>.generate(list.length, (int index) {
                            return GestureDetector(
                                onLongPress: editMode
                                    ? null
                                    : () {
                                        setState(() {
                                          editMode = true;
                                        });
                                        vibrate();
                                        Timer(
                                            Duration(milliseconds: 500),
                                            () => FeatureDiscovery
                                                .discoverFeatures(
                                                    context, mainPageTutt));
                                      },
                                child: FeatureCard(
                                  feature: list[index],
                                  index: index,
                                  editMode: editMode,
                                ));
                          }),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  color: Colors.transparent,
                  child: editMode
                      ? DescribedFeatureOverlay(
                          featureId: mainPageTutt[1],
                          tapTarget: Text('OK',
                              style: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(fontWeight: FontWeight.bold)),
                          backgroundColor: ColorMain,
                          title: Text('Редактирование'),
                          description: Column(
                            children: <Widget>[
                              Text(
                                'В этом режиме можно менять местами карточки разделов, включать и выключать их.',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Чтобы упорядочить разделы просто нажмите на один из них и переместите на удобное вам место.',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: MessageButton(
                                filed: true,
                                count: 0,
                                text: 'Завершить редактированиe',
                                onPressed: () {
                                  setState(() {
                                    editMode = false;
                                  });
                                  StoreProvider.dispatchFuture(
                                      context, AfterEditFeatures());
                                }),
                          ),
                        )
                      : DescribedFeatureOverlay(
                          featureId: mainPageTutt[0],
                          tapTarget: Text('OK',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: ColorMain,
                          title: Text('Добро пожаловать!'),
                          description: Column(
                            children: <Widget>[
                              Text(
                                'Это главный экран приложения. Здесь отображаются сообщения, объявления и доступные разделы, которыми можно управлять.',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Чтобы убрать ненужные разделы или поменять их местами, просто зажмите палец на разделе. Откроется режим редактирования разделами.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          child: StoreConnector<AppState, Settings>(
                            converter: (store) => store.state.settings,
                            builder: (context, settings) {
                              if (settings.bottomBar) {
                                return SafeArea(
                                  bottom: true,
                                  top: false,
                                  child:
                                      StoreConnector<AppState, NewMessageCount>(
                                    converter: (store) =>
                                        store.state.messageCount,
                                    builder: (context, messages) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Expanded(
                                              child: MessageButton(
                                            count: messages.message,
                                            onPressed: () =>
                                                Post.openList(context, false),
                                            text: 'сообщения',
                                          )),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: MessageButton(
                                            count: messages.post,
                                            onPressed: () =>
                                                Post.openList(context, true),
                                            text: 'объявления',
                                          )),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }
                              return Container();
                            },
                          )),
                )
              ],
            ),
          );
        });
  }

  _openMenu(context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Preferences.openItem(context);
                  },
                  child: Text('Настройки')),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      editMode = true;
                    });
                  },
                  child: Text('Изменить рабочий стол'))
            ],
            cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Profile.logOut(context);
                },
                child: Text('Выход')),
          );
        });
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    Key key,
    @required this.feature,
    @required this.index,
    @required this.editMode,
  }) : super(key: key);

  final Feature feature;
  final int index;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    bool even = index % 2 == 0;

    var size = MediaQuery.of(context).size;
    return StoreConnector<AppState, List<Feature>>(
        converter: (store) => store.state.features,
        builder: (context, userFeatures) {
          return Padding(
            padding: EdgeInsets.only(
                top: 10, left: even ? 10 : 5, right: even ? 5 : 10),
            child: Container(
              width: size.width / 2 - 15,
              height: size.height / 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10,
                        color: Theme.of(context).colorScheme.onSecondary,
                        offset: Offset(0, 0),
                        spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black87,
                      feature.enabled ? BlendMode.lighten : BlendMode.hue),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      splashColor: ColorMain,
                      onTap: editMode
                          ? () => toogleFeature(context, feature)
                          : () =>
                              feature.onPressed(context, feature: feature.name),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    feature.name.toUpperCase(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(24)),
                                  child: SizedBox(
                                    width: size.width / 2 - 15,
                                    height: size.height / 5,
                                    child: FittedBox(
                                      alignment: Alignment.bottomLeft,
                                      fit: BoxFit.contain,
                                      child: Image.asset(feature.image),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          feature.isMessage
                              ? StoreConnector<AppState, NewMessageCount>(
                                  converter: (store) =>
                                      store.state.messageCount,
                                  builder: (context, messages) {
                                    if (messages.message == 0) {
                                      return Container();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10),
                                      child: Badge(
                                        padding: EdgeInsets.all(8),
                                        badgeColor: ColorMain,
                                        badgeContent: Text(
                                          '${messages.message}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(),
                          feature.isPublicate
                              ? StoreConnector<AppState, NewMessageCount>(
                                  converter: (store) =>
                                      store.state.messageCount,
                                  builder: (context, messages) {
                                    if (messages.post == 0) {
                                      return Container();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10),
                                      child: Badge(
                                        padding: EdgeInsets.all(8),
                                        badgeColor: ColorMain,
                                        badgeContent: Text(
                                          '${messages.post}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: editMode
                                  ? Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 5,
                                              color: Colors.black38,
                                              offset: Offset(2, 0),
                                              spreadRadius: 2)
                                        ],
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(24)),
                                        color: ColorMain,
                                      ),
                                      child: Material(
                                        color: ColorMain,
                                        child: InkWell(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(24),
                                              bottomRight: Radius.circular(24)),
                                          splashColor:
                                              Theme.of(context).cardTheme.color,
                                          child: Center(
                                              child: Text(
                                            feature.enabled
                                                ? 'выключить'
                                                : 'включить',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          )),
                                          onTap: () {
                                            toogleFeature(context, feature);
                                          },
                                        ),
                                      ),
                                    )
                                  : Container())
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void toogleFeature(BuildContext context, Feature feature) {
    if (feature.enabled) {
      StoreProvider.dispatchFuture(context, RemoveFeature(feature));
    } else {
      StoreProvider.dispatchFuture(context, AddFeature(feature));
    }
  }
}

class MessageButton extends StatelessWidget {
  final int count;
  final String text;
  final VoidCallback onPressed;
  final bool filed;
  const MessageButton(
      {Key key,
      @required this.count,
      @required this.text,
      @required this.onPressed,
      this.filed = false})
      : super(key: key);

  Widget body() {
    return count == 0
        ? Text(text)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(text),
              Badge(
                badgeColor: ColorMain,
                badgeContent: Text(
                  '$count',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return filed
        ? CupertinoButton(
            padding: EdgeInsets.all(0),
            color: ColorMain,
            child: body(),
            onPressed: onPressed)
        : OutlineButton(
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.body1.color.withAlpha(100)),
            textColor: Theme.of(context).textTheme.body1.color,
            padding: EdgeInsets.all(0),
            color: ColorMain,
            child: body(),
            onPressed: onPressed);
  }
}
