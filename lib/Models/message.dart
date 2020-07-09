import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Models/attachment.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';

class Message {
  String guid;
  String number;
  DateTime date;
  String title;
  String text;
  LinkItem from;
  bool isPublicite;
  String status;
  List<LinkItem> to;
  int toCount;
  List<Attachment> attachments;

  bool operator ==(other) => other.guid == guid;

  String getTittle() {
    return title.length > 65 ? title.substring(0, 62) + '...' : title;
  }

  String getText() {
    return text.length > 100 ? text.substring(0, 97) + '...' : text;
  }

  bool isRead() {
    return status == "Прочитано" || status.isEmpty;
  }

  String getAvatarLetter() {
    if (from.name.isEmpty) {
      return "ХЗ";
    }
    var ret = from.name.split(" ");
    if (ret.length >= 2) {
      return "${ret[0][0]}${ret[1][0]}";
    }
    return "ХЗ";
  }

  String getDate() {
    var now = DateTime.now();
    var diff = now.difference(date);
    if (diff.inDays == 0 && now.day == date.day) {
      return DateFormat("HH:mm").format(date);
    } else if ((diff.inDays == 1 || diff.inDays == 0) &&
        now.day - 1 == date.day) {
      return "Вчера";
    }
    initializeDateFormatting();
    return DateFormat.MMMMd('ru').format(date);
  }

  String getSeparatorText() {
    var now = DateTime.now();
    var diff = now.difference(date);
    if (diff.inDays == 0 && now.day == date.day) {
      return "Сегодня";
    } else if ((diff.inDays == 1 || diff.inDays == 0) &&
        now.day - 1 == date.day) {
      return "Вчера";
    }
    initializeDateFormatting();
    return DateFormat.MMMMd('ru').format(date);
  }

  Message(
      {this.guid,
      this.number,
      this.date,
      this.title,
      this.text,
      this.from,
      this.isPublicite,
      this.status,
      this.to,
      this.toCount,
      this.attachments});

  factory Message.fromJSON(Map<String, dynamic> _json) {
    List<dynamic> _to = _json['to'];
    List<LinkItem> to = List<LinkItem>();
    if (_to != null) {
      for (var item in _to) {
        to.add(LinkItem.fromJSON(item));
      }
    }

    List<dynamic> _att = _json['attachments'];
    List<Attachment> att = List<Attachment>();
    if (_att != null) {
      for (var item in _att) {
        att.add(Attachment.fromJSON(item));
      }
    }

    return Message(
      guid: _json["guid"],
      number: _json['number'],
      date: DateTime.parse(_json['date']),
      title: _json['title'],
      text: _json['text'],
      from: LinkItem.fromJSON(_json['from']),
      isPublicite: _json['isPublicite'],
      status: _json['status'],
      to: to,
      toCount: _json['toCount'] ?? 0,
      attachments: att,
    );
  }

  Map<String, dynamic> toJson() => {
        "guid": guid ?? '',
        "number": number ?? '',
        "date": date ?? '',
        "title": title ?? '',
        "text": text ?? '',
        "from": from == null ? '' : from.toJson(),
        "isPublicite": isPublicite ?? '',
        "status": status ?? '',
        "to": to.map((t) => t.toJson()).toList(),
        "toCount": toCount ?? 0,
        "attachments": attachments.map((t) => t.toJson()).toList(),
      };

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class NewMessageCount {
  int message;
  int post;

  NewMessageCount({this.message = 0, this.post = 0});
}
