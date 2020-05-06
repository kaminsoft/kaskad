import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';

class Picker {
  static Map<String, String> _commonFields = {"Контрагенты": "ИНН"};

  static String getObjectFields(String name) {
    return _commonFields[name] ?? "";
  }

  static Future<LinkItem> pickElement(BuildContext context, String type) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PickerWidget(type: type)),
    );
  }
}

class PikerController extends ValueNotifier<LinkItem> {
  PikerController({LinkItem value}) : super(value);
}

class PikerField extends StatefulWidget {
  PikerController controller;
  String type;
  String label;
  String placeholder;

  PikerField(
      {Key key,
      @required this.controller,
      @required this.type,
      this.label = "",
      this.placeholder = ""})
      : super(key: key);

  @override
  _PikerFieldState createState() => _PikerFieldState();
}

class _PikerFieldState extends State<PikerField> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: widget.label.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                widget.label,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: CupertinoTextField(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  onTap: () {
                    Picker.pickElement(context, widget.type).then((onValue) {
                      if (onValue != null) {
                        setState(() {
                          widget.controller.value = onValue;
                          _controller.text = onValue.name;
                        });
                      }
                    });
                  },
                  readOnly: true,
                  controller: _controller,
                  placeholder: widget.placeholder,
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
              InkWell(
                onTap: () {
                    if (widget.controller.value != null) {
                      widget.controller.value.open(context);
                    }
                  },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                      CupertinoIcons.search,
                      color: Theme.of(context).iconTheme.color.withOpacity(.5),
                    ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class PickerWidget extends StatefulWidget {
  final String type;
  final LinkItem owner;

  const PickerWidget({Key key, @required this.type, this.owner})
      : super(key: key);
  @override
  _PickerWidgetState createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  List<LinkItem> list = List<LinkItem>();
  TextEditingController filter = TextEditingController();
  Timer timer;
  bool loading = true;
  String fields;
  LinkItem selected;

  @override
  void initState() {
    fields = Picker.getObjectFields(widget.type);
    _getList().then((val) {
      list = val;
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  Future<List<LinkItem>> _getList() async {
    String last = "";
    if (list.length > 0) {
      last = list.last.name;
    }
    return await Connection.getListPiker(widget.type,
        fields: fields, query: filter.text, owner: widget.owner, last: last);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Выбор'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(36),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: CupertinoTextField(
                controller: filter,
                padding: EdgeInsets.all(10),
                textAlign: TextAlign.center,
                placeholder: "Поиск",
                style: Theme.of(context).textTheme.body1,
                onChanged: (text) {
                  if (timer != null) {
                    timer.cancel();
                  }
                  timer = Timer(Duration(milliseconds: 500), () async {
                    setState(() {
                      loading = true;
                    });
                    var lst = await _getList();
                    setState(() {
                      list = lst;
                    });
                    setState(() {
                      loading = false;
                    });
                  });
                },
              ),
            ),
          ),
        ),
        floatingActionButton: Visibility(
            visible: selected != null,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, selected);
              },
              child: Icon(Icons.check),
            )),
        body: loading
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : list.isEmpty
                ? Center(
                    child: Text("Нет данных для отображения"),
                  )
                : Scrollbar(
                    child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          LinkItem item = list[index];
                          return Card(
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  if (selected == item) {
                                    selected = null;
                                  } else {
                                    selected = item;
                                  }
                                });
                              },
                              selected: item == selected,
                              title: Text(item.name),
                              trailing: Visibility(
                                visible: item == selected,
                                child: Icon(Icons.check),
                              ),
                            ),
                          );
                        }),
                  ));
  }
}
