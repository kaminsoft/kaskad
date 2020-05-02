import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Store/Actions.dart';

class Profile {
  static void logIn(context, user) async {
    await StoreProvider.dispatchFuture(context, LogIn(user));
  }

  static void logOut(context, {bool close = true}) async {
    Data.analytics.logEvent(name: 'logout');
    Connection.logOut();
    if (close) {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
    await StoreProvider.dispatchFuture(context, LogOut());
  }
}
