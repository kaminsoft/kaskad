import 'package:flutter/material.dart';

class KontaktList extends StatefulWidget {
  @override
  _KontaktListState createState() => _KontaktListState();
}

class _KontaktListState extends State<KontaktList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Контакты"),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        ],
      ),
    );
  }
}
