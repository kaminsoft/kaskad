import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Models/kontakt.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:mobile_kaskad/Structures/Kontakts/KontaktHelper.dart';

class ItemWidget extends StatefulWidget {
  final String guid;

  const ItemWidget({Key key, @required this.guid}) : super(key: key);
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Kontakt kontakt;
  bool loaded = false;
  bool canEdit = true;
  bool canTakeToWork = false;
  bool isChanged = false;

  PikerController kontragent = PikerController(
    type: "Контрагенты",
    label: "Контрагент",
  );
  PikerController kontragentUser = PikerController(
    type: "КонтактныеЛица",
    label: "Контактное лицо",
  );

  PikerController sotrudnik = PikerController(
    type: "ФизЛица",
    label: "Сотрудник",
  );
  PikerController vid = PikerController(
    type: "ВидыКонтактов",
    label: "Вид",
  );
  PikerController theme = PikerController(
    type: "ТемыКонтактов",
    label: "Тема",
  );
  PikerController sposob = PikerController(
    type: "СпособыКонтактов",
    label: "Способ",
  );
  PikerController infoSource = PikerController(
    type: "ИсточникиИнформации",
    label: "Источник",
  );

  @override
  void initState() {
    super.initState();
    kontragentUser.setOwner(kontragent);
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      StoreProvider.dispatchFuture(context, UpdateKontakt(guid: widget.guid));
      loaded = true;
    }
    return StoreConnector<AppState, List<Kontakt>>(
      converter: (state) => state.state.kontakts,
      builder: (context, kontakts) {
        kontakt = kontakts.firstWhere(
          (element) => element.guid == widget.guid,
          orElse: () => Kontakt(),
        );

        if (!kontakt.loaded) {
          return Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        kontragent.value = kontakt.kontragent;
        kontragentUser.value = kontakt.kontragentUser;
        sotrudnik.value = kontakt.sotrudnik;
        vid.value = kontakt.vid;
        sposob.value = kontakt.sposob;
        theme.value = kontakt.theme;

        return WillPopScope(
          onWillPop: () async {
            if (isChanged) {
              String _question = "Данные были изменены.\nСохранить изменения?";
              if (Platform.isAndroid) {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text(_question),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () async {
                                await onSavePress(context);
                              },
                              child: Text("Да")),
                          FlatButton(
                              onPressed: () => onNotSavePress(context),
                              child: Text("Нет")),
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Отмена")),
                        ],
                      );
                    });
              } else {
                showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        content: Text(_question),
                        actions: <Widget>[
                          CupertinoDialogAction(
                              onPressed: () async {
                                await onSavePress(context);
                              },
                              child: Text("Да")),
                          CupertinoDialogAction(
                              onPressed: () => onNotSavePress(context),
                              child: Text("Нет")),
                          CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Отмена")),
                        ],
                      );
                    });
              }

              return false;
            }

            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Контакт"),
              actions: <Widget>[
                Visibility(
                  visible: kontakt.isAuthor,
                  child: IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () async {
                        await StoreProvider.dispatchFuture(context,
                            SaveKontakt(kontakt: copyKontakt(kontakt)));
                        setState(() {
                          loaded = false;
                        });
                        isChanged = false;
                      }),
                )
              ],
            ),
            body: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      kontakt.status,
                      style: TextStyle(
                        color: KontaktHelper.getStatusColor(
                            context, kontakt.status),
                      ),
                    ),
                    Text(
                        '№ ${kontakt.number} от ${DateFormat.MMMMd("ru").format(kontakt.date)}'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          CupertinoIcons.person_solid,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ),
                      Text(
                        "${kontakt.author.name}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.caption.color),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                ),
                PikerField(
                  controller: kontragent,
                  readOnly: !kontakt.isAuthor,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: kontragentUser,
                  readOnly: !kontakt.isAuthor,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: vid,
                  readOnly: !kontakt.isAuthor,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: theme,
                  readOnly: !kontakt.isAuthor,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: sposob,
                  readOnly: !kontakt.isAuthor,
                  onPickerChanged: onPickerChanged,
                ),
                PikerField(
                  controller: sotrudnik,
                  readOnly: !kontakt.isAuthor,
                  onPickerChanged: onPickerChanged,
                ),
                Divider(
                  height: 5,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Text(kontakt.text),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void onNotSavePress(BuildContext context) {
    Navigator.of(context).pop();
    isChanged = false;
    Navigator.of(context).pop();
  }

  Future onSavePress(BuildContext context) async {
    Navigator.of(context).pop();
    await StoreProvider.dispatchFuture(
        context, SaveKontakt(kontakt: copyKontakt(kontakt)));
    setState(() {
      loaded = false;
    });
    isChanged = false;
    Navigator.of(context).pop();
  }

  void onPickerChanged(PikerController controller) {
    isChanged = true;
  }

  Kontakt copyKontakt(kontakt) {
    Kontakt copyKontakt = kontakt;

    copyKontakt.kontragent = kontragent.value;
    copyKontakt.kontragentUser = kontragentUser.value;
    copyKontakt.vid = vid.value;
    copyKontakt.theme = theme.value;
    copyKontakt.sotrudnik = sotrudnik.value;

    return kontakt;
  }
}
