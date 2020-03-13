import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_kaskad/Data/Connection.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Models/intro.dart';
import 'package:mobile_kaskad/Models/user.dart';
import 'package:mobile_kaskad/Pages/internetError.dart';
import 'package:mobile_kaskad/Structures/Profile/Profile.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int _current = 0;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorGray,
        body: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CarouselSlider.builder(
                    itemCount: introList.length,
                    aspectRatio: .75,
                    viewportFraction: 1.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      Intro _intro = introList[index];
                      return IntroCard(
                        title: _intro.title,
                        description: _intro.description,
                        image: _intro.image,
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: map<Widget>(
                    introList,
                    (index, url) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == index
                                ? ColorMain
                                : Colors.grey[400]),
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  width: double.infinity,
                  // height: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    color: ColorMain,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AuthNamePage()),
                      );
                    },
                    child: Text(
                      "ВОЙТИ",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 11),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class IntroCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const IntroCard({Key key, this.title, this.description, this.image})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 5, right: 20, left: 20),
      //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: SvgPicture.asset(
              image,
              placeholderBuilder: (context) =>
                  Center(child: CupertinoActivityIndicator()),
            ),
          ),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ))),
          Expanded(
              flex: 3,
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14,),
              )),
        ],
      ),
    );
  }
}

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
          title: Text(usr.username),
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
          darkColor: CupertinoColors.black,
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
      backgroundColor: ColorGray,
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
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ),
                    CupertinoTextField(
                      textAlign: TextAlign.center,
                      placeholder: 'Пароль',
                      autofocus: true,
                      obscureText: true,
                      decoration: _authwrong
                          ? BoxDecoration(
                              color: CupertinoDynamicColor.withBrightness(
                                color: CupertinoColors.white,
                                darkColor: CupertinoColors.black,
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
                                darkColor: CupertinoColors.black,
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
                          color: Colors.black12,
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
                        style: Theme.of(context).textTheme.display2,
                      ),
                    ),
                  
                  ],
                ),
              ),
            ),
    );
  }
}
