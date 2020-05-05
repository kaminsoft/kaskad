import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Models/attachment.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CustomLink extends StatefulWidget {
  final String type;
  final String id;

  const CustomLink({Key key, @required this.type, @required this.id})
      : super(key: key);
  @override
  _CustomLinkState createState() => _CustomLinkState();
}

class _CustomLinkState extends State<CustomLink> {
  Map<String, dynamic> fields;

  @override
  void initState() {
    initializeDateFormatting();
    Connection.getCustomLink(widget.type, widget.id).then((val) {
      setState(() {
        fields = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (fields == null) {
      return Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(fields['title']),
        centerTitle: true,
      ),
      body: ListView(
        children: listFields(),
      ),
    );
  }

  List<Widget> listFields() {
    List<Widget> result = List<Widget>();

    fields.forEach((key, value) {
      if (key != 'title') {
        if (!(value is Map || value is List)) {
          result.add(_labeledWidget(value, key));
        } else if (value is Map) {
          result.add(_linkWidget(value, key));
        } else {
          for (var item in value) {
            result.add(_tabledWidget(item));
          }
        }
      }
    });

    return result;
  }

  Widget _tabledWidget(Map<String, dynamic> item) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item["Номенклатура"], style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${item["Количество"]} ${item["ЕдиницаИзмерения"]} по ${item["Цена"]} руб."),
            ],
          )),
          Expanded(
            flex: 1,
            child: Text("${item["Сумма"]} руб", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold)))
        ],
      ),
    ));
  }

  Widget _labeledWidget(dynamic value, String label) {
    String _value = value == null ? 'Не указан' : value.toString().trim();
    switch (_value) {
      case "false":
        _value = "Нет";
        break;
      case "true":
        _value = "Да";
        break;
      default:
    }

    if (_value == "0001-01-01T00:00:00") {
      _value = "Нет";
    } else if (label.contains("Дата") || label.contains("ВыполнитьДо")) {
      _value = DateFormat('dd MMMM yyyy', 'ru').format(DateTime.parse(value));
    }
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

  Widget _linkWidget(dynamic value, String label) {
    String name = value["name"] == null || value["name"] == ""
        ? 'Не указан'
        : value["name"];
    return InkWell(
      onTap: name == 'Не указан'
          ? null
          : () {
              Attachment att = Attachment.fromJSON(value);
              att.open(context);
            },
      child: Padding(
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
              name,
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
