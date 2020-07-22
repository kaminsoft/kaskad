import 'package:flutter/material.dart';

class ProjectList extends StatefulWidget {
  ProjectList({Key key}) : super(key: key);

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Проекты"),
      ),
    );
  }
}
