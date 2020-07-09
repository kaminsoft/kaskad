import 'package:flutter/material.dart';
import 'package:mobile_kaskad/Data/Consts.dart';
import 'package:toast/toast.dart';

class UnderConstruction extends StatelessWidget {
  final String feature;
  const UnderConstruction({
    Key key,
    @required this.feature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset('assets/img/under_constructions.png'),
              ),
            ),
            Text(
              '$feature в разработке',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Проголосуйте за функционал, если он Вам необходим, это поможет понять, что реализовывать в первую очередь',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    textColor: Theme.of(context).textTheme.bodyText2.color,
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withAlpha(150)),
                    color: ColorMain,
                    highlightColor: ColorMain,
                    splashColor: ColorMain,
                    child: Text("Назад"),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        Data.analytics.logEvent(
                            name: 'feature_vote',
                            parameters: {'name': feature});
                        Navigator.of(context).pop();
                        Toast.show('Спасибо, Ваш голос учтен!', context,
                            backgroundColor: ColorMain,
                            gravity: Toast.TOP,
                            duration: 5);
                      },
                      color: ColorMain,
                      highlightColor: ColorMain,
                      splashColor: ColorMain,
                      child: Text(
                        "Хочу!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
