import 'dart:ui';

import 'package:async_redux/async_redux.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/fcm.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
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
      subscibed = true;
    }
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        StoreProvider.dispatchFuture(context, UpdateMessageCount());
      }
    });
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
                          onPressed: () =>
                              _openMenu(context)),
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
                          needsLongPressDraggable: !editMode,
                          children:
                              List<Widget>.generate(list.length, (int index) {
                            return GestureDetector(
                                onLongPress: () {
                                  if (!editMode) {
                                    setState(() {
                                      editMode = true;
                                    });
                                    vibrate();
                                  }
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.transparent,
                  child: editMode
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
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
                          ],
                        )
                      : StoreConnector<AppState, NewMessageCount>(
                          converter: (store) => store.state.messageCount,
                          builder: (context, messages) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  onPressed: () => Post.openList(context, true),
                                  text: 'объявления',
                                )),
                              ],
                            );
                          },
                        ),
                )
              ],
            ),
          );
        });
  }

  _openMenu(context) {
    showCupertinoModalPopup(context: context, builder: (context){
      return CupertinoActionSheet(
        
        actions: <Widget>[
          CupertinoActionSheetAction(onPressed: (){
            Navigator.of(context).pop();
            showCupertinoDialog(context: context, builder: (context){
              return CupertinoAlertDialog(
                
                content: Column(
                  children: <Widget>[
                    Text('Мобильное приложение для взаимодействия с функциями КАСКАДа'),
                    SizedBox(height: 5,),
                    Text('Версия ${Data.version}', style: TextStyle(color: Colors.black54),)
                  ],
                ),
                actions: <Widget>[
                  CupertinoDialogAction(child: Text('OK'), onPressed: () => Navigator.of(context).pop(),)
                ],
              );
            });
          }, child: Text('О приложении'))
        ],
        cancelButton: CupertinoActionSheetAction(isDestructiveAction: true, onPressed: (){Profile.logOut(context);}, child: Text('Выход')),
      );
    });
    // showModalBottomSheet(
    //   isDismissible: true,
    //   backgroundColor: Colors.transparent,
    //   clipBehavior: Clip.antiAlias,
    //   context: context, builder: (context){
    //   return Container(
        
    //     height: MediaQuery.of(context).size.height/3,
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
    //     ),
    //     child: Column(children: <Widget>[
    //       Row(children: <Widget>[
    //         CupertinoButton(color: ColorMain, child: Text('О приложении'), onPressed: (){},),
    //         CupertinoButton(color: ColorMain, child: Text('Выход'), onPressed: (){},)
    //       ],) 
          
    //     ],),
    //   );
    // });
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10,
                        color: Color(0xFFDADDEB),
                        offset: Offset(0, 0),
                        spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: NewBanner(
                  visible: feature.isNew,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.black87,
                        feature.enabled ? BlendMode.lighten : BlendMode.hue),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        splashColor: ColorMain,
                        onTap: editMode
                            ? null
                            : () => feature.onPressed(context,
                                feature: feature.name),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                bottomRight:
                                                    Radius.circular(24)),
                                            color: ColorMain,
                                          ),
                                          child: Material(
                                            color: ColorMain,
                                            child: InkWell(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(24),
                                                  bottomRight:
                                                      Radius.circular(24)),
                                              splashColor: Colors.white,
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
                                                if (feature.enabled) {
                                                  StoreProvider.dispatchFuture(
                                                      context,
                                                      RemoveFeature(feature));
                                                } else {
                                                  StoreProvider.dispatchFuture(
                                                      context,
                                                      AddFeature(feature));
                                                }
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
              ),
            ),
          );
        });
  }
}

class NewBanner extends StatelessWidget {
  final bool visible;
  final Widget child;

  const NewBanner({Key key, this.visible, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return visible
        ? Banner(
            message: "NEW",
            color: ColorMain,
            location: BannerLocation.topStart,
            child: child,
          )
        : Container(
            child: child,
          );
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
            padding: EdgeInsets.all(0),
            color: ColorMain,
            child: body(),
            onPressed: onPressed);
  }
}
