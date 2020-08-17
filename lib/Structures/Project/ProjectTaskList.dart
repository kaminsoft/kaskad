import 'package:async_redux/async_redux.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/filters.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Project/ProjectTaskHelper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProjectTaskList extends StatefulWidget {
  @override
  _ProjectTaskListState createState() => _ProjectTaskListState();
}

class _ProjectTaskListState extends State<ProjectTaskList> {
  bool loading = true;
  bool updating = false;
  bool listEnded = false;
  double _fabOpacity = 1;
  bool _fabVisibility = true;
  RefreshController _refreshController = RefreshController(
      initialRefresh: false, initialLoadStatus: LoadStatus.loading);
  ScrollController _scrollController = ScrollController();
  ProjectFilter filter;

  Future _updateList() async {
    updating = true;
    await StoreProvider.dispatchFuture(
        context, GetProjectTasks(clearLoad: false, filter: filter));
    updating = false;
  }

  void _onRefresh() async {
    await StoreProvider.dispatchFuture(
        context, GetProjectTasks(clearLoad: true, filter: filter));
    _refreshController.refreshCompleted();
  }

  void loadProjectTasks() async {
    if (filter == null) {
      filter = await Filters.getProjectFilter();
    }
    setState(() {
      loading = true;
    });
    await StoreProvider.dispatchFuture(
        context, GetProjectTasks(filter: filter));
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
    loadProjectTasks();
    initializeDateFormatting();
    addScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Задачи по проектам"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                //ProjectTaskHelper.newItem(context);
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
                    var list = List();
                    if (filter.forMe) {
                      list = state.projectTasksGroup;
                      listEnded = true;
                    } else {
                      list = state.projectTasks;
                      listEnded = state.projectTaskListEnded ?? false;
                    }
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
                          if (filter.forMe) {
                            ProjectTaskGroup task = list[index];
                            return taskProjectGroup(task, state.projectTasks);
                          }
                          ProjectTask task = list[index];
                          return taskBody(task);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget taskGoupHeader(ProjectTaskGroup task, bool expanded) {
    return ExpandableButton(
      child: Card(
        child: ListTile(
          title: Text(
            task.project,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text('${task.count}'),
        ),
      ),
    );
  }

  Widget taskStatusHeader(StatusTaskGroup status, bool expanded) {
    return ExpandableButton(
      child: Card(
        child: ListTile(
          title: Text(
            status.status,
          ),
          trailing: Text('${status.count}'),
        ),
      ),
    );
  }

  Widget taskProjectGroup(
      ProjectTaskGroup task, List<ProjectTask> projectTaskList) {
    return ExpandableNotifier(
      child: Column(
        children: [
          Expandable(
            collapsed: taskGoupHeader(task, false),
            expanded: Column(
                children: taskProjectGroupChildren(task, projectTaskList)),
          ),
        ],
      ),
    );
  }

  List<Widget> taskProjectGroupChildren(
      ProjectTaskGroup task, List<ProjectTask> projectTaskList) {
    List<Widget> result = List<Widget>();
    result.add(taskGoupHeader(task, true));
    for (var item in task.data) {
      result.add(ExpandableNotifier(
        child: Column(
          children: [
            Expandable(
              collapsed: taskStatusHeader(item, false),
              expanded: Column(
                  children: taskStatusGroupChildren(item, projectTaskList)),
            ),
          ],
        ),
      ));
    }
    result.add(Divider());

    return result;
  }

  List<Widget> taskStatusGroupChildren(
      StatusTaskGroup status, List<ProjectTask> projectTaskList) {
    List<Widget> result = List<Widget>();
    result.add(taskStatusHeader(status, true));
    for (var item in status.data) {
      result.add(
          taskBody(projectTaskList.firstWhere((e) => e.guid == item.guid)));
    }
    result.add(ExpandableButton(
      child: FlatButton.icon(
          onPressed: null,
          icon: Icon(Icons.keyboard_arrow_up),
          label: Text("свернуть")),
    ));
    return result;
  }

  Widget taskBody(ProjectTask task) {
    List<String> statuses = [
      'Новое',
      'Выполненное',
      'Отложенное',
      'Отклоненное',
      'В очереди',
      'Закрыто',
    ];
    String user = statuses.contains(task.status) ? '' : ' у ${task.user}';

    return Card(
      child: InkWell(
        onTap: () =>
            ProjectTaskHelper.openItem(context, task.guid, task.type == "Нс"),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    '${task.type} - ${task.number}',
                    style: TextStyle(
                        color:
                            task.type == "Нс" ? Colors.redAccent : Colors.blue,
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
                            '${task.name}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        task.expired
                            ? Text(
                                "просрочено",
                                style: TextStyle(
                                    color: Colors.redAccent, fontSize: 12),
                              )
                            : Container()
                      ],
                    ),
                    Text('${task.project}'),
                    Text(
                      '${task.status}$user',
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
    List<bool> isSelectedType = List<bool>();
    List<String> allTypes = ["предложения", "несоответствия"];
    List<String> allStatuses = [
      'все',
      'новое',
      'на исполнении',
      'на проверке',
      'на тестировании',
      'на уточнении',
      'выполненное',
      'отложенное',
      'отклоненное'
    ];
    PikerController project = PikerController(
        label: 'Проект', type: 'Проекты', value: filter.project);
    PikerController executer = PikerController(
        label: 'Исполнитель', type: 'Пользователи', value: filter.executer);
    isSelectedType = [
      filter.type == "предложения",
      filter.type == "несоответствия"
    ];
    if (statuses.contains('все')) {
      isSelected = [
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ];
    } else {
      isSelected = [
        false,
        statuses.contains(allStatuses[1]),
        statuses.contains(allStatuses[2]),
        statuses.contains(allStatuses[3]),
        statuses.contains(allStatuses[4]),
        statuses.contains(allStatuses[5]),
        statuses.contains(allStatuses[6]),
        statuses.contains(allStatuses[7]),
        statuses.contains(allStatuses[8]),
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
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Text(
                        "Фильтр",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Visibility(
                      visible: !filter.forMe,
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(5),
                        textStyle: Theme.of(context).textTheme.caption,
                        color: Theme.of(context).textTheme.caption.color,
                        constraints: BoxConstraints(
                            minWidth: width / 2 - 10, minHeight: 36),
                        children: allTypes.map((e) => Text(e)).toList(),
                        onPressed: (int index) {
                          setModalState(() {
                            for (var i = 0; i < isSelectedType.length; i++) {
                              isSelectedType[i] = !isSelectedType[i];
                            }
                            if (isSelectedType[0]) {
                              filter.type = "предложения";
                            } else {
                              filter.type = "несоответствия";
                            }
                          });
                        },
                        isSelected: isSelectedType,
                      ),
                    ),
                    PikerField(
                      controller: project,
                    ),
                    Visibility(
                      visible: !filter.forMe,
                      child: PikerField(
                        controller: executer,
                      ),
                    ),
                    Visibility(
                      visible: filter.forMe,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        title: Text('Все по моим проектам'),
                        // subtitle: Text(
                        //   'Задачи, которые выполняю или могу взять',
                        //   style: TextStyle(fontSize: 12),
                        // ),
                        trailing: CupertinoSwitch(
                          activeColor: ColorMain,
                          value: filter.forMyProjects,
                          onChanged: (bool value) {
                            setModalState(() {
                              filter.forMyProjects = value;
                            });
                          },
                        ),
                        onTap: () {
                          setModalState(() {
                            filter.forMyProjects = !filter.forMyProjects;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      title: Text('Доступные мне'),
                      // subtitle: Text(
                      //   'Задачи, которые выполняю или могу взять',
                      //   style: TextStyle(fontSize: 12),
                      // ),
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
                            filter.project = project.value;
                            filter.executer = executer.value;
                            Navigator.of(context).pop();
                            loadProjectTasks();
                            Filters.saveProjectFilter(filter);
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
