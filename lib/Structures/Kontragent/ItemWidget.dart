import 'package:async_redux/async_redux.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:url_launcher/url_launcher.dart';

var dogovors;
var products;

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
  bool loaded = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    dogovors = null;
    products = null;
    super.dispose();
  }

  Widget _getWidget(kontragents) {
    List<Widget> _tabs = [
      _mainWidget(kontragents),
      DogovorWidget(
        kontragent: kontragent,
      ),
      ProductWidget(
        kontragent: kontragent,
      )
    ];
    return _tabs[currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      Connection.getKontragent(kontragent.guid).then((kontr) {
        if (kontr != null) {
          setState(() {
            kontragent = kontr;
            loaded = true;
          });
          if (active) {
            StoreProvider.dispatchFuture(
                context, AddKontragent(kontr, fromServer: false));
          }
        }
      });
    }
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
          body: _getWidget(kontragents),
          bottomNavigationBar: BottomNavigationBar(
              backgroundColor: ColorGray,
              elevation: 0,
              selectedItemColor: ColorMain,
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_box), title: Text('Контрагент')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.description), title: Text('Договоры')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive), title: Text('Продукты/ИТС')),
              ]),
        );
      },
    );
  }

  Widget _mainWidget(List<Kontragent> kontragents) {
    return Builder(builder: (context) {
      if (kontragent.fullName == null) {
        if (active && !loaded) {
          kontragent =
              kontragents.where((k) => k.guid == kontragent.guid).first;
        } else {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _labeledWidget(kontragent.fullName, 'Полное наименование'),
            _getAdresses(),
            _getINNKPP(),
            _getKontacts(),
            _getContactUsers(),
            _getSecrets()
          ],
        ),
      );
    });
  }

  Widget _getSecrets() {
    return Visibility(
      visible: kontragent.secrets.isNotEmpty,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          itemCount: kontragent.secrets.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            var secret = kontragent.secrets[index];
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: Icon(
                          Icons.lock,
                          color: Colors.black38,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(secret.type.trim()),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _labeledWidget(secret.login, 'Логин'),
                      _labeledWidget(secret.password, 'Пароль'),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getContactUsers() {
    if (kontragent.persons.isEmpty) {
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
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _labeledWidget(kontragent.inn, 'ИНН'),
          _labeledWidget(kontragent.kpp, 'КПП'),
          _labeledWidget(kontragent.orientir, 'Ориентир'),
        ],
      ),
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

class DogovorWidget extends StatefulWidget {
  const DogovorWidget({
    @required this.kontragent,
    Key key,
  }) : super(key: key);

  final Kontragent kontragent;

  @override
  _DogovorWidgetState createState() => _DogovorWidgetState();
}

class _DogovorWidgetState extends State<DogovorWidget> {
  List _dogovors;
  @override
  Widget build(BuildContext context) {
    if (dogovors == null) {
      Connection.getKontragentDogovors(widget.kontragent.guid).then((_dogs) {
        setState(() {
          _dogovors = _dogs;
          dogovors = _dogovors;
        });
      });
    } else {
      _dogovors = dogovors;
    }

    if (_dogovors == null) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_dogovors.isEmpty) {
      return Center(
          child: Text(
        'Нет действующих договоров',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black45),
      ));
    }

    return ListView.builder(
      itemCount: _dogovors.length,
      itemBuilder: (BuildContext context, int index) {
        var dogovor = _dogovors[index];
        return Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      dogovor['numberDate'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(dogovor["vid"]),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${dogovor["dateFrom"]} - ${dogovor["dateTo"]}'),
                    Text(dogovor["type"]),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      dogovor['organisation'],
                      //style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dogovor['status'].toString().toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    @required this.kontragent,
    Key key,
  }) : super(key: key);

  final Kontragent kontragent;

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  List _allProducts;
  List _products;
  List _its;
  List _services;
  @override
  Widget build(BuildContext context) {
    if (products == null) {
      Connection.getKontragentProducts(widget.kontragent.guid).then((_dogs) {
        setState(() {
          _allProducts = _dogs;
          products = _allProducts;
        });
      });
    } else {
      _allProducts = products;
    }

    if (_allProducts == null) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_allProducts.isEmpty) {
      return Center(
          child: Text(
        'Нет продуктов, ИТС и сервисов',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black45),
      ));
    }

    _products = _allProducts.where((e) => e['type'] == 'product').toList();
    _its = _allProducts.where((e) => e['type'] == 'its').toList();
    _services = _allProducts.where((e) => e['type'] == 'service').toList();

    String curType = '';
    return Scrollbar(
      child: ListView.separated(

        itemCount: _allProducts.length,
        separatorBuilder: (BuildContext context, int index) {
          var element = _allProducts[index];
          if (element['type'] != curType) {
            curType = element['type'];
            return _getTypeText(element['type']);
          }
          return Container();
        },
        itemBuilder: (BuildContext context, int index) {
          var element = _allProducts[index];
          if (element['type'] != curType) {
            curType = element['type'];
            return Column(
              children: <Widget>[
                _getTypeText(element['type']),
                _getProductCard(element)
              ],
            );
          }
          return _getProductCard(element);
        },
      ),
    );
  }

  Widget _getProductCard(element) {
    if (element['type'] == 'product') {
      return Card(
        child: ListTile(
          title: Text(element['name']),
          subtitle: Text(element['regNumber']),
        ),
      );
    }
    if (element['type'] == 'its') {
      return Card(
        child: ListTile(
          title: Text(element['name']),
          subtitle:
              Text('${element["periodFrom"]} - ${element["periodTo"]}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(element['sotrudnik']),
              Text(element['status'])
            ],
          ),
        ),
      );
    }
    return Card(
      child: ListTile(
        title: Text(element['vid']),
        subtitle: Text('${element["dateFrom"]} - ${element["dateTo"]}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(element['sotrudnik']),
            Text(element['status'])
          ],
        ),
      ),
    );
  }

  Widget _getTypeText(type) {
    TextStyle _style = TextStyle(color: Colors.black54, fontSize: 16);
    if (type == 'product') {
      return Text(
        'Продукты',
        textAlign: TextAlign.center,
        style: _style,
      );
    }
    if (type == 'its') {
      return Text(
        'ИТС',
        textAlign: TextAlign.center,
        style: _style,
      );
    }
    return Text(
      'Сервисы',
      textAlign: TextAlign.center,
      style: _style,
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
