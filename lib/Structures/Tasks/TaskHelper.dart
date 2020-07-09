import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Structures/Tasks/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Tasks/NewItemWidget.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskList.dart';

abstract class TaskStatus {
  static const String New = "Новая";
  static const String Done = "Завершена";
  static const String Work = "В работе";
  static const String Canceled = "Отменена";
}

extension StringTaskStatusExtension on String {
  bool get isNew => this == TaskStatus.New;
  bool get isDone => this == TaskStatus.Done;
  bool get isWork => this == TaskStatus.Work;
  bool get isCanceled => this == TaskStatus.Canceled;
}

class TaskHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Задачи'), builder: (ctx) => TaskList()));
  }

  static void openItem(BuildContext context, String guid) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Задача'),
        builder: (ctx) => ItemWidget(
              guid: guid,
            )));
  }

  static void newItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Новая задача'),
        builder: (ctx) => NewItemWidget()));
  }

  static Color getStatusColor(BuildContext context, String status) {
    if (status.isNew) {
      return Colors.lightBlue;
    }
    if (status.isWork) {
      return Colors.green;
    }

    return Theme.of(context).textTheme.bodyText1.color.withAlpha(150);
  }

  static Widget getDateBadge(Task task, {bool force = false}) {
    String date = '';
    bool usual = !task.status.isDone && !task.status.isCanceled;
    if (usual || force) {
      String minutes = task.releaseBefore.minute < 10
          ? '0${task.releaseBefore.minute}'
          : task.releaseBefore.minute.toString();
      if (task.releaseBefore.minute == 0 && task.releaseBefore.hour == 0) {
        date = 'до ${DateFormat.MMMMd("ru").format(task.releaseBefore)}';
      } else {
        date =
            'до ${DateFormat.MMMMd("ru").format(task.releaseBefore)} ${task.releaseBefore.hour}:$minutes';
      }
    }

    var now = DateTime.now();
    var diff = task.releaseBefore.difference(now);
    Color textColor = Colors.white;
    Color badgeColor = Colors.green;
    if (!usual && force) {
      badgeColor = Colors.grey;
    } else if (diff.isNegative) {
      badgeColor = Colors.red;
    } else if (diff.inHours <= 12) {
      badgeColor = Colors.orange; //Color(0xFFcc6633);
    }
    return Visibility(
      visible: date.isNotEmpty,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        decoration: BoxDecoration(
            color: badgeColor, borderRadius: BorderRadius.circular(5)),
        child: Text(
          date,
          style: TextStyle(fontSize: 10, color: textColor),
        ),
      ),
    );
  }
}
