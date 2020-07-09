import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskHelper.dart';

class ItemWidget extends StatefulWidget {
  final String guid;

  const ItemWidget({Key key, @required this.guid}) : super(key: key);
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Task task;
  bool loaded = false;
  bool canEdit = true;
  bool canTakeToWork = false;
  bool isChanged = false;

  PikerController kontragent = PikerController(
    type: "Контрагенты",
    label: "Контрагент",
  );
  PikerController kontragentUser = PikerController(
    type: "КонтактныеЛица",
    label: "Контактное лицо",
  );

  PikerController executer = PikerController(
    type: "Пользователи",
    label: "Сотрудник",
  );
  PikerController group = PikerController(
    type: "СпискиИсполнителейЗадач",
    label: "Кому",
  );
  PikerController theme = PikerController(
    type: "ТемыКонтактов",
    label: "Тема",
  );

  @override
  void initState() {
    super.initState();
    kontragentUser.setOwner(kontragent);
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      StoreProvider.dispatchFuture(context, UpdateTask(guid: widget.guid));
      loaded = true;
    }
    return StoreConnector<AppState, List<Task>>(
      converter: (state) => state.state.tasks,
      builder: (context, tasks) {
        task = tasks.firstWhere((element) => element.guid == widget.guid);

        if (!task.loaded) {
          return Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        kontragent.value = task.kontragent;
        kontragentUser.value = task.kontragentUser;
        executer.value = task.executer;
        group.value = task.group;
        theme.value = task.theme;

        checkAccesseble(isBuild: true);
        return WillPopScope(
          onWillPop: () async {
            if (isChanged) {
              String _question = "Данные были изменены.\nСохранить изменения?";
              if (Platform.isAndroid) {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text(_question),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () async {
                                await onSavePress(context);
                              },
                              child: Text("Да")),
                          FlatButton(
                              onPressed: () => onNotSavePress(context),
                              child: Text("Нет")),
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Отмена")),
                        ],
                      );
                    });
              } else {
                showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        content: Text(_question),
                        actions: <Widget>[
                          CupertinoDialogAction(
                              onPressed: () async {
                                await onSavePress(context);
                              },
                              child: Text("Да")),
                          CupertinoDialogAction(
                              onPressed: () => onNotSavePress(context),
                              child: Text("Нет")),
                          CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Отмена")),
                        ],
                      );
                    });
              }

              return false;
            }

            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Задача"),
              actions: <Widget>[
                Visibility(
                  visible: task.attachments.isNotEmpty,
                  child: IconButton(
                      icon: Icon(Icons.attach_file),
                      onPressed: () {
                        Post.showAttachments(context, task.attachments);
                      }),
                ),
                Visibility(
                  visible: (task.isAuthor || task.isOwner) &&
                      (task.status.isNew || task.status.isWork),
                  child: IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () async {
                        await StoreProvider.dispatchFuture(
                            context, SaveTask(task: copyTask(task)));
                        setState(() {
                          loaded = false;
                        });
                        isChanged = false;
                      }),
                )
              ],
            ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                takeToWork(context),
                doneTask(context),
                cancelTask(context),
              ],
            ),
            body: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      task.status,
                      style: TextStyle(
                        color: TaskHelper.getStatusColor(context, task.status),
                      ),
                    ),
                    Text(
                        '№ ${task.number} от ${DateFormat.MMMMd("ru").format(task.date)}'),
                    TaskHelper.getDateBadge(task, force: true)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          CupertinoIcons.person_solid,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ),
                      Text(
                        "${task.author.name}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.caption.color),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                ),
                PikerField(
                  controller: kontragent,
                  readOnly: !task.hasAccess || !canEdit,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: kontragentUser,
                  readOnly: !task.hasAccess || !canEdit,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: group,
                  readOnly: !task.hasAccess || !canEdit,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: theme,
                  readOnly: !task.hasAccess || !canEdit,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: executer,
                  readOnly: checkElementReadOnly(task),
                  onPickerChanged: onPickerChanged,
                ),
                Divider(
                  height: 5,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(task.text),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void onNotSavePress(BuildContext context) {
    Navigator.of(context).pop();
    isChanged = false;
    Navigator.of(context).pop();
  }

  Future onSavePress(BuildContext context) async {
    Navigator.of(context).pop();
    await StoreProvider.dispatchFuture(context, SaveTask(task: copyTask(task)));
    setState(() {
      loaded = false;
    });
    isChanged = false;
    Navigator.of(context).pop();
  }

  void onPickerChanged(PikerController controller) {
    isChanged = true;
  }

  Task copyTask(task) {
    Task copyTask = task;

    copyTask.kontragent = kontragent.value;
    copyTask.kontragentUser = kontragentUser.value;
    copyTask.group = group.value;
    copyTask.theme = theme.value;
    copyTask.executer = executer.value;

    return task;
  }

  bool checkElementReadOnly(Task task) {
    if (task.status.isDone || task.status.isCanceled) {
      return true;
    }
    if (task.isOwner) {
      return false;
    }
    return !task.hasAccess || !canEdit;
  }

  Widget takeToWork(BuildContext context) {
    if (task.hasAccess && task.executer.isEmpty) {
      return FlatButton(
          onPressed: () async {
            await StoreProvider.dispatchFuture(
                context,
                SetTaskStatus(
                    guid: task.guid,
                    taskStatus: TaskStatus.Work,
                    toastText: "Задача в работе"));
            setState(() {
              loaded = false;
            });
          },
          child: Text(
            "Взять себе",
            style: TextStyle(color: Theme.of(context).textTheme.caption.color),
          ));
    }

    return SizedBox.shrink();
  }

  Widget doneTask(BuildContext context) {
    if (task.status == TaskStatus.Work && task.isExecuter) {
      return FlatButton(
          onPressed: () async {
            await StoreProvider.dispatchFuture(
                context,
                SetTaskStatus(
                    guid: task.guid,
                    taskStatus: TaskStatus.Done,
                    toastText: "Задача выполнена"));

            setState(() {
              loaded = false;
            });
          },
          child: Text(
            "Выполнено",
            style: TextStyle(color: Theme.of(context).textTheme.caption.color),
          ));
    }

    return SizedBox.shrink();
  }

  Widget cancelTask(BuildContext context) {
    if (task.isOwner && !task.status.isCanceled && !task.status.isDone) {
      return FlatButton(
          onPressed: () async {
            await StoreProvider.dispatchFuture(
                context,
                SetTaskStatus(
                    guid: task.guid,
                    taskStatus: TaskStatus.Canceled,
                    toastText: "Задача отменена"));

            setState(() {
              loaded = false;
            });
          },
          child: Text(
            "Отменить",
            style: TextStyle(color: Theme.of(context).textTheme.caption.color),
          ));
    }

    return SizedBox.shrink();
  }

  void checkAccesseble({bool isBuild = false}) {
    if (!task.status.isNew || task.status.isNew && !task.isAuthor) {
      canEdit = false;
    } else {
      canEdit = true;
    }
    if (task.status.isNew) {
      if (task.isExecuter) {
        StoreProvider.dispatchFuture(
            context,
            SetTaskStatus(
                guid: task.guid,
                taskStatus: TaskStatus.Work,
                toastText: "Задача теперь в работе"));
      }
    }
  }

  checkElementAccess(Task task) {}
}
