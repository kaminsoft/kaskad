import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  PikerController kontragent = PikerController();
  PikerController worker = PikerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Задачи"),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.filter_frames),
          onPressed: () {
            print(kontragent.value.toJson());
            print(worker.value.toJson());
          }),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              PikerField(controller: kontragent, type: "Контрагенты", label: "Контрагент",),
              PikerField(controller: worker, type: "Пользователи", label: "Сотрудник",),
            ],
          ),
        ),
      ),
    );
  }
}
