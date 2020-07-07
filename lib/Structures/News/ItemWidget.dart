import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';

class NewVersion {
  String version;
  List<FeatureDescriber> features;
  List<FeatureDescriber> bugs;
  NewVersion({this.version, this.features, this.bugs});

  Widget versionTitle({@required String version, bool showAll}) {
    return Visibility(
      visible: showAll,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(
              height: 30,
            ),
            Text(
              version == Data.version
                  ? "Версия $version (текущая)"
                  : "Версия $version",
              style: Theme.of(mainWidgetKey.currentContext).textTheme.title,
            ),
          ],
        ),
      ),
    );
  }

  Widget newTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Text(
        'НОВЫЕ ФУНКЦИИ',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(mainWidgetKey.currentContext).colorScheme.onSurface),
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

  Widget newLine(FeatureDescriber ftr) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 8, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ftr.isHot
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.new_releases,
                    color: Theme.of(mainWidgetKey.currentContext)
                        .colorScheme
                        .onSurface,
                    size: 18,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.done,
                    size: 18,
                  ),
                ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                ftr.title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                ftr.description,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(mainWidgetKey.currentContext)
                        .textTheme
                        .body1
                        .color
                        .withAlpha(150)),
              ),
              ftr.attentionText.isNotEmpty
                  ? Text(
                      ftr.attentionText,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(mainWidgetKey.currentContext)
                              .colorScheme
                              .onSurface),
                    )
                  : Container(),
            ],
          ))
        ],
      ),
    );
  }

  List<Widget> getFeatures(bool showAll) {
    List<Widget> result = <Widget>[];
    result.add(versionTitle(version: version, showAll: showAll));
    if (features.length > 0) {
      result.add(Divider());
      result.add(newTitle());
      for (var ftr in features) {
        result.add(newLine(ftr));
      }
    }
    if (bugs.length > 0) {
      result.add(Divider());
      result.add(bugTitle());
      for (var ftr in bugs) {
        result.add(newLine(ftr));
      }
    }
    return result;
  }
}

class FeatureDescriber {
  String title;
  String description;
  String attentionText;
  bool isHot;
  FeatureDescriber(this.title, this.description,
      {this.isHot = false, this.attentionText = ""});
}

class ItemWidget extends StatefulWidget {
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool showAll = false;

