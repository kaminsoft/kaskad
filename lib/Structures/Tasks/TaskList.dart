import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/filters.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerForm.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskHelper.dart';
import 'package:intl/date_symbol_data_local.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> list = List<Task>();
  bool loading = true;
  bool updating = false;
  int lastLength = 0;
  bool listEnded = false;
  double _fabOpacity = 1;
  bool _fabVisibility = true;
  ScrollController _scrollController = ScrollController();
  TaskFilter filter;

  Future _updateList() async {
    updating = true;
    await StoreProvider.dispatchFuture(
        context, GetTasks(clearLoad: false, filter: filter));
    updating = false;
  }

  void loadTasks() async {
    if (filter == null) {
      filter = await Filters.getTaskFilter();
    }
    setState(() {
      loading = true;
    });
    await StoreProvider.dispatchFuture(context, GetTasks(filter: filter));
    listEnded = false;
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
    loadTasks();
    initializeDateFormatting();
    addScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Задачи"),
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
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200 &&
                      scrollInfo.metrics.pixels <=
                          scrollInfo.metrics.maxScrollExtent) {
                    _updateList();
                    return true;
                  }
                  return false;
                },
                child: StoreConnector<AppState, List<Task>>(
                        converter: (state) => state.state.tasks,
                        builder: (context, list) {
                          if (list.isEmpty) {
                            return Center(
                              child: Text('Нет данных для отображения'),
                            );
                          }
                          return ListView.builder(
                            itemCount: list.length,
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              Task task = list[index];
                              return taskBody(task);
                            },
                          );
                        },
                      ),
              ),
            ),
    );
  }

  Widget taskBody(Task task) {
    String executer = task.executer.isNotEmpty
        ? task.executer.toString()
        : 'Исполнитель не назначен';
    String kontragent = task.kontragent.isNotEmpty
        ? task.kontragent.toString()
        : 'Контрагент не указан';
    return Card(
      child: InkWell(
        onTap: () => TaskHelper.openItem(context, task.guid),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    '${task.status}',
                    style: TextStyle(
                        color: TaskHelper.getStatusColor(context, task.status),
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
                            '${task.theme}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        TaskHelper.getDateBadge(task)
                      ],
                    ),
                    Text(kontragent),
                    Text(
                      executer,
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
    List<String> allStatuses = ['все', 'новая', 'в работе', 'завершена'];
    PikerController kontragent = PikerController(
        label: 'Контрагент', type: 'Контрагенты', value: filter.kontragent);
    PikerController theme = PikerController(
        label: 'Тема', type: 'ТемыКонтактов', value: filter.theme);
    PikerController group = PikerController(
        label: 'Группа', type: 'СпискиИсполнителейЗадач', value: filter.group);
    PikerController executer = PikerController(
        label: 'Исполнитель', type: 'Пользователи', value: filter.executer);
    if (statuses.contains('все')) {
      isSelected = [true, false, false, false];
    } else {
      isSelected = [
        false,
        statuses.contains(allStatuses[1]),
        statuses.contains(allStatuses[2]),
        statuses.contains(allStatuses[3])
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
                    Visibility(
                      visible: !filter.forMe,
                      child: PikerField(
                        controller: group,
                      ),
                    ),
                    Visibility(
                      visible: !filter.forMe,
                      child: PikerField(
                        controller: executer,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      title: Text('Доступные мне'),
                      subtitle: Text(
                        'Задачи, которые выполняю или могу взять',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: CupertinoSwitch(
                        activeColor: ColorMain,
                        value: filter.forMe,
                        onChanged: (bool value) {
                          setModalState(() {
                            filter.forMe = value;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          filter.forMe = !filter.forMe;
                        });
                      },
                    ),
                    ToggleButtons(
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
                          } else if (index == 0 && isSelected[index] == true) {
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
                            filter.group = group.value;
                            filter.executer = executer.value;
                            Navigator.of(context).pop();
                            loadTasks();
                            Filters.saveTaskFilter(filter);
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
