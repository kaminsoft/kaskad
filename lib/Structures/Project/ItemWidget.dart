import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';

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
  int curTextIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      StoreProvider.dispatchFuture(
          context, UpdateProjectTask(guid: widget.guid, isBug: widget.isBug));
      loaded = true;
    }

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

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                '${task.type} - ${task.number}',
              ),
            ),
            body: Scrollbar(
              child: ListView(
                children: [
                  Visibility(
                      visible: task.expired,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Просрочено',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      )),
                  _labeledWidget('${task.status}$user',
                      textAlign: TextAlign.center),
                  _labeledWidget(task.project.name, label: 'Проект'),
                  _labeledWidget(task.name, label: "Тема"),
                  _labeledWidget(task.executer.name, label: "Исполнитель"),
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
                  _labeledWidget(curTextIndex == 0 ? task.text : task.siteText)
                ],
              ),
            ),
            bottomNavigationBar: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: actionBar(context, task),
              ),
            ),
          );
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

    var toWork = FlatButton(onPressed: () {}, child: Text("На исполнение"));
    var toWorkFromTest =
        FlatButton(onPressed: () {}, child: Text("На доработку"));
    var toDoneFromTest = FlatButton(onPressed: () {}, child: Text("Работает"));
    var toTest = FlatButton(onPressed: () {}, child: Text("Тестировать"));
    var toInfo = FlatButton(onPressed: () {}, child: Text("Уточнить"));
    var toCheck = FlatButton(onPressed: () {}, child: Text("На проверку"));
    var toCancel = FlatButton(onPressed: () {}, child: Text("Отклонить"));
    var toWait = FlatButton(onPressed: () {}, child: Text("Откложить"));
    var toDone = FlatButton(onPressed: () {}, child: Text("Выполнить"));

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
}
