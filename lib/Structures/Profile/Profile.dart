import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/MainPage.dart';
import 'package:mobile_kaskad/Pages/auth.dart';
import 'package:mobile_kaskad/Store/Actions.dart';

class Profile {
  static void logIn(context, user) async {
    await StoreProvider.dispatchFuture(context, LogIn(user));
  }

  static void logOut(context) async {
    Data.analytics.logEvent(name: 'logout');
    await StoreProvider.dispatchFuture(context, LogOut());
    Navigator.of(context).pop();
  }
}