  var versions = [
    NewVersion(version: "0.0.5", features: [
      FeatureDescriber("Задачи",
          "Добавлен новый раздел - задачи. Создавайте и выполняйте задачи прямо из мобильного приложения",
          isHot: true),
      FeatureDescriber("Сообщения",
          "Команда прочитать все сообщения перемещена в фильтры, добавлен вопрос для подтверждения прочтения"),
      FeatureDescriber("Рабочий стол",
          "Переработано отображение индикаторов сообщений, объявлений и задач",
          attentionText:
              "Рекомендуется передобавить плитки сообщений, объявлений и задач, если они были добавлены ранее"),
      FeatureDescriber("Вложения",
          "Теперь если вложение в объекте одно, то оно открвается сразу при нажатии на кнопку вложений. Если вложений несколько - открывается список, как и реньше"),
    ], bugs: []),
    NewVersion(version: "0.0.4", features: [
      FeatureDescriber("Пролистование сообщений",
          "Теперь можно свайпать вправо/влево для пролистывания сообщений и объявлений. Нет необходимости возвращаться в список, чтобы открыть новое сообщение"),
      FeatureDescriber("Сообщения",
          "Добавлена возможность прочтения сразу всех сообщений или объявлений\nКомандная панель из дополнительного меню сверху переместилась вниз"),
      FeatureDescriber("Вложения сообщений",
          "Появилась возможность просматривать вложения с типами: web ссылка, справочник, документ. Элементы открываются только на просмотр"),
      FeatureDescriber("Получатели сообщения",
          "Теперь при выборе получателей в сообщении можно долгим нажатием на группу открыть меню и отметить сотрудников списка. В этом случае отметятся сотрудники группы, а не группа вцелом. Так можно исключить сотрудников из получателей"),
      FeatureDescriber("Сотрудники",
          "Теперь открыть карточку сотрудника можно из письма, нажав на автора или получателя"),
      FeatureDescriber("Дни рождения",
          "Появилась возможность получать уведомления о днях рождения сотрудников. Эти уведомления можно отключить в настройках. \nВ списке сотрудников появилась кнопка, где можно посмотреть у кого сегодня день рождения. Если кнопки нет, значит нет и дней рождения"),
    ], bugs: [
      FeatureDescriber("Контрагенты",
          "Исправлено отображение информации контрагента при большом размере текста"),
      FeatureDescriber("Сообщения",
          "Новые сообщения теперь отличаются от прочитанных в темной теме")
    ]),
    NewVersion(version: "0.0.3", features: [
      FeatureDescriber("Настройки",
          "Добавлены настройки приложения. В настройки перемещена информация о новых функциях, возможность отправки сообщения разработчику"),
      FeatureDescriber("Панель почты",
          "Теперь можно скрыть нижнюю панель почты на рабочем столе. Сообщения и объявления можно отобразить в виде разделов"),
      FeatureDescriber("Почта",
          "Добавлена возможность просмотра только новых, исходящих сообщений и объявлений"),
      FeatureDescriber("Темы",
          "Теперь можно выбрать тему в настройках. Системная тема зависит от системных настроек"),
      FeatureDescriber("Изменения рабочего стола",
          "Плитки разделов теперь перемещаются после долгого зажатия в режиме редактирования"),
      FeatureDescriber("Что дальше",
          "В настройки добавлена ссылка на планы работ над приложением"),
    ], bugs: [
      FeatureDescriber("Сообщения",
          "Исправлена ошибка, при которой отправлялся запрос о прочтении сообщения, которое уже было прочитано"),
      FeatureDescriber(
          "Темная тема", "Исправлены ошибки, связанные с темной темой"),
    ]),
    NewVersion(version: "0.0.2", features: [
      FeatureDescriber("Контактная информация",
          "Копирование телефона, email сотрудника или контактного лица контрагента производится долгим нажатием. Звонок/написать по нажатию, как и ранее "),
      FeatureDescriber("Переработан список контактных лиц",
          "Теперь контактные лица отображаются раскрывающимся списком, в котором отображается контактная информация"),
      FeatureDescriber("Добавлена почта контактного лица",
          "Контактные лица котнтрагентов теперь содержат почту для связи"),
      FeatureDescriber("Сервисы контрагента",
          "Добавлен признак платного сервиса и срок действия лицензии"),
      FeatureDescriber("Рабочий стол",
          "Редактирование рабочего стола можно вызвать из меню, а не только по долгому нажатию на кнопку раздела"),
      FeatureDescriber("Контактная информация сотрудников",
          "Добавлен внутренний, домашний, рабочий телефоны. Добавлен личный и рабочий email"),
      FeatureDescriber("Сообщить об ошибке",
          "Добавлена возможность отправить сообшение об ошибке из меню"),
      FeatureDescriber("Новое в версии", "Добавлено это окно :)"),
    ], bugs: [
      FeatureDescriber("Количество сообщений",
          "Исправлена ошибка, при которой отображалось некорректное число сообщений и объявлений"),
      FeatureDescriber("Неактивные контактные лица",
          "Контактные лица, которые помечены как неактивные, теперь не отображаются"),
      FeatureDescriber("Обучающие подсказки",
          "Подсказка больше не появится, если ее не выполнить, а нажать в любое другое место"),
    ]),
  ];

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
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.history,
                color: showAll
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).appBarTheme.iconTheme.color,
              ),
              onPressed: () {
                setState(() {
                  showAll = !showAll;
                });
              })
        ],
      ),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            newImage(),
            Builder(
              builder: (_) {
                List<Widget> children = List<Widget>();
                for (var ver in versions) {
                  if (showAll || ver.version == Data.version) {
                    children.addAll(ver.getFeatures(showAll));
                  }
                }
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget newImage() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 4,
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
}
