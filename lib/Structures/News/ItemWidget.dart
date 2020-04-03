import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';

class ItemWidget extends StatefulWidget {
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: <Widget>[
            Text(
              "Что нового",
              style: Theme.of(context).textTheme.subtitle,
            ),
            Text(
              Data.version,
              style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          newImage(),
          new002(),
        ],
      ),
    );
  }

  Widget new002({bool showTitle = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showTitle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Версия 0.0.2", style: Theme.of(context).textTheme.title.copyWith(color: Colors.black54),),
          ),
        ),
        newTitle(),
        newLine("Контактная информация",
            "Копирование телефона, email сотрудника или контактного лица контрагента производится долгим нажатием. Звонок/написать по нажатию, как и ранее "),
        newLine("Переработан список контактных лиц",
            "Теперь контактные лица отображаются раскрывающимся списком, в котором отображается контактная информация"),
        newLine("Добавлена почта контактного лица",
            "Контактные лица котнтрагентов теперь содержат почту для связи"),
        newLine("Сервисы контрагента",
            "Добавлен признак платного сервиса и срок действия лицензии"),
        newLine("Рабочий стол",
            "Редактирование рабочего стола можно вызвать из меню, а не только по долгому нажатию на кнопку раздела"),
        newLine("Контактная информация сотрудников",
            "Добавлен внутренний, домашний, рабочий телефоны. Добавлен личный и рабочий email"),
        newLine("Сообщить об ошибке", "Добавлена возможность отправить сообшение об ошибке из меню"),
        newLine("Новое в версии", "Добавлено это окно :)"),
        Divider(
          thickness: 2,
        ),
        bugTitle(),
        newLine("Количество сообщений",
            "Исправлена ошибка, при которой отображалось некорректное число сообщений и объявлений"),
        newLine("Неактивные контактные лица",
            "Контактные лица, которые помечены как неактивные, теперь не отображаются"),
        newLine("Обучающие подсказки",
            "Подсказка больше не появится, если ее не выполнить, а нажать в любое другое место"),
      ]);
  }

  Widget newImage() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/4,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset('assets/img/news.png'),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget newLine(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 8, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RotatedBox(
              quarterTurns: -1,
              child: Text(
                "•",
                style: TextStyle(
                  fontSize: 28,
                ),
              )),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                text,
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.body1.color.withAlpha(150)),
              ),
            ],
          ))
        ],
      ),
    );
  }

  Widget newTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Text(
        'НОВЫЕ ФУНКЦИИ',
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: ColorMain),
      ),
    );
  }

  Widget bugTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Text(
        'ИСПРАВЛЕНИЯ',
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }
}
