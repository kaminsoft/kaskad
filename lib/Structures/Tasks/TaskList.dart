import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerForm.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Задачи"),
      ),
      body: Center(
        
      ),
    );
  }
}
