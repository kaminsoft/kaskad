import 'dart:async';
import 'dart:io' show Platform;

import 'package:async_redux/async_redux.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';

import 'Kontragent.dart';

GlobalKey kontragentListKey = GlobalKey();

class KontragentList extends StatefulWidget {
  KontragentList({Key key}) : super(key: key);

  @override
  _KontragentListState createState() => _KontragentListState();
}

class _KontragentListState extends State<KontragentList> {
  bool searchMode = false;
  TextEditingController filter = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<Kontragent> searchList = List<Kontragent>();
  String query = '';
  List list = [];
  bool loading = false;
  Timer timer;

  @override
  void initState() {
    //FeatureDiscovery.clearPreferences(context, kontragenTutt);
    FeatureDiscovery.discoverFeatures(
      context,
      <String>{kontragenTutt[0]},
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: kontragentListKey,
      appBar: searchMode
          ? AppBar(
              automaticallyImplyLeading: false,
              title: TextField(
                controller: filter,
                focusNode: focusNode,
                style: Theme.of(context).textTheme.title,
                textInputAction: TextInputAction.unspecified,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск',
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                ),
                onChanged: (text) {
                  if (timer != null) {
                    timer.cancel();
                  }
                  timer = Timer(Duration(milliseconds: 500), () async {
                    setState(() {
                      loading = true;
                    });
                    var lst = await Connection.searchKontragent(filter.text);
                    setState(() {
                      list = lst;
                    });
                    setState(() {
                      loading = false;
                    });
                  });
                },
              ),
              leading: IconButton(
                  icon: Icon(Platform.isAndroid
                      ? Icons.arrow_back
                      : Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      searchMode = false;
                    });
                  }),
              actions: <Widget>[
                Visibility(
                  visible: filter.text.isNotEmpty,
                  child: IconButton(
                      icon: Icon(CupertinoIcons.clear),
                      onPressed: () {
                        setState(() {
                          query = '';
                          filter.text = '';
                        });
                      }),
                ),
              ],
            )
          : AppBar(
              title: Text('Контрагенты'),
              centerTitle: true,
              actions: <Widget>[
                DescribedFeatureOverlay(
                  featureId: kontragenTutt[0],
                  tapTarget: Icon(Icons.search),
                  backgroundColor: ColorMain,
                  onDismiss: () async {
                    FeatureDiscovery.completeCurrentStep(context);
                    return true;
                  },
                  title: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Контрагенты',
                        textAlign: TextAlign.right,
                      )),
                  description: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Здесь отображаются избранные контрагенты. Они доступны даже без подключения к сети.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Информацию по всем контрагентам можно получить по поиску. Нажмите на кнопку поиска для поиска контрагентов.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  onComplete: () async {
                    _openSearch(context);
                    return true;
                  },
                  child: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _openSearch(context);
                      }),
                )
              ],
            ),
      body: StoreConnector<AppState, List<Kontragent>>(
          converter: (store) => store.state.kontragents,
          builder: (context, kontragents) {
            if (searchMode) {
              if (filter.text.length < 2) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Введите наименование, инн или код контрагента',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                  ),
                );
              }
              if (loading) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              if (list.length == 0) {
                return Center(
                  child: Text(
                    'Нет данных для отображения',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                );
              }
              FeatureDiscovery.discoverFeatures(
                context,
                <String>{kontragenTutt[1]},
              );
              return Scrollbar(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    Kontragent kontragent = list[index];
                    Kontragent cashedKontragent = kontragents.firstWhere(
                        (k) => k.guid == kontragent.guid,
                        orElse: () => null);
                    bool active = cashedKontragent != null;
                    return ItemCard(
                        cashedKontragent: cashedKontragent,
                        kontragent: kontragent,
                        active: active,
                        showTut: index == 0);
                  },
                ),
              );
            }

            if (kontragents.length == 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(45.0),
                  child: Text(
                    'В избранном нет контрагентов\n Для добавления в избранное перейдите в поиск',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                ),
              );
            }

            return Scrollbar(
              child: ListView.builder(
                itemCount: kontragents.length,
                itemBuilder: (BuildContext context, int index) {
                  Kontragent kontragent = kontragents[index];
                  Kontragent cashedKontragent = kontragents.firstWhere(
                      (k) => k.guid == kontragent.guid,
                      orElse: () => null);
                  bool active = cashedKontragent != null;
                  return ItemCard(
                    kontragent: kontragent,
                    cashedKontragent: cashedKontragent,
                    active: active,
                    showStar: false,
                  );
                },
              ),
            );
          }),
    );
  }

  void _openSearch(BuildContext context) {
    setState(() {
      searchMode = true;
    });
    Timer(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }
}

