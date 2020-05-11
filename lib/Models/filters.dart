import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_kaskad/Models/linkItem.dart';

class Filters {
  static Future<TaskFilter> getTaskFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filter = prefs.getString("TaskFilter");
    if (filter == null) {
      return TaskFilter(
          executer: LinkItem(),
          kontragent: LinkItem(),
          group: LinkItem(),
          theme: LinkItem());
    }
    return TaskFilter.fromJson(filter);
  }

  static void saveTaskFilter(TaskFilter filter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("TaskFilter", filter.toJson());
  }
}

class TaskFilter {
  String statusString;
  LinkItem executer;
  LinkItem kontragent;
  LinkItem group;
  LinkItem theme;
  bool forMe;

  TaskFilter({
    this.statusString = "все",
    this.executer,
    this.kontragent,
    this.group,
    this.theme,
    this.forMe = false,
  });

  get statuses => statusString.split(',');
  set status(String newStatus) => statusString = newStatus;

  String toJson() => json.encode(toMap());

  static TaskFilter fromJson(String source) => fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'statusString': statusString,
      'kontragent': kontragent?.toJson(),
      'group': group?.toJson(),
      'theme': theme?.toJson(),
      'forMe': forMe,
    };
  }

  static TaskFilter fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return TaskFilter(
      statusString: map['statusString'],
      kontragent: LinkItem.fromJSON(map['kontragent']),
      group: LinkItem.fromJSON(map['group']),
      theme: LinkItem.fromJSON(map['theme']),
      forMe: map['forMe'],
    );
  }
}
