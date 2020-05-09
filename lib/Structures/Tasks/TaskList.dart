import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerForm.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> list = List<Task>();
  bool loading = true;

  Future updateList() async {
    var nlist = await Connection.getTasks(last: list.last.number);
    setState(() {
      list.addAll(nlist);
    });
  }

  @override
  void initState() {
    Connection.getTasks().then((value) {
      list = value;
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // filter by status - choose from list
    // fliter by kontragent - kontragent piker
    // fliter by theme - theme piker
    // filter by group - group piker
    // filter by for me - checkbox
    // filter by executor - worker piker

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Задачи"),
      ),
      body: loading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = list[index];
                return Text(task.number);
              },
            ),
    );
  }
}
