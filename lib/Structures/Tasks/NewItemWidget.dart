import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:toast/toast.dart';

import 'TaskHelper.dart';

class NewItemWidget extends StatefulWidget {
  @override
  _NewItemWidgetState createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  Task task;
  List<TaskTemplate> templates = List<TaskTemplate>();

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

  TextEditingController textController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    Connection.getTaskTemplates().then((value) {
      setState(() {
        templates = value;
      });
    });
    kontragentUser.setOwner(kontragent);
    task = Task();

    var now = DateTime.now();
    task.releaseBefore = DateTime(now.year, now.month, now.day + 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double mult = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Новая задача"),
      ),
      bottomNavigationBar: loading
          ? SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: templates.length > 0,
                  child: FlatButton(
                    onPressed: () {
                      openTemplates(context);
                    },
                    child: Text(
                      "Из шаблона",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    if (group.value.isEmpty ||
                        theme.value.isEmpty ||
                        textController.text.isEmpty) {
                      Toast.show(
                        "Заполните кому, тему и текст задачи",
                        mainWidgetKey.currentContext,
                        gravity: Toast.BOTTOM,
                        duration: 5,
                      );
                    } else {
                      setState(() {
                        loading = true;
                      });
                      await StoreProvider.dispatchFuture(
                          context, SaveTask(task: copyTask(task)));
                      setState(() {
                        loading = false;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    "Отправить",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.caption.color),
                  ),
                )
              ],
            ),
      body: loading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : Scrollbar(
              child: ListView(
                children: <Widget>[
                  PikerField(
                    controller: kontragent,
                  ),
                  PikerField(
                    controller: kontragentUser,
                  ),
                  PikerField(
                    controller: group,
                  ),
                  PikerField(
                    controller: theme,
                  ),
                  PikerField(
                    controller: executer,
                  ),
                  releaseBefore(mult, context),
                  Divider(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      controller: textController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Текст задачи"),
                      maxLines: null,
                      minLines: null,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget releaseBefore(double mult, BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Container(
              height: 200,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
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
      },
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
            Text(DateFormat("dd.MM.yyyy HH:mm").format(task.releaseBefore),
                style: TextStyle(
                    fontSize: 14 * mult, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void openTemplates(BuildContext context) {
    List<Widget> actions = List<Widget>();
    templates.forEach((element) {
      actions.add(CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              group.value = element.group;
              theme.value = element.theme;
              executer.value = element.executer;
            });
            Navigator.of(context).pop();
          },
          child: Text(element.name)));
    });

    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            actions: actions,
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Отмена')),
          );
        });
  }

  Task copyTask(Task task) {
    Task copyTask = task;

    copyTask.kontragent = kontragent.value;
    copyTask.kontragentUser = kontragentUser.value;
    copyTask.group = group.value;
    copyTask.theme = theme.value;
    copyTask.executer = executer.value;
    copyTask.text = textController.text;
    copyTask.status = TaskStatus.New;
    copyTask.guid = "";

    return task;
  }
}
