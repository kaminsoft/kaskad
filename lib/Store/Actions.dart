import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Models/filters.dart';
import 'package:mobile_kaskad/Models/kontakt.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';
import 'package:mobile_kaskad/Structures/Preferences/Preferences.dart';
import 'package:toast/toast.dart';

// Settings
class SetBottomBar extends ReduxAction<AppState> {
  final bool bottomBar;

  SetBottomBar(this.bottomBar);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    newState.settings.bottomBar = bottomBar;
    for (var feature in newState.features) {
      if (feature.role == FeatureRole.message ||
          feature.role == FeatureRole.publicate) {
        feature.enabled = !bottomBar;
      }
    }
    DBProvider.db.saveFeatures(newState.features);
    Preferences.saveSettings(newState.settings);
    return newState;
  }
}

class SetTheme extends ReduxAction<AppState> {
  final String theme;

  SetTheme(this.theme);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    newState.settings.theme = theme;
    Preferences.saveSettings(newState.settings);
    return newState;
  }
}

class SetRemindOnBirthday extends ReduxAction<AppState> {
  final bool remindOnBirthday;

  SetRemindOnBirthday(this.remindOnBirthday);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    newState.settings.remindOnBirthday = remindOnBirthday;
    Preferences.saveSettings(newState.settings);
    await Connection.sendToken();
    return newState;
  }
}

class SetSettings extends ReduxAction<AppState> {
  final Settings settings;

  SetSettings(this.settings);

  @override
  AppState reduce() {
    AppState newState = AppState.copy(state);
    newState.settings = settings;
    if (state.settings.bottomBar != settings.bottomBar) {
      for (var feature in newState.features) {
        if (feature.role == FeatureRole.message ||
            feature.role == FeatureRole.publicate) {
          feature.enabled = !settings.bottomBar;
        }
      }
      DBProvider.db.saveFeatures(newState.features);
    }
    Preferences.saveSettings(settings);
    return newState;
  }
}

class LogIn extends ReduxAction<AppState> {
  final User user;

  LogIn(this.user);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    newState.features = List<Feature>.from(getInitialFeatureList());
    newState.user = user;
    Data.curUser = user;
    DBProvider.db.addUser(user);
    DBProvider.db.saveFeatures(newState.features);
    return newState;
  }
}

class LogOut extends ReduxAction<AppState> {
  LogOut();

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    DBProvider.db.deleteUser();
    newState.user = null;
    Data.curUser = null;
    return newState;
  }
}

// message

class UpdateMessageTaskCount extends ReduxAction<AppState> {
  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    Map<String, dynamic> count = await Connection.getMessageCount();
    newState.msgCount = count["msg"];
    newState.postCount = count["post"];

    bool tasksEnabled =
        newState.features.firstWhere((f) => f.role == FeatureRole.task) != null;

    newState.taskCount = '';
    if (tasksEnabled) {
      newState.taskCount = await Connection.getTaskCount();
    }

    return newState;
  }
}

class UpdateMessageCount extends ReduxAction<AppState> {
  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    Map<String, dynamic> count = await Connection.getMessageCount();
    newState.msgCount = count["msg"];
    newState.postCount = count["post"];
    print("${newState.msgCount} ${newState.postCount}");
    return newState;
  }
}

class SetMessageRead extends ReduxAction<AppState> {
  final Message msg;

  SetMessageRead(this.msg);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    await Connection.setMessageRead(msg.guid);
    Map<String, dynamic> count = await Connection.getMessageCount();
    newState.msgCount = count["msg"];
    newState.postCount = count["post"];
    Message tmp;
    if (msg.isPublicite) {
      tmp = newState.messagesP.firstWhere((m) => m.guid == msg.guid);
    } else {
      tmp = newState.messages.firstWhere((m) => m.guid == msg.guid);
    }
    tmp.status = 'Прочитано';
    return newState;
  }
}

class SetReadAll extends ReduxAction<AppState> {
  final bool isPublicate;

  SetReadAll(this.isPublicate);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    await Connection.setReadAll(isPublicate);
    newState.msgCount = 0;
    newState.postCount = 0;

    if (isPublicate) {
      newState.messagesP
          .where((m) => m.status != 'Прочитано')
          .forEach((m) => m.status = 'Прочитано');
    } else {
      newState.messages
          .where((m) => m.status != 'Прочитано')
          .forEach((m) => m.status = 'Прочитано');
    }
    return newState;
  }
}

class LoadMessages extends ReduxAction<AppState> {
  final bool isPublicate;
  final bool justNew;
  final bool sent;
  LoadMessages(this.isPublicate, {this.justNew = false, this.sent = false});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    if (isPublicate) {
      newState.messagesP =
          await Connection.getMessageList(true, justNew: justNew, sent: sent);
    } else {
      newState.messages =
          await Connection.getMessageList(false, justNew: justNew, sent: sent);
    }
    return newState;
  }
}

