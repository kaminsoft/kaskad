import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:mobile_kaskad/Pages/Auth/AuthNamePage.dart';

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
        body: Center(
      child: Column(
        children: <Widget>[
          Expanded(
              child: PageView.builder(
                  itemCount: introList.length,
                  onPageChanged: (index) {
                    setState(() {
                      _current = index;
                    });
                  },
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return IntroCard(
                      title: introList[index].title,
                      description: introList[index].description,
                      image: introList[index].image,
                    );
                  })),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(
              introList,
              (index, url) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index ? ColorMain : Colors.grey[400]),
                );
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: ColorMain,
                  child: Text('ВОЙТИ'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AuthNamePage()),
                  ),
                ),
              ))
        ],
      ),
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
                style: TextStyle(
                  fontSize: 14,
                ),
              )),
        ],
      ),
    );
  }
}
