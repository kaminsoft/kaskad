import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/filters.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:toast/toast.dart';

class NewItemWidget extends StatefulWidget {
  final bool isBug;

  const NewItemWidget({Key key, @required this.isBug}) : super(key: key);
  @override
  _NewItemWidgetState createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  ProjectTask task;
  bool isManager = false;

  PikerController project = PikerController(
    type: "Проекты",
    label: "Проект",
  );
  PikerController executer = PikerController(
    type: "Пользователи",
    label: "Исполнитель",
  );

  TextEditingController nameController = TextEditingController();
  TextEditingController textController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    task = ProjectTask(
        status: "Новое",
        type: widget.isBug ? "Нс" : "Пр",
        executer: LinkItem());
    var now = DateTime.now();
    task.releaseBefore = DateTime(now.year, now.month, now.day + 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(widget.isBug ? "Несоответствие" : "Предложение"),
            ),
            body: ListView(
              children: [
                PikerField(
                  controller: project,
                  onPickerChanged: (controller) {
                    CustomField manager =
                        controller.value.getCustomFieldByName("Менеджер");
                    CustomField techLead = controller.value
                        .getCustomFieldByName("Технический руководитель");
                    if (manager != null && manager.guid == Data.curUser.guid ||
                        techLead != null &&
                            techLead.guid == Data.curUser.guid) {
                      setState(() {
                        isManager = true;
                      });
                    } else {
                      setState(() {
                        isManager = false;
                        executer.value = LinkItem();
                      });
                    }
                  },
                ),
                Visibility(
                    visible: isManager,
                    child: PikerField(controller: executer)),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Тема"),
                    controller: nameController,
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
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
                        hintText: "Описание"),
                    controller: textController,
                    maxLines: null,
                  ),
                )
              ],
            ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                    onPressed: () async {
                      if (checkFields()) {
                        task.project = project.value;
                        task.name = nameController.text;
                        task.text = textController.text;
                        setState(() {
                          loading = true;
                        });
                        await StoreProvider.dispatchFuture(
                            context, SaveNewProjectTask(task: task));
                        await StoreProvider.dispatchFuture(
                            context,
                            GetProjectTasks(
                                filter: await Filters.getProjectFilter()));
                        setState(() {
                          loading = false;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("Отправить")),
                Visibility(
                  visible: isManager,
                  child: FlatButton(
                      onPressed: () async {
                        if (checkFields(toWork: true)) {
                          task.project = project.value;
                          task.name = nameController.text;
                          task.text = textController.text;
                          task.executer = executer.value;
                          task.status = "На исполнении";
                          setState(() {
                            loading = true;
                          });
                          await StoreProvider.dispatchFuture(
                              context, SaveNewProjectTask(task: task));
                          await StoreProvider.dispatchFuture(
                              context,
                              GetProjectTasks(
                                  filter: await Filters.getProjectFilter()));
                          setState(() {
                            loading = false;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("На исполнение")),
                )
              ],
            ));
  }

  bool checkFields({bool toWork = false}) {
    if (project.value.isEmpty) {
      Toast.show(
        "Заполните проект",
        context,
        gravity: Toast.BOTTOM,
        duration: 5,
      );
      return false;
    }
    if (nameController.text.isEmpty) {
      Toast.show(
        "Заполните тему",
        context,
        gravity: Toast.BOTTOM,
        duration: 5,
      );
      return false;
    }
    if (textController.text.isEmpty) {
      Toast.show(
        "Заполните описание",
        context,
        gravity: Toast.BOTTOM,
        duration: 5,
      );
      return false;
    }
    if (toWork && executer.value.isEmpty) {
      Toast.show(
        "Заполните исполнителя",
        context,
        gravity: Toast.BOTTOM,
        duration: 5,
      );
      return false;
    }
    return true;
  }
}