class UpdateMessages extends ReduxAction<AppState> {
  final bool isPublicate;
  final bool addBefore;
  final bool justNew;
  final bool sent;

  UpdateMessages(this.isPublicate,
      {this.addBefore = false, this.justNew = false, this.sent = false});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);

    if (isPublicate) {
      if (newState.messagesP.isEmpty) {
        return null;
      }
      var msgs = await Connection.getMessageList(isPublicate,
          justNew: justNew,
          sent: sent,
          lastNum: addBefore ? null : newState.messagesP.last.number,
          firstNum: newState.messagesP.first.number);
      if (addBefore) {
        newState.messagesP.insertAll(0, msgs);
      } else {
        newState.messagesP.addAll(msgs);
      }
    } else {
      if (newState.messages.isEmpty) {
        return null;
      }
      var msgs = await Connection.getMessageList(isPublicate,
          justNew: justNew,
          sent: sent,
          lastNum: addBefore ? null : newState.messages.last.number,
          firstNum: newState.messages.first.number);
      if (addBefore) {
        newState.messages.insertAll(0, msgs);
      } else {
        newState.messages.addAll(msgs);
      }
    }
    return newState;
  }
}

class AddMessage extends ReduxAction<AppState> {
  final Message message;
  AddMessage(this.message);

  @override
  FutureOr<AppState> reduce() {
    AppState newState = AppState.copy(state);
    newState.messages.insert(0, message);
    return newState;
  }
}

class ClearMessages extends ReduxAction<AppState> {
  final bool isPublicate;

  ClearMessages(this.isPublicate);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    if (isPublicate) {
      newState.messagesP.clear();
    } else {
      newState.messages.clear();
    }
    return newState;
  }
}

// features

class UpdateFeatures extends ReduxAction<AppState> {
  final List<Feature> features;

  UpdateFeatures(this.features);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    DBProvider.db.saveFeatures(features);
    newState.features = List<Feature>.from(features);
    return newState;
  }
}

class ReorderFeatures extends ReduxAction<AppState> {
  final int oldIndex;
  final int newIndex;

  ReorderFeatures(this.oldIndex, this.newIndex);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    var item = newState.features.removeAt(oldIndex);
    newState.features.insert(newIndex, item);
    DBProvider.db.saveFeatures(newState.features);
    return newState;
  }
}

class AfterEditFeatures extends ReduxAction<AppState> {
  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);

    var tmp =
        List<Feature>.from(newState.features.where((t) => t.enabled).toList());
    tmp.addAll(newState.features.where((t) => !t.enabled).toList());
    newState.features = tmp;
    DBProvider.db.saveFeatures(newState.features);
    return newState;
  }
}

class AddFeature extends ReduxAction<AppState> {
  final Feature feature;

  AddFeature(this.feature);

  @override
  FutureOr<AppState> reduce() {
    AppState newState = AppState.copy(state);
    feature.enabled = true;
    DBProvider.db.saveFeatures(newState.features);
    return newState;
  }
}

class RemoveFeature extends ReduxAction<AppState> {
  final Feature feature;

  RemoveFeature(this.feature);

  @override
  FutureOr<AppState> reduce() {
    AppState newState = AppState.copy(state);
    feature.enabled = false;
    DBProvider.db.saveFeatures(newState.features);
    return newState;
  }
}

// kontragents

class AddKontragent extends ReduxAction<AppState> {
  final Kontragent kontragent;
  final bool fromServer;

  AddKontragent(this.kontragent, {this.fromServer = true});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    Kontragent newKontr;
    if (fromServer) {
      newKontr = await Connection.getKontragent(kontragent.guid);
    } else {
      newKontr = kontragent;
    }

    if (newKontr == null) {
      return null;
    } else {
      newState.kontragents.removeWhere((k) => k.guid == newKontr.guid);
      newState.kontragents.add(newKontr);
    }
    newState.kontragents.sort((a, b) => a.name.compareTo(b.name));
    DBProvider.db.saveKontragents(newState.kontragents);
    return newState;
  }
}

class RemoveKontragent extends ReduxAction<AppState> {
  final Kontragent kontragent;

  RemoveKontragent(this.kontragent);

  @override
  FutureOr<AppState> reduce() {
    AppState newState = AppState.copy(state);

    newState.kontragents.removeWhere((k) => k.guid == kontragent.guid);
    DBProvider.db.saveKontragents(newState.kontragents);
    return newState;
  }
}

// tasks
class GetTasks extends ReduxAction<AppState> {
  bool clearLoad;
  TaskFilter filter;

