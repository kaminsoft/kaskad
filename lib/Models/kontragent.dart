
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

  Kontragent({this.guid, this.code, this.name, this.fullName, this.inn, this.kpp, this.adressLegal, this.adressActual, this.email, this.orientir, this.phone});

  factory Kontragent.fromJSON(Map<String, dynamic> json) {
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
    };

}