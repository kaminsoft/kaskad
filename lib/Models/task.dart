
import 'package:mobile_kaskad/Models/attachment.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';


class Task {
  String guid;
  String number;
  String status;
  String text;
  String comment;

  DateTime date;
  DateTime releaseDate;
  DateTime releaseBefore;

  LinkItem kontragent;
  LinkItem kontragentUser;
  LinkItem group;
  LinkItem theme;
  LinkItem executer;
  LinkItem author;

  bool hasAccess;
  bool isOwner;
  bool isExecuter;
  bool isAuthor;
  bool loaded;

  List<Attachment> attachments;
  Task({
    this.guid,
    this.number,
    this.status,
    this.text,
    this.comment,
    this.date,
    this.releaseDate,
    this.releaseBefore,
    this.kontragent,
    this.kontragentUser,
    this.group,
    this.theme,
    this.executer,
    this.author,
    this.attachments,
    this.hasAccess,
    this.isOwner,
    this.isExecuter,
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
      'comment': comment,
      'date': date?.toString(),
      'releaseDate': releaseDate?.toString(),
      'releaseBefore': releaseBefore?.toString(),
      'kontragent': kontragent?.toJson(),
      'kontragentUser': kontragentUser?.toJson(),
      'group': group?.toJson(),
      'theme': theme?.toJson(),
      'executer': executer?.toJson(),
      'author': author?.toJson(),
      'attachments': attachments?.map((x) => x?.toJson())?.toList(),
      'hasAccess': hasAccess,
      'isOwner': isOwner,
      'isExecuter': isExecuter,
      'isAuthor': isAuthor,
    };
  }

  factory Task.fromJSON(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Task(
      guid: map['guid'],
      number: map['number'],
      status: map['status'],
      text: map['text'],
      comment: map['comment'],
      date: DateTime.parse(map['date']),
      releaseDate: map['releaseDate'] == null ? DateTime.now() : DateTime.parse(map['releaseDate']),
      releaseBefore: DateTime.parse(map['releaseBefore']),
      kontragent: LinkItem.fromJSON(map['kontragent']),
      kontragentUser: LinkItem.fromJSON(map['kontragentUser']),
      group: LinkItem.fromJSON(map['group']),
      theme: LinkItem.fromJSON(map['theme']),
      executer: LinkItem.fromJSON(map['executer']),
      author: LinkItem.fromJSON(map['author']),
      attachments: map['attachments'] == null ? [] : List<Attachment>.from(map['attachments']?.map((x) => Attachment.fromJSON(x))),
      hasAccess: map['hasAccess'],
      isOwner: map['isOwner'],
      isExecuter: map['isExecuter'],
      isAuthor: map['isAuthor'],
    );
  }
}
