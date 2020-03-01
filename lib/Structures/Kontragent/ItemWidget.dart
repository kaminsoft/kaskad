import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';

class ItemWidget extends StatefulWidget {
  final Kontragent kontragent;

  const ItemWidget({Key key, @required this.kontragent}) : super(key: key);
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.kontragent.name}',maxLines: 2,textAlign: TextAlign.center,),
        actions: <Widget>[
          StoreConnector<AppState, List<Kontragent>>(
            converter: (store) => store.state.kontragents,
            builder: (context, kontragents) {
              bool active = kontragents
                      .where((k) => k.guid == widget.kontragent.guid)
                      .length >
                  0;
              return IconButton(
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
                            ? RemoveKontragent(widget.kontragent)
                            : AddKontragent(widget.kontragent));
                  });
            },
          )
        ],
      ),
      body: Container(),
    );
  }
}
