import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Profile/Profile.dart';


class ItemWidget extends StatefulWidget {
  ItemWidget({Key key}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
         child: FlatButton(onPressed: (){
           Profile.logOut(context);
         }, child: Text('data')),
       ),
    );
  }
}