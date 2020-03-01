
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Database.dart';
import 'package:mobile_kaskad/Models/kontragent.dart';
import 'package:mobile_kaskad/Models/message.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Structures/Feature.dart';

class AppState {

  User user;

  List<Message> messages;
  List<Message> messagesP;

  NewMessageCount messageCount;

  List<Feature> features;
  List<Kontragent> kontragents;

  static Future<AppState> initState() async{
    var user = await DBProvider.db.getUser();
    var msg = user == null ? List<Message>() : await Connection.getMessageList(false);
    var msgP = user == null ? List<Message>() : await Connection.getMessageList(true);
    var msgC = user == null ? NewMessageCount() : await Connection.getMessageCount();
    var ftrs = user == null ? List<Feature>() : await DBProvider.db.getFeatures();
    var kontr = user == null ? List<Kontragent>() : await DBProvider.db.getKontragents();
    return AppState(messages: msg, messagesP: msgP, user: user, features: ftrs, messageCount: msgC, kontragents: kontr);
  }
  AppState({this.user, this.messages, this.messagesP, this.messageCount, this.features, this.kontragents});
    
  AppState.copy(AppState other) {
    messages        = List<Message>.from(other.messages);
    messagesP       = List<Message>.from(other.messagesP);
    features        = List<Feature>.from(other.features);
    kontragents     = List<Kontragent>.from(other.kontragents);
    messageCount    = other.messageCount;
    user            = other.user;
  }

}

