import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_kaskad/MainPage.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';

import 'Data/Consts.dart';
import 'Pages/auth.dart';

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route previousRoute) {
    if (Data.curUser != null && route.settings.name != null) {
      Data.analytics.logEvent(
          name: 'open_screen', parameters: {'name': route.settings.name});
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    if (previousRoute.settings.name == '/' && Data.curUser != null) {
      Timer(Duration(milliseconds: 500), () {
        StoreProvider.dispatchFuture(
            previousRoute.navigator.context, UpdateMessageCount());
      });
    }
    super.didPop(route, previousRoute);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = Store<AppState>(initialState: await AppState.initState());
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StoreProvider<AppState>(
      store: store,
      child: FeatureDiscovery(
        child: MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.white,
            //fontFamily: 'SF Pro Display',
            appBarTheme: AppBarTheme(
              color: ColorGray,
              elevation: 0,
            ),
            scaffoldBackgroundColor: ColorGray,
            textTheme: TextTheme(
                headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                title: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                body1: TextStyle(fontSize: 12),
                display1: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                display2: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.red)),
          ),
          title: 'КАСКАД',
          debugShowCheckedModeBanner: false,
          home: StoreConnector<AppState, User>(
              converter: (store) => store.state.user,
              builder: (context, user) {
                if (user == null) {
                  return AuthPage();
                }
                return MainPage();
              }),
          navigatorObservers: [MyRouteObserver()],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, User>(
        converter: (store) => store.state.user,
        builder: (context, user) {
          if (user == null) {
            return AuthPage();
          }
          return MainPage();
        });
  }
}
