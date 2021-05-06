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
  final bool formattedText;
  final List<MessageImage> images;

  const NewItemWidget(
      {Key key,
      this.title,
      this.text,
      this.to,
      this.reSend,
      this.isPublicate = false,
      this.formattedText = false,
      this.images})
      : super(key: key);

  @override
  _NewItemWidgetState createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  bool isPublicate = false;
  bool formattedText = false;
  TextEditingController textController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Recipient> to = <Recipient>[];
  List<MessageImage> images = <MessageImage>[];
  List<Recipient> allTo = <Recipient>[];
  bool isSending = false;
  bool built = false;

  Future<List<Recipient>> upadteAllTo() async {
    allTo = await Connection.getRecipientList();
    return allTo;
  }

  @override
  void initState() {
    isPublicate = widget.isPublicate ?? false;
    formattedText = widget.formattedText ?? false;
    textController.value = TextEditingValue(
        text: widget.text ?? '',
        selection: TextSelection(baseOffset: 0, extentOffset: 0));
    titleController.text = widget.title ?? '';
    if (widget.to != null) {
      to = List<Recipient>.from(widget.to);
    } else {
      to = <Recipient>[];
    }
    if (widget.images != null) {
      images = List<MessageImage>.from(widget.images);
    } else {
      images = <MessageImage>[];
    }
    allTo = <Recipient>[];
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
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText2.color),
                  value: (isPublicate ? 'Объявление' : 'Сообщение'),
                  underline: Container(),
                  items: <String>['Сообщение', 'Объявление']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      isPublicate = newValue == 'Объявление';
                    });
                  }),
              centerTitle: true,
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
                                  formattedText: formattedText,
                                  text: textController.text,
                                  title: titleController.text,
                                  images: images,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Scrollbar(
                        child: TextFormField(
                          autofocus: widget.text != null
                              ? widget.text.isNotEmpty
                              : false,
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
  bool loading = false;

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
      if (!loading) {
        loading = true;
        Connection.getRecipientList().then((val) => setState(() {
              loading = false;
              widget.list = val;
              filtered = List<Recipient>.from(widget.list);
              list = List<Recipient>.from(widget.list);
            }));
      }
      return Center(child: CupertinoActivityIndicator());
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text("Кому", style: TextStyle(fontSize: 18)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CupertinoTextField(
              controller: filter,
              padding: EdgeInsets.all(10),
              textAlign: TextAlign.center,
              placeholder: "Поиск",
              style: Theme.of(context).textTheme.bodyText2,
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
                  darkColor: ColorMiddle,
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
                    onLongPress: rcp.isGroup
                        ? () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoActionSheet(
                                    cancelButton: CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Отмена")),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        child:
                                            Text('Отметить сотрудников группы'),
                                        onPressed: () async {
                                          List<String> ids =
                                              await Connection.getUsersInList(
                                                  rcp.guid);
                                          List<Recipient> rcps = list
                                              .where(
                                                  (e) => ids.contains(e.guid))
                                              .toList();
                                          setState(() {
                                            tmp.addAll(rcps);
                                            if (tmp.indexOf(rcp) != -1) {
                                              tmp.remove(rcp);
                                            }
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        : null,
                    leading: rcp.isGroup
                        ? Icon(Icons.folder)
                        : Icon(CupertinoIcons.person_solid),
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
