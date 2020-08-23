import 'package:async_redux/async_redux.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:toast/toast.dart';

class ItemWidget extends StatefulWidget {
  final String guid;
  final bool isBug;
  ItemWidget({Key key, @required this.guid, @required this.isBug})
      : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  ProjectTask task;
  bool loaded = false;
  bool loading = false;
  int curTextIndex = 0;
  TextEditingController resolutionText = TextEditingController();

  PikerController executer = PikerController(
    type: "Пользователи",
    label: "Исполнитель",
  );
  PikerController tester = PikerController(
    type: "Пользователи",
    label: "Тестер",
  );
  PikerController metodist = PikerController(
    type: "Пользователи",
    label: "Методист",
  );

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (!loaded) {
      StoreProvider.dispatchFuture(
          context, UpdateProjectTask(guid: widget.guid, isBug: widget.isBug));
      loaded = true;
    }

    double mult = MediaQuery.of(context).textScaleFactor;
    return StoreConnector<AppState, List<ProjectTask>>(
        converter: (state) => state.state.projectTasks,
        builder: (context, tasks) {
          task = tasks.firstWhere(
            (element) => element.guid == widget.guid,
            orElse: () => ProjectTask(),
          );

          if (!task.loaded) {
            return Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          List<String> statuses = [
            'Новое',
            'Выполненное',
            'Отложенное',
            'Отклоненное',
            'В очереди',
            'Закрыто',
          ];
          String user = statuses.contains(task.status) ? '' : ' у ${task.user}';

          executer.value = task.executer;
          tester.value = task.tester;
          metodist.value = task.metodist;

          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  '${task.type} - ${task.number}',
                ),
                actions: [
                  Visibility(
                      visible: task.expired,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            'Просрочено',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      )),
                ],
              ),
              body: Scrollbar(
                child: ListView(
                  children: [
                    _labeledWidget('${task.status}$user',
                        textAlign: TextAlign.center),
                    _labeledWidget(task.project.name, label: 'Проект'),
                    _labeledWidget(task.name, label: 'Тема'),
                    releaseBefore(mult, context),
                    Visibility(
                        visible: task.isToSite,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: curTextIndex,
                            onValueChanged: (int value) {
                              if (value == 0) {
                                setState(() {
                                  curTextIndex = value;
                                });
                              } else {
                                setState(() {
                                  curTextIndex = value;
                                });
                              }
                            },
                            children: {
                              0: Text("Текст"),
                              1: Text("Текст для сайта")
                            },
                          ),
                        )),
                    Divider(),
                    ExpandableNotifier(
                      child: Expandable(
                        collapsed: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                curTextIndex == 0 ? task.text : task.siteText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ExpandableButton(
                              child: FlatButton.icon(
                                  onPressed: null,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  label: Text("показать весь текст")),
                            ),
                          ],
                        ),
                        expanded: ExpandableButton(
                          child: Column(
                            children: [
                              _labeledWidget(curTextIndex == 0
                                  ? task.text
                                  : task.siteText),
                              ExpandableButton(
                                child: FlatButton.icon(
                                    onPressed: null,
                                    icon: Icon(Icons.keyboard_arrow_up),
                                    label: Text("свернуть")),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    PikerField(
                      controller: executer,
                      readOnly: !(task.userIsManager || task.userIsTechLead),
                      onPickerChanged: (controller) =>
                          task.executer = controller.value,
                    ),
                    PikerField(
                      controller: tester,
                      readOnly: !(task.userIsManager || task.userIsTechLead),
                      onPickerChanged: (controller) =>
                          task.tester = controller.value,
                    ),
                    PikerField(
                      controller: metodist,
                      readOnly: !(task.userIsManager || task.userIsTechLead),
                      onPickerChanged: (controller) =>
                          task.metodist = controller.value,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: TextField(
                        onChanged: (value) =>
                            task.resolutionText = resolutionText.text,
                        decoration: InputDecoration(
                            suffixIcon: Visibility(
                              visible:
                                  MediaQuery.of(context).viewInsets.bottom != 0,
                              child: IconButton(
                                  color: Colors.grey,
                                  icon: Icon(Icons.keyboard_hide),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                  }),
                            ),
                            border: InputBorder.none,
                            hintText: "Текст резолюции"),
                        controller: resolutionText,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: actionBar(context, task),
                ),
              ));
        });
  }

