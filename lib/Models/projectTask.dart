import 'dart:convert';

import 'package:mobile_kaskad/Data/Consts.dart';

import 'linkItem.dart';

class ProjectTask {
  String guid;
  int number;
  String status;
  String text;
  String siteText;
  String name;
  String type;
  String user;

  DateTime date;
  DateTime releaseBefore;
  DateTime releaseDate;

  LinkItem author;
  LinkItem executer;
  LinkItem tester;
  LinkItem metodist;
  LinkItem project;
  LinkItem manager;
  LinkItem techLead;

  bool doubleRepo;
  bool isToSite;
  bool isCirculation;
  bool loaded;

  bool get expired => releaseBefore.isBefore(DateTime.now());
  bool get onProgress => status == "На исполнении";
  bool get onTest => status == "На тестировании";
  bool get onInfo => status == "На уточнении задания";
  bool get onCheck => status == "На проверке";
  bool get isNew => status == "Новое";

  bool get userIsAuthor => author.guid == Data.curUser.guid;
  bool get userIsExecuter => executer.guid == Data.curUser.guid;
  bool get userIsTester => tester.guid == Data.curUser.guid;
  bool get userIsMetodist => metodist.guid == Data.curUser.guid;
  bool get userIsManager => manager.guid == Data.curUser.guid;
  bool get userIsTechLead => techLead.guid == Data.curUser.guid;

  ProjectTask({
    this.guid,
    this.number,
    this.status,
    this.text,
    this.siteText,
    this.name,
    this.date,
    this.releaseBefore,
    this.releaseDate,
    this.author,
    this.executer,
    this.tester,
    this.metodist,
    this.project,
    this.manager,
    this.techLead,
    this.doubleRepo,
    this.isToSite,
    this.isCirculation,
    this.type,
    this.user,
    this.loaded = false,
  });

  bool operator ==(other) => other.guid == guid;

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'number': number,
      'status': status,
      'text': text,
      'siteText': siteText,
      'name': name,
      'date': date?.toString(),
      'releaseDate': releaseDate?.toString(),
      'releaseBefore': releaseBefore?.toString(),
      'author': author?.toJson(),
      'executer': executer?.toJson(),
      'tester': tester?.toJson(),
      'metodist': metodist?.toJson(),
      'project': project?.toJson(),
      'manager': manager?.toJson(),
      'techLead': techLead?.toJson(),
      'user': user,
      'doubleRepo': doubleRepo,
      'isToSite': isToSite,
      'type': type,
      'isCirculation': isCirculation,
    };
  }

  factory ProjectTask.fromJSON(Map<String, dynamic> map) {
    if (map == null) return null;

    return ProjectTask(
      guid: map['guid'],
      number: map['number'],
      status: map['status'],
      text: map['text'],
      siteText: map['siteText'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      releaseDate: map['releaseDate'] == null
          ? DateTime.now()
          : DateTime.parse(map['releaseDate']),
      releaseBefore: DateTime.parse(map['releaseBefore']),
      author: LinkItem.fromJSON(map['author']),
      executer: LinkItem.fromJSON(map['executer']),
      tester: LinkItem.fromJSON(map['tester']),
      metodist: LinkItem.fromJSON(map['metodist']),
      project: LinkItem.fromJSON(map['project']),
      manager: LinkItem.fromJSON(map['manager']),
      techLead: LinkItem.fromJSON(map['techLead']),
      user: map['user'],
      doubleRepo: map['doubleRepo'],
      type: map['type'],
      isToSite: map['isToSite'],
      isCirculation: map['isCirculation'],
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class ProjectTaskGroup {
  String project;
  int count;
  List<StatusTaskGroup> data;

  ProjectTaskGroup({
    this.project,
    this.count,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'project': project,
      'count': count,
      'data': data?.map((e) => e?.toJson())?.toList(),
    };
  }

  factory ProjectTaskGroup.fromJSON(Map<String, dynamic> map) {
    if (map == null) return null;

    return ProjectTaskGroup(
      project: map['project'],
      count: map['count'],
      data: List<StatusTaskGroup>.from(
          map['data']?.map((x) => StatusTaskGroup.fromJSON(x))),
    );
  }
}

class StatusTaskGroup {
  String status;
  int count;
  List<ProjectTask> data;

  StatusTaskGroup({
    this.status,
    this.count,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'data': data?.map((e) => e?.toJson())?.toList(),
    };
  }

  factory StatusTaskGroup.fromJSON(Map<String, dynamic> map) {
    if (map == null) return null;

    return StatusTaskGroup(
      status: map['status'],
      count: map['count'],
      data: List<ProjectTask>.from(
          map['data']?.map((x) => ProjectTask.fromJSON(x))),
    );
  }
}
