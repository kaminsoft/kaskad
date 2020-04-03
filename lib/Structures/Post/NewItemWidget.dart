import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eventemitter/flutter_eventemitter.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Structures/Post/Post.dart';

class NewItemWidget extends StatefulWidget {
  final String title;
  final String text;
  final List<Recipient> to;
  final bool reSend;
  final bool isPublicate;
  

  const NewItemWidget({Key key, this.title, this.text, this.to, this.reSend, this.isPublicate = false})
      : super(key: key);

  @override
  _NewItemWidgetState createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  bool isPublicate = false;
  TextEditingController textController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Recipient> to = List<Recipient>();
  List<Recipient> allTo = List<Recipient>();
  bool isSending = false;
  bool built = false;

  Future<List<Recipient>> upadteAllTo() async {
    allTo = await Connection.getRecipientList();
    return allTo;
  }

  @override
  void initState() {
    isPublicate = widget.isPublicate ?? false;
    textController.value = TextEditingValue(
        text: widget.text ?? '',
        selection: TextSelection(baseOffset: 0, extentOffset: 0));
    titleController.text = widget.title ?? '';
    if (widget.to != null) {
      to = List<Recipient>.from(widget.to);
    } else {
      to = List<Recipient>();
    }
    allTo = List<Recipient>();
    EventEmitter.subscribe('Recipients_selected', (data) {
      setState(() {
        to = data;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    EventEmitter.unsubscribe('Recipients_selected');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reSend == true && !built) {
      Timer(Duration(milliseconds: 500), () => openUserChoiser(context));
      built = true;
    }

    return isSending
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CupertinoActivityIndicator(),
                  ),
                  Text("Отправка"),
                ],
              ),
            ),
          )
        : Scaffold(
            
            appBar: AppBar(
              title: DropdownButton<String>(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  value: (isPublicate ? 'Объявление' : 'Сообщение'),
                  underline: Container(),
                  items: <String>['Сообщение','Объявление'].map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String newValue){
                    setState(() {
                      isPublicate = newValue == 'Объявление';
                    });
                  }),
              centerTitle: true,
              
              brightness: Brightness.light,
              actions: <Widget>[
                FlatButton(
                    disabledTextColor: Colors.grey,
                    textColor: Colors.blue,
                    onPressed: to.length == 0
                        ? null
                        : () async {
                            if (formKey.currentState.validate()) {
                              Message msg = Message(
                                  isPublicite: isPublicate,
                                  text: textController.text,
                                  title: titleController.text,
                                  to: to.map((t) => t.toLinkItem()).toList());
                              setState(() {
                                isSending = true;
                              });
                              if (await Connection.sendMessage(msg)) {
                                Post.msgSent(context, msg);
                              }
                            }
                          },
                    child: Text(
                      "Отправить",
                    ))
              ],
            ),
            body: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        openUserChoiser(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Кому: ",
                            style: TextStyle(fontSize: 14),
                          ),
                          to.length == 0
                              ? Text(
                                  "Выбрать получателей",
                                  style: TextStyle(
                                      color: ColorMain,
                                      decoration: TextDecoration.underline),
                                )
                              : Container(),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ListView.builder(
                                itemCount: to.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  Recipient rcp = to[index];
                                  return Chip(
                                      label: Text(rcp.name),
                                      avatar: CircleAvatar(
                                          backgroundColor: ColorMain,
                                          child: rcp.isGroup
                                              ? Icon(
                                                  Icons.folder,
                                                  size: 12,
                                                )
                                              : Text(
                                                  getAvatarLetter(rcp.name),
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                )));
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Введите тему';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      controller: titleController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Тема'),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Scrollbar(
                        child: TextFormField(
                          autofocus: widget.text != null ? widget.text.isNotEmpty : false,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Введите текст';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.newline,
                          controller: textController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Текст " +
                                  (isPublicate ? ' объявления' : 'сообщения')),
                          maxLines: null,
                          minLines: null,
                          expands: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future openUserChoiser(BuildContext context) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
            ),
            body: RecipientList(
              list: allTo,
              selected: to,
            ),
          );
        });
  }
}

class RecipientList extends StatefulWidget {
  RecipientList({
    Key key,
    @required this.list,
    @required this.selected,
  }) : super(key: key);

  List<Recipient> list;
  List<Recipient> selected;

  @override
  _RecipientListState createState() => _RecipientListState();
}

class _RecipientListState extends State<RecipientList> {
  TextEditingController filter = TextEditingController();
  List<Recipient> tmp;
  List<Recipient> list;
  List<Recipient> filtered;

  @override
  void initState() {
    super.initState();
    tmp = List<Recipient>.from(widget.selected);
    filtered = List<Recipient>.from(widget.list);
    list = List<Recipient>.from(widget.list);
  }

  @override
  Widget build(BuildContext context) {
    if (list == null || list.length == 0) {
      Connection.getRecipientList().then((val) => setState(() {
            widget.list = val;
            filtered = List<Recipient>.from(widget.list);
            list = List<Recipient>.from(widget.list);
          }));
      return Center(child: CupertinoActivityIndicator());
    }
    return Column(
      children: <Widget>[
        Text("Кому", style: TextStyle(fontSize: 18)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CupertinoTextField(
              controller: filter,
              padding: EdgeInsets.all(10),
              textAlign: TextAlign.center,
              placeholder: "Поиск",
              onChanged: (text) {
                if (filter.text.isNotEmpty) {
                  setState(() {
                    filtered = list
                        .where((e) => e.name
                            .toLowerCase()
                            .startsWith(filter.text.toLowerCase()))
                        .toList();
                  });
                } else {
                  setState(() {
                    filtered = List<Recipient>.from(list);
                  });
                }
              },
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.withBrightness(
                  color: CupertinoColors.white,
                  darkColor: CupertinoColors.white,
                ),
                border: Border(
                  top: kDefaultRoundedBorderSideSuccess,
                  bottom: kDefaultRoundedBorderSideSuccess,
                  left: kDefaultRoundedBorderSideSuccess,
                  right: kDefaultRoundedBorderSideSuccess,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              )),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.separated(
              itemCount: filtered.length,
              itemBuilder: (BuildContext context, int index) {
                Recipient rcp = filtered[index];
                return ListTileTheme(
                  selectedColor: Colors.green,
                  child: ListTile(
                    leading:
                        rcp.isGroup ? Icon(Icons.folder) : Icon(Icons.person),
                    title: Text(rcp.name),
                    selected: tmp.indexOf(rcp) != -1,
                    onTap: () {
                      setState(() {
                        if (tmp.indexOf(rcp) != -1) {
                          tmp.remove(rcp);
                        } else {
                          tmp.add(rcp);
                        }
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
        ),
        ButtonBar(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  setState(() {
                    tmp.clear();
                  });
                },
                child: Text(
                  "Очистить",
                )),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Отмена")),
            FlatButton(
                onPressed: () {
                  EventEmitter.publishSync("Recipients_selected", tmp);
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        )
      ],
    );
  }
}
