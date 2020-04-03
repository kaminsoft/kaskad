
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Woker {
  String guid;
  String name;
  String shortName;
  int sex;
  String position;
  String subdivision;
  DateTime birthday;
  String mobilePhone;
  String workPhone;
  String internalPhone;
  String email;
  String workEmail;
  String homePhone;
  
  Woker({this.guid, this.name, this.shortName, this.sex, this.position, this.subdivision, this.mobilePhone, this.birthday, this.workPhone, this.email, this.internalPhone, this.workEmail, this.homePhone});

  bool operator ==(other)  => other.guid == guid;

  String getBirthdayString() {
    initializeDateFormatting();
    return DateFormat('dd MMMM yyyy', 'ru').format(birthday);
  }

  factory Woker.fromJSON(Map<String, dynamic> json) {
    return Woker(
      guid: json["guid"],
      name: json["name"],
      shortName: json["shortName"],
      sex: json["sex"],
      position: json["position"],
      subdivision: json["subdivision"],
      mobilePhone: json["mobilePhone"],
      birthday: DateTime.parse(json["birthday"]),
      workPhone: json["workPhone"],
      internalPhone: json["internalPhone"],
      email: json["email"],
      workEmail: json["workEmail"],
      homePhone: json["homePhone"],
    );
  }

   Map<String, dynamic> toJson() => {
        "guid": guid,
        "name": name,
        "shortName": shortName,
        "sex": sex,
        "position": position,
        "subdivision": subdivision,
        "mobilePhone": mobilePhone,
        "birthday": birthday.toIso8601String(),
        "workPhone": workPhone,
        "internalPhone": internalPhone,
        "email": email,
        "workEmail": workEmail,
        "homePhone": homePhone,
    };
}