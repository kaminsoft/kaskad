import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerForm.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskHelper.dart';
import 'package:toast/toast.dart';

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

  final _formKey = GlobalKey<PikerFormState>();

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
        return Scaffold(
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
              )
            ],
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              takeToWork(context),
              doneTask(context),
              cancelTask(context)
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
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 5,
              ),
              PikerField(
                controller: kontragent,
                readOnly: !task.hasAccess || !canEdit,
              ),
              PikerField(
                  controller: kontragentUser,
                  readOnly: !task.hasAccess || !canEdit),
              PikerField(
                  controller: group, readOnly: !task.hasAccess || !canEdit),
              PikerField(
                  controller: theme, readOnly: !task.hasAccess || !canEdit),
              PikerField(
                  controller: executer, readOnly: !task.hasAccess || !canEdit),
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
        );
      },
    );
  }

  Widget takeToWork(BuildContext context) {
    if (task.hasAccess && task.executer.isEmpty) {
      return FlatButton(
          onPressed: () async {
            setState(() {
              loaded = false;
            });
            await StoreProvider.dispatchFuture(
                context,
                SetTaskStatus(
                    guid: task.guid,
                    status: TaskStatus.Work,
                    toastText: "Задача теперь в работе"));

            task.loaded = false;
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
            setState(() {
              loaded = false;
            });
            await StoreProvider.dispatchFuture(
                context,
                SetTaskStatus(
                    guid: task.guid,
                    status: TaskStatus.Done,
                    toastText: "Задача выполнена"));

            task.loaded = false;
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
            setState(() {
              loaded = false;
            });
            await StoreProvider.dispatchFuture(
                context,
                SetTaskStatus(
                    guid: task.guid,
                    status: TaskStatus.Canceled,
                    toastText: "Задача отменена"));

            task.loaded = false;
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
    }
    if (task.status.isNew) {
      if (task.isExecuter) {
        StoreProvider.dispatchFuture(
            context,
            SetTaskStatus(
                guid: task.guid,
                status: TaskStatus.Work,
                toastText: "Задача теперь в работе"));
      }
    }
  }
}