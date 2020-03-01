
import 'dart:convert';

class Kontragent {
  String guid;
  String code;
  String name;
  String fullName;
  String inn;
  String kpp;
  String adressLegal; // юр адрес
  String adressActual; // факт адрес
  String phone;
  String email;
  String orientir;
  List<KontaktPerson> persons;
  List<KontragentSecret> secrets;

  Kontragent({this.guid, this.code, this.name, this.fullName, this.inn, this.kpp, this.adressLegal, this.adressActual, this.email, this.orientir, this.phone, this.persons, this.secrets});

  factory Kontragent.fromJSON(Map<String, dynamic> json) {

    List<dynamic> _tmp = json['secrets'] == null ? [] : json['secrets'];
    List<KontragentSecret> secrets = List<KontragentSecret>();
    if (_tmp != null) {
      for (var item in _tmp) {
        secrets.add(KontragentSecret.fromJSON(item));
      }
    }

    _tmp = json['persons'] == null ? [] : json['persons'];
    List<KontaktPerson> persons = List<KontaktPerson>();
    if (_tmp != null) {
      for (var item in _tmp) {
        persons.add(KontaktPerson.fromJSON(item));
      }
    }

    return Kontragent(
      guid: json["guid"],
      code: json["code"],
      name: json["name"],
      fullName: json["fullName"],
      inn: json["inn"],
      kpp: json["kpp"],
      adressLegal: json["adressLegal"],
      adressActual: json["adressActual"],
      email: json["email"],
      orientir: json["orientir"],
      phone: json["phone"],
      persons: persons,
      secrets: secrets,
    );
  }

  Map<String, dynamic> toJson() => {
        "guid": guid,
        "code": code,
        "name": name,
        "fullName": fullName,
        "inn": inn,
        "kpp": kpp,
        "adressLegal": adressLegal,
        "adressActual": adressActual,
        "email": email,
        "orientir": orientir,
        "phone": phone,
        "persons": json.encode(persons),
        "secrets": json.encode(secrets),
    };

}

class KontaktPerson {

  String name;
  String position;
  String phone;
  String workPhone;

  KontaktPerson({this.name, this.position, this.phone, this.workPhone});

  factory KontaktPerson.fromJSON(Map<String, dynamic> json) {
    return KontaktPerson(
      name: json["name"],
      position: json["position"],
      phone: json["phone"],
      workPhone: json["workPhone"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "position": position,
        "phone": phone,
        "workPhone": workPhone,
    };

}

class KontragentSecret {

  String type;
  String text;
  String login;
  String password;
  String email;

  KontragentSecret({this.type, this.text, this.login, this.password, this.email});

  factory KontragentSecret.fromJSON(Map<String, dynamic> json) {
    return KontragentSecret(
      type: json["type"],
      text: json["text"],
      login: json["login"],
      password: json["password"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "text": text,
        "login": login,
        "password": password,
        "email": email,
    };

}