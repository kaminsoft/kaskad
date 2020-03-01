import 'package:mobile_kaskad/Models/Recipient.dart';

class LinkItem {
  String guid;
  String name;
  String type;

    LinkItem({this.guid, this.name, this.type});

  factory LinkItem.fromJSON(Map<String, dynamic> json) {
    return LinkItem(
      guid: json["guid"],
      name: json['name'],
      type: json['type'],
    );
  }

  Recipient toRecipient() {
    return Recipient(guid: guid, name: name, isGroup: type == 'Справочник.Пользователи' ? false : true);
  }

  Map<String, dynamic> toJson() => {
        "guid": guid,
        "name": name,
        "type": type,
    };
}