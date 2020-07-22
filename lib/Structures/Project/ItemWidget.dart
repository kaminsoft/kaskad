import 'package:flutter/material.dart';

class ItemWidget extends StatefulWidget {
  final String guid;
  ItemWidget({Key key, @required this.guid}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Проект"),
      ),
    );
  }
}
