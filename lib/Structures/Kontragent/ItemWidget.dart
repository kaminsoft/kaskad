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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${kontragent.name}',
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          StoreConnector<AppState, List<Kontragent>>(
            converter: (store) => store.state.kontragents,
            builder: (context, kontragents) {
              active =
                  kontragents.where((k) => k.guid == kontragent.guid).length >
                      0;
              return loading
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
                                : AddKontragent(kontragent));
                        setState(() {
                          loading = false;
                        });
                      });
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: Connection.getKontragent(kontragent.guid),
        builder: (BuildContext context, AsyncSnapshot<Kontragent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (snapshot.hasData) {
            kontragent = snapshot.data;
            if (active) {
              StoreProvider.dispatchFuture(
                  context, AddKontragent(kontragent, fromServer: false));
            }
          }

          return Column(
            children: <Widget>[
              
              Visibility(
                visible: kontragent.persons.length > 0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 115,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: kontragent.persons.length,
                          itemBuilder: (BuildContext context, int index) {
                            var person = kontragent.persons[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 8),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Icon(CupertinoIcons.person_solid, size: 48,color: ColorMain,),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: Text(
                                                person.name,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 3),
                                              child: Text(person.position.isEmpty ? 'Должность не указана' : person.position, style: TextStyle(fontSize: 14),),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Divider(
                                      color: ColorMain,
                                      height: 2,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      
                                      children: <Widget>[
                                        PhoneWidget(phone: person.phone,),
                                        PhoneWidget(phone: person.workPhone,),
                                        
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
      var num = item.replaceAll('-', '');
      num = num.replaceAll('(', '');
      num = num.replaceAll(')', '');
      num = num.replaceAll(' ', '');
      children.add(FlatButton(onPressed: ()=>call(num), child: Text(item),textColor: ColorMain,));
    }
    
    return Row(children: children,);
  }
}
