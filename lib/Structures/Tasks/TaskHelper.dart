import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Structures/Tasks/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Tasks/TaskList.dart';

class TaskHelper {
  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Задачи'),
        builder: (ctx) => TaskList()));
  }

  static void openItem(BuildContext context, String guid) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Задача'),
        builder: (ctx) => ItemWidget(guid: guid,)));
  }

  static Color getStatusColor(BuildContext context, String status) {
    switch (status) {
      case "В работе":
        return Colors.lightBlue;
      case "Новая":
        return Colors.green;
      default:
        return Theme.of(context).textTheme.bodyText1.color.withAlpha(150);
    }
  }

  static Widget getDateBadge(Task task, {bool force = false}) {

    String date = ''; bool usual = task.status != "Завершена" && task.status != "Отклонена";
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
      badgeColor = Color(0xFFcc6633);
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