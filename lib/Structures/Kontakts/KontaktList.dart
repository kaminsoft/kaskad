import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/filters.dart';
import 'package:mobile_kaskad/Models/kontakt.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Kontakts/KontaktHelper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class KontaktList extends StatefulWidget {
  @override
  _KontaktListState createState() => _KontaktListState();
}

class _KontaktListState extends State<KontaktList> {
  bool loading = true;
  bool updating = false;
  bool listEnded = false;
  double _fabOpacity = 1;
  bool _fabVisibility = true;
  RefreshController _refreshController = RefreshController(
      initialRefresh: false, initialLoadStatus: LoadStatus.loading);
  ScrollController _scrollController = ScrollController();
  KontaktFilter filter;

  Future _updateList() async {
    updating = true;
    await StoreProvider.dispatchFuture(
        context, GetKontakts(clearLoad: false, filter: filter));
    updating = false;
  }

  void _onRefresh() async {
    await StoreProvider.dispatchFuture(
        context, GetKontakts(clearLoad: true, filter: filter));
    _refreshController.refreshCompleted();
  }

  void loadKontakts() async {
    if (filter == null) {
      filter = await Filters.getKontaktFilter();
    }
    setState(() {
      loading = true;
    });
    await StoreProvider.dispatchFuture(context, GetKontakts(filter: filter));
    setState(() {
      loading = false;
    });
  }

  void addScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          _fabOpacity == 0) {
        setState(() {
          _fabOpacity = 1;
          _fabVisibility = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _fabOpacity == 1) {
        setState(() {
          _fabOpacity = 0;
        });
      }
    });
  }

  @override
  void initState() {
    loadKontakts();
    initializeDateFormatting();
    addScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Контакты"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                KontaktHelper.newItem(context);
              },
              icon: Icon(Icons.add)),
        ],
      ),
      floatingActionButton: fab(context),
      body: loading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : Scrollbar(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!updating &&
                      !listEnded &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200 &&
                      scrollInfo.metrics.pixels <=
                          scrollInfo.metrics.maxScrollExtent) {
                    _updateList();
                    return true;
                  }
                  return false;
                },
                child: StoreConnector<AppState, AppState>(
                  converter: (state) => state.state,
                  builder: (context, state) {
                    var list = state.kontakts;
                    listEnded = state.kontaktListEnded ?? false;
                    if (list.isEmpty) {
                      return Center(
                        child: Text('Нет данных для отображения'),
                      );
                    }
                    return SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      header: ClassicHeader(
                        completeText: 'Готово',
                        failedText: 'Ошибка обновления',
                        idleText: 'Потяните для обновления',
                        refreshingText: 'Обновление',
                        releaseText: 'Отпустите для обновления',
                      ),
                      child: ListView.builder(
                        itemCount: list.length,
                        controller: _scrollController,
                        itemBuilder: (BuildContext context, int index) {
                          Kontakt kontakt = list[index];
                          return kontaktBody(kontakt);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget kontaktBody(Kontakt kontakt) {
    String sotrudnik = kontakt.sotrudnik.isNotEmpty
        ? kontakt.sotrudnik.toString()
        : 'Сотрудник не указан';
    String kontragent = kontakt.kontragent.isNotEmpty
        ? kontakt.kontragent.toString()
        : 'Контрагент не указан';
    return Card(
      child: InkWell(
        onTap: () => KontaktHelper.openItem(context, kontakt.guid),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    '${kontakt.status}',
                    style: TextStyle(
                        color: KontaktHelper.getStatusColor(
                            context, kontakt.status),
                        fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${kontakt.theme}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Text('${kontakt.number}')
                      ],
                    ),
                    Text(kontragent),
                    Text(
                      sotrudnik,
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .color
                              .withOpacity(.5)),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget fab(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 250),
      opacity: _fabOpacity,
      onEnd: () {
        if (_fabOpacity == 0) {
          setState(() {
            _fabVisibility = false;
          });
        }
      },
      child: Visibility(
        visible: _fabVisibility,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                heroTag: "filter",
                onPressed: () => _openFilter(context),
                child: Icon(
                  FontAwesomeIcons.filter,
                  size: 18,
                )),
          ],
        ),
      ),
    );
  }

  void _openFilter(BuildContext context) {
    List<String> statuses = filter.statuses;
    List<bool> isSelected = List<bool>();
    List<String> allStatuses = [
      'все',
      'запланирован',
      'состоялся',
      'недозвон',
      'отменен'
    ];
    PikerController kontragent = PikerController(
        label: 'Контрагент', type: 'Контрагенты', value: filter.kontragent);
    PikerController theme = PikerController(
        label: 'Тема', type: 'ТемыКонтактов', value: filter.theme);
    PikerController vid =
        PikerController(label: 'Вид', type: 'ВидыКонтактов', value: filter.vid);
    PikerController sposob = PikerController(
        label: 'Способ', type: 'СпособыКонтактов', value: filter.sposob);
    PikerController sotrudnik = PikerController(
        label: 'Сотрудник', type: 'ФизическиеЛица', value: filter.sotrudnik);
    if (statuses.contains('все')) {
      isSelected = [true, false, false, false, false];
    } else {
      isSelected = [
        false,
        statuses.contains(allStatuses[1]),
        statuses.contains(allStatuses[2]),
        statuses.contains(allStatuses[3]),
        statuses.contains(allStatuses[4])
      ];
    }
    double width = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Фильтр",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    PikerField(
                      controller: kontragent,
                    ),
                    PikerField(
                      controller: theme,
                    ),
                    PikerField(
                      controller: vid,
                    ),
                    PikerField(
                      controller: sposob,
                    ),
                    PikerField(
                      controller: sotrudnik,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(5),
                        textStyle: Theme.of(context).textTheme.caption,
                        color: Theme.of(context).textTheme.caption.color,
                        constraints: BoxConstraints(
                            minWidth: width / 4 - 5, minHeight: 36),
                        children: allStatuses.map((e) => Text(e)).toList(),
                        onPressed: (int index) {
                          setModalState(() {
                            isSelected[index] = !isSelected[index];
                            if (index != 0 && isSelected[index] == true) {
                              isSelected[0] = false;
                            } else if (index == 0 &&
                                isSelected[index] == true) {
                              for (var i = 1; i < isSelected.length; i++) {
                                isSelected[i] = false;
                              }
                            }
                            if (!isSelected.contains(true)) {
                              isSelected[0] = true;
                            }
                          });
                        },
                        isSelected: isSelected,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton(
                          onPressed: () {
                            statuses.clear();
                            if (isSelected[0]) {
                              setModalState(() {
                                filter.statusString = 'все';
                              });
                            } else {
                              for (var i = 1; i < isSelected.length; i++) {
                                if (isSelected[i]) {
                                  statuses.add(allStatuses[i]);
                                }
                              }
                              setModalState(() {
                                filter.statusString = statuses.join(',');
                              });
                            }
                            filter.kontragent = kontragent.value;
                            filter.theme = theme.value;
                            filter.vid = vid.value;
                            filter.sposob = sposob.value;
                            filter.sotrudnik = sotrudnik.value;
                            Navigator.of(context).pop();
                            loadKontakts();
                            Filters.saveKontaktFilter(filter);
                          },
                          color: ColorMain,
                          child: Text("Готово"),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
}
