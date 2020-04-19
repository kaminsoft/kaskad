import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              version == Data.version ? "Версия $version (текущая)" : "Версия $version",
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
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(mainWidgetKey.currentContext)
                        .textTheme
                        .body1
                        .color
                        .withAlpha(150)),
              ),
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
        result.add(newLine(ftr.title, ftr.description));
      }
    }
    if (bugs.length > 0) {
      result.add(Divider());
      result.add(bugTitle());
      for (var ftr in bugs) {
        result.add(newLine(ftr.title, ftr.description));
      }
    }
    return result;
  }
}

class FeatureDescriber {
  String title;
  String description;
  FeatureDescriber(this.title, this.description);
}

class ItemWidget extends StatefulWidget {
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool showAll = false;

  var versions = [
    NewVersion(version: "0.0.4", features: [
      FeatureDescriber("Пролистование сообщений",
          "Теперь можно свайпать вправо/влево для пролистывания сообщений и объявлений. Нет необходимости возвращаться в список, чтобы открыть новое сообщение"),
      FeatureDescriber("Сообщения",
          "Добавлена возможность прочтения сразу всех сообщений или объявлений"),
    ], bugs: [
      FeatureDescriber("Контрагенты",
          "Исправлено отображение информации контрагенты при большом размере текста")
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
      FeatureDescriber("Темная тема",
          "Исправлены ошибки, связанные с темной темой"),
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
      body: ListView(
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
