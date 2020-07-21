import 'linkItem.dart';

class Kontakt {
  String guid;
  int number;
  String status;
  String text;

  DateTime date;

  LinkItem kontragent;
  LinkItem kontragentUser;
  LinkItem vid;
  LinkItem sposob;
  LinkItem infoSource;
  LinkItem theme;
  LinkItem sotrudnik;
  LinkItem author;

  bool isAuthor;
  bool loaded;

  Kontakt({
    this.guid,
    this.number,
    this.status,
    this.text,
    this.date,
    this.kontragent,
    this.kontragentUser,
    this.vid,
    this.sposob,
    this.infoSource,
    this.theme,
    this.sotrudnik,
    this.author,
    this.isAuthor,
    this.loaded = false,
  });

  bool operator ==(other) => other.guid == guid;

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'number': number,
      'status': status,
      'text': text,
      'date': date?.toString(),
      'kontragent': kontragent?.toJson(),
      'kontragentUser': kontragentUser?.toJson(),
      'vid': vid?.toJson(),
      'sposob': sposob?.toJson(),
      'infoSource': infoSource?.toJson(),
      'theme': theme?.toJson(),
      'sotrudnik': sotrudnik?.toJson(),
      'author': author?.toJson(),
      'isAuthor': isAuthor,
    };
  }

  factory Kontakt.fromJSON(Map<String, dynamic> map) {
    if (map == null) return null;

    return Kontakt(
      guid: map['guid'],
      number: map['number'],
      status: map['status'],
      text: map['text'],
      date: DateTime.parse(map['date']),
      kontragent: LinkItem.fromJSON(map['kontragent']),
      kontragentUser: LinkItem.fromJSON(map['kontragentUser']),
      vid: LinkItem.fromJSON(map['vid']),
      sposob: LinkItem.fromJSON(map['sposob']),
      infoSource: LinkItem.fromJSON(map['infoSource']),
      theme: LinkItem.fromJSON(map['theme']),
      sotrudnik: LinkItem.fromJSON(map['sotrudnik']),
      author: LinkItem.fromJSON(map['author']),
      isAuthor: map['isAuthor'],
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class KontaktTemplate {
  String name;

  LinkItem vid;
  LinkItem theme;
  LinkItem sposob;
  LinkItem infoSource;
  String text;

  KontaktTemplate({
    this.name,
    this.vid,
    this.theme,
    this.sposob,
    this.infoSource,
    this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'group': vid?.toJson(),
      'theme': theme?.toJson(),
      'sposob': sposob?.toJson(),
      'infoSource': infoSource?.toJson(),
      'text': text,
    };
  }

  factory KontaktTemplate.fromJSON(Map<String, dynamic> map) {
    if (map == null) return null;

    return KontaktTemplate(
      name: map['name'],
      text: map['text'],
      vid: LinkItem.fromJSON(map['vid']),
      theme: LinkItem.fromJSON(map['theme']),
      sposob: LinkItem.fromJSON(map['sposob']),
      infoSource: LinkItem.fromJSON(map['infoSource']),
    );
  }
}
