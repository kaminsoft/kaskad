import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontakt.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';
import 'package:toast/toast.dart';

import 'KontaktHelper.dart';

class NewItemWidget extends StatefulWidget {
  @override
  _NewItemWidgetState createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  Kontakt kontakt;
  List<KontaktTemplate> templates = List<KontaktTemplate>();

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

  TextEditingController textController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    Connection.getKontaktTemplates().then((value) {
      setState(() {
        templates = value;
      });
    });
    kontragentUser.setOwner(kontragent);
    kontakt = Kontakt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double mult = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Новый контакт"),
      ),
      bottomNavigationBar: loading
          ? SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: templates.length > 0,
                  child: FlatButton(
                    onPressed: () {
                      openTemplates(context);
                    },
                    child: Text(
                      "Из шаблона",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    await StoreProvider.dispatchFuture(
                        context, SaveKontakt(kontakt: copyKontakt(kontakt)));
                    setState(() {
                      loading = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Отправить",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.caption.color),
                  ),
                )
              ],
            ),
      body: loading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : Scrollbar(
              child: ListView(
                children: <Widget>[
                  PikerField(
                    controller: kontragent,
                  ),
                  PikerField(
                    controller: kontragentUser,
                  ),
                  PikerField(
                    controller: vid,
                  ),
                  PikerField(
                    controller: theme,
                  ),
                  PikerField(
                    controller: sposob,
                  ),
                  PikerField(
                    controller: sotrudnik,
                  ),
                  Divider(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      controller: textController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Содержание"),
                      maxLines: null,
                      minLines: null,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void openTemplates(BuildContext context) {
    List<Widget> actions = List<Widget>();
    templates.forEach((element) {
      actions.add(CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              vid.value = element.vid;
              theme.value = element.theme;
              sposob.value = element.sposob;
              if (element.infoSource.isNotEmpty) {
                infoSource.value = element.infoSource;
              }
              if (element.text.isNotEmpty) {
                textController.text = element.text;
              }
            });
            Navigator.of(context).pop();
          },
          child: Text(element.name)));
    });

    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            actions: actions,
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Отмена')),
          );
        });
  }

  Kontakt copyKontakt(Kontakt kontakt) {
    Kontakt copyKontakt = kontakt;

    copyKontakt.kontragent = kontragent.value;
    copyKontakt.kontragentUser = kontragentUser.value;
    copyKontakt.vid = vid.value;
    copyKontakt.theme = theme.value;
    copyKontakt.sposob = sposob.value;
    copyKontakt.text = textController.text;
    copyKontakt.sotrudnik = sotrudnik.value;
    copyKontakt.infoSource = infoSource.value;
    copyKontakt.status = "Состоялся";
    copyKontakt.guid = "";

    return kontakt;
  }
}
