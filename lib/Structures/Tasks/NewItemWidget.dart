import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Store/Actions.dart';

class NewItemWidget extends StatefulWidget {
  @override
  _NewItemWidgetState createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Новая задача"),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text(
              "Шаблон",
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption.color),
            ),
          ),
          FlatButton(
            onPressed: () {},
            child: Text(
              "Отправить",
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption.color),
            ),
          )
        ],
      ),
    );
  }
}
