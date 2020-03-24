
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Pages/Auth/AuthPassPage.dart';
import 'package:mobile_kaskad/Pages/internetError.dart';

class AuthNamePage extends StatefulWidget {
  AuthNamePage({Key key}) : super(key: key);

  @override
  _AuthNamePageState createState() => _AuthNamePageState();
}

class _AuthNamePageState extends State<AuthNamePage> {
  TextEditingController _usernameController = TextEditingController();
  List<User> _sudgestion = List<User>();
  FocusNode _usernameFocusNode;
  Timer _timer;
  Future<List<User>> _futureList;

  @override
  void initState() {
    _futureList = Connection.getAuthList();
    super.initState();
    _usernameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    super.dispose();
  }

  List<Widget> _getColumnChildren(snapshot, context) {
    var result = List<Widget>();
    result.add(usernameInput(snapshot, context));
    if (_sudgestion.length > 0) {
      result.add(Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          "ВЫБЕРИТЕ ПОЛЬЗОВАТЕЛЯ",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 10, color: ColorMain, fontWeight: FontWeight.w600),
        ),
      ));
      for (User usr in _sudgestion) {
        result.add(ListTile(
          onTap: () {
            setState(() {
              _usernameController.text = usr.username;
              _sudgestion.clear();
              _sudgestion.add(usr);
            });
            _openPass(context, usr);
          },
          title: Text(usr.username, textAlign: TextAlign.center,),
        ));
      }
    }
    return result;
  }

  void _openPass(context, user) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthPassPage(
                user: user,
              )),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorGray,
      body: FutureBuilder(
        future: _futureList,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data.isEmpty) {
            return InternetError();
          }
          if (_timer == null) {
            _timer = Timer(Duration(milliseconds: 500), () {
              FocusScope.of(context).requestFocus(_usernameFocusNode);
            });
          }
          return SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: _getColumnChildren(snapshot, context),
            ),
          ));
        },
      ),
    );
  }

  CupertinoTextField usernameInput(
      AsyncSnapshot<List<User>> snapshot, BuildContext context) {
    return CupertinoTextField(
      focusNode: _usernameFocusNode,
      onChanged: (text) {
        setState(() {
          if (_usernameController.text.isNotEmpty) {
            _sudgestion = snapshot.data
                .where((t) => t.username
                    .toLowerCase()
                    .startsWith(_usernameController.text.toLowerCase()))
                .toList();
          } else {
            _sudgestion = [];
          }
        });
      },
      expands: false,
      textAlign: TextAlign.center,
      placeholder: 'Имя пользователя',
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.white,
          darkColor: CupertinoColors.white,
        ),
        border: Border(
          top: kDefaultRoundedBorderSideSuccess,
          bottom: kDefaultRoundedBorderSideSuccess,
          left: kDefaultRoundedBorderSideSuccess,
          right: kDefaultRoundedBorderSideSuccess,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      controller: _usernameController,
    );
  }
}
