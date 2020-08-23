import 'package:flutter/cupertino.dart';

import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/attachment.dart';

class LinkItem {
  String guid;
  String name;
  String type;
  List<CustomField> fields = [];

  LinkItem({this.guid = "", this.name = "Не задано", this.type, this.fields});

  bool operator ==(other) => other.guid == guid && other.type == type;

  bool get isEmpty =>
      guid.isEmpty || guid == '00000000-0000-0000-0000-000000000000';
  bool get isNotEmpty =>
      guid.isNotEmpty && guid != '00000000-0000-0000-0000-000000000000';

  CustomField getCustomFieldByName(String name) {
    return fields.firstWhere((e) => e.name == name, orElse: () => null);
  }

  factory LinkItem.fromJSON(Map<String, dynamic> json) {
    if (json == null) {
      return LinkItem();
    }

    List<CustomField> fields = List<CustomField>();
    if (json['fields'] is List<dynamic>) {
      List<dynamic> _fields = json['fields'];
      if (_fields != null) {
        for (var item in _fields) {
          fields.add(CustomField.fromJSON(item));
        }
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
        "fields":
            fields == null ? 'null' : fields.map((t) => t.toJson()).toList(),
      };

  @override
  String toString() {
    return name.isNotEmpty ? name : 'Не указано';
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class CustomField {
  String name;
  String value;
  String guid;

  CustomField({this.name, this.value, this.guid});

  factory CustomField.fromJSON(Map<String, dynamic> json) {
    return CustomField(
      name: json['name'],
      value: json['value'],
      guid: json['guid'],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
        "guid": guid,
      };
}