  Widget _labeledWidget(String value,
      {String label = "", TextAlign textAlign = TextAlign.left}) {
    String _value = value == null || value.isEmpty ? 'Не указан' : value;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: label.isNotEmpty,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SelectableText(
            _value,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }

  actionBar(BuildContext context, ProjectTask task) {
    List<Widget> list = List<Widget>();

    var toWork = FlatButton(
        onPressed: () async {
          if (task.executer.isEmpty) {
            Toast.show(
              "Заполните исполнителя",
              context,
              gravity: Toast.BOTTOM,
              duration: 5,
            );
          } else {
            task.resolutionText = resolutionText.text;
            await setNewStatus(task, context, "На исполнении",
                shouldPop: false);
          }
        },
        child: Text("На исполнение"));
    var toWorkFromTest = FlatButton(
        onPressed: () async {
          task.resolutionText = resolutionText.text;
          if (task.resolutionText.isEmpty) {
            Toast.show(
              "Заполните текст резолюции",
              context,
              gravity: Toast.BOTTOM,
              duration: 5,
            );
          } else {
            await setNewStatus(task, context, "На исполнении",
                shouldPop: false);
          }
        },
        child: Text("На доработку"));
    var toDoneFromTest = FlatButton(
        onPressed: () async {
          task.resolutionText = resolutionText.text;
          await setNewStatus(task, context, "Выполненное", shouldPop: false);
        },
        child: Text("Работает"));
    var toTest = toTestButton(context, task);
    var toInfo = toInfoButton(context, task);
    var toCheck = FlatButton(
        onPressed: () async {
          task.resolutionText = resolutionText.text;

          await setNewStatus(task, context,
              task.tester.isEmpty ? "На проверке" : "На тестировании",
              shouldPop: false);
        },
        child: Text("На проверку"));
    var toCancel = FlatButton(
        onPressed: () async {
          task.resolutionText = resolutionText.text;
          await setNewStatus(task, context, "Отклоненное", shouldPop: false);
        },
        child: Text("Отклонить"));
    var toWait = FlatButton(
        onPressed: () async {
          task.resolutionText = resolutionText.text;
          await setNewStatus(task, context, "Отложенное", shouldPop: false);
        },
        child: Text("Отложить"));
    var toDone = FlatButton(
        onPressed: () async {
          task.resolutionText = resolutionText.text;
          await setNewStatus(task, context, "Выполненное", shouldPop: false);
        },
        child: Text("Выполнить"));

    if (task.userIsManager) {
      list.add(toWork);
      list.add(toTest);
      list.add(toInfo);
      list.add(toDone);
      list.add(toCheck);
      list.add(toCancel);
      list.add(toWait);
    } else if (task.userIsExecuter && task.onProgress) {
      list.add(toCheck);
      list.add(toInfo);
    } else if (task.userIsMetodist && task.onInfo) {
      list.add(toWork);
      list.add(toInfo);
    } else if (task.userIsTester && task.onTest) {
      list.add(toWorkFromTest);
      list.add(toDoneFromTest);
      list.add(toInfo);
    }

    return list;
  }

  FlatButton toTestButton(BuildContext context, ProjectTask task) {
    return FlatButton(
        onPressed: () {
          task.resolutionText = resolutionText.text;
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                PikerController user = PikerController(
                  type: "Пользователи",
                  label: "Тестер",
                );
                user.value = task.tester;

                return Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PikerField(
                          controller: user,
                          onPickerChanged: (controller) =>
                              task.tester = controller.value,
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 2.5),
                                child: CupertinoButton(
                                  color: ColorMain,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    task.tester = task.author;
                                    user.value = task.tester;
                                    await setNewStatus(
                                        task, context, "На тестировании");
                                  },
                                  child: Text("Автору"),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 2.5, right: 10),
                                child: CupertinoButton(
                                  color: ColorMain,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    if (task.tester.isEmpty) {
                                      Toast.show(
                                        "Заполните тестера",
                                        context,
                                        gravity: Toast.BOTTOM,
                                        duration: 5,
                                      );
                                    } else {
                                      await setNewStatus(
                                          task, context, "На тестировании");
                                    }
                                  },
                                  child: Text("Тестировать"),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Text("Тестировать"));
  }

  FlatButton toInfoButton(BuildContext context, ProjectTask task) {
    return FlatButton(
        onPressed: () {
          task.resolutionText = resolutionText.text;
          if (task.resolutionText.isEmpty) {
            Toast.show(
              "Заполните текст резолюции",
              context,
              gravity: Toast.BOTTOM,
              duration: 5,
            );
          } else {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  PikerController user = PikerController(
                    type: "Пользователи",
                    label: "Методист",
                  );
                  user.value = task.metodist;

                  return Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          PikerField(
                            controller: user,
                            onPickerChanged: (controller) =>
                                task.metodist = controller.value,
                          ),
                          Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 2.5),
                                  child: CupertinoButton(
                                    color: ColorMain,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      task.metodist = task.author;
                                      user.value = task.metodist;
                                      await setNewStatus(
                                          task, context, "На уточнении");
                                    },
                                    child: Text("Автору"),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.5, right: 10),
                                  child: CupertinoButton(
                                    color: ColorMain,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      if (task.metodist.isEmpty) {
                                        Toast.show(
                                          "Заполните методиста",
                                          context,
                                          gravity: Toast.BOTTOM,
                                          duration: 5,
                                        );
                                      } else {
                                        await setNewStatus(
                                            task, context, "На уточнении");
                                      }
                                    },
                                    child: Text("Уточнить"),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
        },
        child: Text("Уточнить"));
  }

  Widget releaseBefore(double mult, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: task.userIsManager || task.userIsTechLead
              ? () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 200,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          use24hFormat: true,
                          initialDateTime: task.releaseBefore,
                          onDateTimeChanged: (DateTime newDateTime) {
                            setState(() {
                              task.releaseBefore = newDateTime;
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    "Выполнить до",
                    style: TextStyle(
                        fontSize: 12 * mult,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                Text(DateFormat("dd.MM.yyyy").format(task.releaseBefore),
                    style: TextStyle(
                        fontSize: 14 * mult, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        Visibility(
          visible: task.userIsManager || task.userIsTechLead,
          child: FlatButton.icon(
              onPressed: () {
                setState(() {
                  task.releaseBefore = DateTime.now();
                });
              },
              textColor: Theme.of(context).disabledColor,
              icon: Icon(Icons.chevron_left),
              label: Text("Сегодня")),
        )
      ],
    );
  }

  Future setNewStatus(ProjectTask task, BuildContext context, String status,
      {bool shouldPop = true}) async {
    ProjectTask newTask = task;
    newTask.status = status;
    newTask.executer = executer.value;
    newTask.tester = tester.value;
    newTask.metodist = metodist.value;
    resolutionText.text = "";

    if (shouldPop) {
      Navigator.of(context).pop();
    }
    setState(() {
      loading = true;
    });
    await StoreProvider.dispatchFuture(context, SaveProjectTask(task: newTask));
    setState(() {
      loaded = false;
      loading = false;
    });
  }
}
