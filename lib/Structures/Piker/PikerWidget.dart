import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';

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
  bool updating = false;
  String fields;
  LinkItem selected;
  bool listEnded = false;

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

  Future<List<LinkItem>> _getList({bool clearLoad = false}) async {
    String last = "";
    if (list.length > 0) {
      last = list.last.name;
    }
    if (clearLoad) {
      return await Connection.getListPiker(widget.type,
          fields: fields, query: filter.text, owner: widget.owner);
    }
    return await Connection.getListPiker(widget.type,
        fields: fields, query: filter.text, owner: widget.owner, last: last);
  }

  void _updateList() async {
    String last = "";
    if (list.length > 0) {
      last = list.last.name;
    }
    updating = true;
    var newlist = await Connection.getListPiker(widget.type,
        fields: fields,
        query: filter.text,
        owner: widget.owner,
        last: last,
        length: 20);
    if (newlist.length == 0) {
      listEnded = true;
    }
    setState(() {
      list.addAll(newlist);
    });
    updating = false;
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
                style: Theme.of(context).textTheme.bodyText1,
                onChanged: (text) {
                  if (timer != null) {
                    timer.cancel();
                  }
                  timer = Timer(Duration(milliseconds: 500), () async {
                    setState(() {
                      loading = true;
                    });
                    var lst = await _getList(clearLoad: true);
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
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!listEnded &&
                            !updating &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200 &&
                            scrollInfo.metrics.pixels <=
                                scrollInfo.metrics.maxScrollExtent) {
                          _updateList();
                          return true;
                        }
                        return false;
                      },
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
                    ),
                  ));
  }
}