class ItemCard extends StatefulWidget {
  ItemCard(
      {Key key,
      @required this.kontragent,
      @required this.cashedKontragent,
      @required this.active,
      this.showStar = true,
      this.showTut})
      : super(key: key);

  final Kontragent kontragent;
  final Kontragent cashedKontragent;
  final bool active;
  final bool showStar;
  final bool showTut;

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    String inn =
        widget.kontragent.inn != null && widget.kontragent.inn.isNotEmpty
            ? 'ИНН: ${widget.kontragent.inn}'
            : 'ИНН не указан';
    return Slidable(
      actionPane: SlidableBehindActionPane(),
      enabled: !widget.showStar,
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Убрать',
          icon: Icons.star_border,
          color: Colors.transparent,
          foregroundColor: ColorMain,
          onTap: () {
            deleteKontragent(widget.kontragent);
          },
        ),
      ],
      child: Card(
        child: InkWell(
          onTap: () {
            Kontr.openItem(context,
                widget.active ? widget.cashedKontragent : widget.kontragent);
          },
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      '${widget.kontragent.code}',
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${widget.kontragent.name}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '$inn',
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      )
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    widget.showStar
                        ? loading
                            ? IconButton(
                                icon: CupertinoActivityIndicator(),
                                onPressed: null,
                              )
                            : IconButton(
                                icon: widget.active
                                    ? Icon(
                                        Icons.star,
                                        color: ColorMain,
                                      )
                                    : DescribedFeatureOverlay(
                                        featureId: widget.showTut
                                            ? kontragenTutt[1]
                                            : 'NAN',
                                        tapTarget: Icon(Icons.star_border),
                                        backgroundColor: ColorMain,
                                        contentLocation: ContentLocation.below,
                                        title: Text('Избранное'),
                                        onComplete: () async {
                                          setState(() {
                                            loading = true;
                                          });
                                          StoreProvider.dispatchFuture(
                                                  context,
                                                  AddKontragent(
                                                      widget.kontragent))
                                              .then((val) {
                                            setState(() {
                                              loading = false;
                                            });
                                          });
                                          return true;
                                        },
                                        onDismiss: () async {
                                          FeatureDiscovery.completeCurrentStep(
                                              context);
                                          return true;
                                        },
                                        description: Text(
                                          'Нажмите для добавления контрагента в избранное, информация по контрагенту будет доступна даже без подключения к сети.',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        child: Icon(Icons.star_border)),
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  await StoreProvider.dispatchFuture(
                                      context,
                                      widget.active
                                          ? RemoveKontragent(widget.kontragent)
                                          : AddKontragent(widget.kontragent));
                                  setState(() {
                                    loading = false;
                                  });
                                })
                        : Icon(Icons.chevron_right, color: Colors.black45),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future deleteKontragent(Kontragent kontragent) async {
  await StoreProvider.dispatchFuture(
      kontragentListKey.currentContext, RemoveKontragent(kontragent));
  Flushbar(
    messageText: Text(
      'Удален из избранного',
      style: TextStyle(fontSize: 11, color: Colors.white54),
    ),
    titleText: Text(
      kontragent.name,
      style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    mainButton: FlatButton(
      child: Text(
        'Отменить',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        StoreProvider.dispatchFuture(kontragentListKey.currentContext,
            AddKontragent(kontragent, fromServer: false));
        Navigator.of(kontragentListKey.currentContext).pop();
      },
    ),
    animationDuration: Duration(milliseconds: 200),
    isDismissible: true,
    duration: Duration(seconds: 7),
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    icon: Icon(Icons.close, color: ColorMain),
    // Show it with a cascading operator
  )..show(kontragentListKey.currentContext);
  // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Контрагент удален'),action: SnackBarAction(label: 'Отменить', onPressed: (){
  //   StoreProvider.dispatchFuture(context, AddKontragent(kontragent, fromServer: false));
  // }),));
}
