import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Structures/Woker/BirthdayWidget.dart';
import 'package:mobile_kaskad/Structures/Woker/ItemWidget.dart';
import 'package:mobile_kaskad/Structures/Woker/ListWidget.dart';
import 'package:mobile_kaskad/Models/woker.dart';

class WorkerHelper {

  static Future<List<Woker>> getBirthdayWorkers({List<Woker> allWorkers}) async{
    if (allWorkers == null) {
      allWorkers = await DBProvider.db.getWorkers();
    }
    var now = DateTime.now();
    return allWorkers.where((w) => w.birthday.day == now.day && w.birthday.month == now.month).toList();
  }

  static void openItem(BuildContext context, Woker woker) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(
          name: 'Сотрудник',
        ),
        builder: (ctx) => ItemWidget(
              woker: woker,
            )));
  }

  static void openItemById(BuildContext context, String id) {
    DBProvider.db
        .getWorker(id)
        .then((woker) => Navigator.of(context).push(MaterialPageRoute(
            settings: RouteSettings(
              name: 'Сотрудник',
            ),
            builder: (ctx) => ItemWidget(
                  woker: woker,
                ))));
  }

  static void openBirthdayWidget(BuildContext context, {List<Woker> workers}) async{
    if(workers == null){
      workers = await getBirthdayWorkers();
    }
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Дни рождения'),
        builder: (ctx) => BirthdayWidget(workers: workers,)));
  }

  static void openList(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: 'Сотрудники'),
        builder: (ctx) => ListWidget()));
  }
}
