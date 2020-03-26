
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/woker.dart';

import '../../Data/Consts.dart';

class ItemWidget extends StatefulWidget {
  final Woker woker;

  const ItemWidget({Key key, @required this.woker}) : super(key: key);
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.woker.shortName),
      ),
      body: ListView(children: <Widget>[
        _labeledWidget(widget.woker.name,''),
        _labeledWidget(widget.woker.subdivision,'Подразделение'),
        _labeledWidget(widget.woker.position,'Должность'),
        _labeledWidget(widget.woker.getBirthdayString(),'Дата рождения'),
        _labeledWidget(widget.woker.workPhone,'Внутренний телефон'),
        InkWell(
              onTap: () => call(widget.woker.mobilePhone),
              child: _labeledWidget(widget.woker.mobilePhone, 'Телефон')),
      ],),
    );
  }

   Widget _labeledWidget(String value, String lable) {
    String _value = value == null || value.isEmpty ? 'Не указан' : value;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: lable.isNotEmpty,
            child: Text(
              lable,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            _value,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}