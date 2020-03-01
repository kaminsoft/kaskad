import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';

import 'Kontragent.dart';

class KontragentList extends StatefulWidget {
  KontragentList({Key key}) : super(key: key);

  @override
  _KontragentListState createState() => _KontragentListState();
}

class _KontragentListState extends State<KontragentList> {
  bool searchMode = false;
  TextEditingController filter = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<Kontragent> searchList = List<Kontragent>();
  String query = '';

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

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
                  setState(() {
                    query = filter.text;
                  });
                },
              ),
              actions: <Widget>[
                
                IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        searchMode = false;
                      });
                    }),
              ],
            )
          : AppBar(
              title: Text('Контрагенты'),
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
      body: StoreConnector<AppState, List<Kontragent>>(
          converter: (store) => store.state.kontragents,
          builder: (context, kontragents) {
            var list = [];

            if (searchMode) {
              if (query.length < 2) {
                return Center(
                  child: Text(
                    'Введите наименование, инн или код контрагента',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                );
              }
              return FutureBuilder(
                future: Connection.searchKontragent(query),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  list = snapshot.data;
                  if (list.length == 0) {
                    return Center(
                      child: Text(
                        'Нет данных для отображения',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black45),
                      ),
                    );
                  }
                  return Scrollbar(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        Kontragent kontragent = list[index];
                        Kontragent cashedKontragent = kontragents.firstWhere((k)=> k.guid == kontragent.guid, orElse: ()=> null);
                        bool active = cashedKontragent != null;
                        return ItemCard(
                          cashedKontragent: cashedKontragent,
                          kontragent: kontragent,
                          active: active,
                        );
                      },
                    ),
                  );
                },
              );
            }

            if (kontragents.length == 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(45.0),
                  child: Text(
                    'В избранном нет контрагентов\n Для добавления в избранное перейдите в поиск',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                ),
              );
            }

            return Scrollbar(
              child: ListView.builder(
                itemCount: kontragents.length,
                itemBuilder: (BuildContext context, int index) {
                  Kontragent kontragent = kontragents[index];
                  Kontragent cashedKontragent = kontragents.firstWhere((k)=> k.guid == kontragent.guid, orElse: ()=> null);
                  bool active = cashedKontragent != null;
                  return ItemCard(
                    kontragent: kontragent,
                    cashedKontragent: cashedKontragent,
                    active: active,
                    showStar: false,
                  );
                },
              ),
            );
          }),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard(
      {Key key,
      @required this.kontragent,
      @required this.cashedKontragent,
      @required this.active,
      this.showStar = true})
      : super(key: key);

  final Kontragent kontragent;
  final Kontragent cashedKontragent;
  final bool active;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    String inn = kontragent.inn != null && kontragent.inn.isNotEmpty
        ? 'ИНН: ${kontragent.inn}'
        : 'ИНН не указан';
    return Card(
      child: InkWell(
        onTap: () {
          Kontr.openItem(context, active ? cashedKontragent : kontragent);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    '${kontragent.code}',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${kontragent.name}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$inn',
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  showStar ? IconButton(
                      icon: active
                          ? Icon(
                              Icons.star,
                              color: ColorMain,
                            )
                          : Icon(Icons.star_border),
                      onPressed: () {
                        StoreProvider.dispatchFuture(
                            context,
                            active
                                ? RemoveKontragent(kontragent)
                                : AddKontragent(kontragent));
                      }) : Icon(Icons.chevron_right, color: Colors.black45),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
