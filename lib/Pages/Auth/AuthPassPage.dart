

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Structures/Profile/Profile.dart';
import 'package:http/http.dart' as http;

class AuthPassPage extends StatefulWidget {
  final User user;

  const AuthPassPage({Key key, this.user}) : super(key: key);

  @override
  _AuthPassPageState createState() => _AuthPassPageState();
}

class _AuthPassPageState extends State<AuthPassPage> {
  TextEditingController _passController = TextEditingController();
  bool _authwrong = false;
  bool _isLoading = false;

  auth(User user, String password) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('${user.username}:$password'));

    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
      '${Connection.url}/ping',
      headers: {HttpHeaders.authorizationHeader: basicAuth},
    );

    if (response.statusCode == 200) {
      user.password = base64Encode(utf8.encode('${user.username}:$password'));
      Profile.logIn(context, user);
      setState(() {
        _authwrong = false;
        _isLoading = false;
      });
      Navigator.popUntil(context, (ModalRoute.withName('/')),);
    } else {
      setState(() {
        _authwrong = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Здравствуйте,",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.body1,
                    ),
                    Text(
                      "${widget.user.firstname}!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.title,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Text(
                        "Для продолжения введите свой пароль",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                    CupertinoTextField(
                      style: Theme.of(context).textTheme.body2,
                      textAlign: TextAlign.center,
                      placeholder: 'Пароль',
                      autofocus: true,
                      obscureText: true,
                      decoration: _authwrong
                          ? BoxDecoration(
                              color: CupertinoDynamicColor.withBrightness(
                                color: CupertinoColors.white,
                                darkColor: ColorMiddle,
                              ),
                              border: Border(
                                top: kDefaultRoundedBorderSideError,
                                bottom: kDefaultRoundedBorderSideError,
                                left: kDefaultRoundedBorderSideError,
                                right: kDefaultRoundedBorderSideError,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            )
                          : BoxDecoration(
                              color: CupertinoDynamicColor.withBrightness(
                                color: CupertinoColors.white,
                                darkColor: ColorMiddle,
                              ),
                              border: Border(
                                top: kDefaultRoundedBorderSideSuccess,
                                bottom: kDefaultRoundedBorderSideSuccess,
                                left: kDefaultRoundedBorderSideSuccess,
                                right: kDefaultRoundedBorderSideSuccess,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            ),
                      controller: _passController,
                      onSubmitted: (text) {
                        auth(widget.user, _passController.text);
                      },
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context).textTheme.body2.color,
                          size: 12,
                        ),
                      ),
                      suffix: CupertinoButton(
                        child: Icon(
                          Icons.send,
                          size: 12,
                        ),
                        onPressed: () {
                          auth(widget.user, _passController.text);
                        },
                      ),
                    ),
                    Visibility(
                      visible: _authwrong,
                      child: Text(
                        "Неправильный пароль",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.body2.copyWith(color: Colors.red),
                      ),
                    ),
                  
                  ],
                ),
              ),
            ),
    );
  }
}
