import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Data/Logger.dart';
import 'package:mobile_kaskad/Models/Recipient.dart';
import 'package:mobile_kaskad/Models/filters.dart';
import 'package:mobile_kaskad/Models/kontakt.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/linkItem.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/projectTask.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Models/woker.dart';
import 'package:mobile_kaskad/Structures/Preferences/Preferences.dart';
import 'package:mobile_kaskad/Structures/Profile/Profile.dart';

typedef OnError = void Function(String error);

class Connection {
  static bool isProduction = bool.fromEnvironment('dart.vm.product');
  static int timeOut = 5;

  static String url = 'http://62.148.143.24:81/kaskad/hs/mobile';

  static FutureOr<http.Response> onTimeout() {
    Logger.log('time out');

    return http.Response('time out', 504);
  }

  static Future<List<User>> getAuthList() async {
    List<User> users = <User>[];

    Logger.log('getting auth list');
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
      Logger.warning(e);
    }

    return users;
  }

  static sendToken() async {
    User user = Data.curUser;
    Settings settings = await Preferences.getSettings();
    try {
      final response = await http.get(
        '$url/auth?token=${Data.token}&birthday=${settings.remindOnBirthday}',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        Logger.log('token sent');
        var userFields = json.decode(response.body);
        user.guid = userFields["guid"];
        user.individualGuid = userFields["individualGuid"];
        user.firstname = userFields["firstname"];
        user.lastname = userFields["lastname"];
        user.secondname = userFields["secondname"];
        user.position = userFields["position"];
        user.subdivision = userFields["subdivision"];
        DBProvider.db.updateUser(user);
      } else if (response.statusCode == 401) {
        Profile.logOut(mainWidgetKey.currentContext, close: false);
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }
  }

  static logOut() async {
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/auth/logout?token=${Data.token}',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        Logger.log('logouted');
      }
    } catch (e) {
      Logger.warning(e);
    }
  }

  // message

  static Future<List<Message>> getMessageList(bool isPublicate,
      {String lastNum, String firstNum, bool justNew, bool sent}) async {
    Logger.log('getting messages');
    List<Message> msgs = List<Message>();
    User user = Data.curUser;
    String _lastNum = lastNum == null ? '' : '&lastNum=$lastNum';
    String _firstNum = firstNum == null ? '' : '&firstNum=$firstNum';
    String _justNew = justNew == null ? '' : '&justNew=$justNew';
    String _sent = sent == null ? '' : '&sent=$sent';
    try {
      final response = await http.get(
        '$url/messages/inbox?isPublicate=$isPublicate' +
            _lastNum +
            _firstNum +
            _justNew +
            _sent,
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        if (response.body != "[]") {
          var parsedUsersList = json.decode(response.body);
          parsedUsersList.forEach((msg) {
            msgs.add(Message.fromJSON(msg));
          });
        }
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return msgs;
  }

  static Future<Map<String, dynamic>> getMessageCount() async {
    Map<String, dynamic> count = Map<String, dynamic>();
    User user = Data.curUser;
    Logger.log("getting message count");
    try {
      final response = await http.get(
        '$url/message_count',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        count = json.decode(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return count;
  }

  static Future<Message> getMessage(String guid) async {
    Message msg = Message();
    Logger.log('getting message');
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/messages/$guid',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        msg = Message.fromJSON(json.decode(response.body));
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
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
      Logger.warning(e);
    }

    return false;
  }

  static Future<bool> setReadAll(bool isPublicate) async {
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/messages/read/all?isPublicate=$isPublicate',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      Logger.warning(e);
    }

    return false;
  }

  static Future<List<Recipient>> getRecipientList() async {
    List<Recipient> list = List<Recipient>();
    User user = Data.curUser;
    Logger.log('getting recipient list');
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
      Logger.warning(e);
    }

    return list;
  }

  static Future<List<String>> getUsersInList(String listId) async {
    List<String> list = List<String>();
    User user = Data.curUser;
    Logger.log('getting users in list');
    try {
      final response = await http.get(
        '$url/message/usersinlist?list_id=$listId',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);
      if (response.statusCode == 200) {
        var parsedList = json.decode(response.body);
        parsedList.forEach((item) {
          list.add(item);
        });
      }
    } catch (e) {
      Logger.warning(e);
    }

    return list;
  }

  static Future<bool> sendMessage(Message msg) async {
    User user = Data.curUser;
    var body = {
      'title': msg.title,
      'text': msg.text,
      'isPublicate': msg.isPublicite,
      'formattedText': msg.formattedText,
      'to': msg.to,
      'images': msg.images,
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
      Logger.warning(e);
    }

    return false;
  }

  // kontragent

  static Future<List<Kontragent>> searchKontragent(String query) async {
    List<Kontragent> list = List<Kontragent>();
    User user = Data.curUser;
    Logger.log('searching Kontragent');
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
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return list;
  }

  static Future<Kontragent> getKontragent(String id) async {
    User user = Data.curUser;
    Kontragent kontr;
    Logger.log('getting Kontragent');
    try {
      final response = await http.get(
        '$url/partner/$id',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        kontr = Kontragent.fromJSON(json.decode(response.body));
      }
    } catch (e) {
      Logger.warning(e);
    }

    return kontr;
  }

  static Future<List<dynamic>> getKontragentDogovors(String id) async {
    User user = Data.curUser;
    var result;
    Logger.log('getting Dogovors');
    try {
      final response = await http.get(
        '$url/partner/$id/dogovors',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = json.decode(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<List<dynamic>> getKontragentProducts(String id) async {
    User user = Data.curUser;
    var result;
    Logger.log('getting Products');
    try {
      final response = await http.get(
        '$url/partner/$id/products',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = json.decode(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<List<KontragentSettlement>> getKontragentSettlement(
      String id) async {
    List<KontragentSettlement> list = List<KontragentSettlement>();
    User user = Data.curUser;
    Logger.log('getting KontragentSettlement');
    try {
      final response = await http.get(
        '$url/settlements/$id',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = json.decode(response.body);
        parsedList.forEach((item) {
          list.add(KontragentSettlement.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return list;
  }

  // workers

  static Future<List<Woker>> getWorkers() async {
    List<Woker> list = List<Woker>();
    User user = Data.curUser;
    Logger.log('getting Workers');
    try {
      final response = await http.get(
        '$url/users',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = json.decode(response.body);
        parsedList.forEach((item) {
          list.add(Woker.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return list;
  }

  // custom link

  static Future<Map<String, dynamic>> getCustomLink(
      String type, String id) async {
    User user = Data.curUser;
    Logger.log('getting $type');
    try {
      final response = await http.get(
        '$url/link?type=$type&id=$id',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return null;
  }

  static Future<List<LinkItem>> getListPiker(String type,
      {String query = "",
      String last = "",
      String fields = "",
      int length = 100,
      LinkItem owner}) async {
    List<LinkItem> list = List<LinkItem>();
    User user = Data.curUser;
    Logger.log('getting picker list');
    String _owner = owner == null ? "" : json.encode(owner);
    try {
      final response = await http.get(
        '$url/picker?query=$query&type=$type&last=$last&fields=$fields&length=$length&owner=$_owner',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = json.decode(response.body);
        parsedList.forEach((item) {
          list.add(LinkItem.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return list;
  }

  // tasks

  static Future<List<Task>> getTasks({
    TaskFilter filter,
    String last = "",
  }) async {
    List<Task> list = List<Task>();
    User user = Data.curUser;
    Logger.log('getting Tasks');
    var _kontragent = filter.kontragent == null || filter.kontragent.isEmpty
        ? ''
        : jsonEncode(filter.kontragent?.toJson());
    var _theme = filter.theme == null || filter.theme.isEmpty
        ? ''
        : jsonEncode(filter.theme?.toJson());
    var _group = filter.group == null || filter.group.isEmpty
        ? ''
        : jsonEncode(filter.group?.toJson());
    var _executer = filter.executer == null || filter.executer.isEmpty
        ? ''
        : jsonEncode(filter.executer?.toJson());
    var status = filter.statusString == 'все' ? '' : filter.statusString;
    try {
      final response = await http.get(
        '$url/tasks?forMe=${filter.forMe}&status=$status&lastNum=$last&kontragent=$_kontragent&theme=$_theme&group=$_group&executor=$_executer',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = jsonDecode(response.body);
        parsedList.forEach((item) {
          list.add(Task.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e.toString());
    }

    return list;
  }

  static Future<Task> getTask(String guid) async {
    Task task = Task();
    Logger.log('getting task');
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/tasks/$guid',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        task = Task.fromJSON(json.decode(response.body));
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return task;
  }

  static Future<bool> setTaskStatus(String guid, String status,
      {String comment = '', String executer = '', OnError onError}) async {
    bool result = false;
    Logger.log('setting task status');
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/tasks/setstatus?id=$guid&status=$status&comment=$comment&executer=$executer',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = true;
      } else {
        Logger.error(response.body);
        onError(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<String> saveTask(
      {@required Task task, bool authorInfo = true, OnError onError}) async {
    String result = '';
    Logger.log('saving task');
    User user = Data.curUser;
    String releaseBefore =
        DateFormat("yyyyMMddHHmmss").format(task.releaseBefore);
    try {
      final response = await http.get(
        '$url/tasks/save?id=${task.guid}&status=${task.status}&text=${task.text}&authorInfo=$authorInfo' +
            '&releaseBefore=$releaseBefore&kontragent=${task.kontragent.guid}&kontragentUser=${task.kontragentUser.guid}' +
            '&group=${task.group.guid}&theme=${task.theme.guid}&executer=${task.executer.guid}',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = response.body;
      } else {
        Logger.error(response.body);
        onError(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<String> getTaskCount() async {
    String result = '';
    Logger.log('getting task count');
    User user = Data.curUser;

    try {
      final response = await http.get(
        '$url/tasks/count',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = response.body;
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<List<TaskTemplate>> getTaskTemplates() async {
    List<TaskTemplate> result = List<TaskTemplate>();
    Logger.log('getting task templates');
    User user = Data.curUser;

    try {
      final response = await http.get(
        '$url/tasks/templates',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = jsonDecode(response.body);
        parsedList.forEach((item) {
          result.add(TaskTemplate.fromJSON(item));
        });
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  // kontakts

  static Future<List<Kontakt>> getKontakts({
    KontaktFilter filter,
    int last = 0,
  }) async {
    List<Kontakt> list = List<Kontakt>();
    User user = Data.curUser;
    Logger.log('getting Kontakts');
    var _kontragent = filter.kontragent == null || filter.kontragent.isEmpty
        ? ''
        : jsonEncode(filter.kontragent?.toJson());
    var _theme = filter.theme == null || filter.theme.isEmpty
        ? ''
        : jsonEncode(filter.theme?.toJson());
    var _vid = filter.vid == null || filter.vid.isEmpty
        ? ''
        : jsonEncode(filter.vid?.toJson());
    var _sotrudnik = filter.sotrudnik == null || filter.sotrudnik.isEmpty
        ? ''
        : jsonEncode(filter.sotrudnik?.toJson());
    var _sposob = filter.sposob == null || filter.sposob.isEmpty
        ? ''
        : jsonEncode(filter.sposob?.toJson());
    var _infoSource = filter.infoSource == null || filter.infoSource.isEmpty
        ? ''
        : jsonEncode(filter.infoSource?.toJson());
    var status = filter.statusString == 'все' ? '' : filter.statusString;
    try {
      final response = await http.get(
        '$url/kontakts?status=$status&lastNum=$last&kontragent=$_kontragent&theme=$_theme&vid=$_vid&sotrudnik=$_sotrudnik&sposob=$_sposob&infoSource=$_infoSource',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = jsonDecode(response.body);
        parsedList.forEach((item) {
          list.add(Kontakt.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e.toString());
    }

    return list;
  }

  static Future<Kontakt> getKontakt(String guid) async {
    Kontakt task = Kontakt();
    Logger.log('getting Kontakt');
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/kontakts/$guid',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        task = Kontakt.fromJSON(json.decode(response.body));
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return task;
  }

  static Future<String> saveKontakt(
      {@required Kontakt kontakt, OnError onError}) async {
    String result = '';
    Logger.log('saving kontakt');
    User user = Data.curUser;

    try {
      final response = await http.get(
        '$url/kontakts/save?id=${kontakt.guid}&status=${kontakt.status}&text=${kontakt.text}' +
            '&kontragent=${kontakt.kontragent.guid}&kontragentUser=${kontakt.kontragentUser.guid}' +
            '&vid=${kontakt.vid.guid}&theme=${kontakt.theme.guid}&sotrudnik=${kontakt.sotrudnik.guid}' +
            '&sposob=${kontakt.sposob.guid}&infoSource=${kontakt.infoSource.guid}',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = response.body;
      } else {
        Logger.error(response.body);
        onError(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<List<KontaktTemplate>> getKontaktTemplates() async {
    List<KontaktTemplate> result = List<KontaktTemplate>();
    Logger.log('getting kontakt templates');
    User user = Data.curUser;

    try {
      final response = await http.get(
        '$url/kontakts/templates',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = jsonDecode(response.body);
        parsedList.forEach((item) {
          result.add(KontaktTemplate.fromJSON(item));
        });
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  // projects

  static Future<List<ProjectTask>> getProjctTasks({
    ProjectFilter filter,
    int last = 0,
  }) async {
    List<ProjectTask> list = List<ProjectTask>();
    User user = Data.curUser;
    Logger.log('getting Tasks');
    var project = filter.project == null || filter.project.isEmpty
        ? ''
        : jsonEncode(filter.project?.toJson());
    var executer = filter.executer == null || filter.executer.isEmpty
        ? ''
        : jsonEncode(filter.executer?.toJson());
    var status = filter.statusString == 'все' ? '' : filter.statusString;
    try {
      final response = await http.get(
        '$url/projects?type=${filter.type}&forMe=${filter.forMe}&forMyProjects=${filter.forMyProjects}&status=$status&lastNum=$last&project=$project&executer=$executer',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = jsonDecode(response.body);
        parsedList.forEach((item) {
          list.add(ProjectTask.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e.toString());
    }

    return list;
  }

  static Future<List<ProjectTaskGroup>> getProjctTasksGroup({
    ProjectFilter filter,
  }) async {
    List<ProjectTaskGroup> list = List<ProjectTaskGroup>();
    User user = Data.curUser;
    Logger.log('getting Tasks');
    var project = filter.project == null || filter.project.isEmpty
        ? ''
        : jsonEncode(filter.project?.toJson());
    var executer = filter.executer == null || filter.executer.isEmpty
        ? ''
        : jsonEncode(filter.executer?.toJson());
    var status = filter.statusString == 'все' ? '' : filter.statusString;
    try {
      final response = await http.get(
        '$url/projects?type=${filter.type}&forMe=${filter.forMe}&forMyProjects=${filter.forMyProjects}&status=$status&project=$project&executer=$executer',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        var parsedList = jsonDecode(response.body);
        parsedList.forEach((item) {
          list.add(ProjectTaskGroup.fromJSON(item));
        });
      } else {
        Logger.warning(response.body);
      }
    } catch (e) {
      Logger.warning(e.toString());
    }

    return list;
  }

  static Future<ProjectTask> getProjectTask(String guid, bool isBug) async {
    ProjectTask task = ProjectTask();
    Logger.log('getting project task');
    User user = Data.curUser;
    try {
      final response = await http.get(
        '$url/projects/$guid/$isBug',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        task = ProjectTask.fromJSON(json.decode(response.body));
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return task;
  }

  static Future<String> getProjectCount() async {
    String result = '';
    Logger.log('getting project count');
    User user = Data.curUser;

    try {
      final response = await http.get(
        '$url/projects/count',
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = response.body;
      } else {
        Logger.error(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<String> saveProjectTask(
      {@required ProjectTask task,
      bool statusChanged = true,
      OnError onError}) async {
    String result = '';
    Logger.log('saving project task');
    User user = Data.curUser;
    String releaseBefore = DateFormat("yyyyMMdd").format(task.releaseBefore);
    try {
      final response = await http.post(
        '$url/projects/save',
        body: jsonEncode(<String, String>{
          'id': task.guid,
          'status': task.status,
          'isBug': task.isBug.toString(),
          'isChange': statusChanged.toString(),
          'executer': task.executer.guid,
          'tester': task.tester.guid,
          'metodist': task.metodist.guid,
          'project': task.project.guid,
          'text': task.text,
          'resolutionText': task.resolutionText,
          'siteText': task.siteText,
          'isToSite': task.isToSite.toString(),
          'name': task.name,
          'releaseBefore': releaseBefore,
        }),
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);
      // final response = await http.get(
      //   '$url/projects/save?id=${task.guid}&status=${task.status}&isBug=${task.isBug}' +
      //       '&isChange=$statusChanged' +
      //       '&executer=${task.executer}' +
      //       '&tester=${task.tester}' +
      //       '&metodist=${task.metodist}' +
      //       '&project=${task.project}' +
      //       '&text=${task.text}' +
      //       '&resolutionText=${task.resolutionText}' +
      //       '&siteText=${task.siteText}' +
      //       '&isToSite=${task.isToSite}' +
      //       '&name=${task.name}' +
      //       '&releaseBefore=$releaseBefore',
      //   headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      // ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = response.body;
      } else {
        Logger.error(response.body);
        onError(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }

  static Future<String> saveNewProjectTask(
      {@required ProjectTask task, OnError onError}) async {
    String result = '';
    Logger.log('saving new project task');
    User user = Data.curUser;
    String releaseBefore = DateFormat("yyyyMMdd").format(task.releaseBefore);
    try {
      final response = await http.post(
        '$url/projects/new',
        body: jsonEncode(<String, String>{
          'status': task.status,
          'isBug': task.isBug.toString(),
          'executer': task.executer.guid,
          'project': task.project.guid,
          'text': task.text,
          'name': task.name,
          'releaseBefore': releaseBefore,
        }),
        headers: {HttpHeaders.authorizationHeader: "Basic ${user.password}"},
      ).timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

      if (response.statusCode == 200) {
        result = response.body;
      } else {
        Logger.error(response.body);
        onError(response.body);
      }
    } catch (e) {
      Logger.warning(e);
    }

    return result;
  }
}
