import 'package:flutter/cupertino.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/attachment.dart';

class LinkItem {
  String guid;
  String name;
  String type;
  List<CustomField> fields;

  LinkItem({this.guid="", this.name="Не задано", this.type, this.fields});

  bool operator ==(other)  => other.guid == guid && other.type == type;

  bool get isEmpty => guid.isEmpty;
  bool get isNotEmpty => guid.isNotEmpty;
  
  factory LinkItem.fromJSON(Map<String, dynamic> json) {
    List<dynamic> _fields = json['fields'];
    List<CustomField> fields = List<CustomField>();
    if (_fields != null) {
      for (var item in _fields) {
        fields.add(CustomField.fromJSON(item));
      }
    }

    return LinkItem(
      guid: json["guid"],
      name: json['name'],
      type: json['type'],
      fields: fields,
    );
  }

  Recipient toRecipient() {
    return Recipient(
        guid: guid,
        name: name,
        isGroup: type == 'Справочник.Пользователи' ? false : true);
  }

  void open(BuildContext context) {
    Attachment attachment = Attachment(name: name, value: guid, type: type);
    attachment.open(context);
  }

  Map<String, dynamic> toJson() => {
        "guid": guid,
        "name": name,
        "type": type,
        "fields": fields.map((t) => t.toJson()).toList(),
      };
}

class CustomField {
  String name;
  String value;

  CustomField({this.name, this.value});

  factory CustomField.fromJSON(Map<String, dynamic> json) {
    return CustomField(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
      };
}