  GetTasks({this.clearLoad = true, this.filter});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);

    List<Task> newList = await Connection.getTasks(
        filter: filter, last: clearLoad ? '' : newState.tasks.last.number);

    if (clearLoad) {
      newState.tasks = newList;
    } else {
      newState.tasks.addAll(newList);
    }

    newState.taskListEnded = newList.isEmpty;

    return newState;
  }
}

class SetTaskStatus extends ReduxAction<AppState> {
  String guid;
  String taskStatus;
  String comment;
  String toastText;
  String executer;

  SetTaskStatus(
      {@required this.guid,
      @required this.taskStatus,
      this.comment = '',
      this.toastText = '',
      this.executer = ''});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    bool success = await Connection.setTaskStatus(guid, taskStatus,
        comment: comment, executer: executer, onError: (error) {
      Toast.show(
        error,
        mainWidgetKey.currentContext,
        gravity: Toast.BOTTOM,
        duration: 5,
      );
    });
    if (success) {
      int index = newState.tasks.indexWhere((element) => element.guid == guid);
      newState.tasks[index].status = taskStatus;
      if (toastText.isNotEmpty) {
        Toast.show(
          toastText,
          mainWidgetKey.currentContext,
          gravity: Toast.BOTTOM,
          duration: 5,
        );
      }
    }
    return newState;
  }
}

class SaveTask extends ReduxAction<AppState> {
  Task task;
  bool authorInfo;
  SaveTask({@required this.task, this.authorInfo = true});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    String guid = await Connection.saveTask(
        task: task,
        authorInfo: authorInfo,
        onError: (error) {
          Toast.show(
            error,
            mainWidgetKey.currentContext,
            gravity: Toast.BOTTOM,
            duration: 5,
          );
        });
    if (guid.isNotEmpty) {
      Task newTask = await Connection.getTask(guid);
      if (task.guid.isEmpty) {
        newState.tasks.insert(0, newTask);
      } else {
        int index =
            newState.tasks.indexWhere((element) => element.guid == guid);
        newState.tasks[index] = newTask;
      }
    }
    return newState;
  }
}

class UpdateTask extends ReduxAction<AppState> {
  String guid;

  UpdateTask({@required this.guid});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    int index = newState.tasks.indexWhere((element) => element.guid == guid);
    Task newTask = await Connection.getTask(guid);
    newTask.loaded = true;
    if (index == -1) {
      newState.tasks.insert(0, newTask);
    } else {
      newState.tasks[index] = newTask;
    }
    return newState;
  }
}

class UpdateTaskCount extends ReduxAction<AppState> {
  UpdateTaskCount();

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    bool tasksEnabled =
        newState.features.firstWhere((f) => f.role == FeatureRole.task) != null;

    newState.taskCount = '';
    if (tasksEnabled) {
      newState.taskCount = await Connection.getTaskCount();
    }

    return newState;
  }
}

// kontakts
class GetKontakts extends ReduxAction<AppState> {
  bool clearLoad;
  KontaktFilter filter;

  GetKontakts({this.clearLoad = true, this.filter});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);

    List<Kontakt> newList = await Connection.getKontakts(
        filter: filter, last: clearLoad ? 0 : newState.kontakts.last.number);

    if (clearLoad) {
      newState.kontakts = newList;
    } else {
      newState.kontakts.addAll(newList);
    }

    newState.kontaktListEnded = newList.isEmpty;

    return newState;
  }
}

class UpdateKontakt extends ReduxAction<AppState> {
  String guid;

  UpdateKontakt({@required this.guid});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    int index = newState.kontakts.indexWhere((element) => element.guid == guid);
    Kontakt newKontakt = await Connection.getKontakt(guid);
    newKontakt.loaded = true;
    if (index == -1) {
      newState.kontakts.insert(0, newKontakt);
    } else {
      newState.kontakts[index] = newKontakt;
    }
    return newState;
  }
}

class SaveKontakt extends ReduxAction<AppState> {
  Kontakt kontakt;

  SaveKontakt({@required this.kontakt});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    String guid = await Connection.saveKontakt(
        kontakt: kontakt,
        onError: (error) {
          Toast.show(
            error,
            mainWidgetKey.currentContext,
            gravity: Toast.BOTTOM,
            duration: 5,
          );
        });
    if (guid.isNotEmpty) {
      Kontakt newKontakt = await Connection.getKontakt(guid);
      if (kontakt.guid.isEmpty) {
        newState.kontakts.insert(0, newKontakt);
      } else {
        int index =
            newState.kontakts.indexWhere((element) => element.guid == guid);
        newState.kontakts[index] = newKontakt;
      }
    }
    return newState;
  }
}
