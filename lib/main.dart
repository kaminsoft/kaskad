import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';

import 'package:mobile_kaskad/MainPage.dart';

import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Store/Actions.dart';
import 'package:mobile_kaskad/Store/AppState.dart';

import 'package:package_info/package_info.dart';

import 'Data/Consts.dart';
import 'Pages/auth.dart';

Future<void> _warmupAnimations() async {
  for (var item in Data.cachedAssets) {
    await cachedActor(item);
  }
}

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
        StoreProvider.dispatchFuture(
            previousRoute.navigator.context, UpdateTaskCount());
      });
    }
    super.didPop(route, previousRoute);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    Data.version = packageInfo.version;
  });
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final store = Store<AppState>(initialState: await AppState.initState());
  FlareCache.doesPrune = false;
  await _warmupAnimations();
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
      child: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            var mode = ThemeMode.system;
            if (state.settings.theme == "Темная") {
              mode = ThemeMode.dark;
            } else if (state.settings.theme == "Светлая") {
              mode = ThemeMode.light;
            }
            return MaterialApp(
              darkTheme: darkTheme(context),
              theme: lightTheme(context),
              themeMode: mode,
              title: 'КАСКАД',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                // ... app-specific localization delegate[s] here
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('ru', ''),
              ],
              home: StoreConnector<AppState, User>(
                  converter: (store) => store.state.user,
                  builder: (context, user) {
                    if (user == null) {
                      return AuthPage();
                    }
                    return MainPage();
                  }),
              navigatorObservers: [MyRouteObserver()],
            );
          }),
    );
  }

  ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: ColorMain),
      cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.light),
      accentColor: ColorMain,
      colorScheme: Theme.of(context).colorScheme.copyWith(
          brightness: Brightness.light,
          primary: ColorMain,
          onSecondary: Color(0xFFDADDEB),
          onSurface: ColorMain),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          color: ColorGray,
          textTheme: TextTheme(
              headline6: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.black)),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black)),
      scaffoldBackgroundColor: ColorGray,
    );
  }

  ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ColorMain, foregroundColor: Colors.white),
      cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(color: Colors.white),
          )),
      accentColor: ColorMainLight,
      colorScheme: Theme.of(context).colorScheme.copyWith(
          brightness: Brightness.dark,
          primary: ColorMainLight,
          onSecondary: ColorMiddle,
          onSurface: ColorMainLight),
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: ColorDark,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white)),
      textTheme: TextTheme(
          headline6: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.white)),
      scaffoldBackgroundColor: ColorDark,
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
