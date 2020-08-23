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

  static Future<KontaktFilter> getKontaktFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filter = prefs.getString("KontaktFilter");
    if (filter == null) {
      return KontaktFilter(
        sotrudnik: LinkItem(),
        kontragent: LinkItem(),
        vid: LinkItem(),
        theme: LinkItem(),
        sposob: LinkItem(),
        infoSource: LinkItem(),
      );
    }
    return KontaktFilter.fromJson(filter);
  }

  static void saveKontaktFilter(KontaktFilter filter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("KontaktFilter", filter.toJson());
  }

  static Future<ProjectFilter> getProjectFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filter = prefs.getString("ProjectFilter");
    if (filter == null) {
      return ProjectFilter(
        project: LinkItem(),
        executer: LinkItem(),
      );
    }
    return ProjectFilter.fromJson(filter);
  }

  static void saveProjectFilter(ProjectFilter filter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ProjectFilter", filter.toJson());
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

class KontaktFilter {
  String statusString;
  LinkItem sotrudnik;
  LinkItem kontragent;
  LinkItem vid;
  LinkItem sposob;
  LinkItem infoSource;
  LinkItem theme;

  KontaktFilter({
    this.statusString = "все",
    this.sotrudnik,
    this.kontragent,
    this.vid,
    this.theme,
    this.sposob,
    this.infoSource,
  });

  get statuses => statusString.split(',');
  set status(String newStatus) => statusString = newStatus;

  String toJson() => json.encode(toMap());

  static KontaktFilter fromJson(String source) => fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'statusString': statusString,
      'sotrudnik': sotrudnik?.toJson(),
      'kontragent': kontragent?.toJson(),
      'vid': vid?.toJson(),
      'theme': theme?.toJson(),
      'sposob': sposob?.toJson(),
      'infoSource': infoSource?.toJson(),
    };
  }

  static KontaktFilter fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return KontaktFilter(
      statusString: map['statusString'],
      sotrudnik: LinkItem.fromJSON(map['sotrudnik']),
      kontragent: LinkItem.fromJSON(map['kontragent']),
      vid: LinkItem.fromJSON(map['vid']),
      theme: LinkItem.fromJSON(map['theme']),
      sposob: LinkItem.fromJSON(map['sposob']),
      infoSource: LinkItem.fromJSON(map['infoSource']),
    );
  }
}

class ProjectFilter {
  String statusString;
  String type;
  LinkItem executer;
  LinkItem project;
  bool forMe;
  bool forMyProjects;

  ProjectFilter({
    this.statusString = "все",
    this.type = "предложения",
    this.executer,
    this.project,
    this.forMe = true,
    this.forMyProjects = false,
  });

  get statuses => statusString.split(',');
  set status(String newStatus) => statusString = newStatus;

  String toJson() => json.encode(toMap());

  static ProjectFilter fromJson(String source) => fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'statusString': statusString,
      'executer': executer?.toJson(),
      'type': type,
      'project': project?.toJson(),
      'forMe': forMe,
      'forMyProjects': forMyProjects,
    };
  }

  static ProjectFilter fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ProjectFilter(
      statusString: map['statusString'],
      executer: LinkItem.fromJSON(map['executer']),
      project: LinkItem.fromJSON(map['project']),
      type: map['type'],
      forMe: map['forMe'],
      forMyProjects: map['forMyProjects'],
    );
  }
}
