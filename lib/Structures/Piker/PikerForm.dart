
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerField.dart';

class PikerForm extends StatefulWidget {
  final List<PikerField> children;
  
  const PikerForm({Key key, @required this.children}) : super(key: key);
  @override
  PikerFormState createState() => PikerFormState();
}

class PikerFormState extends State<PikerForm> {

  bool validate(){
    bool result = true;
    for (PikerField item in widget.children) {
      result = item.validate() && result;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children,
    );
  }
}