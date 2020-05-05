
import 'package:mobile_kaskad/Models/linkItem.dart';

class Recipient {

  String guid;
  String name;
  bool isGroup;

  Recipient({this.name, this.guid, this.isGroup});

  bool operator ==(other)  => other.guid == guid;

  static List<Recipient> getDevs() {
    var res = List<Recipient>();
    res.add(Recipient(guid: "0668986c-13d9-11e4-5693-0025900ed684", name: "Разработчики КАСКАД", isGroup: false));
    return res;
  }

  factory Recipient.fromJSON(Map<String, dynamic> json) {
    return Recipient(
      guid: json["guid"],
      name: json['name'],
      isGroup: json['group'],
    );
  }

  LinkItem toLinkItem() {
    return LinkItem(guid: guid, name: name, type: isGroup ? 'СпискиПользователей' : 'Пользователи');
  }

  Map<String, dynamic> toJson() => {
        "guid": guid,
        "name": name,
        "group": isGroup,
    };

}