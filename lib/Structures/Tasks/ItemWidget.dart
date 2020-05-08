import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Structures/Piker/Piker.dart';
import 'package:mobile_kaskad/Structures/Piker/PikerForm.dart';

class ItemWidget extends StatefulWidget {
  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {

  PikerController kontragent = PikerController(type: "Контрагенты", label: "Контрагент",);
  PikerController kontragentUser = PikerController(type: "КонтактныеЛица", label: "Контактное лицо",);
  
  PikerController worker = PikerController(type: "Пользователи", label: "Сотрудник",);
  PikerController group = PikerController(type: "СпискиИсполнителейЗадач", label: "Кому",);

  final _formKey = GlobalKey<PikerFormState>();

  @override
  void initState() { 
    kontragentUser.setOwner(kontragent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Задача"),
      ),
    );
  }
}