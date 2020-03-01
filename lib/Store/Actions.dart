import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Store/AppState.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';

class LogIn extends ReduxAction<AppState> {
  final User user;

  LogIn(this.user);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    newState.features = List<Feature>.from(getInitialFeatureList());
    newState.user = user;
    await DBProvider.db.addUser(user);
    await DBProvider.db.saveFeatures(newState.features);
    return newState;
  }
}

class LogOut extends ReduxAction<AppState> {
  LogOut();

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    await DBProvider.db.deleteUser();
    newState.user = null;
    return newState;
  }
}

// message

class UpdateMessageCount extends ReduxAction<AppState> {
  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    newState.messageCount = await Connection.getMessageCount();
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
    newState.messageCount = await Connection.getMessageCount();
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

class LoadMessages extends ReduxAction<AppState> {
  final bool isPublicate;
  LoadMessages(this.isPublicate);

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);
    if (isPublicate) {
      newState.messagesP = await Connection.getMessageList(true);
    } else {
      newState.messages = await Connection.getMessageList(false);
    }
    return newState;
  }
}

class UpdateMessages extends ReduxAction<AppState> {
  final bool isPublicate;
  final bool addBefore;

  UpdateMessages(this.isPublicate, {this.addBefore = false});

  @override
  FutureOr<AppState> reduce() async {
    AppState newState = AppState.copy(state);

    if (isPublicate) {
      var msgs = await Connection.getMessageList(isPublicate,
          lastNum: addBefore ? null : newState.messagesP.last.number,
          firstNum: newState.messagesP.first.number);
      if (addBefore) {
        newState.messagesP.insertAll(0, msgs);
      } else {
        newState.messagesP.addAll(msgs);
      }
    } else {
      var msgs = await Connection.getMessageList(isPublicate,
          lastNum: addBefore ? null : newState.messages.last.number,
          firstNum: newState.messagesP.first.number);
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

  AddKontragent(this.kontragent);

  @override
  FutureOr<AppState> reduce() {
    AppState newState = AppState.copy(state);
    newState.kontragents.add(kontragent);
    newState.kontragents.sort((a,b) => a.name.compareTo(b.name) );
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
