import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/settings.dart';
import 'package:mobile_kaskad/Models/task.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';
import 'package:mobile_kaskad/Structures/Preferences/Preferences.dart';

class AppState {
  User user;

  List<Message> messages;
  List<Message> messagesP;

  NewMessageCount messageCount;

  List<Feature> features;
  List<Kontragent> kontragents;
  List<Task> tasks;

  Settings settings;

  static Future<AppState> initState() async {
    var user = await DBProvider.db.getUser();
    Settings prefs = await Preferences.getSettings();
    var ftrs =
        user == null ? List<Feature>() : await DBProvider.db.getFeatures();
    var kontr = user == null
        ? List<Kontragent>()
        : await DBProvider.db.getKontragents();
    Data.curUser = user;
    return AppState(
        messages: List<Message>(),
        messagesP: List<Message>(),
        user: user,
        features: ftrs,
        messageCount: NewMessageCount(),
        kontragents: kontr,
        settings: prefs,
        tasks: List<Task>());
  }

  AppState(
      {this.user,
      this.messages,
      this.messagesP,
      this.messageCount,
      this.features,
      this.kontragents,
      this.settings,
      this.tasks});

  AppState.copy(AppState other) {
    messages = List<Message>.from(other.messages);
    messagesP = List<Message>.from(other.messagesP);
    features = List<Feature>.from(other.features);
    kontragents = List<Kontragent>.from(other.kontragents);
    tasks = List<Task>.from(other.tasks);
    messageCount = other.messageCount;
    user = other.user;
    settings = other.settings;
  }
}
