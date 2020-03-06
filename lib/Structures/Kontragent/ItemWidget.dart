import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemWidget extends StatefulWidget {
  final Kontragent kontragent;

  const ItemWidget({Key key, @required this.kontragent}) : super(key: key);
  @override
  _ItemWidgetState createState() => _ItemWidgetState(kontragent);
}

class _ItemWidgetState extends State<ItemWidget> {
  _ItemWidgetState(this.kontragent);
  Kontragent kontragent;
  bool loading = false;
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Kontragent>>(
      converter: (store) => store.state.kontragents,
      builder: (context, kontragents) {
        active = kontragents.where((k) => k.guid == kontragent.guid).length > 0;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '${kontragent.name}',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              loading
                  ? IconButton(
                      icon: CupertinoActivityIndicator(),
                      onPressed: null,
                    )
                  : IconButton(
                      icon: active
                          ? Icon(
                              Icons.star,
                              color: ColorMain,
                            )
                          : Icon(Icons.star_border),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await StoreProvider.dispatchFuture(
                            context,
                            active
                                ? RemoveKontragent(kontragent)
                                : AddKontragent(kontragent, fromServer: false));
                        setState(() {
                          loading = false;
                        });
                      })
            ],
          ),
          body: FutureBuilder(
            future: Connection.getKontragent(kontragent.guid),
            builder:
                (BuildContext context, AsyncSnapshot<Kontragent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                if (active) {
                  kontragent =
                      kontragents.where((k) => k.guid == kontragent.guid).first;
                } else if (kontragent.fullName == null) {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              }
              if (snapshot.hasData) {
                kontragent = snapshot.data;
                if (active) {
                  StoreProvider.dispatchFuture(
                      context, AddKontragent(kontragent, fromServer: false));
                }
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _labeledWidget(kontragent.fullName, 'Полное наименование'),
                    _getAdresses(),
                    _labeledWidget(kontragent.orientir, 'Ориентир'),
                    _getINNKPP(),
                    _getKontacts(),
                    _getContactUsers(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _getContactUsers() {
    if (kontragent.persons.length == 0) {
      return Column(
        children: <Widget>[
          Divider(),
          SizedBox(
            height: 115,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    CupertinoIcons.person_solid,
                    size: 48,
                    color: Colors.black26,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Нет контактных лиц'.toUpperCase(),
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
        ],
      );
    }
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 115,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kontragent.persons.length,
                  itemBuilder: (BuildContext context, int index) {
                    var person = kontragent.persons[index];
                    return ContactUserCard(person: person);
                  },
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _getAdresses() {
    if (kontragent.adressActual == kontragent.adressLegal) {
      return _labeledWidget(kontragent.adressActual, 'Адрес');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _labeledWidget(kontragent.adressActual, 'Фактический адрес'),
        _labeledWidget(kontragent.adressLegal, 'Юридический адрес'),
      ],
    );
  }

  Widget _labeledWidget(String value, String lable) {
    String _value = value == null || value.isEmpty ? 'Не указан' : value;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            lable,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText(
            _value,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }

  Widget _getINNKPP() {
    return Row(
      children: <Widget>[
        _labeledWidget(kontragent.inn, 'ИНН'),
        _labeledWidget(kontragent.kpp, 'КПП')
      ],
    );
  }

  Widget _getKontacts() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          InkWell(
              onTap: () => call(kontragent.phone),
              child: _labeledWidget(kontragent.phone, 'Телефон')),
          _labeledWidget(kontragent.email, 'Email')
        ],
      ),
    );
  }
}

class ContactUserCard extends StatelessWidget {
  const ContactUserCard({
    Key key,
    @required this.person,
  }) : super(key: key);

  final KontaktPerson person;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    CupertinoIcons.person_solid,
                    size: 48,
                    color: Colors.black38,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text(
                        person.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        person.position.isEmpty
                            ? 'Должность не указана'
                            : person.position,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Divider(
              color: Colors.transparent,
              height: 2,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                PhoneWidget(
                  phone: person.phone,
                ),
                PhoneWidget(
                  phone: person.workPhone,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PhoneWidget extends StatelessWidget {
  final String phone;

  const PhoneWidget({Key key, this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (phone == null) {
      return Container();
    }
    var phones = phone.split(new RegExp(r'[,;]'));
    List<Widget> children = List<Widget>();
    for (var item in phones) {
      children.add(FlatButton(
        onPressed: () => call(item),
        child: Text(item),
        textColor: ColorMain,
      ));
    }

    return Row(
      children: children,
    );
  }
}
