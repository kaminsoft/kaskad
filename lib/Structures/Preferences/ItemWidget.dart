import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';

class ItemWidget extends StatefulWidget {
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Настройки"),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.work),
              title: Text("Таймаут подключения"),
              subtitle: Text("Время ожидания ответа от сервера"),
              trailing: Text("${Data.settings.timeOut} сек"),
              onTap: () {},
            )
          ],
        ));
  }
}
