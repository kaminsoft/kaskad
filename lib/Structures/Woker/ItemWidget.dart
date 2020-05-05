import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_kaskad/Models/woker.dart';
import 'package:toast/toast.dart';

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
      body: ListView(
        children: <Widget>[
          _labeledWidget(widget.woker.name, ''),
          _labeledWidget(widget.woker.subdivision, 'Подразделение'),
          _labeledWidget(widget.woker.position, 'Должность'),
          _labeledWidget(widget.woker.getBirthdayString(), 'Дата рождения'),
          phoneWidget(widget.woker.mobilePhone, 'Мобильный телефон'),
          phoneWidget(widget.woker.homePhone, 'Домашний телефон'),
          mailWidget(widget.woker.email, 'Личная почта'),
          Divider(),
          phoneWidget(widget.woker.workPhone, 'Рабочий телефон'),
          mailWidget(widget.woker.workEmail, 'Рабочая почта'),
          _labeledWidget(widget.woker.internalPhone, 'Внутренний телефон'),
        ],
      ),
    );
  }

  Widget phoneWidget(String phone, String label) {
    return Visibility(
      visible: phone.isNotEmpty,
      child: InkWell(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: phone));
            Toast.show('Телефон скопирован в буфер обмена', context,
                backgroundColor: ColorMain, gravity: Toast.BOTTOM, duration: 5);
          },
          onTap: () => call(phone),
          child: _labeledWidget(phone, label)),
    );
  }

  Widget mailWidget(String mail, String label) {
    return Visibility(
      visible: mail.isNotEmpty,
      child: InkWell(
        onLongPress: () {
            Clipboard.setData(ClipboardData(text: mail));
            Toast.show('Почта скопирована в буфер обмена', context,
                backgroundColor: ColorMain, gravity: Toast.BOTTOM, duration: 5);
          },
          onTap: () => mailto(mail), child: _labeledWidget(mail, label)),
    );
  }

  Widget _labeledWidget(String value, String label) {
    String _value = value == null || value.isEmpty ? 'Не указан' : value;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: label.isNotEmpty,
            child: Text(
              label,
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
