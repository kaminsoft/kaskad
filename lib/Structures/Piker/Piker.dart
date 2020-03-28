import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';

class Picker {

  Future<LinkItem> pickElement(BuildContext context, String type) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PickerWidget(type:type)),
    );
  }

}

class PickerWidget extends StatefulWidget {
  final String type;

  const PickerWidget({Key key, @required this.type}) : super(key: key);
  @override
  _PickerWidgetState createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  List<LinkItem> list;
  List<LinkItem> searchList;
  bool searchMode = false;
  FocusNode focusNode = FocusNode();
  TextEditingController filter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchMode
          ? AppBar(
              automaticallyImplyLeading: false,
              title: TextField(
                controller: filter,
                focusNode: focusNode,
                style: Theme.of(context).textTheme.title,
                textInputAction: TextInputAction.unspecified,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск',
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                ),
                onChanged: (text) {
                  if (filter.text.isEmpty) {
                    setState(() {
                      searchList = list;
                    });
                  } else {
                    setState(() {
                      searchList = list.where((e) => e.name
                          .toLowerCase()
                          .startsWith(filter.text.toLowerCase())).toList();
                    });
                  }
                },
              ),
              leading: IconButton(
                  icon: Icon(Platform.isAndroid
                      ? Icons.arrow_back
                      : Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      searchMode = false;
                    });
                  }),
              actions: <Widget>[
                Visibility(
                  visible: filter.text.isNotEmpty,
                  child: IconButton(
                      icon: Icon(CupertinoIcons.clear),
                      onPressed: () {
                        setState(() {
                          filter.text = '';
                          searchList = list;
                        });
                      }),
                ),
              ],
            )
          : AppBar(
              title: Text('Выбор'),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchMode = true;
                      });
                      Timer(Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(focusNode);
                      });
                    })
              ],
            ),
      body: Container()
    );
  }
}