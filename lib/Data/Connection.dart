import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/user.dart';

class Connection {
  static bool isProduction = bool.fromEnvironment('dart.vm.product');
  static int timeOut = 5;

  static String get url => 'http://62.148.143.24:81/kaskadfb/hs/mobile';
  //static String get url => isProduction ? 'http://62.148.143.24:81/kaskadfb/hs/mobile' : 'http://62.148.143.24:81/kaskad/hs/mobile';

  static FutureOr<http.Response> onTimeout() {
    return http.Response('time out', 504);
  }

  static Future<List<User>> getAuthList() async {
    List<User> users = List<User>();
    print('${DateTime.now()} getting auth list');
    try {
      final response = await http.get(
        '$url/users/auth/list',
        headers: {
          HttpHeaders.authorizationHeader:
              "Basic 0JzQsNCy0YDQuNC9INCQLtCQLjo3NDUyNzc="
        },
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedUsersList = json.decode(response.body);
        parsedUsersList.forEach((usr) {
          users.add(User.fromJSON(usr));
        });
      }
    } catch (e) {
      print(e);
    }

    return users;
  }

  static sendToken(String token) async {
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/auth?token=$token',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        print('token sent');
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<List<Message>> getMessageList(bool isPublicate,
      {String lastNum, String firstNum}) async {
    print('${DateTime.now()} getting messages');
    List<Message> msgs = List<Message>();
    User user = Data.curUser;
    String _lastNum = lastNum == null ? '' : '&lastNum=$lastNum';
    String _firstNum = firstNum == null ? '' : '&firstNum=$firstNum';
    try {
      final response = await http.get(
        '$url/messages/inbox?isPublicate=$isPublicate' + _lastNum + _firstNum,
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedUsersList = json.decode(response.body);
        parsedUsersList.forEach((msg) {
          msgs.add(Message.fromJSON(msg));
        });
      }
    } catch (e) {
      print(e);
    }

    return msgs;
  }

  static Future<NewMessageCount> getMessageCount() async {
    NewMessageCount count = NewMessageCount();
    print('${DateTime.now()} getting message count');
    try {
      final response = await http.get(
        '$url/message_count',
        headers: {
          HttpHeaders.authorizationHeader:
              "Basic 0JzQsNCy0YDQuNC9INCQLtCQLjo3NDUyNzc="
        },
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedres = json.decode(response.body);
        count.message = parsedres['msg'];
        count.post = parsedres['post'];
      }
    } catch (e) {
      print(e);
    }

    return count;
  }

  static Future<Message> getMessage(String guid) async {
    Message msg = Message();
    print('${DateTime.now()} getting message');
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/messages/$guid',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        msg = Message.fromJSON(json.decode(response.body));
      }
    } catch (e) {
      print(e);
    }

    return msg;
  }

  static Future<bool> setMessageRead(String guid) async {
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/messages/read/$guid',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  static Future<List<Recipient>> getRecipientList() async {
    List<Recipient> list = List<Recipient>();
    User user = Data.curUser;
    print('${DateTime.now()} getting recipient list');
    try {
      final response = await http.get(
        '$url/message/users',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);
      if (response.statusCode == 200) {
        var parsedList = json.decode(response.body);
        parsedList.forEach((item) {
          list.add(Recipient.fromJSON(item));
        });
      }
    } catch (e) {
      print(e);
    }

    return list;
  }

  static Future<bool> sendMessage(Message msg) async {
    User user = Data.curUser;
    var body = {
      'title': msg.title,
      'text': msg.text,
      'isPublicate': msg.isPublicite,
      'to': msg.to,
    };
    try {
      final response = await http.post(
        '$url/message/send',
        body: json.encode(body),
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  static Future<List<Kontragent>> searchKontragent(String query) async {
    List<Kontragent> list = List<Kontragent>();
    User user = Data.curUser;
    print('${DateTime.now()} searching Kontragent');
    try {
      final response = await http.get(
        '$url/searchpartner?query=$query',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = json.decode(response.body);
        parsedList.forEach((item) {
          list.add(Kontragent.fromJSON(item));
        });
      }
      else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }

    return list;
  }

  static Future<Kontragent> getKontragent(String id) async {
    User user = Data.curUser;
    Kontragent kontr;
    print('${DateTime.now()} getting Kontragent');
    try {
      final response = await http.get(
        '$url/partner/$id',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        kontr = Kontragent.fromJSON(json.decode(response.body));
      }
    } catch (e) {
      print(e);
    }

    return kontr;
  }

  static Future<List<dynamic>> getKontragentDogovors(String id) async {
    User user = Data.curUser;
    var result;
    print('${DateTime.now()} getting Dogovors');
    try {
      final response = await http.get(
        '$url/partner/$id/dogovors',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }

    return result;
  }

  static Future<List<dynamic>> getKontragentProducts(String id) async {
    User user = Data.curUser;
    var result;
    print('${DateTime.now()} getting Products');
    try {
      final response = await http.get(
        '$url/partner/$id/products',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }

    return result;
  }
}
