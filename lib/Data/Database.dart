import 'dart:io';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Models/woker.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  void _update002(Database db) async {
    // added fields to worker
    await db.execute("ALTER TABLE Woker ADD COLUMN homePhone TEXT");
    await db.execute("ALTER TABLE Woker ADD COLUMN internalPhone TEXT");
    await db.execute("ALTER TABLE Woker ADD COLUMN email TEXT");
    await db.execute("ALTER TABLE Woker ADD COLUMN workEmail TEXT");
  }

  void _update003(Database db) async {
    // added fields to user
    await db.execute("ALTER TABLE User ADD COLUMN secondname TEXT");
    await db.execute("ALTER TABLE User ADD COLUMN position TEXT");
    await db.execute("ALTER TABLE User ADD COLUMN subdivision TEXT");
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "kaskad.db");
    return await openDatabase(
      path,
      version: getDBVersion(),
      onOpen: (db) async {},
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE User ("
            "id INTEGER PRIMARY KEY,"
            "username TEXT,"
            "firstname TEXT,"
            "lastname TEXT,"
            "password TEXT,"
            "avatar TEXT"
            ")");
        await db.execute("CREATE TABLE Feature ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "enabled INTEGER"
            ")");
        await db.execute("CREATE TABLE Kontragent ("
            "id INTEGER PRIMARY KEY,"
            "guid TEXT,"
            "code TEXT,"
            "name TEXT,"
            "fullName TEXT,"
            "inn TEXT,"
            "kpp TEXT,"
            "adressLegal TEXT,"
            "adressActual TEXT,"
            "email TEXT,"
            "orientir TEXT,"
            "phone TEXT,"
            "persons TEXT,"
            "secrets TEXT"
            ")");
        await db.execute("CREATE TABLE Woker ("
            "id INTEGER PRIMARY KEY,"
            "guid TEXT,"
            "name TEXT,"
            "shortName TEXT,"
            "sex INTEGER,"
            "position TEXT,"
            "subdivision TEXT,"
            "mobilePhone TEXT,"
            "birthday TEXT,"
            "workPhone TEXT"
            ")");
        if (version >= 2) {
          _update002(db);
        }
        if (version >= 3) {
          _update003(db);
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        Data.showNews = true;

        if (oldVersion < 2) {
          _update002(db);
        }
        if (oldVersion < 3) {
          _update003(db);
        }
      },
    );
  }

  Future<bool> hasUser() async {
    final db = await database;
    var res =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM User'));
    return res > 0;
  }

  Future<User> getUser() async {
    print('${DateTime.now()} getting user');
    final db = await database;
    var res = await db.query("User");
    return res.isNotEmpty ? User.fromJSON(res.first) : null;
  }

  deleteUser() async {
    final db = await database;
    db.delete("User");
    db.delete("Feature");
    db.delete("Kontragent");
  }

  Future<int> addUser(User newUser) async {
    final db = await database;
    var res = await db.insert("User", newUser.toJson());
    return res;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    var res = await db.update("User", user.toJson(),
        where: "username = ?", whereArgs: [user.username]);
    return res;
  }

  // features

  Future<List<Feature>> getFeatures() async {
    final db = await database;
    List<Feature> tmp = List<Feature>();
    var res = await db.query("Feature", orderBy: 'id');
    if (res.isEmpty) {
      return tmp;
    }

    var list = getInitialFeatureList();
    for (var item in res) {
      var ftr = list.where((t) => t.name == item['name']).first;
      ftr.enabled = item['enabled'] == 1;
      tmp.add(ftr);
    }
    if (list.length != tmp.length) {
      for (var item in list) {
        if (!tmp.contains(item)) {
          tmp.insert(0, item);
        }
      }
      saveFeatures(tmp);
    }
    return tmp;
  }

  saveFeatures(List<Feature> list) async {
    final db = await database;
    db.delete("Feature");
    for (var item in list) {
      await db.insert("Feature", item.toJson());
    }
  }

  // kontragents

  Future<List<Kontragent>> getKontragents() async {
    List<Kontragent> tmp = List<Kontragent>();
    final db = await database;
    var res = await db.query("Kontragent", orderBy: 'name');
    if (res.isEmpty) {
      return tmp;
    }
    for (var item in res) {
      Kontragent kntr = Kontragent.fromJSON(item);
      if (!tmp.contains(kntr)) {
        tmp.add(kntr);
      }
    }
    return tmp;
  }

  saveKontragents(List<Kontragent> list) async {
    final db = await database;
    db.delete("Kontragent");
    for (var item in list) {
      await db.insert("Kontragent", item.toJson());
    }
  }

  // workers

  Future<List<Woker>> getWorkers() async {
    List<Woker> tmp = List<Woker>();
    final db = await database;
    var res = await db.query("Woker", orderBy: 'name');
    if (res.isEmpty) {
      return tmp;
    }
    for (var item in res) {
      Woker kntr = Woker.fromJSON(item);
      if (!tmp.contains(kntr)) {
        tmp.add(kntr);
      }
    }
    return tmp;
  }

  Future<Woker> getWorker(String id) async {
    final db = await database;
    var res = await db.query("Woker", where: "guid = ?", whereArgs: [id]);
    if (res.isEmpty) {
      List<Woker> workers = await Connection.getWorkers();
      saveWorkers(workers);
      return workers.firstWhere((e) => e.guid == id);
    }
    return Woker.fromJSON(res.first);
  }

  saveWorkers(List<Woker> list) async {
    final db = await database;
    db.delete("Woker");
    for (var item in list) {
      await db.insert("Woker", item.toJson());
    }
  }
}
